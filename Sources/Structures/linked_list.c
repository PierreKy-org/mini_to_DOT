#include <stdio.h>
#include <stdlib.h>
#include "linked_list.h"
void print_list(node_t * head) {
    node_t * current = head;

    while (current != NULL) {
        printf("%d, %s\n", current->val, current->type);
        current = current->next;
    }
}


void push(node_t * head, int val, char* type) {
    node_t * current = head;
    while (current->next != NULL) {
        current = current->next;
    }

    /* now we can add a new variable */
    current->next = (node_t *) malloc(sizeof(node_t));
    current->next->val = val;
	current->next->type= type;
    current->next->next = NULL;
}


int pop(node_t ** head) {
    int retval = -1;
    node_t * next_node = NULL;

    if (*head == NULL) {
        return -1;
    }

    next_node = (*head)->next;
    retval = (*head)->val;
    free(*head);
    *head = next_node;

    return retval;
}
 
int remove_by_index(node_t ** head, int n) {
    int i = 0;
    int retval = -1;
    node_t * current = *head;
    node_t * temp_node = NULL;

    if (n == 0) {
        return pop(head);
    }

    for (i = 0; i < n-1; i++) {
        if (current->next == NULL) {
            return -1;
        }
        current = current->next;
    }

    temp_node = current->next;
    retval = temp_node->val;
    current->next = temp_node->next;
    free(temp_node);

    return retval;
}

node_t* makeLinkedList(int val, char* type){
    node_t * head = NULL;
    head = (node_t *) malloc(sizeof(node_t));
    head->val = val;
    head->type = type;
    head->next = NULL;
    return head;
}