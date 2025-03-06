#include <stdio.h>
#include <stdio.h>
#include <conio.h>
#include <windows.h>

int main(int argc, char const *argv[])
{
	HANDLE console_IN,console_OUT;
	console_OUT=GetStdHandle(STD_OUTPUT_HANDLE);
	console_IN=GetStdHandle(STD_INPUT_HANDLE);
	/*int i;
	for(i=0;i<16;i++)
	{
		SetConsoleTextAttribute(console_OUT,i);
		printf("Couleur\n");
	}*/
	int col; scanf("%d",&col);
	SetConsoleTextAttribute(console_OUT,col);
	return 0;
}