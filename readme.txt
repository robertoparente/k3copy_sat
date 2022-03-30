This program is part of the papper "Proper edge colorings of complete graphs without repeated triangles"
Authors: Fabio Botler, Lucas Colucci, Paulo Matias, Guilherme Mota, Roberto Parente and Matheus Secco.

:: About the solution ::

The strategy used to solve the problem is to create a DIMACS file from Sage (https://doc.sagemath.org/html/en/reference/sat/sage/sat/solvers/dimacs.html) and send it to the sat solver Plingeling [2] and if it returns
true means that there is a proper coloring without two disjoint triangles of the same color. For this purpose we created two codes to execute on Sage [1]. The first code will receive as input a complete graph G, the number of colors and the name of the FILE associated with the running instance. The output is given by two text files as FILE and FILE_DICTIONARY, where FILE is the input of sat solver and FILE_DICTIONARY is the dictionary that translates the sat solver variables into variables to be retrieved and translated into the graph. The second code aims to check if the resulting output of the sat solver is indeed a valid instance for our problem and print it the adjacency matrix as well as plotting the graph. To solve the problem we will use "Plingeling SAT Solver Version ayv-86bf266-140429" with GNU/Linux operating system.

:: Executing the codes ::

1) Enter in the directory where the files "gen_DIMACS_SAT.sage" and "check-show_output.sage" are
2) Enter in sage and put the follow lines
sage: G = graphs.CompleteGraph(12)
sage: load("gen_DIMACS_SAT.sage")
sage: SAT1(G,12,"K12c12")
3) Execute de Plingeling Sat Solver with output to FILE.output in as follow:
./plingeling K12c12 > K12c12.output
4) Enter in sage and put the following lines
sage: G = graphs.CompleteGraph(12)
sage: load("check-show_output.sage")
sage: show_output("K12c12_DICTIONARY","K12c12.output",12) 

:: References ::  
[1] - The Sage Developers (2020). SageMath, the Sage Mathematics Software System (Version 9.1). https://www.sagemath.org.
[2] - Biere, A. (2018). Lingeling, Plingeling and Treengeling. http://fmv.jku.at/lingeling.
