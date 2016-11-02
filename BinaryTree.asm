#### Binary Tree in Assembly Language
#### Jacob Danks

.data
buffer:		.space 4
println:	.asciiz "\n"
CMD:		.asciiz "Input command (I,P,D,Q): "
input:		.asciiz "Input inputeger: "
already:	.asciiz "That value is already in the tree.\n"
not_in_tree_msg:.asciiz "That value is not in the tree.\n"
empty_tree_msg:	.asciiz "The tree is empty.\n"
error:		.asciiz "Please input a valid command.\n"
ERRORMEM_MSG:	.asciiz "Out of memory!\n"

.text
#######################   SET UP THE ROOT   #######################
move $s0, $zero		# ROOT POINTER IS NULL
move $s7, $zero		# $s7 IS A FLAG -> 0 = EMPTY TREE

#########################   INPUT LOOP   #########################
input_loop:
li $v0, 4		# SYSCALL TO PRINT A STRING
la $a0, CMD		# ADDRESS OF STRING TO PRINT
syscall			# PRINT "INPUT A COMMAND (I, P, D, Q)"
li $v0, 8		# SYSCALL TO READ A STRING
la $a0, buffer		# ADDRESS OF BUFFER
li $a1, 4		# NUMBER OF CHARS TO READ
syscall			# READ THE STRING

lb $t1, 0($a0)			# READ THE INPUT COMMAND
li $t4, 'D'			# 'D' = DELETE
li $t5, 'I'			# 'I' = INSERT
li $t6, 'P'			# 'P' = PRINT
li $t7, 'Q'			# 'Q' = QUIT
beq $t1, $t4, input_integer	# INPUT INTEGER TO DELETE
beq $t1, $t5, input_integer	# INPUT INTEGER TO INSERT
beq $t1, $t6, print_input	# PRINT THE TREE
beq $t1, $t7, exit		# EXIT THE PROGRAM
b err				# ERROR MESSAGE IF NOT A VALID COMMAND

########################   INPUT INTEGER   #############################
input_integer:
li $v0, 4		# SYSCALL TO PRINT A STRING
la $a0, input		# ADDRESS OF STRING TO PRINT
syscall			# PRINT "INPUT INTEGER"
li $v0, 5		# SYSCALL TO READ INTEGER
syscall			# READ THE INPUT
move $t2, $v0		# MOVE INPUT TO TEMP REGISTER
beq $t1, $t4, delete	# CONTINUE TO DELETE FUNCTION
beq $t1, $t5, insert	# CONTINUE TO INSERT FUNCTION

########################   DELETE   ################
delete:
lw $t1, 0($s0)			# $t1 IS THE VALUE OF THE ROOT
beq $t2, $t1, delete_root	# IF INPUT = ROOT VALUE, DELETE THE ROOT
move $t0, $s0			# $t0 IS THE CURRENT NODE
blt $t2, $t1, look_left		# IF INPUT < CURRENT NODE VALUE, LOOK LEFT
b look_right			# IF INPUT > CURRENT NODE VALUE, LOOK RIGHT

look_left:
lw $t3, 4($t0)			# $t3 = LEFT CHILD ADDRESS
beqz $t3, not_in_tree		# IF INPUT < CURRENT VALUE AND NO LEFT CHILD, NOT IN TREE
lw $t4, 0($t3)			# $t4 = LEFT CHILD VALUE
beq $t2, $t4, delete_left	# IF INPUT = LEFT CHILD VALUE, DELETE LEFT
lw $t0, 4($t0)			# CURRENT NODE = LEFT CHILD ADDRESS
blt $t2, $t4, look_left		# IF INPUT < LEFT CHILD VALUE, LOOK LEFT
b look_right			# IF INPUT > LEFT CHILD VALUE, LOOK RIGHT

look_right:
lw $t3, 8($t0)			# $t3 = RIGHT CHILD ADDRESS
beqz $t3, not_in_tree		# IF INPUT > CURRENT VALUE AND NO RIGHT CHILD, NOT IN TREE
lw $t4, 0($t3)			# $t4 = RIGHT CHILD VALUE
beq $t2, $t4, delete_right	# IF INPUT = RIGHT CHILD VALUE, DELETE RIGHT
lw $t0, 8($t0)			# CURRENT NODE = RIGHT CHILD ADDRESS
blt $t2, $t4, look_left		# IF INPUT < RIGHT CHILD VALUE, LOOK LEFT
b look_right			# IF INPUT > RIGHT CHILD VALUE, LOOK RIGHT

