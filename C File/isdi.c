#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <dirent.h>


int isdir(char *ent)
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

    if((strrchr(ent,'.')) == NULL) //s'il n'a pas d'extension
    {
        //c'est un dossier mais il existe des fichier qui n'ont pas d'extensions donc
        if(OpenFile(ent)==0)//s'il existe un dossier qui a pu s'ouvrir enten que fichier
            return 0;//c'est que c'est un fichier sans extension
        else if(OpenFile(ent)==1)//sinon
            return 1; //c'est un dossier
    }
    //else//sinon si il a des extension
    //{
        //c'est un fichier mais il existe des dossier qui ont des extensions donc
        if(OpenDoc(ent)==1)//s'il existe un fichier qui a pu souvrir enten que dossier
            return 1; //c'est que c'est un dossier qui a des extension
        else if(OpenDoc(ent)==0)//sinon
            return 0;//c'st un fichier
    //}
}

void scanfs_mod(char *chaine , int longueur)
{
    int i,j,z; char temp;
    fgets(chaine,longueur,stdin);
    for(i=0;chaine[i];i++) if(chaine[i]=='\n') chaine[i]='\0';

    //printf("%s\n",chaine);
    for(i=0,z=0;chaine[i]==34;z++)
    {
        //printf("%d\n",i);
        for(j=i;chaine[j];j++)
            {
                temp=chaine[j];
                if (chaine[j+1])
                {
                    chaine[j]=chaine[j+1];
                    chaine[j+1]=temp;
                }
                else continue;
                //printf("%s ==>%d\n",chaine,j);
            }
        //printf("%s\n",chaine);
    }
    //printf("%d\n",z);
    int log;
    for(log=0;chaine[log];log++);
    chaine[log-z]='\0';
    for(log=0;chaine[log];log++);
    for(i=log-1,j=0;chaine[i]==34;i--,j++);
    //printf("%d\n",j);
    chaine[log-j]='\0';

    fflush(stdin);
}

int main(int argc, char const *argv[])
{
	char *nom_fich=(char *) malloc(sizeof(char)*50);
	scanfs_mod(nom_fich,50);
	if(isdir(nom_fich)==1) printf("1\n");
	else printf("0\n");
	free(nom_fich);
	return 0;
}