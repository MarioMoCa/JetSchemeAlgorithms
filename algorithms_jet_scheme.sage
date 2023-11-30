def jet_ring(base,var,dim,trun,monomial_order):
	"""
	Constructs the section ring of the jet scheme of some level of an affine scheme.

	**Inputs:**

		- `base`: the base field.
		- `var`: a list $[v_0,\dots,v_n]$ of strings containing the names of the variables of the (polynomial) section ring of the affine space.
		- `dim`: a list $[d_0,\dots,d_n]$ of positive integers of the same lenght as `var`. If some integer $d_i$ is greater than 1, then the base polynomial ring is supposed to have $d_i$ copies of the variable $v_i$, which are called $v_{i,0},\dots,v_{i,d_i-1}$.
		- `trun`: a positive integer, the level of the jet scheme plus 1.
		- `monomial_order`: the monomial order on the section ring of the jet scheme, described with respect to the ordered list of variables $v_{0,0},\dots,v_{0,d_0-1},v_{1,0},\dots,v_{1,d_1-1},\dots,v_{n,0},\dots,v_{n,d_n-1}$.

	**Output:** the (polynomial) section ring of the jet scheme of level `trun`-1 of the affine scheme whose section ring is the polynomial ring in the variables in `var`, each one appearing as many times as the corresponding integer in `dim`.
	"""
	variables=[];
	for r in range(len(var)):
		if dim[r]==1:
			variables.extend([var[r]+'%i' %i for i in range(trun)]);
		else:
			for j in range(dim[r]):
				variables.extend([var[r]+str(j)+'%i' %i for i in range(trun)]);
	R=PolynomialRing(base, variables, order=monomial_order);
	return R
	

def truncation_order(R):
	"""
	Given a (polynomial) section ring of a jet scheme of level $m$ of an affine space, returns the order of truncation $m+1$.

	Caution: does not work if the polynomial ring has been constructed using `jet_ring` where `dim` contains some entries equal to 1 and some entries different from 1 (and possibly in other cases).

	**Inputs:**

		- `R`: a (polynomial) section ring of a jet scheme of level $m$ of an affine space. It must be of the form of the ones constructed using the function `jet_ring`.

	**Output:** the order of truncation $m+1$.
	"""
	c=len(R.variable_names()[-1])-len(R.variable_names()[0])+1;
	trun=int(R.variable_names()[-1][-c:])+1;
	return trun
	
	
def HasseSchmidt (L,N):
	"""
	Computes the polynomials in the ideal defining the jet scheme of a given level from the polynomials defining the base variety.

	**Inputs:**

		- `L`: a list $L=[f_1,\dots,f_r]$ of elements of $A_0$, the section ring of the $0$-jet scheme (which is canonically isomorphic to $A$, the (polynomial) section ring of the base affine scheme).
		- `N`: a non-negative integer number.

	**Output:** A list of lists $[[f_{1,0},\dots,f_{1,N}],\dots, [f_{r,0},\dots,f_{r,N}]]$, such that if $A=k[x_1,\dots,x_n]$ then for every $1\le i\le s$ we have the following equality in $k[x_1,\dots,x_n]_N[t]$:
	\\[f_i\left(\left(\sum\limits_{j=0}^{N}x_{i,j}t^{j}\right)_{0\le i\le n}\right)=\sum\limits_{s=0}^{N}f_{i,s}\left((x_{i,j})_{\substack{0\le i\le n\\0\le j\le s}}\right)t^s \hspace{5mm}(\mathrm{mod}\; t^{N+1})\\]
	"""
	trun=truncation_order(L[0].parent());
	v=list(L[0].parent().variable_names());
	v.append('t');
	nvar=L[0].parent().ngens()//trun;
	R1=PolynomialRing(L[0].parent().base_ring(), v, order=L[0].parent().term_order());
	varser=[sum([R1.gen(r*trun+i)*R1.gen(R1.ngens()-1)^i for i in range(N+1)]) for r in range(nvar)];
	dicsub = dict((R1.gen(r*trun),varser[r]) for r in range(nvar));
	Lseries=[R1(s).subs(dicsub) for s in L];
	LHS=[[L[0].parent()(s.coefficient({R1.gen(R1.ngens()-1):i})) for i in range(N+1)] for s in Lseries];
	return LHS
	
	
def HS_to_ideal (LHS,N):
	"""
	Returns the ideal generated by the polynomials in the input of `HasseSchmidt`.

	**Inputs:**

		- `LHS`: a list of lists $[[f_{1,0},\dots,f_{1,N}],\dots, [f_{r,0},\dots,f_{r,N}]]$ as in the output of `HasseSchmidt`.
		- `N`: a non-negative integer number, corresponding to the size of any of the inner lists in `LHS`.

	**Output:** The ideal generated by all the polynomials in `LHS`.
	"""
	gen=[];
	for s in LHS:
		gen=gen + s[:N+1];
	HSideal=gen[0].parent().ideal(gen);
	return HSideal   
	
	