delete_left:
la $t7, 4($t0)			# $t7 = DELETE NODE'S PARENT'S LEFT CHILD FIELD
lw $t0, 4($t0)			# CURRENT NODE = LEFT CHILD ADDRESS
lw $t6, 4($t0)			# $t6 = DELETE NODE'S LEFT CHILD ADDRESS
sw $t6, ($t7)			# PARENT'S LEFT CHILD IS NOW DELETE NODE'S LEFT CHILD
b delete_finish

delete_right:
la $t7, 8($t0)			# $t7 = DELETE NODE'S PARENT'S RIGHT CHILD FIELD
lw $t0, 8($t0)			# CURRENT NODE = RIGHT CHILD ADDRESS
lw $t6, 4($t0)			# $t6 = DELETE NODE'S LEFT CHILD ADDRESS
sw $t6, ($t7)			# PARENT'S RIGHT CHILD IS NOW DELETE NODE'S LEFT CHILD
b delete_finish

delete_finish:
lw $s1, 8($t0)			# $s1 = DELETE NODE'S RIGHT CHILD
lw $t0, 4($t0)			# CURRENT NODE = DELETE NODE'S LEFT CHILD
beqz $t0, direct_attach		# PARENT'S LEFT CHILD = DELETE NODE'S RIGHT CHILD
delete_loop:
lw $t1, 8($t0)			# $t1 = CURRENT NODE'S RIGHT CHILD
beqz $t1, attach_trees		# IF NO RIGHT CHILD, ATTACH SUBTREES
lw $t0, 8($t0)			# CURRENT NODE = CURRENT NODE'S RIGHT CHILD
b delete_loop			# KEEP LOOKING FOR MOST RIGHT CHILD
attach_trees:
sw $s1, 8($t0)			# ATTACH DELETED NODE'S RIGHT CHILD TO MOST RIGHT CHILD OF LEFT SUBTREE
b input_loop			# BACK TO INPUT LOOP
direct_attach:
sw $s1, ($t7)			# DELETE NODE HAD NO LEFT CHILD, PUT RIGHT CHILD IN PLACE OF DELETE NODE
b input_loop			# BACK TO INPUT LOOP

delete_root:
lw $s1, 8($s0)			# $s1 = ROOT'S RIGHT CHILD
lw $t0, 4($s0)			# CURRENT NODE = ROOT'S LEFT CHILD
beqz $t0, root_direct_attach	# IF NO LEFT SUBTREE, ROOT = ROOT'S RIGHT CHILD
root_loop:
lw $t1, 8($t0)			# $t1 = CURRENT NODE'S RIGHT CHILD
beqz $t1, root_attach_trees	# IF NO RIGHT CHILD, ATTACH SUBTREES
lw  $t0, 8($t0)			# CURRENT NODE = CURRENT NODE'S RIGHT CHILD
b root_loop			# KEEP LOOKING FOR MOST RIGHT CHILD
root_attach_trees:
lw $s0, 4($s0)			# ROOT = ROOT'S LEFT CHILD
sw $s1, 8($t0)			# ATTACH DELETED ROOT'S RIGHT CHILD TO MOST RIGHT CHILD OF LEFT SUBTREE
b input_loop			# BACK TO INPUT LOOP
root_direct_attach:
move $s0, $s1			# ROOT HAD NO LEFT CHILD, $S0 (ROOT) = ROOT'S RIGHT CHILD
bnez $s1, input_loop		# IF TREE STILL HAS CONTENTS, BACK TO INPUT LOOP
move $s7, $zero			# FLAG NOW INDICATES THAT TREE IS EMPTY
b input_loop			# BACK TO INPUT LOOP

not_in_tree:
li $v0, 4			# SYSCALL TO PRINT A STRING
la $a0, not_in_tree_msg		# ADDRESS OF STRING TO PRINT
syscall				# PRINT "NOT IN TREE"
b input_loop			# BACK TO INPUT LOOP


######################   INSERT   #########################
insert:
beqz $s7, empty_tree 	# IF TREE IS EMPTY, SET UP ROOT
move $s1, $t2 		# MOVE INPUT TO $s1
move $a0, $s1 		# VALUE IS ARGUMENT 0
move $a1, $s0 		# ROOT IS ARGUMENT 1
jal tree_insert 	# CALL TREE_INSERT FUNCTION
b input_loop 		# BACK TO INPUT_LOOP

empty_tree:
move $a0, $t2		# VALUE = INPUT
li $a1, 0		# LEFT = NULL
li $a2, 0		# RIGHT = NULL
jal node_create		# CALL NODE CREATE
move $s0, $v0		# $s0 IS THE ADDRESS OF THE ROOT
addi $s7, $s7, 1        # EMPTY TREE FLAG NOW INDICATES THAT TREE HAS CONTENTS
b input_loop


