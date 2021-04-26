import numpy as np

def all_triples(S):
    n=len(S)
    result=[]
    for i in range(n-2):
        for j in range(i+1,n-1):
            for k in range(j+1,n):
                result.append([S[i],S[j],S[k]])
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

def is_good_coloring(G):
	# Verificando coloração própria
	for v in G.edges():
		for f in G.edges_incident(v):
			for e in G.edges_incident(v):
				if (G.edge_label(e[0],e[1]) == G.edge_label(f[0],f[1]) and e!=f):
					if(f[0] == e[0] or f[1] == e[0] or e[1] == f[0] or e[1] == f[1]):
						print(e,f)
						return false

    # Verificando se não existem dois triângulos disjuntos com a mesma cor
	disj_triangles=all_disjoint_pairs(all_triples(G.vertices()))
	for pair in disj_triangles:
		triple1,triple2=pair
		H1=G.subgraph(triple1)
		H2=G.subgraph(triple2)
		colors1=[]
		colors2=[]
		for e in H1.edges():
			if e[2]!=None:
				colors1.append(e[2])
		for e in H2.edges():
			if e[2]!=None:
				colors2.append(e[2])
		if colors1==colors2 and len(colors1)==3:
			return False,pair,colors1,colors2
	return True 
   
def show_output(fileDic,fileOutPut,size):
	G = graphs.CompleteGraph(size)
	dic = {}
	true_var = list()
	# Recuperando dicionário
	with open(fileDic, 'r') as reader:
		for line in reader:
			dic_var,var = line.split(" : ")
			dic[int(var.rstrip("\n"))] = dic_var

	#Recuperando variáveis verdadeiras da saída
	with open(fileOutPut, 'r') as reader:
		for line in reader:
			if (line[0] == 'v' and line[2] != '0'):
				x = line.split("v")
				vector = x[1].split(" ")
				for i in vector:
					if(i != '' and i[0] != '-'):
						true_var.append(int(i.rstrip("\n")))

	# Gerando grafo de acordo com as variáveis
	G=graphs.CompleteGraph(size)
	# print(true_var)
	for x in true_var:
		variable = dic[x]
		if(variable[0] == "x"):
			vertices,color=variable.split("c:")
			vertices = vertices.strip("x:")
			u,v = vertices = vertices.strip("_").split(",")
			color=int(color)
			G.set_edge_label(int(u),int(v),color)

	#Gerando matriz de cores
	matrixColor = np.zeros((12,12))
	
	for v in G.vertices():
		lineV = list(range(12))
		for e in G.edges_incident(v):
			if (e[2] in lineV):
				lineV.remove(e[2])
			matrixColor[e[0]][e[1]] = e[2]+1
			matrixColor[e[1]][e[0]] = e[2]+1
		matrixColor[v][v] = lineV[0]+1
		# print(G.edges_incident(v))
	print(matrixColor)

	# Test if coloring is good.
	# if(is_good_coloring(G) == True):
	#	 print("Coloração verificada como ok!")
	# else:
	#	 print("Coloração não verificada!")

	# G.plot(heights=1022,color_by_label=True).show()

	# Seperando emparelhamentos em H[i] para i=0,1,...,11 (12 cores)
	H = list()
	for i in range(12):
		graphColor = []
		for e in G.edges():
			if(e[2] == i):
				graphColor.append(e)
		H.append(graphColor)

	#Regras para apresentar emparelhamentos (cores)
	# for i in range(10):
		# U = list()
		# for j in range(10):
			# if (i != j):
				# U = U + H[j]
		# T = G.subgraph(edges=U)
		# T.plot(heights=1022,color_by_label=True).show()

	# Apresentar união de emparelhamentos 
	size_matching = 5
	U = []
	for i in range(12):
		if (len(H[i]) == size_matching):
			U = U + H[i]

	T = G.subgraph(edges=U)
	# print(T.edges())
	# T.plot(heights=1022,color_by_label=True).show()


	return 1