def Delta (f):
	"""
	Implements the derivation $\Delta:A_\infty\rightarrow A_\infty$, given by $\Delta(T_{e,i})=T_{e,i+1}$.

	**Inputs:**

		- `f`: a polynomial in an "affine jet ring", a ring as in the output of `jet_ring`.

	**Output:** The polynomial $\Delta(f)$ as an element of the same ring (the truncation level of the ring must be large enough).
	"""
	trun=truncation_order(f.parent());
	nvar=f.parent().ngens()//trun
	a=sum([sum([f.derivative(f.parent().gen(r*trun+i))*f.parent().gen(r*trun+i+1) for i in range(trun-1)]) for r in range(nvar)])
	return a
	

def Delta_it (f,N):
	"""
	Implements the iteration of the derivation $\Delta:A_\infty\rightarrow A_\infty$, given by $\Delta(T_{e,i})=T_{e,i+1}$.

	**Inputs:**

		- `f`: a polynomial in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The polynomial $\Delta^N(f)$ as an element of the same ring (the truncation level of the ring must be large enough).
	"""
	for i in range(N):
		f=Delta(f);
	return f
	
	
def Delta_list (f,N):
	"""
	Returns a list with some iterations of the derivation $\Delta:A_\infty\rightarrow A_\infty$, given by $\Delta(T_{e,i})=T_{e,i+1}$.

	**Inputs:**

		- `f`: a polynomial in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The list $[f,\Delta(f),\Delta^2(f),...,\Delta^N(f)]$ of size $N+1$, where each polynomial is an element of the same ring as $f$ (the truncation level of the ring must be large enough).
	"""
	l=[f];
	for i in range(N):
		l.append(Delta(l[-1]));
	return l
	
	
def Delta_ideal (L,N):
	"""
	Given an ideal, returns the corresponding truncated differential ideal up to a given order for the derivation $\Delta:A_\infty\rightarrow A_\infty$, given by $\Delta(T_{e,i})=T_{e,i+1}$.

	**Inputs:**

		- `L`: a list of polynomials in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The ideal $\langle f,\Delta(f),\Delta^2(f),...,\Delta^N(f):f\in L\rangle$ of the same ring (the truncation level of the ring must be large enough).
	"""
	gen=[];
	for r in L:
		gen=gen+Delta_list(r,N);
	Deltaideal=L[0].parent().ideal(gen);
	return Deltaideal
	
	
def deltilde (f):
	"""
	Implements the derivation $\tilde{\delta}_{\infty}:A_\infty\rightarrow A_\infty$, given by $\tilde{\delta}_{\infty}(T_{e,i})=(i+1)T_{e,i+1}$.

	**Inputs:**

		- `f`: a polynomial in an "affine jet ring", a ring as in the output of `jet_ring`.

	**Output:** The polynomial $\tilde{\delta}_{\infty}(f)$ as an element of the same ring (the truncation level of the ring must be large enough).
	"""
	trun=truncation_order(f.parent());
	nvar=f.parent().ngens()//trun
	a=sum([sum([(i+1)*f.derivative(f.parent().gen(r*trun+i))*f.parent().gen(r*trun+i+1) for i in range(0,trun-1)]) for r in range(0,nvar)])
	return a
	
	
def deltilde_it (f,N):
	"""
	Implements the iteration of the derivation $\tilde{\delta}_{\infty}:A_\infty\rightarrow A_\infty$, given by $\tilde{\delta}_{\infty}(T_{e,i})=(i+1)T_{e,i+1}$.

	**Inputs:**

		- `f`: a polynomial in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The polynomial $\tilde{\delta}_{\infty}^N(f)$ as an element of the same ring (the truncation level of the ring must be large enough).
	"""
	for i in range(0,N):
		f=deltilde(f);
	return f
	
	
def deltilde_list (f,N):
	"""
	Returns a list with some iterations of the derivation $\tilde{\delta}_{\infty}:A_\infty\rightarrow A_\infty$, given by $\tilde{\delta}_{\infty}(T_{e,i})=(i+1)T_{e,i+1}$.

	**Inputs:**

		- `f`: a polynomial in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The list $[f,\tilde{\delta}_{\infty}(f),\tilde{\delta}_{\infty}^2(f),...,\tilde{\delta}_{\infty}^N(f)]$ of size $N+1$, where each polynomial is an element of the same ring as $f$ (the truncation level of the ring must be large enough).
	"""
	l=[f];
	for i in range(0,N):
		l.append(deltilde(l[-1]));
	return l
	
	
def deltilde_ideal (L,N):
	"""
	Given an ideal, returns the corresponding truncated differential ideal up to a given order for the derivation $\tilde{\delta}_{\infty}:A_\infty\rightarrow A_\infty$, given by $\tilde{\delta}_{\infty}(T_{e,i})=(i+1)T_{e,i+1}$.

	**Inputs:**

		- `L`: a list of polynomials in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The ideal $\langle f,\tilde{\delta}_{\infty}(f),\tilde{\delta}_{\infty}^2(f),...,\tilde{\delta}_{\infty}^N(f):f\in L\rangle$ of the same ring (the truncation level of the ring must be large enough).
	"""
	gen=[];
	for r in L:
		gen=gen+deltilde_list(r,N);
	deltildeideal=L[0].parent().ideal(gen);
	return deltildeideal
	

