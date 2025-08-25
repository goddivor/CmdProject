#!/usr/bin/env node

const { exec, spawn } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);
const { program } = require('commander');
const chalk = require('chalk');
const inquirer = require('inquirer');
const ora = require('ora');
const Table = require('cli-table3');
const fs = require('fs');
const path = require('path');

class WiFiManager {
    constructor() {
        this.profiles = [];
        this.availableNetworks = [];
    }

    // Nettoyer les problèmes d'encodage Windows
    cleanEncoding(text) {
        return text
            // D'abord corriger les patterns spécifiques
            .replace(/WPA2[��ÿ]-[��ÿ]Personnel/g, 'WPA2-Personnel')
            .replace(/WPA2[��ÿ]-[��ÿ]Entreprise/g, 'WPA2-Entreprise')
            .replace(/WPA3[��ÿ]-[��ÿ]Personnel/g, 'WPA3-Personnel')
            .replace(/WPA3[��ÿ]-[��ÿ]Entreprise/g, 'WPA3-Entreprise')
            .replace(/WPA[��ÿ]-[��ÿ]Personnel/g, 'WPA-Personnel')
            // Ensuite corriger les tirets isolés
            .replace(/[��ÿ]-[��ÿ]/g, '-')
            // Enfin corriger les caractères restants (mais pas dans les mots corrigés)
            .replace(/[��ÿ](?!Personnel|Entreprise)/g, 'é')
            .replace(/\ufffd/g, 'é'); // Caractère de remplacement Unicode
    }

    // Vérifier les privilèges administrateur
    async checkAdminPrivileges() {
        try {
            await execAsync('net session');
            return true;
        } catch (error) {
            return false;
        }
    }

    // Parser la sortie de netsh wlan show profiles (version française)
    parseProfiles(output) {
        const profiles = [];
        const lines = output.split('\n');
        
        for (const line of lines) {
            // Chercher les lignes contenant "Profil Tous les utilisateurs"
            const match = line.match(/Profil Tous les utilisateurs\s*[^\:]*\s*[^\:]*\s*:\s*(.+)/);
            if (match) {
                const name = match[1].trim();
                if (name && name !== '' && name !== '<Aucun>') {
                    profiles.push({
                        name: name,
                        type: 'Saved'
                    });
                }
            }
        }
        return profiles;
    }