#####################   INVALID INPUT   ###########################
err:
li $v0, 4		# SYSCALL TO PRINT A STRING
la $a0, error		# ADDRESS OF STRING TO PRINT
syscall			# PRINT "PLEASE INPUT A VALID COMMAND"
b input_loop		# BACK TO COMMAND INPUT


#######################                 #############################
print_input:
beqz $s7, print_empty_tree	# IF TREE IS EMPTY, PRINT MESSAGE

lw $a0, 4($s0) 			# PRINT OUT THE ROOTS OF THE LEFT CHILD
jal tree_print_input

# PRINT THE ROOT
li $v0, 1			# SYSCALL TO PRING AN INTEGER
lw $a0, ($s0)			# ADDRESS OF INTEGER TO PRINT
syscall				# PRINT THE ROOT
li $v0, 4			# SYSCALL TO PRINT A STRING
la $a0, println			# ADDRESS OF STRING TO PRINT
syscall				# PRINT A NEWLINE CHARACTER

lw $a0, 8($s0) 			# PRINT OUT THE ROOTS OF THE RIGHT CHILD
jal tree_print_input
b input_loop 			# REPEAT INPUT_LOOP

print_empty_tree:
li $v0, 4			# SYSCALL TO PRINT A STRING
la $a0, empty_tree_msg		# ADDRESS OF STRING TO PRINT
syscall				# PRINT "TREE IS EMPTY"
b input_loop			# BACK TO INPUT_LOOP


#########################    NODE CREATE   ############################
node_create:
subu $sp, $sp, 32	# SET UP THE STACK
sw $ra, 28($sp)		# STORE THE RETURN ADDRESS
sw $fp, 24($sp)		# STORE THE FRAME POINTER
sw $s0, 20($sp)		# STORE $s0
sw $s1, 16($sp)		# STORE $s1
sw $s2, 12($sp)		# STORE $s2
sw $s3, 8($sp)		# STORE $s3
addu $fp, $sp, 32	

move $s0, $a0 		# set $s0 = TO ARGUMENT 0 (VALUE)
move $s1, $a1 		# SET $s1 = TO ARGUMENT 1 (ADDRESS OF LEFT CHILD)
move $s2, $a2 		# SET $S2 = TO ARGUMENT 2 (ADDRESS OF RIGHT CHILD)

li $a0, 12 		# ALLOT 12 BYTES FOR A NEW NODE
li $v0, 9 		# SYSCALL TO ALLOT MEMORY
syscall			# ALLOT THE MEMORY
move $s3, $v0		# MOVE NODE LOCATION IN MEMORY TO $s3

beqz $s3, ERRORMEM	# PRINT ERROR MESSAGE IF SBRK DID NOT WORK
sw $s0, 0($s3) 		# NODE ADDRESS (0) OFFSET = VALUE
sw $s1, 4($s3) 		# NODE ADDRESS (4) OFFSET = ADDRESS OF LEFT CHILD
sw $s2, 8($s3) 		# NODE ADDRESS (8) OFFSET = ADDRESS OF RIGHT CHILD

move $v0, $s3 		# $v0 = VALUE OF NEW NODE

lw $ra, 28($sp) 	# RESTORE THE RETURN ADDRESS
lw $fp, 24($sp) 	# RESTORE THE FRAME POINTER
lw $s0, 20($sp) 	# RESTORE $s0
lw $s1, 16($sp) 	# RESTORE $s1
lw $s2, 12($sp) 	# RESTORE $s2
lw $s3, 8($sp) 		# RESTORE $s3
addu $sp, $sp, 32 	# RESTORE THE STACK POINTER
jr $ra 			# RETURN

ERRORMEM:
li $v0, 4		# SYSCALL TO PRINT A STRING
la $a0, ERRORMEM_MSG	# ADDRESS OF STRING TO PRINT
syscall			# PRINT "OUT OF MEMORY!"
j exit			# EXIT THE PROGRAM


############################   TREE INSERT   ############################
tree_insert:
subu $sp, $sp, 32	# MOVE THE STACK POINTER
sw $ra, 28($sp)		# STORE THE RETURN ADDRESS
sw $fp, 24($sp)		# STORE THE FRAME POINTER
sw $s0, 20($sp)		# STORE $s0 (VALUE)
sw $s1, 16($sp)		# STORE $s1 (ROOT NODE ADDRESS)
sw $s2, 12($sp)		# STORE $s2 (NEW NODE ADDRESS)
sw $s3, 8($sp)		# STORE $s3 (VALUE OF ROOT)
sw $s3, 4($sp)		# STORE $S3
addu $fp, $sp, 32	# MOVE FRAME POINTER