def deltilde_corr_list (f,N):
	"""
	Returns a list with some iterations of the derivation $\tilde{\delta}_{\infty}:A_\infty\rightarrow A_\infty$, given by $\tilde{\delta}_{\infty}(T_{e,i})=(i+1)T_{e,i+1}$ with the correction factor in the denominator. If $char(k)=0$, we obtain the same result than using Hasse-Schmidt derivations, but usually faster.

	**Inputs:**

		- `f`: a polynomial in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The list $[f,\tilde{\delta}_{\infty}(f),\frac{\tilde{\delta}_{\infty}^2(f)}{2!},...,\frac{\tilde{\delta}_{\infty}^N(f)}{N!}]$ of size $N+1$, where each polynomial is an element of the same ring as $f$ (the truncation level of the ring must be large enough).
	"""
	l=[f];
	for i in range(0,N):
		l.append(deltilde(l[-1])/(i+1));
	return l
	
	
def deltilde_corr_ideal (L,N):
	"""
	Given an ideal, returns the corresponding truncated differential ideal up to a given order for the derivation $\tilde{\delta}_{\infty}:A_\infty\rightarrow A_\infty$, given by $\tilde{\delta}_{\infty}(T_{e,i})=(i+1)T_{e,i+1}$ with the correction factor in the denominator. If $char(k)=0$, we obtain the same result than using Hasse-Schmidt derivations, but usually faster.

	**Inputs:**

		- `L`: a list of polynomials in an "affine jet ring", a ring as in the output of `jet_ring`.
		- `N`: a nonnegative integer number.

	**Output:** The ideal $\langle f,\tilde{\delta}_{\infty}(f),\frac{\tilde{\delta}_{\infty}^2(f)}{2!},...,\frac{\tilde{\delta}_{\infty}^N(f)}{N!}:f\in L\rangle$ of the same ring (the truncation level of the ring must be large enough).
	"""
	gen=[];
	for r in L:
		gen=gen+deltilde_corr_list(r,N);
	deltildecorrideal=L[0].parent().ideal(gen);
	return deltildecorrideal
	
	
def change_var_HS_to_diff (R):
	"""
	Given the section ring of a jet scheme of some affine space, performs the automorphism transforming the ideal obtained via Hasse-Schmidt derivations into the ideal obtained using $\Delta$.

	**Inputs:**

		- `R`: a polynomial ring, the section ring of the jet scheme of some level of an affine space (constructed for example using `jet_ring`).

	**Output:** The automorphism $\phi$ of `R` such that $\phi(\langle f_0,f_1,f_2,...,f_N:f\in L\rangle)=\langle f,\Delta(f),\Delta^2(f),...,\Delta^N(f):f\in L\rangle$.
	"""
	trun=truncation_order(R);
	nvar=R.ngens()//trun;
	phi=R.hom([R.gen(r*trun+i)/factorial(i) for r in range(nvar) for i in range(trun)]);
	return phi
	
	
def change_var_diff_to_HS (R):
	"""
	Given the section ring of a jet scheme of some affine space, performs the automorphism transforming the ideal obtained via the derivation $\Delta$ into the ideal obtained using Hasse-Schmidt derivations.

	**Inputs:**

		- `R`: a polynomial ring, the section ring of the jet scheme of some level of an affine space (constructed for example using `jet_ring`).

	**Output:** The automorphism $\phi$ of `R` such that $\phi(\langle f,\Delta(f),\Delta^2(f),...,\Delta^N(f):f\in L\rangle)=\langle f_0,f_1,f_2,...,f_N:f\in L\rangle$.
	"""
	trun=truncation_order(R);
	nvar=R.ngens()//trun;
	phi=R.hom([R.gen(r*trun+i)*factorial(i) for r in range(nvar) for i in range(trun)]);
	return phi
	
	
def jet_ring_HS(base_affine, base_ideal, trun):
	"""
	Given a polynomial ring and an ideal of this ring defining a variety $V$, it computes the section ring of the jet scheme of a given level `trun`=$m+1$ of the corresponding affine scheme and the ideal defining $\mathcal{L}_{m}(V)$ as a closed subscheme, using Hasse-Schmidt derivations (valid in arbitrary characteristic).

	**Inputs:**

		- `base_affine`: a polynomial ring, the section ring of the base affine scheme.
		- `base_ideal`: an ideal of `base_affine` defining the base variety $V$.
		- `trun`: a positive integer , the level $m$ of the jet scheme plus 1.

	**Output:** A list containing:
		- In the first position the (polynomial) section ring of the jet scheme of level `trun`-1 of the affine scheme corresponding to `base_affine`.
		- In the second position the ideal of the preceding polynomial ideal defining $\mathcal{L}_{m}(V)$.
	"""
	var=list(base_affine.variable_names());
	R=jet_ring(base_affine.base_ring(),var,[1 for r in var],trun,base_affine.term_order());
	inj=base_affine.hom([R.gen(i*trun) for i in range(base_affine.ngens())]);
	gen_base_ideal=base_ideal.gens();
	inj_base_ideal=[inj(g) for g in gen_base_ideal];
	HSideal_gen=HasseSchmidt(inj_base_ideal,trun-1);
	HSideal=HS_to_ideal(HSideal_gen,trun-1);
	return [R,HSideal]
	
	
