# CmdProject - Collection de commandes batch utilitaires

Collection de commandes batch créées pour faciliter diverses tâches système sous Windows.

## Liste des commandes disponibles

### Gestion des fichiers et dossiers
- **all.bat** - Affiche tous les dossiers et compte les éléments avec elem.bat
- **ddir.bat** - Affiche le nombre de fichiers/dossiers dans un répertoire
- **elem.bat** - Compte les fichiers, dossiers et éléments totaux dans un répertoire
- **fdir.bat** - Liste les fichiers avec filtrage par pattern (wildcards)
- **emptdoc.bat** - Supprime tous les dossiers vides du répertoire courant
- **isdir.bat** - Vérifie si un chemin est un dossier (utilise isdi.exe)
- **movedoc.bat** - Déplace tous les dossiers d'un répertoire vers un autre
- **opn.bat** - Ouvre un dossier dans l'explorateur Windows

### Analyse de taille et espace disque
- **dsize.bat** - Calcule la taille totale de plusieurs répertoires
- **fsize.bat** - Affiche la taille d'un fichier (utilise xfsize.exe)
- **ftipe.bat** - Affiche la taille d'un répertoire avec conversion d'unités
- **diskfree.bat** - Affiche l'espace libre sur un ou plusieurs disques
- **freedsk.bat** - Affiche l'espace libre d'un disque spécifique
- **dsk.bat** - Liste les lecteurs disponibles et leurs types

### Organisation et tri de fichiers
- **tri.bat** - Trie automatiquement les fichiers par type/extension
- **groupfile.bat** - Groupe les fichiers par extension dans des dossiers
- **groupfile2.bat** - Version alternative de groupfile.bat
- **rang.bat** - Range les fichiers par extension dans un dossier spécifique
- **rang-cli** - Outil moderne de renommage séquentiel avec support multi-extensions
- **manga.bat** - Organise les fichiers média (mp4, mp3, mkv) par nom
- **dedup** - Détection et suppression intelligente des fichiers dupliqués
- **test.bat + sup_double.exe** - Système de déduplication par taille et comparaison binaire

### Gestion système
- **closeapp.bat** - Ferme plusieurs applications (IDM, MySQL, uTorrent, etc.)
- **desk.bat** - Redémarre ou arrête l'explorer Windows (/brk ou /str)
- **useracc.bat** - Gestion complète des comptes utilisateurs (/add, /del, /mod, /rename, /list, /ini, /help)
- **useraccold.bat** - Version ancienne de la gestion d'utilisateurs
- **inipass.bat** - Initialise le mot de passe d'un utilisateur

### Utilitaires réseau
- **wifimap.bat** - Gestion des profils WiFi (/l, /k, /d, /?) - liste, clés, suppression
- **wifi-cli** - Gestionnaire WiFi moderne avec interface colorée et mots de passe visibles

### Outils spécialisés
- **col.bat** - Change la couleur de la console (utilise couleur.exe)
- **converti.bat** - Conversion d'unités (utilise convertion.exe)
- **heur.bat** - Affiche l'heure actuelle formatée
- **steg.bat** - Outil de stéganographie pour combiner image et archive
- **treex.bat** - Wrapper UTF-8 pour tree_ex.exe avec options avancées
- **treex2.bat** - Version alternative de treex.bat
- **genicon.bat** - Génère des icônes en plusieurs tailles avec ImageMagick
- **folder-icon-cli** - Changement d'icônes de dossiers avec conversion PNG vers ICO

### Fichiers de développement/test
- **test.bat** - Fichier de test
- **testing.bat** - Fichier de test
- **dbl_cln.bat** - Outil de nettoyage (versions dans racine et C File/)
- **move_file.bat** - Utilitaire de déplacement de fichiers (versions dans racine et C File/)

## Usage général

La plupart des commandes acceptent des paramètres. Utilisez `/help` ou `/?` quand disponible pour voir les options.

