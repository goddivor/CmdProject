#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { program } = require('commander');
const chalk = require('chalk');
const inquirer = require('inquirer');
const ora = require('ora');
const Table = require('cli-table3');

class DedupEngine {
    constructor() {
        this.reset();
    }

    reset() {
        this.duplicateGroups = [];
        this.totalFiles = 0;
        this.totalSize = 0;
        this.duplicateSize = 0;
    }

    // Équivalent de votre fonction isiden2() mais en JavaScript asynchrone
    async compareFiles(file1, file2) {
        return new Promise((resolve, reject) => {
            const stream1 = fs.createReadStream(file1);
            const stream2 = fs.createReadStream(file2);
            let identical = true;

            stream1.on('data', (chunk1) => {
                stream2.once('data', (chunk2) => {
                    if (!chunk1.equals(chunk2)) {
                        identical = false;
                        stream1.destroy();
                        stream2.destroy();
                        resolve(false); // Différents
                    }
                });
            });

            stream1.on('end', () => {
                stream2.on('end', () => {
                    resolve(identical); // Identiques
                });
            });

            stream1.on('error', reject);
            stream2.on('error', reject);
        });
    }

    // Grouper les fichiers par taille (équivalent du tri batch)
    async groupFilesBySize(directory) {
        const sizeGroups = new Map();
        const files = await this.getAllFiles(directory);

        for (const file of files) {
            try {
                const stats = fs.statSync(file);
                if (stats.isFile()) {
                    const size = stats.size;
                    if (!sizeGroups.has(size)) {
                        sizeGroups.set(size, []);
                    }
                    sizeGroups.get(size).push({
                        path: file,
                        size: size,
                        mtime: stats.mtime
                    });
                    this.totalFiles++;
                    this.totalSize += size;
                }
            } catch (err) {
                console.log(chalk.yellow(`⚠️  Cannot access: ${file}`));
            }
        }

        return sizeGroups;
    }

    // Récupérer tous les fichiers récursivement
    async getAllFiles(directory) {
        const files = [];
        
        const traverse = (dir) => {
            const items = fs.readdirSync(dir);
            
            for (const item of items) {
                const fullPath = path.join(dir, item);
                try {
                    const stat = fs.statSync(fullPath);
                    if (stat.isDirectory()) {
                        traverse(fullPath);
                    } else {
                        files.push(fullPath);
                    }
                } catch (err) {
                    // Ignorer les fichiers inaccessibles
                }
            }
        };

        traverse(directory);
        return files;
    }

    // Logique principale de détection des doublons (équivalent de votre boucle C)
    async findDuplicates(directory) {
        // Réinitialiser pour éviter l'accumulation entre les appels
        this.reset();
        
        const spinner = ora('Analyzing files by size...').start();
        const sizeGroups = await this.groupFilesBySize(directory);
        
        spinner.text = 'Comparing potential duplicates...';
        
        for (const [size, files] of sizeGroups) {
            if (files.length > 1) {
                // Même logique que votre algorithme C : comparaison 2 à 2
                const processed = new Array(files.length).fill(false);

                for (let i = 0; i < files.length; i++) {
                    if (processed[i]) continue;

                    const group = [files[i]];
                    processed[i] = true;

                    for (let j = i + 1; j < files.length; j++) {
                        if (processed[j]) continue;

                        try {
                            const identical = await this.compareFiles(files[i].path, files[j].path);
                            if (identical) {
                                group.push(files[j]);
                                processed[j] = true;
                            }
                        } catch (err) {
                            console.log(chalk.red(`Error comparing files: ${err.message}`));
                        }
                    }

                    if (group.length > 1) {
                        this.duplicateGroups.push(group);
                        this.duplicateSize += size * (group.length - 1); // Espace qui peut être libéré
                    }
                }
            }
        }

        spinner.succeed(`Found ${this.duplicateGroups.length} duplicate groups`);
    }

    // Afficher les statistiques
    showStats() {
        console.log(chalk.cyan('\n📊 Statistics:'));
        console.log(`Total files scanned: ${this.totalFiles}`);
        console.log(`Total size: ${this.formatSize(this.totalSize)}`);
        console.log(`Duplicate groups found: ${this.duplicateGroups.length}`);
        console.log(`Potential space to free: ${chalk.green(this.formatSize(this.duplicateSize))}`);
    }

    // Afficher le preview des doublons
    showPreview() {
        if (this.duplicateGroups.length === 0) {
            console.log(chalk.green('✨ No duplicates found!'));
            return;
        }

        console.log(chalk.cyan('\n🔍 Duplicate Files Preview:\n'));

        this.duplicateGroups.forEach((group, index) => {
            const table = new Table({
                head: ['File', 'Size', 'Modified'],
                colWidths: [60, 12, 20]
            });

            console.log(chalk.yellow(`Group ${index + 1} (${group.length} files):`));
            
            group.forEach((file, fileIndex) => {
                const color = fileIndex === 0 ? chalk.green : chalk.red;
                const marker = fileIndex === 0 ? '✓ Keep' : '✗ Delete';
                
                table.push([
                    color(`${marker} ${path.basename(file.path)}`),
                    this.formatSize(file.size),
                    file.mtime.toLocaleDateString()
                ]);
            });

            console.log(table.toString());
            console.log();
        });
    }

