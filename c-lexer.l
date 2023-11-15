%option noyywrap

%{
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>

    enum{ELSE, IF, INT, RETURN, VOID, WHILE, ADD, SUB, TIM, DIV, LT, LE, GT, GE, EQ, NEQ, ASOP, SEMCOL, COMMA, LPAR, RPAR, LBRA, RBRA, LCUR, RCUR, COM, ID, STR, NUM};    

    int line_count;

    typedef struct node{
        char lexeme[256];
        char token[16];
        char attribute[32];
        struct node * next;
    }node;

    typedef struct list{
        node * head;
        node * last_created;
    }list;

    node * search_node(list*curr_list, char*lexeme);

    node * new_node(list*curr_list, char*lexem, char*tok, char*attr);
    
    void write_list(list*curr_list);

    void write_as_input(list*curr_list);

    list * my_list;

%}

letter [a-zA-Z]
digit [0-9]

%%

"else"              {new_node(my_list, yytext, "else", "ELSE");}
"if"                {new_node(my_list, yytext, "if", "IF");}
"int"               {new_node(my_list, yytext, "int", "INT");}
"return"            {new_node(my_list, yytext, "return", "RETURN");}
"void"              {new_node(my_list, yytext, "void", "VOID");}
"while"             {new_node(my_list, yytext, "while", "WHILE");}
"+"                 {new_node(my_list, yytext, "mat", "ADD");}
"-"                 {new_node(my_list, yytext, "mat", "SUB");}
"*"                 {new_node(my_list, yytext, "mat", "TIM");}
\n                  {line_count++;}
"//".*\n            {;}
"/"                 {new_node(my_list, yytext, "mat", "DIV");}
"<"                 {new_node(my_list, yytext, "relop", "LT");}
"<="                {new_node(my_list, yytext, "relop", "LE");}
">"                 {new_node(my_list, yytext, "relop", "GT");}
">="                {new_node(my_list, yytext, "relop", "GE");}
"=="                {new_node(my_list, yytext, "relop", "EQ");}   
"!="                {new_node(my_list, yytext, "relop", "NEQ");}
"="                 {new_node(my_list, yytext, "asop", "ASOP");}
";"                 {new_node(my_list, yytext, "semcol", "SEMCOL");}
","                 {new_node(my_list, yytext, "comma", "COMMA");}
"("                 {new_node(my_list, yytext, "lpar", "LPAR");}
")"                 {new_node(my_list, yytext, "rpar", "RPAR");}
"["                 {new_node(my_list, yytext, "lbra", "LBRA");}
"]"                 {new_node(my_list, yytext, "rbra", "RBRA");}
"{"                 {new_node(my_list, yytext, "lcur", "LCUR");}
"}"                 {new_node(my_list, yytext, "rcur", "RCUR");}
"/*"(.|\n)*"*/"     {;}
"/*"(.|\n)*         {;}
{digit}+            {new_node(my_list, yytext, "num", "NUM");}
{letter}+           {new_node(my_list, yytext, "id", "ID");}
<<EOF>>             {yyterminate();}
.                   {;}


%%

//TODO: Token List, Symbol Table

list * create_list(){
    list * new_list = (list *)malloc(sizeof(list));
    new_list->head = NULL;
    new_list->last_created = NULL;
    return new_list;
}

/*node * search_node(list*curr_list, char*lexem){
    node * checker = curr_list->head;
    while(checker != NULL){
        if(strcmp(checker->lexeme, lexem)==0){
            return checker;
        }
        checker = checker->next;
    }
    return NULL;
}*/

node * new_node(list * curr_list, char*lexem, char*tok, char*attr){
    if(curr_list->last_created != NULL){
        node * refer = curr_list->last_created;
        refer->next = (node *)malloc(sizeof(node));
        refer = refer->next;
        curr_list->last_created = refer;
        strcpy(refer->lexeme, lexem);
        strcpy(refer->token, tok);
        strcpy(refer->attribute, attr);
        refer->next = NULL;
        return refer;
    }
    else{
        curr_list->head = (node *)malloc(sizeof(node));
        curr_list->last_created = curr_list->head;
        node * refer = curr_list->last_created;
        strcpy(refer->lexeme, lexem);
        strcpy(refer->token, tok);
        strcpy(refer->attribute, attr);
        refer->next = NULL;
        return refer;
    }
}

void write_list(list*curr_list){
    node * writer = curr_list->head;
    printf("Tokens are in inputed order:\n");
    while(writer != NULL){
        printf("%s | %s | %s\n", writer->lexeme, writer->token, writer->attribute);
        writer=writer->next;
    }
    printf("-----------------------------\n");
}

void write_as_input(list*curr_list){
    node * writer = curr_list->head;
    while(writer != NULL){
        printf("%s", writer->lexeme);
        writer=writer->next;
    }
}

int main(int argc,char *argv[]){
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (!file) {
        printf("Could not open file: %s\n", argv[1]);
        return 1;
    }

    my_list = create_list();

    yyin = file;
    yylex();
    write_list(my_list);

    fclose(file);
    return 0;
}