move $s0, $a0 		# $s0 = VALUE
move $s1, $a1 		# $s1 = CURRENT NODE

# CREATE A NEW NODE
move $a0, $s0 		# ARGUMNET 0 (VALUE) = $s0
li $a1, 0 		# ARGUMENT 1 (LEFT) = 0
li $a2, 0 		# ARGUMENT 2 (RIGHT) = 0
jal node_create 	# CALL NODE_CREATE
move $s2, $v0 		# SAVE THE NEW NODE ADDRESS IN $s2

insert_loop:
lw $s3, 0($s1) 			# $s3 = VALUE IN ROOT NODE
blt $s0, $s3, insert_left 	# IF VALUE < ROOT VALUE, MOVE LEFT
bgt $s0, $s3, insert_right 	# IF VALUE > ROOT VALUE, MOVE RIGHT
b already_there			# IF VALUE = ROOT VALUE, ERROR MESSAGE

already_there:
li $v0, 4		# SYSCALL TO PRINT A STRING
la $a0, already		# ADDRESS OF STRING TO PRINT
syscall			# PRINT "THAT VALUE IS ALREADY IN THE TREE"
b end_insert_loop	# FINISH INSERT LOOP

insert_left:
lw $s4, 4($s1) 		# $s4 = ADDRESS OF LEFT CHILD
beqz $s4, add_left 	# IF NO LEFT CHILD, ADD NEW LEFT CHILD
move $s1, $s4 		# IF LEFT CHILD EXISTS, USE IT TO COMPARE
b insert_loop 		# COMPARE AGAIN

add_left:
sw $s2, 4($s1) 		# LEFT CHILD = ADDRESS OF NEW NODE
b end_insert_loop 	# FINISH INSERT LOOP

insert_right:
lw $s4, 8($s1) 		# $s4 = ADDRESS OF RIGHT CHILD
beqz $s4, add_right 	# IF NO RIGHT CHILD, ADD NEW RIGHT CHILD
move $s1, $s4 		# IF RIGHT CHILD EXISTS, USE IT TO COMPARE
b insert_loop 		# COMPARE AGAIN

add_right:
sw $s2, 8($s1) 		# RIGHT CHILD = ADDRESS OF NEW NODE
b end_insert_loop 	# FINISH INSERT LOOP

end_insert_loop:
lw $ra, 28($sp) 	# RESTORE THE RETURN ADDRESS
lw $fp, 24($sp) 	# RESTORE THE FRAME POINTER
lw $s0, 20($sp) 	# RESTORE $s0
lw $s1, 16($sp) 	# RESTORE $s1
lw $s2, 12($sp) 	# RESTORE $s2
lw $s3, 8($sp) 		# RESTORE $s3
lw $s4, 4($sp) 		# RESTORE $s4
addu $sp, $sp, 32 	# RESTORE THE STACK POINTER
jr $ra 			# RETURN


############################   PRINT   ###########################
#### Binary Tree in Assembly Language
#### Jacob Danks

.data
buffer:           .space 4
println:          .asciiz "\n"
CMD:              .asciiz "Input command (I,P,D,Q): "
input:            .asciiz "Input inputeger: "
already:          .asciiz "That value is already in the tree.\n"
not_in_tree_msg:  .asciiz "That value is not in the tree.\n"
empty_tree_msg:   .asciiz "The tree is empty.\n"
error:            .asciiz "Please input a valid command.\n"
ERRORMEM_MSG:     .asciiz "Out of memory!\n"

.text
#######################   SET UP THE ROOT   #######################
move $s0, $zero        # ROOT POINTER IS NULL
move $s7, $zero        # $s7 IS A FLAG -> 0 = EMPTY TREE

#########################   INPUT LOOP   #########################
input_loop:
li $v0, 4          # SYSCALL TO PRINT A STRING
la $a0, CMD        # ADDRESS OF STRING TO PRINT
syscall            # PRINT "INPUT A COMMAND (I, P, D, Q)"
li $v0, 8          # SYSCALL TO READ A STRING
la $a0, buffer     # ADDRESS OF BUFFER
li $a1, 4          # NUMBER OF CHARS TO READ
syscall            # READ THE STRING

lb $t1, 0($a0)                 # READ THE INPUT COMMAND
li $t4, 'D'                    # 'D' = DELETE
li $t5, 'I'                    # 'I' = INSERT
li $t6, 'P'                    # 'P' = PRINT
li $t7, 'Q'                    # 'Q' = QUIT
beq $t1, $t4, input_integer    # INPUT INTEGER TO DELETE
beq $t1, $t5, input_integer    # INPUT INTEGER TO INSERT
beq $t1, $t6, print_input      # PRINT THE TREE
beq $t1, $t7, exit             # EXIT THE PROGRAM
b err                          # ERROR MESSAGE IF NOT A VALID COMMAND

