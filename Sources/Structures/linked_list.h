typedef struct node {
    char* val;
    char* type;
    char * iden;
    struct node * next;
} node_t;

void print_list(node_t * head);
void push(node_t * head, char* val, char* type, char* iden);
int remove_by_index(node_t ** head, int n);
int pop(node_t ** head);
node_t* makeLinkedList(char* val, char* type,char* iden);