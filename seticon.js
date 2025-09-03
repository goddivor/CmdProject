#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class FolderIconCLI {
    constructor() {
        this.tempDir = path.join(__dirname, 'temp');
        this.ensureTempDir();
    }

    ensureTempDir() {
        if (!fs.existsSync(this.tempDir)) {
            fs.mkdirSync(this.tempDir, { recursive: true });
        }
    }

    async convertPngToIco(pngPath, icoPath, sizes = [16, 32, 48, 64, 128, 256]) {
        try {
            const sharp = require('sharp');
            const toIco = require('to-ico');

            const pngBuffers = [];
            
            for (const size of sizes) {
                const buffer = await sharp(pngPath)
                    .resize(size, size, {
                        fit: 'contain',
                        background: { r: 0, g: 0, b: 0, alpha: 0 }
                    })
                    .png()
                    .toBuffer();
                pngBuffers.push(buffer);
            }

            const icoBuffer = await toIco(pngBuffers);
            fs.writeFileSync(icoPath, icoBuffer);
            return icoPath;
        } catch (error) {
            throw new Error(`Failed to convert PNG to ICO: ${error.message}`);
        }
    }

    setFolderIcon(folderPath, iconPath) {
        try {
            const absoluteFolderPath = path.resolve(folderPath);
            const absoluteIconPath = path.resolve(iconPath);

            if (!fs.existsSync(absoluteFolderPath)) {
                throw new Error(`Folder does not exist: ${absoluteFolderPath}`);
            }

            if (!fs.existsSync(absoluteIconPath)) {
                throw new Error(`Icon file does not exist: ${absoluteIconPath}`);
            }

            const desktopIni = path.join(absoluteFolderPath, 'desktop.ini');
            const iconFileName = path.basename(absoluteIconPath);
            const iconInFolder = path.join(absoluteFolderPath, iconFileName);

            fs.copyFileSync(absoluteIconPath, iconInFolder);

            execSync(`attrib +H +S "${iconInFolder}"`, { stdio: 'ignore' });

            const iniContent = `[.ShellClassInfo]
IconResource=${iconFileName},0
[ViewState]
Mode=
Vid=
FolderType=Generic
`;

            fs.writeFileSync(desktopIni, iniContent);

            execSync(`attrib +H +S "${desktopIni}"`, { stdio: 'ignore' });
            execSync(`attrib +R "${absoluteFolderPath}"`, { stdio: 'ignore' });

            console.log(`✓ Folder icon changed successfully: ${absoluteFolderPath}`);
            return true;
        } catch (error) {
            throw new Error(`Failed to set folder icon: ${error.message}`);
        }
    }

    async processIconChange(folderPath, iconOrPngPath, dimensions = [16, 32, 48, 64, 128, 256]) {
        try {
            const ext = path.extname(iconOrPngPath).toLowerCase();
            let iconPath = iconOrPngPath;

            if (ext === '.png') {
                console.log('📸 PNG detected, converting to ICO...');
                const tempIcoName = `converted_${Date.now()}.ico`;
                const tempIcoPath = path.join(this.tempDir, tempIcoName);
                
                iconPath = await this.convertPngToIco(iconOrPngPath, tempIcoPath, dimensions);
                console.log(`✓ PNG converted to ICO: ${iconPath}`);
            } else if (ext !== '.ico') {
                throw new Error('Icon file must be .ico or .png format');
            }

            this.setFolderIcon(folderPath, iconPath);
            return true;
        } catch (error) {
            console.error(`❌ Error: ${error.message}`);
            return false;
        }
    }

    showHelp() {
        console.log(`
📁 SETICON - Manuel d'utilisation
${'='.repeat(34)}

📋 DESCRIPTION:
   Utilitaire en ligne de commande pour changer les icônes de dossiers
   sous Windows avec conversion automatique PNG vers ICO.

🎯 UTILISATION:
   seticon [OPTIONS] [COMMANDES]

📝 COMMANDES:
   set              Définir l'icône d'un dossier
   convert          Convertir PNG vers ICO
   help, --help, -h Afficher ce manuel

⚙️  OPTIONS PRINCIPALES:
   -f, --folder <path>     Chemin du dossier cible
   -i, --icon <path>       Chemin du fichier icône (.ico ou .png)
   -o, --output <path>     Fichier de sortie pour conversion
   -s, --sizes <sizes>     Tailles d'icône (ex: 16,32,48,64,128,256)
   -v, --verbose          Mode verbeux
   -h, --help             Afficher l'aide

📋 EXEMPLES D'UTILISATION:

   1. Changer l'icône d'un dossier avec un fichier ICO:
      seticon set -f "./MonDossier" -i "./icone.ico"
      seticon set --folder "C:\\Users\\Docs" --icon "icon.ico"

   2. Changer l'icône avec un PNG (conversion automatique):
      seticon set -f "./Projet" -i "./logo.png"
      seticon set --folder "./Images" --icon "./favicon.png" --sizes 16,32,48

   3. Convertir PNG vers ICO uniquement:
      seticon convert -i "./image.png" -o "./icone.ico"
      seticon convert --icon "logo.png" --output "logo.ico" --sizes 16,32,64,128

   4. Syntaxe simplifiée (rétrocompatibilité):
      seticon "./MonDossier" "./icone.png"
      seticon convert "./image.png" "./icon.ico"

🔧 FONCTIONNALITÉS:
   ✓ Conversion automatique PNG → ICO si nécessaire
   ✓ Support de multiples tailles d'icônes
   ✓ Création automatique du fichier desktop.ini
   ✓ Fichiers ICO et desktop.ini rendus invisibles (+H +S)
   ✓ Application des attributs système appropriés
   ✓ Nettoyage automatique des fichiers temporaires
   ✓ Gestion d'erreurs complète

📁 FORMATS SUPPORTÉS:
   Entrée: PNG, ICO
   Sortie: ICO
   Tailles: 16x16, 32x32, 48x48, 64x64, 128x128, 256x256

⚠️  NOTES IMPORTANTES:
   • L'utilitaire fonctionne uniquement sous Windows
   • Les fichiers desktop.ini et ICO sont rendus invisibles
   • Le dossier devient en lecture seule pour préserver l'icône
   • Les conversions PNG utilisent des tailles standards

🆘 AIDE ET SUPPORT:
   Pour plus d'informations: seticon --help
   Version: 1.0.0
        `);
    }

    cleanup() {
        try {
            if (fs.existsSync(this.tempDir)) {
                const files = fs.readdirSync(this.tempDir);
                files.forEach(file => {
                    const filePath = path.join(this.tempDir, file);
                    if (file.startsWith('converted_') && file.endsWith('.ico')) {
                        fs.unlinkSync(filePath);
                    }
                });
            }
        } catch (error) {
            // Ignore cleanup errors
        }
    }
}