    // Parser la sortie de netsh wlan show profile avec détails (version française)
    async parseProfileDetails(profileName) {
        try {
            const { stdout } = await execAsync(`netsh wlan show profile name="${profileName}" key=clear`, { encoding: 'buffer' });
            // Convertir et nettoyer l'encodage
            const cleanedOutput = this.cleanEncoding(stdout.toString('latin1'));
            const lines = cleanedOutput.split('\n');
            
            const profile = {
                name: profileName,
                ssid: '',
                authentication: '',
                encryption: '',
                key: 'Not available',
                autoConnect: false
            };

            for (const line of lines) {
                // Nom du SSID : "Home"
                if (line.includes('Nom du SSID') || line.includes('SSID')) {
                    const match = line.match(/(?:Nom du )?SSID[^\:]*\s*:\s*["\"]?([^"]+)["\"]?/);
                    if (match) profile.ssid = match[1].trim().replace(/"/g, '');
                }
                // Authentification : WPA2-Personnel
                if (line.includes('Authentification')) {
                    const match = line.match(/Authentification[^\:]*\s*:\s*(.+)/);
                    if (match) profile.authentication = match[1].trim();
                }
                // Chiffrement : CCMP
                if (line.includes('Chiffrement')) {
                    const match = line.match(/Chiffrement[^\:]*\s*:\s*(.+)/);
                    if (match) profile.encryption = match[1].trim();
                }
                // Contenu de la clé : KING1999PAUl@ (gère les caractères spéciaux)
                if (line.includes('Contenu de la cl')) {
                    // Plus flexible pour gérer l'encodage des caractères
                    const match = line.match(/Contenu de la cl[^\:]*\s*:\s*(.+)/);
                    if (match) {
                        const keyValue = match[1].trim();
                        if (keyValue && keyValue !== '' && keyValue !== 'Absent') {
                            profile.key = keyValue;
                        }
                    }
                }
                
                // Clé de sécurité : Présent (pour détecter s'il y a une clé)
                if (line.includes('Cl') && line.includes('de s') && line.includes('curit')) {
                    if (line.includes('Pr') && line.includes('sent')) {
                        // Il y a une clé mais on ne l'a pas encore trouvée
                        if (profile.key === 'Not available') {
                            profile.key = 'Password available';
                        }
                    }
                }
                // Mode de connexion : connexion automatique
                if (line.includes('Mode de connexion') || line.includes('connexion automatique')) {
                    profile.autoConnect = line.includes('connexion automatique') || line.includes('automatique');
                }
            }

            return profile;
        } catch (error) {
            return null;
        }
    }

    // Scanner les réseaux disponibles
    async scanAvailableNetworks() {
        const spinner = ora('Scanning for available networks...').start();
        
        try {
            const { stdout } = await execAsync('netsh wlan show profiles', { encoding: 'buffer' });
            const cleanedOutput = this.cleanEncoding(stdout.toString('latin1'));
            this.profiles = this.parseProfiles(cleanedOutput);
            
            // Scan des réseaux disponibles
            const { stdout: scanOutput } = await execAsync('netsh wlan show profiles');
            
            spinner.succeed(`Found ${this.profiles.length} saved networks`);
            return this.profiles;
        } catch (error) {
            spinner.fail('Failed to scan networks');
            throw error;
        }
    }

    // Lister les profils sauvegardés (avec mots de passe par défaut)
    async listSavedProfiles(showPasswords = true) {
        try {
            await this.scanAvailableNetworks();
            
            if (this.profiles.length === 0) {
                console.log(chalk.yellow('No saved WiFi profiles found.'));
                return;
            }

            console.log(chalk.cyan('\n📡 Saved WiFi Profiles:\n'));

            const table = new Table({
                head: ['Profile Name', 'Authentication', 'Encryption', 'Auto Connect', 'Password'],
                colWidths: [30, 15, 15, 12, 20]
            });

            const spinner = ora('Loading profile details...').start();

            for (const profile of this.profiles) {
                const details = await this.parseProfileDetails(profile.name);
                if (details) {
                    const statusColor = details.autoConnect ? chalk.green : chalk.gray;
                    const password = (details.key !== 'Not available' && details.key !== 'Available (use --show-password)') ? 
                        details.key : chalk.red('N/A');
                    
                    table.push([
                        chalk.white(details.name),
                        chalk.blue(details.authentication || 'Unknown'),
                        chalk.blue(details.encryption || 'Unknown'),
                        statusColor(details.autoConnect ? 'Yes' : 'No'),
                        password
                    ]);
                }
            }

            spinner.stop();
            console.log(table.toString());

        } catch (error) {
            console.error(chalk.red(`Error: ${error.message}`));
        }
    }

    // Afficher les détails d'un profil spécifique (avec mot de passe)
    async showProfileDetails(profileName) {
        const spinner = ora(`Loading details for "${profileName}"...`).start();
        
        try {
            const details = await this.parseProfileDetails(profileName);
            
            if (!details) {
                spinner.fail(`Profile "${profileName}" not found`);
                return;
            }

            spinner.succeed(`Profile details loaded`);

            console.log(chalk.cyan('\n📋 Profile Details:\n'));
            
            console.log(chalk.white('Profile Name: ') + chalk.green(details.name));
            console.log(chalk.white('SSID: ') + chalk.blue(details.ssid || details.name));
            console.log(chalk.white('Authentication: ') + chalk.yellow(details.authentication || 'Unknown'));
            console.log(chalk.white('Encryption: ') + chalk.yellow(details.encryption || 'Unknown'));
            console.log(chalk.white('Auto Connect: ') + (details.autoConnect ? chalk.green('Yes') : chalk.red('No')));
            
            // Affichage direct du mot de passe
            if (details.key !== 'Not available' && details.key !== 'Available (use --show-password)') {
                console.log(chalk.white('Password: ') + chalk.red(details.key));
            } else {
                console.log(chalk.white('Password: ') + chalk.gray('Not stored or not available'));
            }

        } catch (error) {
            spinner.fail(`Error loading profile: ${error.message}`);
        }
    }


    // Supprimer un profil
    async deleteProfile(profileName) {
        const { confirm } = await inquirer.prompt([{
            type: 'confirm',
            name: 'confirm',
            message: `Delete WiFi profile "${profileName}"? This action cannot be undone.`,
            default: false
        }]);

        if (!confirm) {
            console.log(chalk.yellow('Operation cancelled.'));
            return;
        }

        const spinner = ora(`Deleting profile "${profileName}"...`).start();
        
        try {
            await execAsync(`netsh wlan delete profile name="${profileName}" i=*`);
            spinner.succeed(`Profile "${profileName}" deleted successfully`);
        } catch (error) {
            spinner.fail(`Failed to delete profile: ${error.message}`);
        }
    }

    // Rechercher des profils
    async searchProfiles(pattern) {
        await this.scanAvailableNetworks();
        
        const matchingProfiles = this.profiles.filter(profile => 
            profile.name.toLowerCase().includes(pattern.toLowerCase())
        );

        if (matchingProfiles.length === 0) {
            console.log(chalk.yellow(`No profiles found matching "${pattern}"`));
            return;
        }

        console.log(chalk.cyan(`\n🔍 Found ${matchingProfiles.length} profiles matching "${pattern}":\n`));

        const table = new Table({
            head: ['Profile Name', 'Type'],
            colWidths: [40, 10]
        });

        matchingProfiles.forEach(profile => {
            table.push([
                chalk.white(profile.name),
                chalk.green(profile.type)
            ]);
        });

        console.log(table.toString());
    }

    // Exporter les profils
    async exportProfiles(outputPath) {
        const spinner = ora('Exporting WiFi profiles...').start();
        
        try {
            await this.scanAvailableNetworks();
            
            const exportData = {
                exportDate: new Date().toISOString(),
                profiles: []
            };

            for (const profile of this.profiles) {
                const details = await this.parseProfileDetails(profile.name);
                if (details) {
                    exportData.profiles.push({
                        name: details.name,
                        ssid: details.ssid,
                        authentication: details.authentication,
                        encryption: details.encryption,
                        autoConnect: details.autoConnect,
                        // Note: Passwords are not exported for security
                        hasPassword: details.key !== 'Not available'
                    });
                }
            }

            const filePath = outputPath || `wifi-profiles-${new Date().toISOString().slice(0, 10)}.json`;
            fs.writeFileSync(filePath, JSON.stringify(exportData, null, 2));
            
            spinner.succeed(`Exported ${exportData.profiles.length} profiles to ${filePath}`);
            console.log(chalk.gray('⚠️  Passwords are not included for security reasons'));

        } catch (error) {
            spinner.fail(`Export failed: ${error.message}`);
        }
    }
}

// CLI Interface
program
    .name('wifi-cli')
    .description('Modern WiFi management tool - successor to wifimap.bat')
    .version('1.0.0');

program
    .command('list')
    .alias('l')
    .description('List saved WiFi profiles with passwords')
    .action(async () => {
        const manager = new WiFiManager();
        await manager.listSavedProfiles();
    });

program
    .command('show <profile>')
    .alias('s')
    .description('Show detailed information for a specific profile')
    .action(async (profile) => {
        const manager = new WiFiManager();
        await manager.showProfileDetails(profile);
    });

program
    .command('delete <profile>')
    .alias('d')
    .description('Delete a WiFi profile')
    .action(async (profile) => {
        const manager = new WiFiManager();
        await manager.deleteProfile(profile);
    });

program
    .command('search <pattern>')
    .alias('f')
    .description('Search for profiles matching a pattern')
    .action(async (pattern) => {
        const manager = new WiFiManager();
        await manager.searchProfiles(pattern);
    });

program
    .command('export [file]')
    .alias('e')
    .description('Export WiFi profiles to JSON file')
    .action(async (file) => {
        const manager = new WiFiManager();
        await manager.exportProfiles(file);
    });

// Commandes héritées de wifimap.bat pour compatibilité
program
    .command('legacy-list [pattern]')
    .description('Legacy command (equivalent to wifimap /l)')
    .action(async (pattern) => {
        const manager = new WiFiManager();
        if (pattern) {
            await manager.searchProfiles(pattern);
        } else {
            await manager.listSavedProfiles();
        }
    });

program
    .command('legacy-key <ssid>')
    .description('Legacy command (equivalent to wifimap /k)')
    .action(async (ssid) => {
        const manager = new WiFiManager();
        await manager.showProfileDetails(ssid);
    });

program
    .command('legacy-delete <ssid>')
    .description('Legacy command (equivalent to wifimap /d)')
    .action(async (ssid) => {
        const manager = new WiFiManager();
        await manager.deleteProfile(ssid);
    });

program.parse();