Exemples d'usage :
```batch
# Outils batch classiques
elem .                    # Compte les éléments du répertoire courant
dsize dossier1 dossier2   # Taille de plusieurs dossiers
wifimap /l                # Liste des réseaux WiFi
useracc /help             # Aide pour la gestion d'utilisateurs

# Nouveaux outils CLI modernes
dedup scan Documents      # Scanner les doublons dans Documents
dedup clean --interactive # Suppression interactive des doublons
rang-cli rename Photos -e jpg png -m prefixed -t vacation
                          # Renommer photos avec préfixe "vacation_001.jpg"
rang-cli preview Downloads -e pdf
                          # Prévisualiser les PDFs à renommer
wifi-cli list             # Voir tous les profils WiFi avec mots de passe
```

## Outils CLI modernes (Node.js)

Le projet inclut désormais des outils CLI modernes développés en Node.js :

### **dedup** - Déduplication intelligente de fichiers
- **Architecture 2-phases** : Tri par taille puis comparaison binaire optimisée
- **Interface interactive** : Preview, confirmation, sélection individuelle
- **Performance** : Comparaison par chunks 64KB pour rapidité maximale
- **Sécurité** : Preview obligatoire, pas de suppression accidentelle

```bash
dedup scan [directory]    # Scanner et afficher les doublons
dedup clean [directory]   # Mode nettoyage interactif
```

### **rang-cli** - Renommage séquentiel avancé
- **Multi-extensions** : Traiter txt, pdf, jpg simultanément
- **4 modes de renommage** : simple (0.txt), padded (001.txt), prefixed (photo_001.jpg), custom
- **Options de tri** : Par nom, date ou taille
- **Fonction undo** : Annulation du dernier renommage
- **Dry-run** : Test sans modification

```bash
rang-cli rename [dir] -e txt pdf -m prefixed -t document
rang-cli preview [dir] -e jpg      # Prévisualisation seule
rang-cli undo                      # Annuler dernier renommage
```

### **wifi-cli** - Gestion WiFi moderne
- **Interface utilisateur améliorée** : Tableaux colorés, spinners, indicateurs visuels
- **Mots de passe visibles** : Affichage direct sans privilèges administrateur requis
- **Encodage corrigé** : Support parfait des caractères spéciaux Windows
- **Recherche et export** : Filtrage par pattern, export JSON
- **Compatibilité legacy** : Commandes wifimap.bat intégrées

```bash
wifi-cli list                      # Liste tous les profils avec mots de passe
wifi-cli show "NomDuWiFi"          # Détails d'un profil spécifique
wifi-cli search pattern            # Rechercher des profils
wifi-cli export [fichier.json]     # Exporter les profils
wifi-cli delete "NomDuWiFi"        # Supprimer un profil
```

### **folder-icon-cli** - Gestionnaire d'icônes de dossiers
- **Conversion intelligente** : PNG vers ICO automatique avec Sharp
- **Gestion Windows** : Création desktop.ini et attributs système
- **Multi-tailles** : Support 16x16 à 256x256 pixels dans un seul ICO
- **Fichiers invisibles** : ICO et desktop.ini rendus invisibles (+H +S)
- **Interface moderne** : Options --folder/-f, --icon/-i avec manuel complet
- **Haute performance** : Aucune limite de taille sur les PNG sources

```bash
folder-icon-cli set -f "./MonDossier" -i "./icone.png"
folder-icon-cli set --folder "Documents" --icon "logo.ico"
folder-icon-cli convert -i "./image.png" -o "./icon.ico"
folder-icon-cli convert --icon "photo.png" --output "icon.ico" --sizes 16,32,48
folder-icon-cli --help                # Manuel d'utilisation complet
```

## Installation des outils CLI

```bash
# Installation globale (Windows)
npm install -g .          # Installe dedup, rang-cli, wifi-cli et folder-icon-cli globalement
```