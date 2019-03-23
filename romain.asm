# AUTEURS: Raphael Aubin, raphael.aubin@umontreal.ca, p0803846, AUBR18098608
#	   David Raby-Pepin, david.raby-pepin@umontreal.ca, p0918119, RABD15018902
#
# DATE: 28 mars 2019
#
# BUT: Ecrire un programme qui fait la conversion d'un nombre entier entre 1 et 3999 entré par l’utilisateur
#      en un texte correspondant à la numération romaine de ce nombre et qui affiche ce texte a la console.
#
# DESCRIPTION: Le programme contient 4 fonctions: 
#		1)Main: fonction demande a l'utilisateur d'entrer un nombre à encoder à partir d'un appel systeme,
#		verifie la valididte de l'entree, appelle la fonction "romain" afin de convertir le nombre en
#		nombre romain et affiche le resultat a la console.		 
# 		2)Romain: fonction qui prends en entree le nombre numerique, initialise l'adresse ou placer le
#		texte romain et boucle a travers les 4 ordres de grandeur en appellant la fonction "chiffre".
#		3)Chiffre: fonction qui prend en entrees le nombre à encoder, le rang du chiffre à encoder,
#		l’adresse d'un symbole d’encodage romain et l'adresse ou placer le résultat. La fonction encode
#		un seul chiffre du nombre decimal en romain et fait appel a la fonction "repeter" pour les cas
#		ou plusieurs chiffres romains se repetent.
#		4)Repeter: fonction qui prend en entrees un nombre de répétitions, l’adresse d'un symbole
#		d’encodage romain et l'adresse ou placer le résultat. La fonction enregistre un meme chiffre romain
#		le nombre de fois requises et retourne une adresse mise a jour ou placer le résultat.
#


# segment de la mémoire contenant les données globales
.data
# tampon résérvé pour une chaîne encodée
buffer: .space 30
I: .ascii "I"
V: .ascii "V"
X: .ascii "X"
L: .ascii "L"
C: .ascii "C"
D: .ascii "D"
M: .ascii "M"
msg: .asciiz  "Veuillez entrer un nombre entier entre 1 et 3999: "
inval: .asciiz  "Le nombre entré est invalide."


# segment de la mémoire contenant le code
.text
main:
	j	msgout		# sauter le message d'erreur
	
	# message d'erreur si l'entree est invalide
erreur:	la 	$a0,inval	# mettre le string contenu dans inval dans $a0
	li 	$v0,4 		# instruction print string (Code 4 de syscall)
	syscall 		# faire appel a syscall pour imprimer le message
	j	fini		# terminer le programme
	
	
msgout:	la 	$a0,msg		# mettre le string contenu dans msg dans $a0
	li 	$v0,4 		# instruction print string (Code 4 de syscall)
	syscall 		# faire appel a syscall pour imprimer le message

	li 	$v0,5 		# instruction read integer (lire nombre entre par utilisateur)
	syscall 		# faire appel a syscall pour lire le nombre entre par l'utilisateur

	# si le nombre entre par l'utilisateur est plus grand que 3999, lui redemander un autre nombre
	addi	$t0,$0,1	# stocker 1 dans $t0
	addi 	$t1,$0,4000	# stocker le nombre 4000 dans $t0
	slt	$t2,$v0,$t1	# verifier si le nombre entre (dans $v0) est plus petit que 4000
	bne	$t2,$t0,erreur	# redemander un autre nombre si $v0!<4000

	# si le nombre entre par l'utilisateur est plus petit que 1, lui redemander un autre nombre
	slt	$t2,$v0,$t0	# verifier si le nombre entre (dans $v0) est plus petit que 1
	beq	$t2,$t0,erreur	# redemander un autre nombre si $v0<1

	move 	$a0,$v0		# mettre le contenu de $v0 dans $a0
	jal 	romain		# appeler la fonction romain
	
	# imprimer le nombre romain
	la	$a0,buffer	# mettre le string contenu dans buffer dans $a0
	li 	$v0,4 		# instruction print string (Code 4 de syscall)
	syscall 		
	
	# terminer le programme
fini:	li 	$v0,10 	
	syscall 


