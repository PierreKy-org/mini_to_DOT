#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "Stack.h"


// Utility function to initialize the stack
struct stack* newStack(int capacity) {
    struct stack *pt = (struct stack*)malloc(sizeof(struct stack));
 
    node_t* linked = (node_t*)malloc(sizeof(node_t*) * capacity);
    node_t** ptLinked = (node_t**) malloc(sizeof(linked));
    pt->maxsize = capacity;
    pt->top = -1;
    pt->items =linked;
  
    return pt;
}
 
// Utility function to return the size of the stack
int stack_size(struct stack *pt) {
    return pt->top + 1;
}
 
// Utility function to check if the stack is empty or not
int stack_isEmpty(struct stack *pt) {
    return pt->top == -1;                   // or return size(pt) == 0;
}
 
// Utility function to check if the stack is full or not
int stack_isFull(struct stack *pt) {
    return pt->top == pt->maxsize - 1;      // or return size(pt) == pt->maxsize;
}
 
// Utility function to add an element `x` to the stack
void stack_push(struct stack *pt, node_t *t) {
    // check if the stack is already full. Then inserting an element would
    // lead to stack overflow
    if (stack_isFull(pt))
    {
        printf("Overflow\nProgram Terminated\n");
        exit(EXIT_FAILURE);
    }
 
    // add an element and increment the top's index
    pt->items[++pt->top] = t;
}
 
// Utility function to return the top element of the stack
node_t* stack_peek(struct stack *pt) {
    
    node_t *temp = malloc(sizeof(node_t));

    // check for an empty stack
    if (!stack_isEmpty(pt)) {
        return pt->items[pt->top];
    }
    else {
        exit(EXIT_FAILURE);
    }
}

 
// Utility function to pop a top element from the stack
node_t* stack_pop(struct stack *pt) {
    // check for stack underflow
    if (stack_isEmpty(pt))
    {
        printf("Underflow\nProgram Terminated\n");
        exit(EXIT_FAILURE);
    }
    // decrement stack size by 1 and (optionally) return the popped element
    return pt->items[pt->top--];
}

struct stack* stack_copy(struct stack *pt){
    struct stack *copyPointer = (struct stack*)malloc(sizeof(struct stack));
    *copyPointer = *pt;
    return copyPointer;
}

int stack_search(struct stack *pt, char *iden){
    struct stack *copy = (struct stack*)malloc(sizeof(struct stack));
    copy = stack_copy(pt);

    printf("\n taille stack %d",stack_size(pt));
    printf("\n taille copy %d",stack_size(copy));
    node_t* t = (node_t*)malloc(sizeof(node_t));
    int taille_stack = stack_size(copy);

    for(int i=0; i < taille_stack; i++){

        t = search(stack_peek(copy),iden);
        //On vient de trouver une définition correspondante dans une des tables de la pile
        //On revoit vrai
        if (t!=NULL){
            return 1;
        }
        stack_pop(copy);
    }
    printf("\n DEUXIEME taille stack %d",stack_size(pt));
    printf("\n DEUXIEME taille copy %d",stack_size(copy));
    free(t);
    free(copy);
    //On a parcourut toute la stack mais on pas trouvé ident
    return 0;
}