########################   INPUT INTEGER   #############################
input_integer:
li $v0, 4               # SYSCALL TO PRINT A STRING
la $a0, input           # ADDRESS OF STRING TO PRINT
syscall                 # PRINT "INPUT INTEGER"
li $v0, 5               # SYSCALL TO READ INTEGER
syscall                 # READ THE INPUT
move $t2, $v0           # MOVE INPUT TO TEMP REGISTER
beq $t1, $t4, delete    # CONTINUE TO DELETE FUNCTION
beq $t1, $t5, insert    # CONTINUE TO INSERT FUNCTION

########################   DELETE   ################
delete:
lw $t1, 0($s0)               # $t1 IS THE VALUE OF THE ROOT
beq $t2, $t1, delete_root    # IF INPUT = ROOT VALUE, DELETE THE ROOT
move $t0, $s0                # $t0 IS THE CURRENT NODE
blt $t2, $t1, look_left      # IF INPUT < CURRENT NODE VALUE, LOOK LEFT
b look_right                 # IF INPUT > CURRENT NODE VALUE, LOOK RIGHT

look_left:
lw $t3, 4($t0)               # $t3 = LEFT CHILD ADDRESS
beqz $t3, not_in_tree        # IF INPUT < CURRENT VALUE AND NO LEFT CHILD, NOT IN TREE
lw $t4, 0($t3)               # $t4 = LEFT CHILD VALUE
beq $t2, $t4, delete_left    # IF INPUT = LEFT CHILD VALUE, DELETE LEFT
lw $t0, 4($t0)               # CURRENT NODE = LEFT CHILD ADDRESS
blt $t2, $t4, look_left      # IF INPUT < LEFT CHILD VALUE, LOOK LEFT
b look_right                 # IF INPUT > LEFT CHILD VALUE, LOOK RIGHT

look_right:
lw $t3, 8($t0)               # $t3 = RIGHT CHILD ADDRESS
beqz $t3, not_in_tree        # IF INPUT > CURRENT VALUE AND NO RIGHT CHILD, NOT IN TREE
lw $t4, 0($t3)               # $t4 = RIGHT CHILD VALUE
beq $t2, $t4, delete_right   # IF INPUT = RIGHT CHILD VALUE, DELETE RIGHT
lw $t0, 8($t0)               # CURRENT NODE = RIGHT CHILD ADDRESS
blt $t2, $t4, look_left      # IF INPUT < RIGHT CHILD VALUE, LOOK LEFT
b look_right                 # IF INPUT > RIGHT CHILD VALUE, LOOK RIGHT

delete_left:
la $t7, 4($t0)            # $t7 = DELETE NODE'S PARENT'S LEFT CHILD FIELD
lw $t0, 4($t0)            # CURRENT NODE = LEFT CHILD ADDRESS
lw $t6, 4($t0)            # $t6 = DELETE NODE'S LEFT CHILD ADDRESS
sw $t6, ($t7)             # PARENT'S LEFT CHILD IS NOW DELETE NODE'S LEFT CHILD
b delete_finish

delete_right:
la $t7, 8($t0)            # $t7 = DELETE NODE'S PARENT'S RIGHT CHILD FIELD
lw $t0, 8($t0)            # CURRENT NODE = RIGHT CHILD ADDRESS
lw $t6, 4($t0)            # $t6 = DELETE NODE'S LEFT CHILD ADDRESS
sw $t6, ($t7)             # PARENT'S RIGHT CHILD IS NOW DELETE NODE'S LEFT CHILD
b delete_finish

delete_finish:
lw $s1, 8($t0)            # $s1 = DELETE NODE'S RIGHT CHILD
lw $t0, 4($t0)            # CURRENT NODE = DELETE NODE'S LEFT CHILD
beqz $t0, direct_attach   # PARENT'S LEFT CHILD = DELETE NODE'S RIGHT CHILD
delete_loop:
lw $t1, 8($t0)            # $t1 = CURRENT NODE'S RIGHT CHILD
beqz $t1, attach_trees    # IF NO RIGHT CHILD, ATTACH SUBTREES
lw $t0, 8($t0)            # CURRENT NODE = CURRENT NODE'S RIGHT CHILD
b delete_loop             # KEEP LOOKING FOR MOST RIGHT CHILD
attach_trees:
sw $s1, 8($t0)            # ATTACH DELETED NODE'S RIGHT CHILD TO MOST RIGHT CHILD OF LEFT SUBTREE
b input_loop              # BACK TO INPUT LOOP
direct_attach:
sw $s1, ($t7)             # DELETE NODE HAD NO LEFT CHILD, PUT RIGHT CHILD IN PLACE OF DELETE NODE
b input_loop              # BACK TO INPUT LOOP

