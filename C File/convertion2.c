#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
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
//humm

void IniTab_C(char *tab, int taille)
{
    int i;
    for(i=0;i<taille;i++)
        tab[i]=0;
}

double affiche(int a, int b, char *chaine)
{
    char *chaine2=(char *) malloc(sizeof(char)*((b-a)+2));
    IniTab_C(chaine2,((b-a)+2));
    int i; int f=0;
    for (i=a; i <=b; i++)
    {
        // printf("%c",chaine[i]);
        chaine2[f]=chaine[i];
        f++;
    }
    // printf("%s\n",chaine2);
    double entier = atof(chaine2);
    // printf("voici l'entier en double %1f\n",entier);
    free(chaine2);
    // printf("\n");
    return entier;
}

void bizard(int tab[], int g, char *chaine, double tab2[])
{
    int i,p=0;
    for (i = 0; i < g; i++)
    {
        // printf("%d\n",tab[i]);
        if (i==0){
            // printf("%d a %d\n",tab[i],tab[i+1]); printf("%d\n",p);
            tab2[p]=affiche(tab[i],tab[i+1],chaine); p++;
        }
        else {
            // printf("%d a %d\n",tab[i]+2,tab[i+1]); printf("%d\n",p);
            tab2[p]=affiche(tab[i]+2,tab[i+1],chaine); p++;
        }
    }
    // printf("il ya donc %d nombre\n",p);
}

double traiter(char *chaine)
{
    // printf("%s\n",chaine);
    int i; int a=0;
    for (i = 0; chaine[i]; i++)
    {
        if(chaine[i]=='+') a++;
    }
    int b=a+1;
    // printf("il ya %d + dans la chaine donc il ya %d nombre\n",a,b);
    int tab[a+2],c=1; tab[0]=0; tab[a+1]=strlen(chaine)-1;
    for (i = 0; chaine[i]; i++)
    {
        if (chaine[i]=='+')
        {
            tab[c]=i-1; c++;
        }
    }
    // printf("il ya plus au emplacement\n");
/*    for (i = 0; i < a+2; i++)
    {
        printf("%d\n",tab[i]);
    }*/
    double tab2[b],sum=0;
    bizard(tab,(a+1),chaine,tab2);
    // printf("\n\ndonc les entiers sont successivement\n");
    for(i=0;i<b;i++)
    {
        // printf("\t%1f",tab2[i]);
        sum+=tab2[i];
    }
    // printf("\nLa somme total fais %1f\n",sum);
    return sum;
}

//humm
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
/*        for(i=0;integer[i];i++)
        {
            integer[j]=integer[i];
            if(!(integer[i]<'0'|| integer[i]>'9'))
                j++;
        }*/
        entier=traiter(integer); //ici
        // printf("%s\n",integer);
        /*Effacer les caracteres non entier a la fin de la chaine*/
        // integer[j]='\0';
        /*convertion du tableau de caractere en entier*/
        // entier = atof(integer);
        /*affectation du resultat a la variable entrer en parametre*/
        // if(negation) entier*=-negation;
         *nbr=entier;
    /*Liberer la memoir du tableau*/
    free(integer);
    /*Vider la memoire tampon*/
    fflush(stdin);
    // return entier;
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
