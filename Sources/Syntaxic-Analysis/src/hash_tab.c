#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "hash_tab.h"
#define SIZE 103
#define CAPACITY 50000 // Size of the Hash Table


 
int hash_function(int key) {
   return key % SIZE;
}

node_t search(node_t* tab,int key) {
   //get the hash 
   int hashIndex = hash_function(key);  
	int i =0; 
   //move in array until an empty 
   while(tab[i].val != NULL) {
	
      if(i == hashIndex)
         return tab[i]; 
			
      //go to next cell
      ++i;
		
      //wrap around the table
      i %= SIZE;
   }        
	node_t t;
   t.val = NULL;
   t.next = NULL;
   t.type = NULL;
   return t ;        
}

void insert(node_t* tab,int key,node_t* data) {

   //get the hash 
   int hashIndex = hash_function(key);
   //move in array until an empty or deleted cell
   while(tab[hashIndex].val != NULL && hashIndex != 99) {
      //go to next cell
      ++hashIndex;
		
      //wrap around the table
      hashIndex %= SIZE;
   }
	
   tab[hashIndex] = *data;
}

 

void display(node_t* tab) {
   int i = 0;
	
   for(i = 0; i<SIZE; i++) {
	
      if(tab[i].val != NULL){
         printf(" (%d,%s,%d)",i,tab[i].type,tab[i].val);
         
         //La valeur du deuxieme element de la liste chainée
         if(tab[i].next != NULL){
            printf("lol");
            printf(" (%d,%s,%d)",i,tab[i].next->type,tab[i].next->val);
         }
      }
      else
         printf(" ~~ ");
   }
	
   printf("\n\n");
}

 node_t* makeTab(){
   node_t* tab =  malloc(sizeof(node_t) * SIZE);
   return tab;
}