def jet_ring_Delta(base_affine, base_ideal, trun):
	"""
	Given a polynomial ring and an ideal of this ring defining a variety $V$, it computes the section ring of the jet scheme of a given level `trun`=$m+1$ of the corresponding affine scheme and the ideal defining $\mathcal{L}_{m}(V)$ as a closed subscheme, using the derivation $\Delta$ (valid in characteristic 0).

	**Inputs:**

		- `base_affine`: a polynomial ring, the section ring of the base affine scheme.
		- `base_ideal`: an ideal of `base_affine` defining the base variety $V$.
		- `trun`: a positive integer , the level $m$ of the jet scheme plus 1.

	**Output:** A list containing:
		- In the first position the (polynomial) section ring of the jet scheme of level `trun`-1 of the affine scheme corresponding to `base_affine`.
		- In the second position the ideal of the preceding polynomial ideal defining $\mathcal{L}_{m}(V)$.
	"""
	var=list(base_affine.variable_names());
	R=jet_ring(base_affine.base_ring(),var,[1 for r in var],trun,base_affine.term_order());
	inj=base_affine.hom([R.gen(i*trun) for i in range(base_affine.ngens())]);
	gen_base_ideal=base_ideal.gens();
	inj_base_ideal=[inj(g) for g in gen_base_ideal];
	Deltaideal=Delta_ideal(inj_base_ideal,trun-1);
	return [R,Deltaideal]
	
	
def jet_ring_deltatilde(base_affine, base_ideal, trun):
	"""
	Given a polynomial ring and an ideal of this ring defining a variety $V$, it computes the section ring of the jet scheme of a given level `trun`=$m+1$ of the corresponding affine scheme and the ideal defining $\mathcal{L}_{m}(V)$ as a closed subscheme, using the derivation $\tilde{\delta}_{\infty}$ (valid in characteristic 0).

	**Inputs:**

		- `base_affine`: a polynomial ring, the section ring of the base affine scheme.
		- `base_ideal`: an ideal of `base_affine` defining the base variety $V$.
		- `trun`: a positive integer , the level $m$ of the jet scheme plus 1.

	**Output:** A list containing:
		- In the first position the (polynomial) section ring of the jet scheme of level `trun`-1 of the affine scheme corresponding to `base_affine`.
		- In the second position the ideal of the preceding polynomial ideal defining $\mathcal{L}_{m}(V)$.
	"""
	var=list(base_affine.variable_names());
	R=jet_ring(base_affine.base_ring(),var,[1 for r in var],trun,base_affine.term_order());
	inj=base_affine.hom([R.gen(i*trun) for i in range(base_affine.ngens())]);
	gen_base_ideal=base_ideal.gens();
	inj_base_ideal=[inj(g) for g in gen_base_ideal];
	deltatildeideal=deltilde_ideal(inj_base_ideal,trun-1);
	return [R,deltatildeideal]
	
	
def jet_ring_deltatilde_corr(base_affine, base_ideal, trun):
	"""
	Given a polynomial ring and an ideal of this ring defining a variety $V$, it computes the section ring of the jet scheme of a given level `trun`=$m+1$ of the corresponding affine scheme and the ideal defining $\mathcal{L}_{m}(V)$ as a closed subscheme, using the derivation $\tilde{\delta}_{\infty}$ (valid in characteristic 0) with the correction factor in the denominator. If $char(k)=0$, we obtain the same result than using Hasse-Schmidt derivations, but usually faster.

	**Inputs:**

		- `base_affine`: a polynomial ring, the section ring of the base affine scheme.
		- `base_ideal`: an ideal of `base_affine` defining the base variety $V$.
		- `trun`: a positive integer , the level $m$ of the jet scheme plus 1.

	**Output:** A list containing:
		- In the first position the (polynomial) section ring of the jet scheme of level `trun`-1 of the affine scheme corresponding to `base_affine`.
		- In the second position the ideal of the preceding polynomial ideal defining $\mathcal{L}_{m}(V)$.
	"""
	var=list(base_affine.variable_names());
	R=jet_ring(base_affine.base_ring(),var,[1 for r in var],trun,base_affine.term_order());
	inj=base_affine.hom([R.gen(i*trun) for i in range(base_affine.ngens())]);
	gen_base_ideal=base_ideal.gens();
	inj_base_ideal=[inj(g) for g in gen_base_ideal];
	deltatildecorrideal=deltilde_corr_ideal(inj_base_ideal,trun-1);
	return [R,deltatildecorrideal]
	
	
def base_ring_inclusion_jet_ring(base_affine,R):
	"""
	Given the section ring $A$ of a base affine space and the section ring $A_m$ of its jet scheme of some level, it constructs the inclusion morphism $A\rightarrow A_m$.

	**Inputs:**

		- `base_affine`: a polynomial ring, the section ring $A$ of the base affine space.
		- `R`: a polynomial ring, the section ring $A_m$ of the jet scheme of some level of the affine space corresponding to `base_affine`. It must be of the form of the rings contructed using `jet_ring`.

	**Output:** The inclusion morphism $A\rightarrow A_m$.
	"""
	trun=truncation_order(R);
	phi=base_affine.hom([R.gen(trun*i) for i in range(base_affine.ngens())])
	return phi
	

