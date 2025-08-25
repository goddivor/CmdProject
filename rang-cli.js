#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { program } = require('commander');
const chalk = require('chalk');
const inquirer = require('inquirer');
const ora = require('ora');
const Table = require('cli-table3');

class RangEngine {
    constructor() {
        this.files = [];
        this.renamingPlan = [];
        this.backupPlan = [];
    }

    // Équivalent de isitmyfile() du code C original
    hasTargetExtension(filename, extensions) {
        const fileExt = path.extname(filename).toLowerCase().substring(1);
        return extensions.some(ext => ext.toLowerCase() === fileExt);
    }

    // Équivalent de isdir() du code C original
    isFile(filepath) {
        try {
            const stats = fs.statSync(filepath);
            return stats.isFile();
        } catch (error) {
            return false;
        }
    }

    // Scanner les fichiers dans un dossier (équivalent du parcours C)
    scanFiles(directory, extensions, sortBy = 'name') {
        this.files = [];
        
        try {
            const items = fs.readdirSync(directory);
            
            for (const item of items) {
                const fullPath = path.join(directory, item);
                
                if (this.isFile(fullPath) && this.hasTargetExtension(item, extensions)) {
                    const stats = fs.statSync(fullPath);
                    this.files.push({
                        original: item,
                        fullPath: fullPath,
                        extension: path.extname(item),
                        size: stats.size,
                        mtime: stats.mtime
                    });
                }
            }

            // Tri des fichiers
            this.sortFiles(sortBy);
            
        } catch (error) {
            throw new Error(`Cannot read directory: ${directory}`);
        }

        return this.files;
    }

    sortFiles(sortBy) {
        switch (sortBy) {
            case 'name':
                this.files.sort((a, b) => a.original.localeCompare(b.original));
                break;
            case 'date':
                this.files.sort((a, b) => a.mtime - b.mtime);
                break;
            case 'size':
                this.files.sort((a, b) => a.size - b.size);
                break;
        }
    }

    // Générer les nouveaux noms selon différents modes
    generateNewNames(mode, template = '', startIndex = 0) {
        this.renamingPlan = [];
        
        this.files.forEach((file, index) => {
            let newName;
            const counter = startIndex + index;
            
            switch (mode) {
                case 'simple':
                    // Mode original : 0.txt, 1.txt, 2.txt...
                    newName = `${counter}${file.extension}`;
                    break;
                    
                case 'padded':
                    // Mode avec zéros : 001.txt, 002.txt, 003.txt...
                    const paddedCounter = counter.toString().padStart(3, '0');
                    newName = `${paddedCounter}${file.extension}`;
                    break;
                    
                case 'prefixed':
                    // Mode avec préfixe : prefix_001.txt, prefix_002.txt...
                    const paddedIndex = counter.toString().padStart(3, '0');
                    newName = `${template}_${paddedIndex}${file.extension}`;
                    break;
                    
                case 'custom':
                    // Mode template personnalisé : {template}_{counter}.{ext}
                    newName = template
                        .replace('{counter}', counter)
                        .replace('{padded}', counter.toString().padStart(3, '0'))
                        .replace('{ext}', file.extension.substring(1));
                    break;
                    
                default:
                    newName = `${counter}${file.extension}`;
            }

            this.renamingPlan.push({
                oldName: file.original,
                newName: newName,
                oldPath: file.fullPath,
                newPath: path.join(path.dirname(file.fullPath), newName)
            });
        });
    }

    // Prévisualiser le plan de renommage
    showPreview() {
        if (this.renamingPlan.length === 0) {
            console.log(chalk.yellow('No files to rename.'));
            return;
        }

        console.log(chalk.cyan('\n📝 Renaming Preview:\n'));

        const table = new Table({
            head: ['Original Name', 'New Name', 'Size'],
            colWidths: [40, 40, 12]
        });

        this.renamingPlan.forEach(plan => {
            const file = this.files.find(f => f.original === plan.oldName);
            table.push([
                chalk.red(plan.oldName),
                chalk.green(plan.newName),
                this.formatSize(file.size)
            ]);
        });

        console.log(table.toString());
        console.log(chalk.blue(`\nTotal files to rename: ${this.renamingPlan.length}`));
    }

    // Exécuter le renommage
    async executeRenaming() {
        if (this.renamingPlan.length === 0) {
            console.log(chalk.yellow('No renaming plan available.'));
            return;
        }

        // Créer un plan de sauvegarde pour pouvoir annuler
        this.backupPlan = this.renamingPlan.map(plan => ({
            oldPath: plan.newPath,
            newPath: plan.oldPath
        }));

        const spinner = ora('Renaming files...').start();
        let renamedCount = 0;

        for (const plan of this.renamingPlan) {
            try {
                fs.renameSync(plan.oldPath, plan.newPath);
                renamedCount++;
            } catch (error) {
                console.log(chalk.red(`\nFailed to rename: ${plan.oldName} -> ${plan.newName}`));
                console.log(chalk.red(`Error: ${error.message}`));
            }
        }

        spinner.succeed(`Successfully renamed ${renamedCount} files`);
        
        if (renamedCount > 0) {
            console.log(chalk.blue('\n💡 Use "rang-cli undo" to reverse these changes'));
        }
    }