    formatSize(bytes) {
        const units = ['B', 'KB', 'MB', 'GB'];
        let size = bytes;
        let unit = 0;
        
        while (size >= 1024 && unit < units.length - 1) {
            size /= 1024;
            unit++;
        }
        
        return `${size.toFixed(1)} ${units[unit]}`;
    }
}

// Interface CLI
program
    .name('dedup')
    .description('Intelligent file deduplication tool with preview')
    .version('1.0.0');

program
    .command('scan [directory]')
    .description('Scan directory for duplicate files')
    .action(async (directory = '.') => {
        const engine = new DedupEngine();
        
        try {
            await engine.findDuplicates(directory);
            engine.showStats();
            engine.showPreview();
        } catch (error) {
            console.error(chalk.red(`Error: ${error.message}`));
        }
    });

program
    .command('clean [directory]')
    .description('Interactive cleanup of duplicate files')
    .action(async (directory = '.') => {
        const engine = new DedupEngine();
        
        try {
            await engine.findDuplicates(directory);
            
            if (engine.duplicateGroups.length === 0) {
                console.log(chalk.green('✨ No duplicates found!'));
                return;
            }

            // Afficher les stats et la preview AVANT de demander
            engine.showStats();
            engine.showPreview();
            
            // Première question : supprimer tout ou choisir individuellement
            const { action } = await inquirer.prompt([{
                type: 'list',
                name: 'action',
                message: 'What would you like to do?',
                choices: [
                    { name: `Delete all duplicates (free ${engine.formatSize(engine.duplicateSize)})`, value: 'all' },
                    { name: 'Choose which duplicates to delete individually', value: 'select' },
                    { name: 'Cancel', value: 'cancel' }
                ]
            }]);

            if (action === 'cancel') {
                console.log(chalk.yellow('Operation cancelled.'));
                return;
            }

            let filesToDelete = [];

            if (action === 'all') {
                // Supprimer tous les doublons (garder le premier de chaque groupe)
                for (const group of engine.duplicateGroups) {
                    for (let i = 1; i < group.length; i++) {
                        filesToDelete.push(group[i]);
                    }
                }
            } else if (action === 'select') {
                // Sélection individuelle
                for (let groupIndex = 0; groupIndex < engine.duplicateGroups.length; groupIndex++) {
                    const group = engine.duplicateGroups[groupIndex];
                    
                    console.log(chalk.cyan(`\n📁 Group ${groupIndex + 1}:`));
                    
                    const choices = group.map((file, fileIndex) => ({
                        name: `${fileIndex === 0 ? '✓ (Keep)' : '✗ (Delete)'} ${path.basename(file.path)} - ${engine.formatSize(file.size)} - ${file.mtime.toLocaleDateString()}`,
                        value: file,
                        checked: fileIndex > 0 // Par défaut, cocher tous sauf le premier
                    }));

                    const { selectedFiles } = await inquirer.prompt([{
                        type: 'checkbox',
                        name: 'selectedFiles',
                        message: 'Select files to DELETE (use spacebar to toggle):',
                        choices: choices,
                        validate: (answer) => {
                            if (answer.length === group.length) {
                                return 'You cannot delete all files in a group. At least one must remain.';
                            }
                            return true;
                        }
                    }]);

                    filesToDelete.push(...selectedFiles);
                }
            }

            if (filesToDelete.length === 0) {
                console.log(chalk.yellow('No files selected for deletion.'));
                return;
            }

            // Confirmation finale
            const totalSizeToFree = filesToDelete.reduce((sum, file) => sum + file.size, 0);
            const { finalConfirm } = await inquirer.prompt([{
                type: 'confirm',
                name: 'finalConfirm',
                message: `Delete ${filesToDelete.length} files and free ${engine.formatSize(totalSizeToFree)}?`,
                default: false
            }]);

            if (finalConfirm) {
                const spinner = ora('Deleting selected files...').start();
                let deletedCount = 0;
                let deletedSize = 0;

                for (const file of filesToDelete) {
                    try {
                        fs.unlinkSync(file.path);
                        deletedCount++;
                        deletedSize += file.size;
                    } catch (err) {
                        console.log(chalk.red(`Failed to delete: ${file.path}`));
                    }
                }

                spinner.succeed(`Deleted ${deletedCount} files`);
                console.log(chalk.green(`✨ Freed up ${engine.formatSize(deletedSize)} of space!`));
            } else {
                console.log(chalk.yellow('Deletion cancelled.'));
            }
        } catch (error) {
            console.error(chalk.red(`Error: ${error.message}`));
        }
    });

program.parse();