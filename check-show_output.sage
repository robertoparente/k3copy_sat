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
	# Checking proper coloring
	for v in G.edges():
		for f in G.edges_incident(v):
			for e in G.edges_incident(v):
				if (G.edge_label(e[0],e[1]) == G.edge_label(f[0],f[1]) and e!=f):
					if(f[0] == e[0] or f[1] == e[0] or e[1] == f[0] or e[1] == f[1]):
						print(e,f)
						return false

    # Checking if there are not two disjoint triangles with same coloring
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
	# Retrieving dictionary to translate number from sat-solver to variables
	with open(fileDic, 'r') as reader:
		for line in reader:
			dic_var,var = line.split(" : ")
			dic[int(var.rstrip("\n"))] = dic_var

	# Retrieving true variables from output of sat solver
	with open(fileOutPut, 'r') as reader:
		for line in reader:
			if (line[0] == 'v' and line[2] != '0'):
				x = line.split("v")
				vector = x[1].split(" ")
				for i in vector:
					if(i != '' and i[0] != '-'):
						true_var.append(int(i.rstrip("\n")))

	# Creating graph according to variables from sat solver
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



	# Test if coloring is good.
	if(is_good_coloring(G) == True):
		print("Coloring is ok.")	
	else:
		print("Coloring is not ok.")
		return 

	#Creating colors matrix
	matrixColor = np.zeros((12,12))
	for v in G.vertices():
		lineV = list(range(12))
		for e in G.edges_incident(v):
			if (e[2] in lineV):
				lineV.remove(e[2])
			matrixColor[e[0]][e[1]] = e[2]+1
			matrixColor[e[1]][e[0]] = e[2]+1
		matrixColor[v][v] = lineV[0]+1
	print(matrixColor)

	#Plotting graph
	G.plot(heights=1022,color_by_label=True).show()
	return 


