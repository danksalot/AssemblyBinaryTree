# AssemblyBinaryTree
This is an implementation of a binary tree in Assembly language, using the MIPS instruction set.  This was for a project in a class I took during my Masters program.

The interface first prompts you to input a command from these options:
I - Insert an integer
P - Print the contents of the binary tree
D - Delete an integer from the binary tree
Q - Quit the program

Here is an example of the program running:

Input command (I,P,D,Q): I
Input inputeger: 5

Reset: reset completed.

Input command (I,P,D,Q): P
The tree is empty.
Input command (I,P,D,Q): I
Input inputeger: 2
Input command (I,P,D,Q): I
Input inputeger: 5
Input command (I,P,D,Q): P
2
5
Input command (I,P,D,Q): I
Input inputeger: 1
Input command (I,P,D,Q): P
1
2
5
Input command (I,P,D,Q): I
Input inputeger: 3
Input command (I,P,D,Q): I
Input inputeger: 7
Input command (I,P,D,Q): P
1
2
3
5
7
Input command (I,P,D,Q): I
Input inputeger: 5
That value is already in the tree.
Input command (I,P,D,Q): P
1
2
3
5
7
Input command (I,P,D,Q): D
Input inputeger: 5
Input command (I,P,D,Q): P
1
2
3
7
Input command (I,P,D,Q): Q

-- program is finished running --
