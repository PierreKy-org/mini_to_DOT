#include "linked_list.c"

int hash_function(int key);

node_t search(node_t* tab,int key);

void insert(node_t* tab,int key,node_t* data);


void display(node_t* tab);

node_t* makeTab();