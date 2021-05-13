#include "tree.c"
typedef struct node {
    char* val;
    char* type;
    char * iden;
    struct node * next;
} node_t;

typedef struct tree_node_linked{
    struct tree_dot_t* current_node;
    struct tree_node_linked* next;
}tree_node_linked_t;

void print_list(node_t * head);
void push(node_t * head, char* val, char* type, char* iden);
int remove_by_index(node_t ** head, int n);
int pop(node_t ** head);
node_t* makeLinkedList(char* val, char* type,char* iden);

void pushTreeNode(tree_node_linked_t *head, tree_dot_t *nodeToPush);