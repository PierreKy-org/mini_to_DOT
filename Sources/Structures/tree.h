typedef struct tree_dot {
    char* shape ;
    char* style ;
    char* color ;
    struct tree_dot* pere;
} tree_dot_t ;

tree_dot_t* makeTreeNode(char* shape, char* style, char* color, tree_dot_t* pere);
char* readTree(tree_dot_t* tree, char* nom, char* label);
char* link_tree(char* father, char* child);