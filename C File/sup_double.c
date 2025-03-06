#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
/*
int isdir(struct dirent* ent)
{
    if((strrchr(ent->d_name,'.')) == NULL)
        return 1;
        else return 0;
}
*/

void IniTab(int *tab, int taille)
{
    int i;
    for(i=0;i<taille;i++)
        tab[i]=1;
}

int isiden2(char *file1, char *file2)
{
    FILE *fichier; FILE *fichier2; char car,car2;
    fichier=fopen(file1,"r");
    fichier2=fopen(file2,"r");
    if(file1){
        if(file2){
            do
            {
                car=fgetc(fichier);
                car2=fgetc(fichier2);
                if (car != car2)
                {
                    fclose(fichier); fclose(fichier2);
                    return 1; //les fichier sont different
                }
            }while(car != EOF && car2 != EOF);
            fclose(fichier); fclose(fichier2);
            return 0; //les fichier sont identique
        } else {
            return -1;
        }
    } else {
        return -1;
    }
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


int main()
{
    DIR* rep=NULL;
    struct dirent* fichierLU=NULL;
    rep=opendir(".");
    char tab[250][500]; int j=0;
    if(rep == NULL)
    {
        printf("Echec"); exit(0);
    }
    else
    {
        // printf("Accept");
        while((fichierLU=readdir(rep)) != NULL)
        {
            if(isdir(fichierLU)==0){
                sprintf(tab[j],fichierLU->d_name);
                j++;
            }
        }
        //int t;
        //for(t=0;t<j;t++)
        //{
          //  printf("%d ==> %s\n",t,tab[t]);
        //}

//        if(isiden2(tab[0],tab[1])==0) printf("%s et %s sont les identique\n",tab[0],tab[1]); else printf("non\n");
        
       int tab2[j];
       IniTab(tab2,j);
       int k=0;
        printf("\n");
        int y;
        //for(y=0;y<j;y++)
        //{
          //  printf("%d ==> %s\n",tab2[y],tab[y]);
            // if(tab2[y]) printf("un\n");
            // else printf("Z\n");
        //}
        //int i,tmp=1;
        
        //remplir le tableau de facon a ce qu'il a des 0 et des 1 (bianire)
        //si il ya 0 dans une case a lors le nom de fichier contenu dans cette case doit est effacer
        //tab2[7]=0;
        //do
        //{
            /*i=tmp;
            if(tab2[k]){
                while(i<j)
                {
                    if(tab2[i])
                    {
                        if(isiden2(tab[k],tab[i])==0)
                        {
                            tab2[i]=0;
                        }
                        // printf("celui de k : %s celui de i : \n",tab[k],tab[i]);
                    }
                }
            }
            k++;tmp++;*/
            // i=tmp;
            // i=i%j;
            // printf("mis a un dans tab2\n"); else printf("mis a Z dans tab2\n");
            // printf("%s et suiv : %s\n",tab[k],tab[i]);
        //     if(tab2[k]){
        //         if(tab2[i]){
        //             printf("%s et suiv : %s\n",tab[k],tab[i]);
        //         } else {
        //             printf("%s\n",tab[k]);
        //         }
        //     }
        //     printf("k : %d  i:  %d\n",k,i);
        //    k++;tmp++;
        // }while(k<j);
        int h;
        for(k=0;k<j;k++)
        {
            if(tab2[k]){
                for(h=k+1;h<j;h++){
                    if(tab2[h]){
                        if(isiden2(tab[k],tab[h])==0)
                        {
                            printf("%s et %s sont identique\n",tab[k],tab[h]);
                            tab2[h]=0;
                        }
                    }
                }
            }
        }
        //printf("apres\n");
        for(y=0;y<j;y++)
        {
            // printf("%d ==> %s\n",tab2[y],tab[y]);
            if(!tab2[y]) remove(tab[y]);
            // if(!tab2[y]) printf("%s doit etre sup\n",tab[y]);
            // if(tab2[y]) printf("un\n");
            // else printf("Z\n");
        }

        //pout effecer ceux qui sont a zero dans le tableau binaire
        /*
        for(i=0;i<j;i++)
        {
            if(!tab2[i])
            {
                // remove(tab[i]);
                printf("le fichier \"%s\" doit est effacer\n",tab[i]);
            }
        }
        */
    }
    return 0;
}
