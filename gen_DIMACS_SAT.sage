def all_pairs(S):
	n=len(S)
	result=[]
	for i in range(n-1):
		for j in range(i+1,n):
			result.append([S[i],S[j]])
	return result
	
def all_disjoint_pairs(S):
	n=len(S)
	result=[]
	for i in range(n-1):
		for j in range(i+1,n):
			put=True
			for k in S[i]:
				if k in S[j]:
					put=False
			if put:
				result.append([S[i],S[j]])
	return result

def all_triples(S):
	n=len(S)
	result=[]
	for i in range(n-2):
		for j in range(i+1,n-1):
			for k in range(j+1,n):
				result.append([S[i],S[j],S[k]])
	return result
	
def triples_disjoint_from(triples,x):
	result=[]
	for y in triples:
		put=True
		for i in y:
			if i in x:
				put=False
		if put:
			result.append(y)
	return result

def disjoint_paths_with_same_ends(triples,x):
	P=Graph(x)
	result=[]
	for y in triples:
		Q=Graph(y)
		if same_ends(P,Q) and disjoint_internal(P,Q):
			result.append(y)
	return result
	
def is_path(G):
	if G.is_connected()==False:
		return False
	if max(G.degree())>2:
		return False
	if G.degree().count(1)!=2:
		return False
	return True
	
def path_end_vertices(G):
	ends=[]
	for u in G.vertices():
		if G.degree(u)==1:
			ends.append(u)
	return ends
	
def path_internal_vertices(P):
	internal=[]
	for u in G.vertices():
		if G.degree(u)==2:
			internal.append(u)
	return internal
	
def same_ends(P,Q):
	A=path_end_vertices(P)
	B=path_end_vertices(Q)
	u,v=A
	if B==A or B==[v,u]:
		return True
	return False
	
def disjoint_internal(P,Q):
	A=path_internal_vertices(P)
	B=path_internal_vertices(Q)
	for x in A:
		if x in B:
			return False
	return True

def all_3_paths(G):
	paths=[]
	for S in Combinations(G.edges(),3):
		if is_path(Graph(S)):
			paths.append(S)
	return paths
	
def order_edge(u,v):
	if v<u:
		return (v,u)
	return (u,v)
	
def edge_to_string(e):
	a = e[0]
	b = e[1]
	new_string=str(a)+","+str(b)
	return new_string

def edges_incident(G,e):
	u,v,label=e
	result=[]
	for f in G.edges_incident(u):
		if f!=e:
			result.append(f)
	for f in G.edges_incident(v):
		if f!=e:
			result.append(f)
	return result

def edge_variable_to_string(e,color):
	return "x:"+edge_to_string(e)+"_c:"+str(color)

def triangle_variable_to_string(vtx_triple,color_triple):
	u,v,w=vtx_triple
	a,b,c=color_triple
	return "y"+str(u)+","+str(v)+","+str(w)+"c"+str(a)+","+str(b)+","+str(c)

def dictionary_add(dic,var):
	l=len(dic)
	if var not in dic:
		dic[var]=l+1

from sage.sat.solvers.dimacs import DIMACS

def SAT1(G,colors,file):
	n=G.order()

	vertices = G.vertices()
	edges = G.edges()
	clauses=[]
	
	var_dic={}

	solver = DIMACS()
	
#	Equações de cor - cada aresta recebe uma cor
	for e in edges:
		nClause = list()
		for i in range(colors):
			new_string=edge_variable_to_string(e,i)
			dictionary_add(var_dic,new_string)
			nClause.append(var_dic[new_string])
		solver.add_clause(nClause)
	
