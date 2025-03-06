#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#define default 1024


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

void size(char *addr)
{
	FILE *fichier;
	long size; double size_d;
	char *size_c=(char *) malloc(sizeof(char)*30);

	fichier=fopen(addr,"rb");

	if (fichier)
	{
		fseek(fichier,0,SEEK_END);
		size=ftell(fichier);
		fclose(fichier);
		size_d=(double)size;
		convert(size_d,size_c);
		printf("\tsize : %s",size_c);
		free(size_c);
	}
	else
	{
		printf(" it's not a file\n");
		exit(0);
	}
}

int main(int argc, char const *argv[])
{
	char *nom_fich=(char *) malloc(sizeof(char)*50);
	// scanf("%s",nom_fich);
	scanfs_mod(nom_fich,50);
	size(nom_fich);
	free(nom_fich);
	return 0;
}