def jet_rings_inclusion(small_jet_ring,big_jet_ring):
	"""
	Given the section rings $A_n$ and $A_m$ of the jet schemes of level $n$ and $m$ respectively ($n<m$) of an affine space, it constructs the inclusion morphism $A_n\rightarrow A_m$.

	**Inputs:**

		- `small_jet_ring`: a polynomial ring, the section ring $A_n$ of the base affine space. It must be of the form of the rings contructed using `jet_ring`.
		- `big_jet_ring`: a polynomial ring, the section ring $A_m$ of the base affine space. It must be of the form of the rings contructed using `jet_ring`.


	**Output:** The inclusion morphism $A_n\rightarrow A_m$.
	"""
	small_trun=truncation_order(small_jet_ring);
	big_trun=truncation_order(big_jet_ring);
	nvar=small_jet_ring.ngens()//small_trun;
	inj_images=[];
	for r in range(nvar):
		inj_images.extend([big_jet_ring.gen(r*big_trun+i) for i in range(small_trun)]);
	jet_inj=small_jet_ring.hom(inj_images);
	return jet_inj
	
	
def general_component_saturation(base_affine,base_ideal,N):
	"""
	Given a polynomial ring and an ideal of this ring defining a variety $V$, it computes the ideal $\mathcal{N}_N(V)$ defining the general component of the jet scheme of level $N$ of $V$.

	**Inputs:**

		- `base_affine`: a polynomial ring, the section ring of the base affine scheme.
		- `base_ideal`: an ideal of `base_affine` defining the base variety $V$.
		- `N`: a positive integer , the level of the jet scheme.

	**Output:** The ideal $\mathcal{N}_N(V)$ defining the general component of $\mathcal{L}_{N}(V)$.
	"""
	# We construct the affine variety, compute the Jacobian ideal and choose the element H for the saturation
	affine_space=AffineSpace(base_affine);
	variety=affine_space.subscheme(base_ideal);
	jac_ideal=variety.Jacobian();
	jac_generators=jac_ideal.gens();
	for g in jac_generators:
		if base_ideal.reduce(g)!=0:
			H=g;
			break
	# We construct the jet ring and the ideal of Hasse-Schmidt derivatives and inject the chosen H
	[jetring,ideal_HS]=jet_ring_HS(base_affine, base_ideal, N+1);
	base_inj_jet=base_ring_inclusion_jet_ring(base_affine,jetring);
	H_jet=base_inj_jet(H);
	# We extend the ring for the computation of the saturation as an elimination ideal
	v=list(jetring.variable_names());
	v.append('t');
	R1=PolynomialRing(jetring.base_ring(), v, order=jetring.term_order());
	# We define the inclusion morphism from jetring in R1 and compute the extension of the ideal
	inj_extension=jetring.hom(list(R1.gens())[:-1]);
	ideal_HS_extension=inj_extension(ideal_HS);
	# We construct the aimed ideal and perform the elimination
	sat_element=R1.ideal([1-inj_extension(H_jet)*R1.gen(R1.ngens()-1)]);
	sat_ideal=ideal_HS_extension+sat_element;
	elim_ideal=sat_ideal.elimination_ideal([R1.gen(R1.ngens()-1)]);
	# We change the resulting ideal to the original ring
	contraction_morph=R1.hom(list(jetring.gens())+[0]);
	saturation=contraction_morph(elim_ideal);
	return saturation
	
	
def general_component_birational(base_affine,birring,birideal,birimage,N):
	"""
	Given a smooth birational model of a variety $V$, it computes the ideal $\mathcal{N}_N(V)$ defining the general component of the jet scheme of level $N$ of $V$.

	**Inputs:**

		- `base_affine`: a polynomial ring, the section ring of the base affine scheme.
		- `birring`: a polynomial ring, the section ring of the affine scheme which the smooth birational model is a closed subscheme of.
		- `birideal`: a list of elements of `birring` which generate the ideal defining the smooth birational model.
		- `birimage`: a list of elements of `birring` which contain the images of the variables in `base_affine` via the birational morphism.
		- `N`: a positive integer , the level of the jet scheme.

	**Output:** The ideal $\mathcal{N}_N(V)$ defining the general component of $\mathcal{L}_{N}(V)$.
	"""
	# We construct the corresponding jet ring
	var=list(base_affine.variable_names());
	R=jet_ring(base_affine.base_ring(),var,[1 for r in var],N+1,base_affine.term_order());
	trun=N+1;
	nvar=base_affine.ngens();
	# We construct the enlarged ring
	varbir=list(birring.variable_names());
	varbase=var;
	varaug=varbase+varbir;
	dimaug=[1 for s in varaug];
	R_aug=jet_ring(R.base_ring(),varaug,dimaug,trun,R.term_order());
	# We define the ring extension of the ring of the birational model into the elarged ring
	bir_inj=birring.hom([R_aug.gen((nvar + i)*trun) for i in range(birring.ngens())]);
	# We define the extension in the enlarged ring of the ideal defining the jet scheme of the birational model via HS
	gen_birideal_inj=[bir_inj(r) for r in birideal];
	gen_birideal_aug_HS=HasseSchmidt(gen_birideal_inj,N);
	birideal_aug_HS=HS_to_ideal(gen_birideal_aug_HS,N);
	# We define the ideal of the enlarged ring generated by the elements corresponding to the images of the variables via the birational morphism
	birimage_inj=[bir_inj(r) for r in birimage];
	dif_image=[R_aug.gen(trun*i)-birimage_inj[i] for i in range(len(birimage_inj))];
	dif_image_HS=HasseSchmidt(dif_image,N);
	ideal_image_HS=HS_to_ideal(dif_image_HS,N);
	# We define the sum of the preceding ideals and perform the elimination of variables to obtain the kernel
	K=ideal_image_HS + birideal_aug_HS;
	ker=K.elimination_ideal([R_aug.gen(j) for j in range(nvar*trun,len(varaug)*trun)])
	# We consider the obtained ideal in the original ring
	gen_ker=ker.gens();
	gen_ker_original_ring=[R(g) for g in gen_ker];
	ker_original=R.ideal(gen_ker_original_ring);
	return ker_original
	
	