# fonction répéter
repeter:
	# empiler
	addi	$sp,$sp,-16 	# faire 4 espaces sur la pile
	sw	$ra,12($sp) 	# stocker $ra sur la pile
	sw	$a0,8($sp) 	# stocker $a0 sur la pile
	sw	$a1,4($sp) 	# stocker $a1 sur la pile
	sw	$a2,0($sp) 	# stocker $a2 sur la pile

	# verifier si $a0<1
	addi	$t0,$0,1	# mettre la valeur 1 dans $t0
	slt 	$t1,$a0,$t0	# si le nombre de repetitions est plus petit que 1 $t1=1
	beq  	$t1,$t0,fin1	# si le nombre de repetitions est plus petit que 1, aller immediatement a la fin
	
	# si $a0>=1, faire la boucle
loop1:	lb 	$t2,($a1)	# stocker le symbole d’encodage (I, X ou C) dans $t2
	sb 	$t2,($a2)	# stocker le symbole d’encodage (I, X ou C) dans l'adresse actuelle dans buffer
	la	$a2,1($a2)	# passer a la prochaine case memoire dans buffer
	addi	$a0,$a0,-1	# decrementer le nombre de repetitions de 1	
	slt 	$t1,$a0,$t0	# si le nombre de repetitions est plus petit que 1 $t1=1
	bne  	$t1,$t0,loop1	# si le nombre de repetitions n'est pas plus petit que 1, refaire la boucle

fin1:	move	$v0,$a2		# retourner la case memoire actuelle dans buffer
	
	# depiler
	lw	$a2, 0($sp) 	# restaurer $a2 de la pile
	lw	$a1, 4($sp) 	# restaurer $a1 de la pile
	lw	$a0, 8($sp) 	# restaurer $a0 de la pile
	lw	$ra, 12($sp) 	# restaurer $ra de la pile
	addi	$sp, $sp, 16	# depiler de 4 espaces
	
	jr	$ra
	
	
# fonction chiffre
chiffre:
	# empiler
	addi	$sp,$sp,-24 	# faire 6 espaces sur la pile
	sw	$ra,20($sp) 	# stocker $ra sur la pile
	sw	$a0,16($sp) 	# stocker $a0 sur la pile
	sw	$a1,12($sp) 	# stocker $a1 sur la pile
	sw	$a2,8($sp) 	# stocker $a2 sur la pile
	sw	$a3,4($sp) 	# stocker $a3 sur la pile
	sw	$s0,0($sp) 	# stocker $s0 sur la pile

	# obtenir le chiffre au rang desire
	div 	$a0,$a1		# diviser le nombre entre par l'utilisateur par le rand du chiffre
	mflo	$t0		# mettre le quotien de la divison dans $t0
	
	addi	$t1,$0,10	# stocker 10 dans $t1
	div	$t0,$t1		# diviser le quotien precedent par 10
	mfhi 	$a0		# garder le reste de la division, c'est le chiffre qu'on veut isoler
	
	# si le chiffre est entre 0 et 3, utiliser la fonction reperter
	addi	$t0,$0,4	# mettre la valeur 4 dans $t0
	slt 	$t1,$a0,$t0	# si le chiffre est plus petit que 4 $t1=1
	addi	$t0,$0,1	# mettre la valeur 1 dans $t0
	bne 	$t1,$t0,cas2	# si le chiffre n'est pas plus petit que 4, aller immediatement au cas 2
	
	move	$a1,$a2		# mettre l'adresse du symbole d’encodage dans $a1
	move	$a2,$a3		# mettre l'adresse actuelle du resultat dans $a2
	
	jal 	repeter		# appeler la fonction repeter
	j	fin		# aller a la fin de la fonction
	
	# si le chiffre est 4
cas2:	addi	$t0,$0,5	# mettre la valeur 5 dans $t0
	slt 	$t1,$a0,$t0	# si le chiffre est plus petit que 5 $t1=1
	addi	$t0,$0,1	# mettre la valeur 1 dans $t0
	bne 	$t1,$t0,cas3	# si le chiffre n'est pas plus petit que 5, aller immediatement au cas 3
	
	lb 	$t0,($a2)	# stocker le symbole d’encodage (I, X ou C) dans $t0
	sb 	$t0,($a3)	# stocker le symbole d’encodage (I, X ou C) dans l'adresse actuelle dans buffer
	la	$a3,1($a3)	# passer a la prochaine case memoire dans buffer
	la	$a2,1($a2)	# passer au prochain symbole d’encodage (V, L, D)
	lb 	$t0,($a2)	# stocker le symbole d’encodage (V, L, D) dans $t0
	sb 	$t0,($a3)	# stocker le symbole d’encodage (V, L, D) dans l'adresse actuelle dans buffer
	la	$a3,1($a3)	# passer a la prochaine case memoire dans buffer
	
	move	$v0,$a3		# retourner la case memoire actuelle dans buffer
	j	fin		#aller a la fin de la fonction
	
	# si le chiffre est entre 5 et 8, utiliser la fonction reperter	
