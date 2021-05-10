#include "linked_list.c"
struct DataItem {
   node_t* data;   
   int key;
} tab;

int hash_function(int key);

struct DataItem *search(int key);

void insert(int key,node_t* data);

struct DataItem *delete(struct DataItem* item);

void display();