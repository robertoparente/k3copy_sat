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
# Starting the code. We use DIMACS: https://doc.sagemath.org/html/en/reference/sat/sage/sat/solvers/dimacs.html
 
def SAT1(G,colors,file):
	n=G.order()
	vertices = G.vertices()
	edges = G.edges()
	clauses=[]
	var_dic={}
	solver = DIMACS()
	
#	Color equations: Every edges receives a color
	for e in edges:
		nClause = list()
		for i in range(colors):
			new_string=edge_variable_to_string(e,i)
			dictionary_add(var_dic,new_string)
			nClause.append(var_dic[new_string])
		solver.add_clause(nClause)
	
	# Degree equations: The color degree is at most 1
	# The equations must be in the conjunctive normal form (CNF):
	# For every color i, we have "¬x_e,i OR (x_e,i and x_f1,i and ... and x_fj,i)", where fj denotes edges in the neighborhood of edge "e".
	for i in range(colors): 
		for e in edges:
			eVar = -1*var_dic[edge_variable_to_string(e,i)]
			for f in edges_incident(G,e):
				fVar = -1*var_dic[edge_variable_to_string(f,i)]
				solver.add_clause((eVar,fVar))
				
	# Each edge can be only one color
	for e in edges:
		for i in range(colors):
			for j in range(colors):
				if(i<j):
					# -x_e_i, or -x_e_j
					solver.add_clause((-var_dic[edge_variable_to_string(e,i)],-var_dic[edge_variable_to_string(e,j)]))

	# Triangle equations - Part I
	# First we create the variables Y[u,v,w][a,b,c] that determine the colors as a,b,c to K_3 uvw.
	# The equation was converted to conjunctive normal form (CNF)
	for triple_uvw in Combinations(vertices,3):
		u,v,w = triple_uvw
		H=G.subgraph(triple_uvw)
		e,f,g=H.edges()
		for triple_abc in Combinations(range(colors),3):
			a,b,c=triple_abc
			fVar = list()
			new_var=triangle_variable_to_string(triple_uvw,triple_abc)
			dictionary_add(var_dic,new_var)
				
			# The follow clause for variables definition y[x,y,z][a,b,c] := triangle xyz has color abc:
			# -y and (-x_e_a or -x_f_b or -x_g_c) and (-x_e_a or -x_g_b or -x_f_c) and (-x_g_a or -x_f_b or -x_e_c)
			# and (-x_f_a or -x_e_b or -x_g_c) and (-x_f_a or -x_g_b or -x_e_c) and (-x_g_a or -x_e_b or -x_f_c)
			# OR
			# y and ((x_e_a and x_f_b and x_g_c) or (x_e_a and x_g_b and x_f_c) or (x_g_a and x_f_b and x_e_c)
			# or (x_f_a and x_e_b and x_g_c) or (x_f_a and x_g_b and x_e_c) or (x_g_a and x_e_b and x_f_c))
			#
			# In the CNF:
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
	print("Makes equations to triangles") 

	# Triangle equations - Part II
	# We make the clauses:
	# For every a,b,c in COLORS; for every x,y,z in V; for every x',y',z' in V\[x,y,z] we have -y[x,y,z][a,b,c] OR -y[x',y',z'][a,b,c]   
	for c_triple in Combinations(range(colors),3):
		for v1_triple in Combinations(G.vertices(),3):
			H = G.copy()
			vY = var_dic[triangle_variable_to_string(v1_triple,c_triple)]
			H.delete_vertices(v1_triple)
			for v2_triple in Combinations(H.vertices(),3):
				vX = var_dic[triangle_variable_to_string(v2_triple,c_triple)]
				solver.add_clause((-vY,-vX))
	
	print("Makes clauses for disjoint triangles")			
	print("Cleaning some symmetries")	
	
	# Cleaning the symmetry: Forcing n-1 colors in incident edges to vertex "0".
	# (Supposing complete graph and at least n-1 colors)

	i=0
	for f in G.edges_incident(vertices[0]):
		fVar = list()
		fVar.append(var_dic[edge_variable_to_string(f,i)])
		i = i+1
		solver.add_clause((fVar))

	# Writing DIMACS to file "file"
	print("Writing DIMACS file")
	solver.clauses(file)

	# Writing dictionary
	print("Writing dictionary")
	file_dicionario = open(file+"_DICTIONARY",'w')
 
	for chave in var_dic:
		file_dicionario.write(chave+" : "+str(var_dic[chave])+"\n")		
	file_dicionario.close()

	return
	
