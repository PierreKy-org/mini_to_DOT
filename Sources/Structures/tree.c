#include <stdio.h>
#include <stdlib.h>
#include "tree.h"

tree_dot_t* makeTreeNode(char* shape, char* style, char* color, tree_dot_t* pere){
    tree_dot_t * head = NULL;
    head = (tree_dot_t *) malloc(sizeof(tree_dot_t));
    head->shape = shape;
    head->style = style;
    head->color = color;
    if(pere != NULL){
        head->pere = malloc(sizeof(tree_dot_t));
        head->pere = pere;
    }
    else 
    {
        head->pere = NULL;
    }
    
    return head;
}


char* readTree(tree_dot_t* tree, char* nom, char* label){
    char* result = (char*) malloc(sizeof(char) *75);
    strcat(result, nom);
    strcat(result, "[shape=");
    strcat(result, tree->shape);
    strcat(result, " label=\"");
    strcat(result, label);
    strcat(result, "\" style=");
    strcat(result, tree->style);
    strcat(result, " color=");
    strcat(result, tree->color);
    strcat(result, "]");
    
    return result;
}

char* link_tree(char* father, char* child){
    char* result = (char*) malloc(sizeof(child) + sizeof(father) + 400);
    strcat(result, father);
    strcat(result, " -> ");
    strcat(result, child);
    return result;
}