delete_root:
lw $s1, 8($s0)                 # $s1 = ROOT'S RIGHT CHILD
lw $t0, 4($s0)                 # CURRENT NODE = ROOT'S LEFT CHILD
beqz $t0, root_direct_attach   # IF NO LEFT SUBTREE, ROOT = ROOT'S RIGHT CHILD
root_loop:
lw $t1, 8($t0)                 # $t1 = CURRENT NODE'S RIGHT CHILD
beqz $t1, root_attach_trees    # IF NO RIGHT CHILD, ATTACH SUBTREES
lw  $t0, 8($t0)                # CURRENT NODE = CURRENT NODE'S RIGHT CHILD
b root_loop                    # KEEP LOOKING FOR MOST RIGHT CHILD
root_attach_trees:
lw $s0, 4($s0)                 # ROOT = ROOT'S LEFT CHILD
sw $s1, 8($t0)                 # ATTACH DELETED ROOT'S RIGHT CHILD TO MOST RIGHT CHILD OF LEFT SUBTREE
b input_loop                   # BACK TO INPUT LOOP
root_direct_attach:
move $s0, $s1                  # ROOT HAD NO LEFT CHILD, $S0 (ROOT) = ROOT'S RIGHT CHILD
bnez $s1, input_loop           # IF TREE STILL HAS CONTENTS, BACK TO INPUT LOOP
move $s7, $zero                # FLAG NOW INDICATES THAT TREE IS EMPTY
b input_loop                   # BACK TO INPUT LOOP

not_in_tree:
li $v0, 4                      # SYSCALL TO PRINT A STRING
la $a0, not_in_tree_msg        # ADDRESS OF STRING TO PRINT
syscall                        # PRINT "NOT IN TREE"
b input_loop                   # BACK TO INPUT LOOP


######################   INSERT   #########################
insert:
beqz $s7, empty_tree  # IF TREE IS EMPTY, SET UP ROOT
move $s1, $t2         # MOVE INPUT TO $s1
move $a0, $s1         # VALUE IS ARGUMENT 0
move $a1, $s0         # ROOT IS ARGUMENT 1
jal tree_insert       # CALL TREE_INSERT FUNCTION
b input_loop          # BACK TO INPUT_LOOP

empty_tree:
move $a0, $t2        # VALUE = INPUT
li $a1, 0            # LEFT = NULL
li $a2, 0            # RIGHT = NULL
jal node_create      # CALL NODE CREATE
move $s0, $v0        # $s0 IS THE ADDRESS OF THE ROOT
addi $s7, $s7, 1     # EMPTY TREE FLAG NOW INDICATES THAT TREE HAS CONTENTS
b input_loop


#####################   INVALID INPUT   ###########################
err:
li $v0, 4        # SYSCALL TO PRINT A STRING
la $a0, error    # ADDRESS OF STRING TO PRINT
syscall          # PRINT "PLEASE INPUT A VALID COMMAND"
b input_loop     # BACK TO COMMAND INPUT


#######################                 #############################
print_input:
beqz $s7, print_empty_tree    # IF TREE IS EMPTY, PRINT MESSAGE

lw $a0, 4($s0)                # PRINT OUT THE ROOTS OF THE LEFT CHILD
jal tree_print_input

# PRINT THE ROOT
li $v0, 1                # SYSCALL TO PRING AN INTEGER
lw $a0, ($s0)            # ADDRESS OF INTEGER TO PRINT
syscall                  # PRINT THE ROOT
li $v0, 4                # SYSCALL TO PRINT A STRING
la $a0, println          # ADDRESS OF STRING TO PRINT
syscall                  # PRINT A NEWLINE CHARACTER

lw $a0, 8($s0)           # PRINT OUT THE ROOTS OF THE RIGHT CHILD
jal tree_print_input
b input_loop             # REPEAT INPUT_LOOP

print_empty_tree:
li $v0, 4                # SYSCALL TO PRINT A STRING
la $a0, empty_tree_msg   # ADDRESS OF STRING TO PRINT
syscall                  # PRINT "TREE IS EMPTY"
b input_loop             # BACK TO INPUT_LOOP


