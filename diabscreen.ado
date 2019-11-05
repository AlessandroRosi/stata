program define diabscreen
syntax,  [Number(integer 1)  Gen(string)  Varscreen(string)] LFrame(string) CFrame(string) 
	
local listFRAMEname `lframe'
local currentFrame `cframe'
local number `number'



if "`number'"!="" {
mata list_getName(nameLIST, `number' )
}

if "`gen'"!="" {
cwf `currentFrame'
cap drop "`gen'"
gen `gen'=.
local nobs=_N
local var `varscreen'

	forvalues x=1(1)`nobs' {
	di "`x'"
	local prime = `var' in `x'

		mata factor(`prime')
		mata list_getName(nameLIST,`prime')
}
}



end	



	
	
	

mata:

	listFRAME = st_local("listFRAMEname")	
	current = st_local("currentFrame")

	function factor(n_) {
	x = strtoreal(st_local("x"))
	newvar = st_local("gen")
		n = n_
		a = J(0,2,.)
		if (n<2) {
		return(a)
		}
		else if (n<4) {
		return((n,1))	
		}
		else {
			if (mod(n,2)==0) {
			for (i=0; mod(n,2)==0; i++) n = floor(n/2)
			a = a\(2,i)
			}
			for (k=3; k*k<=n; k=k+2) {
				if (mod(n,k)==0) {
				for (i=0; mod(n,k)==0; i++) n = floor(n/k)
				a = a\(k,i)
				}
			}
			if (n>1) a = a\(n,1)
		a
		a=a[.,2]
		a
		a=rows(a)
		a
		st_store(x,newvar,a) 
		}
	}

	
	
	
	
	struct item {
	transmorphic scalar value
	pointer(struct item scalar) scalar next
	}
	
	struct list {
	pointer(struct item scalar) scalar head, tail
	}
	
	real scalar list_empty(struct list scalar a) {
	return(a.head == NULL)
	} 
	
	void function list_insert(struct list scalar a, transmorphic scalar x) {
	struct item scalar i
	i.value = x
	if (a.head == NULL) {
		i.next = NULL
		a.head = a.tail = &i
	} 
	else {
		i.next = a.head
		a.head = &i
	}
	}
	
	
	
	
	
	void list_show(struct list scalar a) {
	pointer(struct item scalar) scalar p
		for (p = a.head; p != NULL; p = (*p).next) {
			if (eltype((*p).value) == "string") {
				printf("%s\n", (*p).value);
			} else {
				printf("%f\n", (*p).value);
			}
		}
	}
	
	
	
	
	
	
	pointer(struct item scalar)  list_getName(struct list scalar a, real scalar n) {	
			t = n
			x = J(0,2,.)
			if (t<2) {
			return(x)
			}
			else if (t<4) {
			return((t,1))	
			}
			else {
			if (mod(t,2)==0) {
			for (m=0; mod(t,2)==0; m++) t = floor(t\2)
			 x\(2,m)
			}
			for (k=3; k*k<=t; k=k+2) {
			if (mod(t,k)==0) {
			for (m=0; mod(t,k)==0; m++) t = floor(t/k)
			x = x\(k,m)
			}
			}
			if (t>1) x = x\(t,1)	
			}
			x2=rows(x)
			stata(`"di "distinct:""')
	
	
	
	listFRAME = st_local("listFRAMEname")	
	current = st_local("currentFrame")

	
	st_framecurrent(listFRAME)
	prime= st_data(.,tokens("prime"))
		for (s=1; s<=rows(x); s++) {
		n=x[s,1]
			for (j = 1; j<=rows(prime); j++) {
				if (n==prime[j,1]) {
				d=j
				}
			}		
		pointer(struct item scalar) scalar p
		real scalar i
		p = a.head
		for (i = 1; p != NULL & i < d; i++) {
			p = (*p).next
		}
		p=(*p).value
		p
		}			
	st_framecurrent(current)
	}
	



	stata("cwf farmaci")

	nameLIST = st_local("lframe")
	nameLIST=list()
	List= st_sdata(.,tokens("type"))
	
	for (t=rows(List); t>=1; t--) {
		b=List[t,.]
		list_insert(nameLIST, b)
				}

end

	
