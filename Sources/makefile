compiler :	lex.yy.c miniC.tab.c
	@gcc -w lex.yy.c miniC.tab.c -lfl `pkg-config --cflags --libs glib-2.0` -o compiler 
	@echo "Un compilateur a été créé : compiler"
	
miniC.tab.c : 
	@bison -Wnone -vd miniC.y 

lex.yy.c :	ANSI-C.l
	@flex ANSI-C.l


clean :
	@rm lex.yy.c miniC.tab.c miniC.tab.h compiler *.output
	@echo "Suppression des fichiers effectuée."

testCleaning : 
	@rm Resultats/*.dot

run  :
	@echo "===============================\nTest du fichier add.c :\n"
	@./compiler < Tests/add.c add

	@echo "===============================\nTest du fichier break.c :\n"
	@./compiler < Tests/break.c break

	@echo "===============================\nTest du fichier compteur.c :\n"
	@./compiler < Tests/compteur.c compteur

	@echo "===============================\nTest du fichier cond.c :\n"
	@./compiler < Tests/cond.c cond

	@echo "===============================\nTest du fichier div.c :\n"
	@./compiler < Tests/div.c div

	@echo "===============================\nTest du fichier expr.c :\n"
	@./compiler < Tests/expr.c expr

	@echo "===============================\nTest du fichier functions.c :\n"
	@./compiler < Tests/functions.c function
	
	@echo "===============================\nTest du fichier loops.c :\n"
	@./compiler < Tests/loops.c  loops
	
	@echo "===============================\nTest du fichier mul.c :\n"
	@./compiler < Tests/mul.c mul
	
	@echo "===============================\nTest du fichier neg.c :\n"
	@./compiler < Tests/neg.c neg
	
	@echo "===============================\nTest du fichier rsh.c :\n"
	@./compiler < Tests/rsh.c rsh

	@echo "===============================\nTest du fichier sub.c :\n"
	@./compiler < Tests/sub.c sub

	@echo "===============================\nTest du fichier switch.c :\n"
	@./compiler < Tests/switch.c switch

	@echo "===============================\nTest du fichier tableaux.c :\n"
	@./compiler < Tests/tableaux.c tableaux

	@echo "===============================\nTest du fichier tableaux-multi.c :\n"
	@./compiler < Tests/tableaux-multi.c tableaux-multi

	@echo "===============================\nTest du fichier variables.c :\n"
	@./compiler < Tests/variables.c variables