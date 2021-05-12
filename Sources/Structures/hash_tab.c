#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "hash_tab.h"
#define SIZE 103
#define CAPACITY 50000 // Size of the Hash Table


 
int hash_function( char *nom ) {
   int i, r;
   int taille = strlen(nom);
   r = 0;
   for ( i = 0; i < taille; i++ )
      r = ((r << 8) + nom[i]) % SIZE;
   return r;
}


node_t* search(node_t* tab, char* iden) {
   //get the hash 
   int hashIndex = hash_function(iden);  
   node_t* s = &tab[hashIndex];
   //move in array until an empty 
   while(s->type != NULL) {
	
      if(strcmp( s->iden, iden ) == 0)
         return s; 
      s = s->next;
		
   }        
	node_t t;
   t.val = NULL;
   t.next = NULL;
   t.type = NULL;
   return &t ;        
}

node_t* insert(node_t* tab,node_t* data) {

   int hashIndex = hash_function(data->iden);
   node_t* s = &tab[hashIndex];
   node_t* precedent = malloc(sizeof(node_t));
   while(s->val != NULL) {
      if (strcmp( s->iden, data->iden ) == 0)
         return s;
		precedent = s;
      if(s->next == NULL){
         s->next = (node_t *) malloc(sizeof(node_t));
      }
      s = s->next;
   }
   if ( precedent->val == NULL ) {
      tab[hashIndex] = *data;
      return &tab[hashIndex];
   }else{
      push(precedent, data->val, data->type, data->iden);
      return precedent->next;
   }

}

 

void display(node_t* tab) {
   int i = 0;
	
   for(i = 0; i<SIZE; i++) {
	
      if(tab[i].val != NULL){
         print_list(&tab[i]);
      }
      else
         printf(" ~~ ");
   }
	
   printf("\n\n");
}

 node_t* makeTab(){
   node_t* tab = (node_t *) malloc(sizeof(node_t) * SIZE);
   return tab;
}