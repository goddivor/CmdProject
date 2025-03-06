#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <dirent.h>
#include <windows.h>
#define default 1024

typedef struct dirent* dir;

/*char* convert(double unit)
{
	char *new_size;
    if(unit>default)
    {
        unit/=default; //convertion en kilo
        if(unit>default)
        {
            unit/=default; //convertion en mega
            if(unit>default)
            {
                unit/=default; //convertion en giga
                if(unit>default)
                {
                    unit/=default; //convertion en tera
                    sprintf(new_size,"%.2lf tera-octet",unit);
                    return new_size;
                }
                else { sprintf(new_size,"%.2lf giga-octet",unit); return new_size; }
            }
            else { sprintf(new_size,"%.2lf mega-octet",unit); return new_size; }
        }
        else { sprintf(new_size,"%.2lf kilo-octet",unit); return new_size; }
    }
    else { sprintf(new_size,"%.2lf octet",unit); return new_size; }
}*/


void convert(double unit, char *new_size)
{
    if(unit>default)
    {
        unit/=default; //convertion en kilo
        if(unit>default)
        {
            unit/=default; //convertion en mega
            if(unit>default)
            {
                unit/=default; //convertion en giga
                if(unit>default)
                {
                    unit/=default; //convertion en tera
                    sprintf(new_size,"%.2lf To",unit);
                    // return new_size;
                }
                else { sprintf(new_size,"%.2lf Go",unit); /*return new_size;*/ }
            }
            else { sprintf(new_size,"%.2lf Mo",unit); /*return new_size;*/ }
        }
        else { sprintf(new_size,"%.2lf Ko",unit); /*return new_size;*/ }
    }
    else { sprintf(new_size,"%.2lf Oc",unit); /*return new_size;*/ }
}



long size(char *addr)
{
	FILE *fichier;
	long size;

	fichier=fopen(addr,"rb");

	if (fichier)
	{
		fseek(fichier,0,SEEK_END);
		size=ftell(fichier);
		fclose(fichier);
	}
	return size;
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
	system("CHCP 1252>nul");
	/*Gestion des couleurs de la console*/
	HANDLE console,console2;
	console = GetStdHandle(STD_OUTPUT_HANDLE);
	console2 = GetStdHandle(STD_INPUT_HANDLE);
	// system("color 7"); //valeur par defaut des couleur

	/*variable necessaire*/
	long size_o; double size_o_c; char* new_size=(char *) malloc(sizeof(char)*30);
	int nbr_doc=0; int nbr_fich=0; int total=0; double total_size=0;
	char* total_new_size=(char *) malloc(sizeof(char)*30);

	/*Gestion des repertoires*/
	DIR *rep=NULL; dir fichierLu=NULL;

	/*Corpt du codoe source*/
	rep=opendir(".\\");
	if (!rep)
	{
		SetConsoleTextAttribute(console,4);//rouge
		printf("Erreur\n");
		SetConsoleTextAttribute(console,7);//blancs
		exit(0);
	}
	printf("\n");
	while((fichierLu=readdir(rep)))
	{
		if (isdir(fichierLu)==1)
		{
			// printf("[%s]\n",fichierLu->d_name);
			SetConsoleTextAttribute(console,5);
			printf("[");
			SetConsoleTextAttribute(console,12);
			printf("%s",fichierLu->d_name);
			SetConsoleTextAttribute(console,5);
			printf("]\n");
			SetConsoleTextAttribute(console,7);
			nbr_doc++;
		}
		else
		{
			size_o=size(fichierLu->d_name);
			size_o_c=(double)size_o;
			total_size+=size_o_c;
			convert(size_o_c,new_size);

			// printf("{%s}\t\t(%s)\n",fichierLu->d_name,new_size);
			SetConsoleTextAttribute(console,5);
			printf("{");
			SetConsoleTextAttribute(console,9);
			printf("%s",fichierLu->d_name);
			SetConsoleTextAttribute(console,5);
			printf("}\t\t(");
			SetConsoleTextAttribute(console,10);
			printf("%s",new_size);
			SetConsoleTextAttribute(console,5);
			printf(")\n");
			SetConsoleTextAttribute(console,7);
			nbr_fich++;
		}
	}
	total=nbr_fich+nbr_doc; convert(total_size,total_new_size);

	// printf("\t %d dossier(s)   %d fichier(s)  (%s)\n\t %d element(s)",nbr_doc,nbr_fich,total_new_size,total);
	SetConsoleTextAttribute(console,1);
	printf("\t %d dossier(s)   ",nbr_doc);
	SetConsoleTextAttribute(console,13);
	printf("%d fichier(s)  ",nbr_fich);
	SetConsoleTextAttribute(console,10);
	printf("(%s)\n\t ",total_new_size);
	SetConsoleTextAttribute(console,6);
	printf("%d element(s)",total);

	free(new_size); free(total_new_size);
	printf("\n");
	SetConsoleTextAttribute(console,7);
	system("CHCP 850>nul");
	return 0;
}