#########################    NODE CREATE   ############################
node_create:
subu $sp, $sp, 32     # SET UP THE STACK
sw $ra, 28($sp)       # STORE THE RETURN ADDRESS
sw $fp, 24($sp)       # STORE THE FRAME POINTER
sw $s0, 20($sp)       # STORE $s0
sw $s1, 16($sp)       # STORE $s1
sw $s2, 12($sp)       # STORE $s2
sw $s3, 8($sp)        # STORE $s3
addu $fp, $sp, 32    

move $s0, $a0         # set $s0 = TO ARGUMENT 0 (VALUE)
move $s1, $a1         # SET $s1 = TO ARGUMENT 1 (ADDRESS OF LEFT CHILD)
move $s2, $a2         # SET $S2 = TO ARGUMENT 2 (ADDRESS OF RIGHT CHILD)

li $a0, 12            # ALLOT 12 BYTES FOR A NEW NODE
li $v0, 9             # SYSCALL TO ALLOT MEMORY
syscall               # ALLOT THE MEMORY
move $s3, $v0         # MOVE NODE LOCATION IN MEMORY TO $s3

beqz $s3, ERRORMEM    # PRINT ERROR MESSAGE IF SBRK DID NOT WORK
sw $s0, 0($s3)        # NODE ADDRESS (0) OFFSET = VALUE
sw $s1, 4($s3)        # NODE ADDRESS (4) OFFSET = ADDRESS OF LEFT CHILD
sw $s2, 8($s3)        # NODE ADDRESS (8) OFFSET = ADDRESS OF RIGHT CHILD

move $v0, $s3         # $v0 = VALUE OF NEW NODE

lw $ra, 28($sp)       # RESTORE THE RETURN ADDRESS
lw $fp, 24($sp)       # RESTORE THE FRAME POINTER
lw $s0, 20($sp)       # RESTORE $s0
lw $s1, 16($sp)       # RESTORE $s1
lw $s2, 12($sp)       # RESTORE $s2
lw $s3, 8($sp)        # RESTORE $s3
addu $sp, $sp, 32     # RESTORE THE STACK POINTER
jr $ra                # RETURN

ERRORMEM:
li $v0, 4             # SYSCALL TO PRINT A STRING
la $a0, ERRORMEM_MSG  # ADDRESS OF STRING TO PRINT
syscall               # PRINT "OUT OF MEMORY!"
j exit                # EXIT THE PROGRAM


############################   TREE INSERT   ############################
tree_insert:
subu $sp, $sp, 32    # MOVE THE STACK POINTER
sw $ra, 28($sp)      # STORE THE RETURN ADDRESS
sw $fp, 24($sp)      # STORE THE FRAME POINTER
sw $s0, 20($sp)      # STORE $s0 (VALUE)
sw $s1, 16($sp)      # STORE $s1 (ROOT NODE ADDRESS)
sw $s2, 12($sp)      # STORE $s2 (NEW NODE ADDRESS)
sw $s3, 8($sp)       # STORE $s3 (VALUE OF ROOT)
sw $s3, 4($sp)       # STORE $S3
addu $fp, $sp, 32    # MOVE FRAME POINTER

move $s0, $a0        # $s0 = VALUE
move $s1, $a1        # $s1 = CURRENT NODE

# CREATE A NEW NODE
move $a0, $s0        # ARGUMNET 0 (VALUE) = $s0
li $a1, 0            # ARGUMENT 1 (LEFT) = 0
li $a2, 0            # ARGUMENT 2 (RIGHT) = 0
jal node_create      # CALL NODE_CREATE
move $s2, $v0        # SAVE THE NEW NODE ADDRESS IN $s2

insert_loop:
lw $s3, 0($s1)                # $s3 = VALUE IN ROOT NODE
blt $s0, $s3, insert_left     # IF VALUE < ROOT VALUE, MOVE LEFT
bgt $s0, $s3, insert_right    # IF VALUE > ROOT VALUE, MOVE RIGHT
b already_there               # IF VALUE = ROOT VALUE, ERROR MESSAGE

already_there:
li $v0, 4            # SYSCALL TO PRINT A STRING
la $a0, already      # ADDRESS OF STRING TO PRINT
syscall              # PRINT "THAT VALUE IS ALREADY IN THE TREE"
b end_insert_loop    # FINISH INSERT LOOP

insert_left:
lw $s4, 4($s1)       # $s4 = ADDRESS OF LEFT CHILD
beqz $s4, add_left   # IF NO LEFT CHILD, ADD NEW LEFT CHILD
move $s1, $s4        # IF LEFT CHILD EXISTS, USE IT TO COMPARE
b insert_loop        # COMPARE AGAIN

