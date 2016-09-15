#include <stdio.h>
#include <time.h>
#include <stdlib.h>

char pipe_stdin_ch;
char pipe_stdin_str [20];
int d;

void print_string(){

    int i;
    //srand((unsigned int)(time(NULL)));
    for (i = 0;i<1024;i++){
        //printf("%d\n",i+(rand()>>13));
        printf("%d\n",i+d);
    }
}


int main(){

    while(1)
    {
//        fflush(stdin);              //Only care the first character of the string
//        pipe_stdin_ch = getchar();
          gets(pipe_stdin_str);


//        switch (pipe_stdin_ch){
        switch (pipe_stdin_str[0]){
            case 's': d++;print_string(); break;
            case 'b': printf("Input b!"); break;

            default : printf("Default!");//\r .\n
        }

     //   printf("\n");
        fflush(stdout);
    }

    return 0;
}


