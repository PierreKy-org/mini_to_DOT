#include "hash_tab.c"
struct stack
{
    int maxsize;    // define max capacity of the stack
    int top;
    node_t** items;
};
struct stack* newStack(int capacity);
int stack_size(struct stack *pt);
int stack_isEmpty(struct stack *pt);
int stack_isFull(struct stack *pt);
void stack_push(struct stack *pt, node_t* t);
node_t* stack_peek(struct stack *pt);
node_t* stack_pop(struct stack *pt);

