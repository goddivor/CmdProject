// tree_ex_with_icons.c
// Un utilitaire 'tree' enrichi pour Windows :
// - Affichage d'icônes/émoticônes selon l'extension
// - Exclusion de dossiers (-e) et fichiers (-E)
// - Support des wildcards (*, ?)
// Compilation : gcc tree_ex_with_icons.c -o tree_ex_with_icons.exe -lshlwapi

#include <windows.h>
#include <shlwapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PATTERNS 32
#define MAX_PATH_LEN 1024

typedef struct {
    char *excludeDirs[MAX_PATTERNS];
    int  excludeDirCount;
    char *excludeFiles[MAX_PATTERNS];
    int  excludeFileCount;
    int  showFiles;
} Options;

// Mapping extension -> emoji
typedef struct {
    const char *ext;
    const char *icon;
} FileIcon;

static FileIcon fileIcons[] = {
    // Langages compilés / scripts
    { ".c",      "🐍" },  // C
    { ".h",      "📘" },  // Header C/C++
    { ".cpp",    "🚀" },  // C++
    { ".java",   "☕" },  // Java
    { ".class",  "☕" },  // Bytecode Java
    { ".jar",    "📦" },  // Archive Java
    { ".go",     "🐹" },  // Go
    { ".php",    "🐘" },  // PHP
    { ".rb",     "💎" },  // Ruby
    { ".cs",     "🔷" },  // C#
    { ".vb",     "🔶" },  // VB.NET
    { ".kt",     "🔷" },  // Kotlin
    { ".kts",    "📝" },  // Kotlin script
    { ".swift",  "🕊️" }, // Swift

    // Frameworks / front-end
    { ".ts",     "🔷" },  // TypeScript
    { ".tsx",    "🔸" },  // TSX React
    { ".js",     "✨" },  // JavaScript
    { ".jsx",    "⚛️" }, // JSX React
    { ".dart",   "🎯" },  // Dart/Flutter
    { ".py",     "🐍" },  // Python
    { ".rs",     "🦀" },  // Rust
    { ".bat",    "💻" },  // Batch
    { ".sh",     "🐚" },  // Shell

    // Web & données
    { ".html",   "🌐" },
    { ".htm",    "🌐" },
    { ".css",    "🎨" },
    { ".json",   "🗄️" },
    { ".xml",    "📄" },
    { ".svg",    "🖌️" },
    
    // Images
    { ".jpg",    "🖼️" },
    { ".jpeg",   "🖼️" },
    { ".png",    "🌆" },
    { ".gif",    "🎞️" },
    { ".bmp",    "🖼️" },

    // Documents & binaires
    { ".exe",    "⚙️" },
    { ".txt",    "📄" },
    { ".md",     "📝" },
    { ".pdf",    "📕" },

    // Office (Excel, Word, PowerPoint)
    { ".xls",   "📊" },  // Excel 97–2003
    { ".xlsx",  "📊" },  // Excel modern
    { ".doc",   "📝" },  // Word 97–2003
    { ".docx",  "📝" },  // Word modern
    { ".ppt",   "📽️" }, // PowerPoint 97–2003
    { ".pptx",  "📽️" }, // PowerPoint modern

    // Archives
    { ".zip",    "🗜️" },
    { ".rar",    "🗜️" },
    { ".tar",    "🗜️" },
    { ".gz",     "🗜️" },
    { ".7z",     "🗜️" },

    // Configurations & verrou
    { ".lock",   "🔒" },
    { ".yml",    "📜" },
    { ".yaml",   "📜" },
    { ".env",    "⚙️" },
    { ".ini",    "⚙️" },
    { ".toml",   "⚙️" },
    { ".conf",   "⚙️" },

    // Clés & certificats
    { ".pem",    "🔑" },
    { ".key",    "🔑" },
    { ".crt",    "🔒" },

    // Polices
    { ".ttf",    "🔤" },
    { ".otf",    "🔤" },
    { ".woff",   "🔤" },
    { ".woff2",  "🔤" },

    // Audio
    { ".mp3",   "🎵" },
    { ".wav",   "🎵" },
    { ".flac",  "🎵" },
    { ".ogg",   "🎵" },

    // Vidéo
    { ".mp4",   "🎬" },
    { ".mkv",   "🎬" },
    { ".avi",   "🎬" },
    { ".mov",   "🎬" },

    // Données & bases
    { ".csv",   "🗃️" },
    { ".tsv",   "🗃️" },
    { ".db",    "🗃️" },
    { ".sqlite","🗃️" },

    // Logs
    { ".log",   "📜" },

    // Images disques & virtualisation
    { ".iso",   "💿" },
    { ".img",   "💿" },
    { ".vmdk",  "💿" },
    { ".vdi",   "💿" },

    // Emails
    { ".eml",   "📧" },

    // Modèles 3D / CAO
    { ".obj",   "🗿" },
    { ".stl",   "🗿" },
    { ".dwg",   "🗿" },

    // Projets / IDE
    { ".sln",    "📐" },
    { ".csproj", "📐" },
    { ".vcxproj","📐" },

    { NULL,      NULL }
};