add_left:
sw $s2, 4($s1)       # LEFT CHILD = ADDRESS OF NEW NODE
b end_insert_loop    # FINISH INSERT LOOP

insert_right:
lw $s4, 8($s1)       # $s4 = ADDRESS OF RIGHT CHILD
beqz $s4, add_right  # IF NO RIGHT CHILD, ADD NEW RIGHT CHILD
move $s1, $s4        # IF RIGHT CHILD EXISTS, USE IT TO COMPARE
b insert_loop        # COMPARE AGAIN

add_right:
sw $s2, 8($s1)       # RIGHT CHILD = ADDRESS OF NEW NODE
b end_insert_loop    # FINISH INSERT LOOP

end_insert_loop:
lw $ra, 28($sp)      # RESTORE THE RETURN ADDRESS
lw $fp, 24($sp)      # RESTORE THE FRAME POINTER
lw $s0, 20($sp)      # RESTORE $s0
lw $s1, 16($sp)      # RESTORE $s1
lw $s2, 12($sp)      # RESTORE $s2
lw $s3, 8($sp)       # RESTORE $s3
lw $s4, 4($sp)       # RESTORE $s4
addu $sp, $sp, 32    # RESTORE THE STACK POINTER
jr $ra               # RETURN


############################   PRINT   ###########################
tree_print_input:
subu $sp, $sp, 32        # SET UP THE STACK FRAME
sw $ra, 28($sp)          # STORE THE RETURN ADDRESS
sw $fp, 24($sp)          # STORE THE FRAME POINTER
sw $s0, 20($sp)          # STORE $s0
addu $fp, $sp, 32        # MOVE FRAME POINTER

move $s0, $a0            # $s0 = ROOT OF SUBTREE

beqz $s0, tree_print_input_end    # IF NODE DOESN'T EXIST, MOVE TO END

lw $a0, 4($s0)           # MOVE LEFT
jal tree_print_input     # RECURSE WITH LEFT CHILD

li $v0, 1                # SYSCALL TO PRINT AN INTEGER
lw $a0, 0($s0)           # VALUE OF THE CURRENT NODE
syscall                  # PRINT VALUE OF CURRENT NODE
li $v0, 4                # SYSCALL TO PRINT A STRING
la $a0, println          # ADDRESS OF STRING TO PRINT
syscall                  # PRINT A NEWLINE CHARACTER

lw $a0, 8($s0)           # MOVE RIGHT
jal tree_print_input     # RECURSE WITH RIGHT CHILD

tree_print_input_end:    # CLEAN UP EACH RECURSION LOOP
lw $ra, 28($sp)          # RESTORE THE RETURN ADDRESS
lw $fp, 24($sp)          # RESTORE THE FRAME POINTER
lw $s0, 20($sp)          # RESTORE $s0
addu $sp, $sp, 32        # RESTORE THE STACK POINTER
jr $ra                   # RETURN

tree_print_input2:
subu $sp, $sp, 32        # SET UP THE STACK FRAME
sw $ra, 28($sp)          # STORE THE RETURN ADDRESS
sw $fp, 24($sp)          # STORE THE FRAME POINTER
sw $s0, 20($sp)          # STORE $s0
addu $fp, $sp, 32        # MOVE FRAME POINTER

move $s0, $a0            # $s0 = ROOT OF SUBTREE

beqz $s0, tree_print_input_end     # IF NODE DOESN'T EXIST, MOVE TO END

lw $a0, 8($s0)           # MOVE LEFT
jal tree_print_input2    # RECURSE WITH LEFT CHILD

li $v0, 1                # SYSCALL TO PRINT AN INTEGER
lw $a0, 0($s0)           # VALUE OF THE CURRENT NODE
syscall                  # PRINT THE VALUE OF THE CURRENT NODE
li $v0, 4                # SYSCALL TO PRINT A STRING
la $a0, println          # ADDRESS OF STRING TO PRINT
syscall                  # PRINT A NEWLINE CHARACTER

lw $a0, 4($s0)           # MOVE RIGHT
jal tree_print_input2    # RECURSE WITH THE RIGHT CHILD

tree_print_input_end2:   # RESTORE VALUES AND RETURN
lw $ra, 28($sp)          # RESTORE THE RETURN ADDRESS
lw $fp, 24($sp)          # RESTORE THE FRAME POINTER
lw $s0, 20($sp)          # RESTORE $s0
addu $sp, $sp, 32        # RESTORE THE STACK POINTER
jr $ra                   # RETURN


########################   EXIT   ##################################
exit:
li $v0, 10               # SYSCALL TO EXIT THE PROGRAM
syscall                  # EXIT