def ideal_origin(I):
	"""
	Given an ideal of a jet scheme of some order of an affine space corresponding to the jet scheme of an affine variety as a closed subscheme, it returns the ideal defining the set of jets centered at the origin.

	**Inputs:**

		- `I`: an ideal of a jet ring $A_n$ (a ring constructed using `jet_ring`) defining as a closed subscheme the jet scheme of some affine variety.

	**Output:** An ideal of the same ring, defining the set $(\pi^{n}_{0})^{-1}(\mathfrak{o})$.
	"""
	trun=truncation_order(I.ring());
	nvar=I.ring().ngens()//trun;
	origin=I.ring().ideal([I.ring().gen(trun*r) for r in range(nvar)]);
	J=I+origin;
	return J
	
	
def V(I,J):
	"""
	Given two ideals $I,J$ of the same polynomial ring, returns the ideal $I+J$ with generators those of $J$ and the reduction of those of $I$ modulo (the reduced Gröbner basis of) $J$.

	**Inputs:**

		- `I`: an ideal of a polynomial ring.
		- `J`: an ideal of the same polynomial ring.

	**Output:** The ideal $I+J$ of the same ring, with generators $\langle g,\mathrm{red}_{J}(f):f \text{ a generator of I}, g \text{ a generator of J}\rangle$.
	"""
	L=J.gens().copy()
	for f in I.gens():
		L.append(J.reduce(f))
	return I.ring().ideal(L)
	
	
def simplify_quotient_ring(I):
	"""
	Given an ideal $I$ of a polynomial ring $A$, it returns another ideal $H$ of a polynomial ring $A'$ such that $A/I\cong A'/H$. The ring $A'$ is the quotient of $A$ by the ideal generated by all the coordinates which appear in the obtained presentation of $I$.

	**Inputs:**

		- `I`: an ideal of a polynomial ring.

	**Output:** An ideal $H$ of the polynomial ring $A'$ such that $A/I\cong A'/H$. The ring $A'$ is the quotient of $A$ by the ideal generated by all the coordinates which appear in the obtained presentation of $I$.
	"""
	var_elim=list(set(I.ring().irrelevant_ideal().gens()).intersection(I.gens()))#list of variables we can eliminate
	A1=I.ring().remove_var(*var_elim)#constructs the new ring removing these variables
	images_quotient=[f if f not in var_elim else 0 for f in I.ring().irrelevant_ideal().gens()]#images of the coordinates in the new ring, just send those that we eliminate to 0
	quotient_morphism=I.ring().hom(images_quotient,A1)
	return quotient_morphism.pushforward(I)
	
	
def Grothendieck_cut_V(I,J):
	"""
	Given two ideals $I,J$ of the same polynomial ring $A$, it returns another ideal $H$ of a polynomial ring $A'$ such that $A/\sqrt{(I+J)}\cong A'/H$. The ring $A'$ is the quotient of $A$ by the ideal generated by all the coordinates which appear in the obtained presentation of $\sqrt{(I+J)}$.

	Note that this function probably requires the computation of a Gröbner basis for computing $\sqrt{(I+J)}$.

	**Inputs:**

		- `I`: an ideal of a polynomial ring.
		- `J`: an ideal of the same polynomial ring.

	**Output:** An ideal $H$ of the polynomial ring $A'$ such that $A/\sqrt{(I+J)}\cong A'/H$. The ring $A'$ is the quotient of $A$ by the ideal generated by all the coordinates which appear in the obtained presentation of $\sqrt{(I+J)}$.
	"""
	I_cut=V(I,J)
	I_cut_rad=I_cut.radical()
	return simplify_quotient_ring(I_cut_rad)
	
	
def free_variables(I):
	"""
	Given an ideal $I$ of some polynomial ring, a list containing all the coordinates of the ring which do not appear in any generator of the ideal (hence they are free).

	**Inputs:**

		- `I`: an ideal of a polynomial ring.

	**Output:** A list containing the coordinates of the ring which do not appear in any generator of the ideal.
	"""
	degrees=[0]*I.ring().ngens()
	for f in I.gens():
		degrees=[max(l1, l2) for l1, l2 in zip(degrees, f.degrees())]#computes the variables which appear in some generator of the ideal via the multidegrees
	free_variables=[]
	for i in range(len(degrees)):
		if degrees[i]==0:
			free_variables.append(I.ring().irrelevant_ideal().gen(i))
	return free_variables
	
	
