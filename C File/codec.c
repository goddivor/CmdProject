#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include<string.h>

typedef struct dirent* dir;



void IniTab_C(char *tab, int taille)
{
    int i;
    for(i=0;i<taille;i++)
        tab[i]=0;
}

void CopieTab_v_Tab_C(char *tab, char *tab2)
{
    int len;
    for(len=0;tab2[len]!=0;len++);

    int i,a=len;
    for (i=0;i<a;i++)
    {
        tab[i]=tab2[i];
    }
}

char* strreverse(char *chaine)
{

    int len;
    for(len=0;chaine[len]!=0;len++);
    char a; int i,c=len-1;

        for(i=0;i<(len/2);i++)
        {
            a=chaine[i]; chaine[i]=chaine[c]; chaine[c]=a; c--;
        }
    return chaine;
}

int  isitmyfile(char *fichierlu, char *extension)
{
    int result; char nfichierlu[strlen(fichierlu)+1]; IniTab_C(nfichierlu,(strlen(fichierlu)+1));
    CopieTab_v_Tab_C(nfichierlu,fichierlu);
    int til=strlen(extension);
    strreverse(nfichierlu);
    nfichierlu[strlen(extension)]='\0';
    strreverse(nfichierlu);
    // printf("%s et %s et %d\n",nfichierlu,extension,til);
    if(stricmp(nfichierlu,extension)==0) return 0;
    return 1;
}


int isdir(struct dirent* ent)
{
/*Fonction Utiles*/

int OpenDoc(char *dossier)//Ouvreur de dossier
{
    DIR* rep_temp = NULL; //variable d'ouverture de dossier
    rep_temp = opendir(dossier);//tentative d'ouverture de dossier
    if(rep_temp == NULL) //si le dossier n'a pas pu s'ouvrir
    {
        return 0;//c'est que c'est un fichier
    }
    else //sinon
    {
        closedir(rep_temp);//on referme l'ouverture du dossier
        rep_temp = NULL;//on efface la variable d'ouverture
        return 1; //c'est bien un dossier
    }
}

int OpenFile(char *fichier)//Ouvreur de fichier
{
    FILE* file_temp =NULL;//variable d'ouverture de fichier
    file_temp = fopen(fichier,"r");//tentative d'ouverture de fichier en mode lecture
    if(file_temp == NULL)//si le fichier n'a pas pu s'ouvrir
    {
        return 1;//c'est que c'est un dossier
    }
    else//sinon
    {
        fclose(file_temp);//on referme l'ouverture du fichier
        file_temp=NULL;//on efface la variable d'ouverture
        return 0;//c'est bien un fichier;
    }
}

/*Debut des Hostilité*/

    if((strrchr(ent->d_name,'.')) == NULL) //s'il n'a pas d'extension
    {
        //c'est un dossier mais il existe des fichier qui n'ont pas d'extensions donc
        if(OpenFile(ent->d_name)==0)//s'il existe un dossier qui a pu s'ouvrir enten que fichier
            return 0;//c'est que c'est un fichier sans extension
        else if(OpenFile(ent->d_name)==1)//sinon
            return 1; //c'est un dossier
    }
    //else//sinon si il a des extension
    //{
        //c'est un fichier mais il existe des dossier qui ont des extensions donc
        if(OpenDoc(ent->d_name)==1)//s'il existe un fichier qui a pu souvrir enten que dossier
            return 1; //c'est que c'est un dossier qui a des extension
        else if(OpenDoc(ent->d_name)==0)//sinon
            return 0;//c'st un fichier
    //}
}


int main(int argc, char const *argv[])
{
	DIR *rep=NULL;
	dir fichierlu=NULL;
	int renom=0; int test;
    char *doctr=(char*) malloc(sizeof(char)*17);
    char *doc=(char*) malloc(sizeof(char)*11);
    char *ext=(char*) malloc(sizeof(char)*7);
	char *new_name=(char*) malloc(sizeof(char)*20);
    char *nomfichactuel=(char*) malloc(sizeof(char)*150);
	char *nouveau_nom_emp=(char*) malloc(sizeof(char)*100);
    scanf("%s",doc);
    scanf("%s",ext);
    fflush(stdin);
    printf("doc : %s ext : %s\n",doc,ext);
    // scanf("%s,%s",doc,ext);
	sprintf(doctr,".\\%s",doc);
    rep=opendir(doctr);
	if(rep==NULL)
	{
		printf("Impossible d'ouvrir ce dossier\n"); exit(0);
	}

	while((fichierlu=readdir(rep)) != NULL)//prtend tous ce qui est dans le dossier
	{
		if(isdir(fichierlu)==0 && isitmyfile(fichierlu->d_name,ext)==0) //premiere tri il prend uniquement que les fichiers
		{
			sprintf(new_name,"%d.%s",renom,ext);
			sprintf(nomfichactuel,"%s\\%s",doctr,fichierlu->d_name);
			sprintf(nouveau_nom_emp,"%s\\%s",doctr,new_name);
			// printf("Old Name : %s eplacement : %s et New nom : %s lien : %s\n",fichierlu->d_name,nomfichactuel,new_name,nouveau_nom_emp);
            printf("Old Name : %s  <=> New nom : %s\n",fichierlu->d_name,new_name);
			test=rename(nomfichactuel,nouveau_nom_emp);
			if(test==0)
                printf("op : --r\n");
            else printf("op : --e\n");
			renom++;
		}
	}
	free(new_name);
    free(ext);
    free(doc);
    free(doctr);
	free(nomfichactuel);
	free(nouveau_nom_emp);
	closedir(rep);
	return 0;
}