function parseArguments(args) {
    const options = {
        command: null,
        folder: null,
        icon: null,
        output: null,
        sizes: [16, 32, 48, 64, 128, 256],
        verbose: false,
        help: false
    };

    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        const nextArg = args[i + 1];

        switch (arg) {
            case '--help':
            case '-h':
            case 'help':
                options.help = true;
                break;
            case '--folder':
            case '-f':
                options.folder = nextArg;
                i++;
                break;
            case '--icon':
            case '-i':
                options.icon = nextArg;
                i++;
                break;
            case '--output':
            case '-o':
                options.output = nextArg;
                i++;
                break;
            case '--sizes':
            case '-s':
                if (nextArg) {
                    options.sizes = nextArg.split(',').map(s => parseInt(s.trim()));
                    i++;
                }
                break;
            case '--verbose':
            case '-v':
                options.verbose = true;
                break;
            case 'set':
            case 'convert':
                options.command = arg;
                break;
            default:
                if (!arg.startsWith('-') && !options.command) {
                    if (args.length >= 2 && !options.folder) {
                        options.command = 'set';
                        options.folder = arg;
                        options.icon = nextArg;
                        i++;
                    } else if (arg === 'convert' || (args.length === 3 && !options.command)) {
                        options.command = 'convert';
                        if (arg !== 'convert') {
                            options.icon = arg;
                            options.output = nextArg;
                            i++;
                        }
                    }
                }
                break;
        }
    }

    return options;
}

async function main() {
    const cli = new FolderIconCLI();
    const args = process.argv.slice(2);
    const options = parseArguments(args);

    process.on('exit', () => cli.cleanup());
    process.on('SIGINT', () => cli.cleanup());
    process.on('SIGTERM', () => cli.cleanup());

    if (options.verbose) {
        console.log('🔧 Options:', options);
    }

    if (args.length === 0 || options.help) {
        cli.showHelp();
        return;
    }

    try {
        if (options.command === 'convert') {
            if (args[0] === 'convert' && args.length === 3) {
                const [, pngPath, icoPath] = args;
                options.icon = pngPath;
                options.output = icoPath;
            }
            
            if (!options.icon || !options.output) {
                console.error('❌ Convert command requires --icon and --output parameters');
                console.log('💡 Example: seticon convert -i "image.png" -o "icon.ico"');
                process.exit(1);
            }
            
            await cli.convertPngToIco(options.icon, options.output, options.sizes);
            console.log(`✓ PNG converted to ICO: ${options.output}`);
            
        } else if (options.command === 'set') {
            if (!options.folder || !options.icon) {
                console.error('❌ Set command requires --folder and --icon parameters');
                console.log('💡 Example: seticon set -f "./MyFolder" -i "icon.png"');
                process.exit(1);
            }
            
            const success = await cli.processIconChange(options.folder, options.icon, options.sizes);
            process.exit(success ? 0 : 1);
            
        } else {
            console.error('❌ Invalid command. Use --help for usage information.');
            process.exit(1);
        }
    } catch (error) {
        console.error(`❌ Error: ${error.message}`);
        if (options.verbose) {
            console.error(error.stack);
        }
        process.exit(1);
    }
}

if (require.main === module) {
    main().catch(error => {
        console.error(`❌ Unexpected error: ${error.message}`);
        process.exit(1);
    });
}

module.exports = FolderIconCLI;