def remove_zero_generators(I):
	"""
	Given an ideal $I$ of a polynomial ring, it returns the same ideal without the zero generators, if any.

	**Inputs:**

		- `I`: an ideal.

	**Output:** The same ideal not including zero generators in its presentation.
	"""
	return I.ring().ideal([f for f in I.gens() if f!=0])
	
	
def cut_D(I,L):
	"""
	Given an ideal $I$ of the a polynomial ring $A$ and a list of coordinates $L$, it returns the ideal $I+\langle T_iT_{i,inv}-1:T_i\in L\rangle$ of the polynomial ring $A[T_{i,inv}]$. This ideal is equal to the extension of $I$ in the localization $A_{\prod_{T_i\in L} T_i}$, up to the isomorphism $A_{\prod_{T_i\in L} T_i}\cong A[T_{i,inv}]/\langle T_iT_{i,inv}-1:T_i\in L\rangle$.

	**Inputs:**

		- `I`: an ideal of a polynomial ring.
		- `L`: a list of the coordinates of the same polynomial ring that we want to make units.

	**Output:** The ideal $I+\langle T_iT_{i,inv}-1:T_i\in L\rangle$ of the polynomial ring $A[T_{i,inv}]$.
	"""
	A1=PolynomialRing(I.ring().base(),list(I.ring().variable_names())+[str(f)+'_inv' for f in L],order=I.ring().term_order())#constructs a polynomial ring with new variables corresponding to inverses to the given elements
	localization_ideal=A1.ideal([L[i]*A1.gen(A1.ngens()-len(L)+i)-1 for i in range(len(L))])#the ideal with the relations making the previous ring isomorphic to the localization
	localization_map=I.ring().hom(I.ring().irrelevant_ideal().gens(),A1)
	return localization_map.pushforward(I)+localization_ideal
	
	
def units(A):
	"""
	Given a polynomial ring $A$ of the form $A'[T_{i,inv}]$, it identifies the variables $T_i$ which have been inversed using the function `cut_D` and returns them and the ideal $\langle T_iT_{i,inv}-1:T_i\in L\rangle$ of relations such that $A'_{\prod T_i}\cong A/\langle T_iT_{i,inv}-1:T_i\in L\rangle$.

	**Inputs:**

		- `A`: a polynomial ring.

	**Output:** A list containing:
		- In the first entry, a list whose entries are lists of the form $[T_i,T_{i,inv}]$.
		- In the second entry, the ideal $\langle T_iT_{i,inv}-1:T_i\in L\rangle$ of $A$.
	"""
	inverses=[var for var in A.variable_names() if '_inv' in var]
	units=[[A.variable_names().index(var[:-4]),A.variable_names().index(var)] for var in inverses]
	localization_ideal=A.ideal([A.gen(var[0])*A.gen(var[1])-1 for var in units])#construir el ideal de relaciones
	return [units,localization_ideal]
	
	
def eliminate_variables_D(I,var,f):
	"""
	Given an ideal $I$ of a localization of a polynomial ring $A$ in the variables $T_i$, a variable $x_i$ of this polynomial ring and a generator $f$ of the ideal which allows to eliminate the variable, it performs this elimination. It returns the ideal $I'$ of $A'$ (here $A\cong A'[x_i]$) such that the morphism $\phi:A\rightarrow A'$ with kernel $\langle f\rangle$ induces an ismorphism $A/I\cong A'/I'$.

	Here we say that $f$ allows to eliminate $x_i$ if $x_i$ only appears in one monomial of $f$ with exponent 1 and all the other variables in this monomial are invertible.

	**Inputs:**

		- `I`: an ideal of a localization of a polynomial ring in some variables.
		- `var`: a variable of the ambient polynomial ring.
		- `f`: a generator of $I$ which allows to eliminate `var`.

	**Output:** $I'$ of $A'$ (here $A\cong A'[x_i]$) such that the morphism $\phi:A\rightarrow A'$ with kernel $\langle f\rangle$ induces an ismorphism $A/I\cong A'/I'$.
	"""
	[units_list,localization_ideal]=units(I.ring())
	var_position=I.ring().gens().index(var)
	f_position=I.gens().index(f)
	#Find the exponents of the invertible coordinates in the monomial where the coordinate we want to eliminate appears
	for monomial in I.gen(f_position).iterator_exp_coeff():
		if monomial[0][var_position]!=0:
			exponents_units=[monomial[0][unit[0]]-monomial[0][unit[1]] for unit in units_list]
	#Suitable multiple of f by the needed powers of the invertible coordinates so that the reduction modulo the localization ideal is direct
	f_multiple=I.gen(f_position)*prod([I.ring().gen(units_list[i][1])^exponents_units[i] if exponents_units[i]>=0 else I.ring().gen(units_list[i][1])^abs(exponents_units[i]) for i in range(len(units_list))])
	f_in_localization=localization_ideal.reduce(f_multiple)
	#Compute the coefficient of the variable we want to eliminate in the localization
	for monomial in f_in_localization.iterator_exp_coeff():
		if monomial[0][var_position]!=0:
			coef_var=monomial[1]
	image_var=-f_in_localization/coef_var+I.ring().gen(var_position)#This polynomial is equal to var in the localization modulo I
	A1=I.ring().remove_var(I.ring().gen(var_position))#constructs the new ring removing the variable
	images_quotient=[f if f!=I.ring().gen(var_position) else image_var for f in I.ring().irrelevant_ideal().gens()]#images of the coordinates in the new ring, just send those that we eliminate to 0
	quotient_morphism=I.ring().hom(images_quotient,A1)
	I1=quotient_morphism.pushforward(I)
	#We reduce modulo localization_ideal in the new ring again, otherwise some simplifications are not made
	[units_list1,localization_ideal1]=units(A1)
	I2=A1.ideal([localization_ideal1.reduce(f) for f in I1.gens()])+localization_ideal1
	#We remove the zero generators
	return remove_zero_generators(I2)
	
	
