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

    // Version OPTIMISÉE de isiden2() - même logique mais par chunks de 64KB
    compareFiles(file1, file2) {
        try {
            const fd1 = fs.openSync(file1, 'r');
            const fd2 = fs.openSync(file2, 'r');
            const chunkSize = 65536; // 64KB chunks au lieu de 1 byte
            const buffer1 = Buffer.alloc(chunkSize);
            const buffer2 = Buffer.alloc(chunkSize);
            
            let bytesRead1, bytesRead2;
            
            do {
                bytesRead1 = fs.readSync(fd1, buffer1, 0, chunkSize, null);
                bytesRead2 = fs.readSync(fd2, buffer2, 0, chunkSize, null);
                
                // Comparer les chunks (équivalent mais plus rapide que car != car2)
                if (bytesRead1 !== bytesRead2 || !buffer1.subarray(0, bytesRead1).equals(buffer2.subarray(0, bytesRead2))) {
                    fs.closeSync(fd1);
                    fs.closeSync(fd2);
                    return false; // return 1 en C = fichiers différents
                }
            } while (bytesRead1 > 0 && bytesRead2 > 0);
            
            fs.closeSync(fd1);
            fs.closeSync(fd2);
            return true; // return 0 en C = fichiers identiques
        } catch (error) {
            return false; // Erreur = différents
        }
    }

    // PHASE 1: Équivalent de test.bat - Grouper par taille (comme tach.txt)
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

    // PHASE 2: Équivalent de sup_double.c - Comparaison exhaustive dans un groupe
    findDuplicatesInGroup(files) {
        const j = files.length; // équivalent de votre variable j en C
        const keep = new Array(j).fill(true); // tab2[] en C (true=1, false=0)
        
        // COPIE EXACTE de vos boucles C (lignes 181-194 de sup_double.c)
        for (let k = 0; k < j; k++) {
            if (keep[k]) { // if(tab2[k]) en C
                for (let h = k + 1; h < j; h++) {
                    if (keep[h]) { // if(tab2[h]) en C
                        // isiden2(tab[k],tab[h])==0 en C
                        if (this.compareFiles(files[k].path, files[h].path)) {
                            keep[h] = false; // tab2[h]=0 en C
                        }
                    }
                }
            }
        }
        
        // Construire le groupe de doublons
        const group = [];
        
        // Ajouter tous les fichiers (gardés et doublons) dans l'ordre
        for (let i = 0; i < j; i++) {
            if (keep[i]) {
                group.push(files[i]); // Fichier à garder en premier
            }
        }
        for (let i = 0; i < j; i++) {
            if (!keep[i]) {
                group.push(files[i]); // Doublons après
            }
        }
        
        if (group.length > 1) {
            return group;
        }
        
        return null; // Pas de doublons dans ce groupe
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

    // Algorithme principal - Reproduction EXACTE de votre système test.bat + sup_double.c
    async findDuplicates(directory) {
        // Réinitialiser pour éviter l'accumulation entre les appels
        this.reset();
        
        const spinner = ora('Phase 1: Grouping files by size (like test.bat)...').start();
        
        // PHASE 1: Équivalent test.bat - tri par taille
        const sizeGroups = await this.groupFilesBySize(directory);
        
        spinner.text = 'Phase 2: Comparing files within each size group (like sup_double.c)...';
        
        // PHASE 2: Pour chaque groupe de même taille, appliquer sup_double.c
        for (const [size, files] of sizeGroups) {
            if (files.length > 1) { // Seulement s'il y a collision (comme tach.txt)
                // Appliquer l'algorithme sup_double.c sur ce groupe
                const duplicateGroup = this.findDuplicatesInGroup(files);
                
                if (duplicateGroup) {
                    this.duplicateGroups.push(duplicateGroup);
                    this.duplicateSize += size * (duplicateGroup.length - 1);
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
    .description('Intelligent file deduplication tool with preview (reproduces test.bat + sup_double.c logic)')
    .version('1.0.1');

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