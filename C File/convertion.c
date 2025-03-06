#include <stdio.h>
#include <stdlib.h>
#define default 1024

void convert(double unit)
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
                    printf("%.2lf tera-octet",unit);
                }
                else printf("%.2lf giga-octet",unit);
            }
            else printf("%.2lf mega-octet",unit);
        }
        else printf("%.2lf kilo-octet",unit);
    }
    else printf("%.2lf octet",unit);
}

void scanfd(double *nbr)
{
    double entier;int i,j,negation=0;
        char *integer = (char *) malloc( sizeof(char)*1001 );
        /*Verifier a la ligne s'il ya un entier si non resaisir*/
        do
        {
            fgets(integer,1000,stdin);
            for (i = 0;(integer[i]<'0'|| integer[i] >'9'); i++)
            if (!integer[i]) break;

            for (j = 0;integer[j];j++);
                if (i==j)
                {
                    printf("(warning) : Il n'y a pas d'entier a la ligne; resaisir : ");
                }
        }while(i==j);
        /*Remplacer le caractere retour a la ligne par le caractere de fin de chaine*/
        for(i=0;i<1000;i++)
            if(integer[i]=='\n') integer[i] ='\0';
        j=0;
        /*Verifier si la chaine comport un signe de negation*/
        for(i=0;integer[i];i++)
        {
            if(integer[i]=='-')
            {
                negation=1; break;
            }
        }
        /*Ranger dans la chaine les caracteres entier au debut*/
        for(i=0;integer[i];i++)
        {
            integer[j]=integer[i];
            if(!(integer[i]<'0'|| integer[i]>'9'))
                j++;
        }
        /*Effacer les caracteres non entier a la fin de la chaine*/
        integer[j]='\0';
        /*convertion du tableau de caractere en entier*/
        entier = atof(integer);
        /*affectation du resultat a la variable entrer en parametre*/
        if(negation) entier*=-negation;
        *nbr=entier;
    /*Liberer la memoir du tableau*/
    free(integer);
    /*Vider la memoire tampon*/
    fflush(stdin);
}

int main()
{
    double taille=0;
    // printf("Entrer une taille en octet a convertir : ");
    // scanf("%lf",&taille);
    // long tailleI;
    // scanfl(&tailleI); taille=(double)tailleI;
    scanfd(&taille);
    // printf("taille : %lf\n",taille);
    convert(taille);
}