#	Equações de grau - o grau de cada cor tem que ser no máximo 1
#	Equações estão na CNF: Para cada cor i, temos "¬x_e,i OR (x_e,i and x_f1,i and ... and x_fj,i)", onde fj arestas na vizinhança da arestas "e".
	for i in range(colors): 
		for e in edges:
			eVar = -1*var_dic[edge_variable_to_string(e,i)]
			for f in edges_incident(G,e):
				fVar = -1*var_dic[edge_variable_to_string(f,i)]
				# New Clause = ¬e OR ¬f
				#nClause = list(eVar,fVar)
				solver.add_clause((eVar,fVar))
				
	# Cada aresta recebe apenas uma cor
	for e in edges:
		for i in range(colors):
			for j in range(colors):
				if(i<j):
					# -x_e_i, or -x_e_j
					solver.add_clause((-var_dic[edge_variable_to_string(e,i)],-var_dic[edge_variable_to_string(e,j)]))

	# Equação dos triângulos - Parte 01
	# Primeiro vamos gerar as variáveis Y[u,v,w][a,b,c] que determina as cores a,b,c para o K_3 uvw.
	# A equação foi convertida em FNC
	for triple_uvw in Combinations(vertices,3):
		u,v,w = triple_uvw
		H=G.subgraph(triple_uvw)
		e,f,g=H.edges()
		for triple_abc in Combinations(range(colors),3):
			a,b,c=triple_abc
			fVar = list()
			new_var=triangle_variable_to_string(triple_uvw,triple_abc)
			dictionary_add(var_dic,new_var)
				
			# Fórmula para definição das variáveis y[x,y,z][a,b,c] = triangulo xyz tem cor abc:
			# -y and (-x_e_a or -x_f_b or -x_g_c) and (-x_e_a or -x_g_b or -x_f_c) and (-x_g_a or -x_f_b or -x_e_c)
			# and (-x_f_a or -x_e_b or -x_g_c) and (-x_f_a or -x_g_b or -x_e_c) and (-x_g_a or -x_e_b or -x_f_c)
			# OR
			# y and ((x_e_a and x_f_b and x_g_c) or (x_e_a and x_g_b and x_f_c) or (x_g_a and x_f_b and x_e_c)
			# or (x_f_a and x_e_b and x_g_c) or (x_f_a and x_g_b and x_e_c) or (x_g_a and x_e_b and x_f_c))
			#
			# Convertendo para CNF:
			# A = y
			# B = xea
			# C = xfb
			# D = xgc
			# E = xgb
			# F = xfc
			# G = xga
			# H = xfa
			# I = xeb
			# J = xec
			
			vA = var_dic[new_var]
			vB = var_dic[edge_variable_to_string(e,a)]
			vC = var_dic[edge_variable_to_string(f,b)]
			vD = var_dic[edge_variable_to_string(g,c)]
			vE = var_dic[edge_variable_to_string(g,b)]
			vF = var_dic[edge_variable_to_string(f,c)]
			vG = var_dic[edge_variable_to_string(g,a)]
			vH = var_dic[edge_variable_to_string(f,a)]
			vI = var_dic[edge_variable_to_string(e,b)]
			vJ = var_dic[edge_variable_to_string(e,c)]

			# CNF

			solver.add_clause((-vA,vB,vC,vD,vE,vF,vG,vH,vI,vJ))
			solver.add_clause((-vB, -vC, -vD, vA))
			solver.add_clause((-vB, -vE, -vF, vA))
			solver.add_clause((-vG, -vC, -vJ, vA))
			solver.add_clause((-vH, -vI, -vD, vA))
			solver.add_clause((-vH, -vE, -vJ, vA))
			solver.add_clause((-vG, -vI, -vF, vA))
	print("Gerou as equações de triângulo") 

	# Equação do triângulo - Parte 2
	# Agora geramos as cláusulas:
	# para todo a,b,c in CORES; para todo x,y,z in V; para to x',y',z' in V\[x,y,z] temos -y[x,y,z][a,b,c] OR -y[x',y',z'][a,b,c]   
	# Y = y[x,y,z][a,b,c]
	# X = y[x',y',z'][a,b,c]
	# vertex_triples=all_triples(vertices)
	for c_triple in Combinations(range(colors),3):
		for v1_triple in Combinations(G.vertices(),3):
			H = G.copy()
			vY = var_dic[triangle_variable_to_string(v1_triple,c_triple)]
			H.delete_vertices(v1_triple)
			for v2_triple in Combinations(H.vertices(),3):
				vX = var_dic[triangle_variable_to_string(v2_triple,c_triple)]
				solver.add_clause((-vY,-vX))
	
	print("Gerou clausulas para triangulos disjuntos")			
	
	print("Removendo simetrias")	
	
	# Retirando simetria. forçando n-1 cores nas arestas incidentes ao vértice "0".
	# Supondo grafo completo e pelo menos n-1 cores
	# Verificar se essa eliminação funciona. Para indice cromático não ajudava. (verificado até n = 29)

	i=0
	for f in G.edges_incident(vertices[0]):
		fVar = list()
		fVar.append(var_dic[edge_variable_to_string(f,i)])
		i = i+1
		solver.add_clause((fVar))

	# Restrições impostas
	
	# print("Impondo padrões")
	# K_{2k} com {2k-1}
 	# Deve existir um C_2k com cores 0 e 2k-1 -- Não é verdade para todo k. Ex: k=5 não funciona
 	# Deve existir um K4 com cores 0,1 e 11
	# if(not (len(vertices) % 2) and (colors == len(vertices))):
		# print("Gerando C_2k com cores 0 e 2k-1")
		# for i in range(len(vertices)-1):
			# print(i)
			# if i %2 != 0:
				# a = colors-2
			# else:
				# a = 0
			# e = [i,i+1]
			# e.sort()
			# dictionary_add(var_dic,edge_variable_to_string(e,a))
			# fVar = list()
			# fVar.append(var_dic[edge_variable_to_string(e,a)])
			# print(fVar)
			# print(edge_variable_to_string(e,a))
			# solver.add_clause((fVar))
			
	# K_12
	# Impondo arestas e[0,2] e e[1,3] com cor 2 (argumento de diagonal pequena)
#		e = [0,2]
#		dictionary_add(var_dic,edge_variable_to_string(e,2))
#		fVar = list()
#		fVar.append(var_dic[edge_variable_to_string(e,2)])
#		solver.add_clause((fVar))
#		e = [1,3]
#		dictionary_add(var_dic,edge_variable_to_string(e,2))
#		fVar = list()
#		fVar.append(var_dic[edge_variable_to_string(e,2)])
#		solver.add_clause((fVar))
				
	# imprimindo DIMACS para arquivo "file"
	print("Imprimindo arquivo DIMACS")
	solver.clauses(file)

	# Escrevendo dicionario
	print("Escrevendo dicionário")
	file_dicionario = open(file+"_dicionario",'w')
 
	for chave in var_dic:
		file_dicionario.write(chave+" : "+str(var_dic[chave])+"\n")		
	file_dicionario.close()

	return
	
