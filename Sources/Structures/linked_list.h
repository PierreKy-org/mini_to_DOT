typedef struct node {
    int val;
    char* type;
    struct node * next;
} node_t;

void print_list(node_t * head);
void push(node_t * head, int val, char* type);
int remove_by_index(node_t ** head, int n);
int pop(node_t ** head);
node_t* makeLinkedList(int val, char* type);