compiler :	lex.yy.c miniC.tab.c
	@gcc lex.yy.c miniC.tab.c -o compiler -ll 
	@echo "Un compilateur a été créé : compiler"
	
miniC.tab.c : 
	@bison  -vd miniC.y

lex.yy.c :	ANSI-C.l
	@flex ANSI-C.l

clean :
	@rm lex.yy.c miniC.tab.c miniC.tab.h compiler *.output
	@echo "Suppression des fichiers effectuée."

run  :
	@echo "===============================\nTest du fichier add.c :\n"
	@pwd
	@./compiler < ../Tests/add.c

	@echo "===============================\nTest du fichier break.c :\n"
	@./compiler < ../Tests/break.c

	@echo "===============================\nTest du fichier compteur.c :\n"
	@./compiler < ../Tests/compteur.c

	@echo "===============================\nTest du fichier cond.c :\n"
	@./compiler < ../Tests/cond.c

	@echo "===============================\nTest du fichier div.c :\n"
	@./compiler < ../Tests/div.c

	@echo "===============================\nTest du fichier expr.c :\n"
	@./compiler < ../Tests/expr.c

	@echo "===============================\nTest du fichier functions.c :\n"
	@./compiler < ../Tests/functions.c
	
	@echo "===============================\nTest du fichier loops.c :\n"
	@./compiler < ../Tests/loops.c
	
	@echo "===============================\nTest du fichier mul.c :\n"
	@./compiler < ../Tests/mul.c
	
	@echo "===============================\nTest du fichier neg.c :\n"
	@./compiler < ../Tests/neg.c
	
	@echo "===============================\nTest du fichier rsh.c :\n"
	@./compiler < ../Tests/rsh.c

	@echo "===============================\nTest du fichier sub.c :\n"
	@./compiler < ../Tests/sub.c

	@echo "===============================\nTest du fichier switch.c :\n"
	@./compiler < ../Tests/switch.c

	@echo "===============================\nTest du fichier tableaux.c :\n"
	@./compiler < ../Tests/tableaux.c

	@echo "===============================\nTest du fichier tableaux-multi.c :\n"
	@./compiler < ../Tests/tableaux-multi.c

	@echo "===============================\nTest du fichier variables.c :\n"
	@./compiler < ../Tests/variables.c