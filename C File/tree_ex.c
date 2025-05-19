// tree_ex.c
// #define UNICODE
// #define _UNICODE

//compiler avec gcc tree_ex.c -o tree_ex.exe -municode -lshlwapi

#include <windows.h>
#include <shlwapi.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_PATTERNS 32
#define MAX_PATH_LEN  1024

typedef struct {
    LPSTR excludeDirs[MAX_PATTERNS];
    int  excludeDirCount;
    LPSTR excludeFiles[MAX_PATTERNS];
    int  excludeFileCount;
    BOOL showFiles;
} Options;

void printIndent(int level) {
    for (int i = 0; i < level; i++) {
        printf("│   ");
    }
}

BOOL matchAny(LPCSTR name, LPSTR pats[], int patCount) {
    for (int i = 0; i < patCount; i++) {
        if (PathMatchSpecA(name, pats[i]))
            return TRUE;
    }
    return FALSE;
}

void recurseTree(LPCSTR basePath, Options *opt, int level) {
    WIN32_FIND_DATAA fd;
    CHAR searchPath[MAX_PATH_LEN];
    HANDLE hFind;

    // Parcours des dossiers
    snprintf(searchPath, MAX_PATH_LEN, "%s\\*", basePath);
    hFind = FindFirstFileA(searchPath, &fd);
    if (hFind == INVALID_HANDLE_VALUE) return;

    do {
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            // ignorer "." et ".."
            if (strcmp(fd.cFileName, ".")==0 || strcmp(fd.cFileName, "..")==0)
                continue;
            // exclusion éventuelle
            if (matchAny(fd.cFileName, opt->excludeDirs, opt->excludeDirCount))
                continue;

            // affichage dossier
            printIndent(level);
            printf("📁 %s\n", fd.cFileName);

            // appel récursif
            CHAR nextPath[MAX_PATH_LEN];
            snprintf(nextPath, MAX_PATH_LEN, "%s\\%s", basePath, fd.cFileName);
            recurseTree(nextPath, opt, level + 1);
        }
    } while (FindNextFileA(hFind, &fd));
    FindClose(hFind);

    if (opt->showFiles) {
        // Parcours des fichiers
        hFind = FindFirstFileA(searchPath, &fd);
        if (hFind == INVALID_HANDLE_VALUE) return;
        do {
            if (!(fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                if (matchAny(fd.cFileName, opt->excludeFiles, opt->excludeFileCount))
                    continue;
                printIndent(level);
                printf("📄 %s\n", fd.cFileName);
            }
        } while (FindNextFileA(hFind, &fd));
        FindClose(hFind);
    }
}

int main(int argc, char *argv[]) {
    Options opt = { .excludeDirCount = 0, .excludeFileCount = 0, .showFiles = FALSE };
    LPCSTR root = ".";

    // Parsing simple des options
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-e")==0 && i+1<argc) {
            if (opt.excludeDirCount < MAX_PATTERNS)
                opt.excludeDirs[opt.excludeDirCount++] = argv[++i];
        }
        else if (strcmp(argv[i], "-E")==0 && i+1<argc) {
            if (opt.excludeFileCount < MAX_PATTERNS)
                opt.excludeFiles[opt.excludeFileCount++] = argv[++i];
        }
        else if (strcmp(argv[i], "-f")==0) {
            opt.showFiles = TRUE;
        }
        else {
            root = argv[i];
        }
    }

    // Affiche la racine
    printf("📁 %s\n", root);
    recurseTree(root, &opt, 1);
    return 0;
}