cas3:	addi	$t0,$0,9	# mettre la valeur 9 dans $t0
	slt 	$t1,$a0,$t0	# si le chiffre est plus petit que 9 $t1=1
	addi	$t0,$0,1	# mettre la valeur 1 dans $t0
	bne 	$t1,$t0,cas4	# si le chiffre n'est pas plus petit que 9, aller immediatement au cas 4
	
	la	$a2,1($a2)	# passer au prochain symbole d’encodage (V, L, D)
	lb 	$t0,($a2)	# stocker le symbole d’encodage (V, L, D) dans $t0
	sb 	$t0,($a3)	# stocker le symbole d’encodage (V, L, D) dans l'adresse actuelle dans buffer
	la	$a3,1($a3)	# passer a la prochaine case memoire dans buffer
	
	la	$a2,-1($a2)	# revenir au symbole d’encodage precedent (I, X ou C)
	move	$a1,$a2		# mettre l'adresse du symbole d’encodage dans $a1
	move	$a2,$a3		# mettre l'adresse actuelle du resultat dans $a2
	
	addi	$a0,$a0,-5	# enlever 5 au chiffre afin d'obtenir le nombre de repetitions
	jal 	repeter		# appeler la fonction repeter
	j	fin		#aller a la fin de la fonction
	
	# si le chiffre est 9	
cas4:	lb 	$t0,($a2)	# stocker le symbole d’encodage (I, X ou C) dans $t0
	sb 	$t0,($a3)	# stocker le symbole d’encodage (I, X ou C) dans l'adresse actuelle dans buffer
	la	$a3,1($a3)	# passer a la prochaine case memoire dans buffer
	la	$a2,2($a2)	# passer au prochain rang de symbole d’encodage (X, C, M)
	lb 	$t0,($a2)	# stocker le symbole d’encodage (X, C, M) dans $t0
	sb 	$t0,($a3)	# stocker le symbole d’encodage (X, C, M) dans l'adresse actuelle dans buffer
	la	$a3,1($a3)	# passer a la prochaine case memoire dans buffer
	
	move	$v0,$a3		# retourner la case memoire actuelle dans buffer

	# depiler
fin:	lw	$s0, 0($sp) 	# restaurer $s0 de la pile
	lw	$a3, 4($sp) 	# restaurer $a3 de la pile
	lw	$a2, 8($sp) 	# restaurer $a2 de la pile
	lw	$a1, 12($sp) 	# restaurer $a1 de la pile
	lw	$a0, 16($sp) 	# restaurer $a0 de la pile
	lw	$ra, 20($sp) 	# restaurer $ra de la pile
	addi	$sp, $sp, 24	# depiler de 6 espaces
	
	jr	$ra


# fonction romain
romain:	
	# empiler
	addi	$sp,$sp,-8 	# faire 2 espaces sur la pile
	sw	$ra,4($sp) 	# stocker $ra sur la pile
	sw	$a0,0($sp) 	# stocker $a0 sur la pile
	
	# preparer les arguments a donner a la fonction chiffre
	addi	$s0,$0,10 	# stocker 10 dans $s0
	addi	$a1,$0,1000 	# stocker 1000 dans $a1
	la 	$a2,M		# mettre l'adresse de M dans $a2
	la 	$a3,buffer	# mettre l'adresse de buffer dans $a3
	
	# boucle qui appelle la fonction chiffre et met a jour les arguments
loop2:	jal 	chiffre
	div	$a1,$a1,$s0	# passer au procahin rang de chiffre
	la	$a2,-2($a2)	# passer a l'adresse du symbole pour le nouveau rang
	move	$a3,$v0		# placer l'adresse du resultat mis-a-jour dans $a3
	
	addi	$t0,$0,1	# stocker 1 dans $t0
	slt	$t1,$a1,$t0	# verifier si le contenu de $a1 est plus petit que 1
	bne 	$t1,$t0,loop2	# sortir de la boucle si $a1<1
	
	# depiler
	lw	$a0, 0($sp) 	# restaurer $a0 de la pile
	lw	$ra, 4($sp) 	# restaurer $ra de la pile
	addi	$sp, $sp, 8	# depiler de 2 espaces
	
	jr	$ra