// Retourne l'emoji selon l'extension du fichier
static const char* getFileIcon(const char *name) {
    const char *ext = strrchr(name, '.');
    if (!ext) return "📄";
    for (FileIcon *fi = fileIcons; fi->ext; fi++) {
        if (_stricmp(ext, fi->ext)==0) return fi->icon;
    }
    return "📄";
}

// Affiche l'indentation
static void printIndent(int level) {
    for (int i = 0; i < level; i++) printf("│   ");
}

// Test si un nom correspond à un des patterns
static int matchAny(const char *name, char *pats[], int patCount) {
    for (int i = 0; i < patCount; i++) {
        if (PathMatchSpecA(name, pats[i])) return 1;
    }
    return 0;
}

// Récursion dans l'arborescence
void recurseTree(const char *basePath, Options *opt, int level) {
    WIN32_FIND_DATAA fd;
    char searchPath[MAX_PATH_LEN];
    HANDLE hFind;

    snprintf(searchPath, MAX_PATH_LEN, "%s\\*", basePath);
    hFind = FindFirstFileA(searchPath, &fd);
    if (hFind == INVALID_HANDLE_VALUE) return;

    do {
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            if (strcmp(fd.cFileName, ".")==0 || strcmp(fd.cFileName, "..")==0) continue;
            if (matchAny(fd.cFileName, opt->excludeDirCount ? opt->excludeDirs : NULL, opt->excludeDirCount)) continue;
            printIndent(level);
            printf("📁 %s\n", fd.cFileName);
            char nextPath[MAX_PATH_LEN];
            snprintf(nextPath, MAX_PATH_LEN, "%s\\%s", basePath, fd.cFileName);
            recurseTree(nextPath, opt, level + 1);
        }
    } while (FindNextFileA(hFind, &fd));
    FindClose(hFind);

    if (opt->showFiles) {
        hFind = FindFirstFileA(searchPath, &fd);
        if (hFind == INVALID_HANDLE_VALUE) return;
        do {
            if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                if (matchAny(fd.cFileName, opt->excludeFiles, opt->excludeFileCount)) continue;
                printIndent(level);
                const char *icon = getFileIcon(fd.cFileName);
                printf("%s %s\n", icon, fd.cFileName);
            }
        } while (FindNextFileA(hFind, &fd));
        FindClose(hFind);
    }
}

int main(int argc, char *argv[]) {
    // On peut forcer le code page depuis le batch : chcp 65001
    Options opt = { .excludeDirCount=0, .excludeFileCount=0, .showFiles=0 };
    const char *root = ".";

    // Parsing des options
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-e")==0 && i+1<argc) opt.excludeDirs[opt.excludeDirCount++] = argv[++i];
        else if (strcmp(argv[i], "-E")==0 && i+1<argc) opt.excludeFiles[opt.excludeFileCount++] = argv[++i];
        else if (strcmp(argv[i], "-f")==0) opt.showFiles = 1;
        else root = argv[i];
    }

    // Affiche la racine
    printf("📁 %s\n", root);
    recurseTree(root, &opt, 1);
    return 0;
}