    // Annuler le dernier renommage
    async undoLastRenaming() {
        if (this.backupPlan.length === 0) {
            console.log(chalk.yellow('No previous renaming operation to undo.'));
            return;
        }

        const spinner = ora('Undoing last renaming...').start();
        let undoneCount = 0;

        for (const plan of this.backupPlan) {
            try {
                if (fs.existsSync(plan.oldPath)) {
                    fs.renameSync(plan.oldPath, plan.newPath);
                    undoneCount++;
                }
            } catch (error) {
                console.log(chalk.red(`\nFailed to undo: ${path.basename(plan.oldPath)}`));
            }
        }

        spinner.succeed(`Successfully undone ${undoneCount} file renames`);
        this.backupPlan = []; // Clear backup plan after use
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

// CLI Interface
program
    .name('rang-cli')
    .description('Advanced sequential file renaming tool - Successor to rang.bat')
    .version('1.0.0');

program
    .command('rename [directory]')
    .description('Rename files in directory with interactive mode')
    .option('-e, --extensions <exts...>', 'file extensions to process (e.g., txt pdf jpg)', ['txt'])
    .option('-m, --mode <mode>', 'renaming mode: simple, padded, prefixed, custom', 'simple')
    .option('-t, --template <template>', 'template for prefixed/custom mode')
    .option('-s, --start <number>', 'starting counter number', '0')
    .option('-o, --sort <type>', 'sort files by: name, date, size', 'name')
    .option('--dry-run', 'show preview only, do not rename')
    .action(async (directory = '.', options) => {
        const engine = new RangEngine();
        
        try {
            console.log(chalk.blue('🔧 Advanced File Renaming Tool'));
            console.log(chalk.gray('Inspired by the original rang.bat + codec.c\n'));

            // Validate template for modes that require it
            if ((options.mode === 'prefixed' || options.mode === 'custom') && !options.template) {
                const { template } = await inquirer.prompt([{
                    type: 'input',
                    name: 'template',
                    message: `Enter template for ${options.mode} mode:`,
                    default: options.mode === 'prefixed' ? 'file' : 'doc_{padded}.{ext}'
                }]);
                options.template = template;
            }

            // Scan files
            const spinner = ora('Scanning files...').start();
            const files = engine.scanFiles(directory, options.extensions, options.sort);
            spinner.succeed(`Found ${files.length} files matching criteria`);

            if (files.length === 0) {
                console.log(chalk.yellow('No files found matching the specified extensions.'));
                return;
            }

            // Generate renaming plan
            engine.generateNewNames(options.mode, options.template, parseInt(options.start));

            // Show preview
            engine.showPreview();

            if (options.dryRun) {
                console.log(chalk.blue('\n--dry-run mode: No files were actually renamed.'));
                return;
            }

            // Confirm action
            const { confirm } = await inquirer.prompt([{
                type: 'confirm',
                name: 'confirm',
                message: 'Proceed with renaming?',
                default: false
            }]);

            if (confirm) {
                await engine.executeRenaming();
            } else {
                console.log(chalk.yellow('Operation cancelled.'));
            }

        } catch (error) {
            console.error(chalk.red(`Error: ${error.message}`));
        }
    });

program
    .command('undo')
    .description('Undo the last renaming operation')
    .action(async () => {
        const engine = new RangEngine();
        try {
            await engine.undoLastRenaming();
        } catch (error) {
            console.error(chalk.red(`Error: ${error.message}`));
        }
    });

program
    .command('preview [directory]')
    .description('Preview files that would be renamed')
    .option('-e, --extensions <exts...>', 'file extensions to process', ['txt'])
    .option('-o, --sort <type>', 'sort files by: name, date, size', 'name')
    .action(async (directory = '.', options) => {
        const engine = new RangEngine();
        
        try {
            const files = engine.scanFiles(directory, options.extensions, options.sort);
            
            if (files.length === 0) {
                console.log(chalk.yellow('No files found matching the specified extensions.'));
                return;
            }

            console.log(chalk.cyan(`\n📁 Found ${files.length} files in ${directory}:\n`));

            const table = new Table({
                head: ['Filename', 'Size', 'Modified'],
                colWidths: [50, 12, 20]
            });

            files.forEach(file => {
                table.push([
                    file.original,
                    engine.formatSize(file.size),
                    file.mtime.toLocaleDateString()
                ]);
            });

            console.log(table.toString());

        } catch (error) {
            console.error(chalk.red(`Error: ${error.message}`));
        }
    });

program.parse();