def can_eliminate_variables(I,L):
	"""
	Given an ideal $I$ of a polynomial ring $k[T_i]$ (maybe some coordinates are invertible because of the relations in the ideal, giving rise to a localization like the one constructed using `cut_D`) and a list of variables $L$, it returns a list of pairs $[T_i,g_i]$ of a variable $T_i$ of the polynomial ring $k[T_i]$ and a generator $g_i$ of $I$ which can be used to eliminate $T_i$ if we make all the variables in $L$ invertible (in addition to the ones which are already invertible in the ring modulo the corresponding relations)

	Here we say that $g_i$ allows to eliminate $T_i$ if $T_i$ only appears in one monomial of $g_i$ with exponent 1 and all the other variables in this monomial are invertible. Note a single generator may allow to eliminate more than one variable, then it will appear in more than one pair in the output.

	**Inputs:**

		- `I`: an ideal of a polynomial ring.
		- `L`: a list containing the new variables that we want to make invertible (possibly empty).

	**Output:** A list $[[T_{i_1},g_{i_1}],[T_{i_2},g_{i_2}],\dots,[T_{i_n},g_{i_n}]]$ where $T_{i_j}$ is a variable which can be eliminated using $g_{i_n}$ and assuming that the variables in $L$ are invertible, in addition to the ones which already were.
	"""
	[units_list,localization_ideal]=units(I.ring())
	new_units_list=[j for i in units_list for j in i]+[I.ring().gens().index(var) for var in L]
	#We map the generators into an auxiliary ring where all the invertible coordinates are mapped to 1
	images_map_aux=[I.ring().gen(i) if i not in new_units_list else 1 for i in range(I.ring().ngens())]
	A_aux=I.ring().remove_var(*[I.ring().gen(i) for i in new_units_list])
	map_aux=I.ring().hom(images_map_aux,A_aux)
	list_eliminate=[]
	#This loop looks, in every generator of the ideal, for variables which only appear in one monomial, with exponent 1 and with only invertible variables in that monomial
	for generator in I.gens():
		gen_aux=map_aux(generator)#We work in the auxiliary ring to remove the invertible variables
		gen_deg=list(gen_aux.iterator_exp_coeff())#The list with the multidegrees of each monomial of the generator (and also its coefficient)
		nonzero_monomials=[[i for i,e in enumerate(monomial[0]) if e!=0] for monomial in gen_deg]#List with the indices of the variables with nonzero exponent for each monomial of the generator 
		nonzero_poly=[i for monomial in nonzero_monomials for i in monomial]#List with all the indices of the variables which appear (exponent at least one) in the generator. Each index appears once for each occurrence of the variable in a monomial
		#Now we identify the monomials which are in fact variables we can eliminate using 3 conditions: (a) only one non-invertible variable in the monomial, (b) it has exponent 1 and (c) the variable does not appear in other monomial of the same generator
		for monomial in range(len(nonzero_monomials)):
			if len(nonzero_monomials[monomial])==1 and gen_deg[monomial][0][nonzero_monomials[monomial][0]]==1 and nonzero_poly.count(nonzero_monomials[monomial][0])==1:
				list_eliminate.append([map_aux.inverse_image(A_aux.gen(nonzero_monomials[monomial][0])),generator])#We come back to the corresponding variable in the original ring (we were in the auxiliary ring)
	return list_eliminate


def I_am_smarter_than_you(I,remove_generators,add_generators,remove_variables):
	"""
	Given an ideal of a polynomial ring $k[T_i]$, it returns the ideal $\langle f,g:f\text{ is a generator of }I\text{ not in remove_generators}, g\in\text{ add_generators}\rangle$ of the polynomial ring $k[T_i:T_i\notin \text{ remove_variables}]$.

	This function is useful for re-entering an ideal after some manipulations made by hand.

	**Inputs:**

		- `I`: an ideal of a polynomial ring.
		- `remove_generators`: a list containing the generators that we want to remove from the ideal.
		- `add_generators`: a list containing the generators that we want to add to the ideal.
		- `remove_variables`: a list containing the variables that we want to remove from the ring.

	**Output:** the ideal $\langle f,g:f\text{ is a generator of }I\text{ not in remove_generators}, g\in\text{ add_generators}\rangle$ of the polynomial ring $k[T_i:T_i\notin \text{ remove_variables}]$.
	"""
	return I.ring().remove_var(*remove_variables).ideal([gen for gen in I.gens() if gen not in remove_generators]+add_generators)
	
	
