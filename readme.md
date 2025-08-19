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
- **manga.bat** - Organise les fichiers média (mp4, mp3, mkv) par nom

### Gestion système
- **closeapp.bat** - Ferme plusieurs applications (IDM, MySQL, uTorrent, etc.)
- **desk.bat** - Redémarre ou arrête l'explorer Windows (/brk ou /str)
- **useracc.bat** - Gestion complète des comptes utilisateurs (/add, /del, /mod, /rename, /list, /ini, /help)
- **useraccold.bat** - Version ancienne de la gestion d'utilisateurs
- **inipass.bat** - Initialise le mot de passe d'un utilisateur

### Utilitaires réseau
- **wifimap.bat** - Gestion des profils WiFi (/l, /k, /d, /?) - liste, clés, suppression

### Outils spécialisés
- **col.bat** - Change la couleur de la console (utilise couleur.exe)
- **converti.bat** - Conversion d'unités (utilise convertion.exe)
- **heur.bat** - Affiche l'heure actuelle formatée
- **steg.bat** - Outil de stéganographie pour combiner image et archive
- **treex.bat** - Wrapper UTF-8 pour tree_ex.exe avec options avancées
- **treex2.bat** - Version alternative de treex.bat
- **genicon.bat** - Génère des icônes en plusieurs tailles avec ImageMagick

### Fichiers de développement/test
- **test.bat** - Fichier de test
- **testing.bat** - Fichier de test
- **dbl_cln.bat** - Outil de nettoyage (versions dans racine et C File/)
- **move_file.bat** - Utilitaire de déplacement de fichiers (versions dans racine et C File/)

## Usage général

La plupart des commandes acceptent des paramètres. Utilisez `/help` ou `/?` quand disponible pour voir les options.

Exemples d'usage :
```batch
elem .                    # Compte les éléments du répertoire courant
dsize dossier1 dossier2   # Taille de plusieurs dossiers
wifimap /l                # Liste des réseaux WiFi
useracc /help             # Aide pour la gestion d'utilisateurs
```