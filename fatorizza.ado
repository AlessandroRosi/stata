program define fatorizza
gettoken first : 0
local num `0'

		if regexm("`0'", "-")==1  {
				local num2=regexr("`0'", "-", " ") 
				tokenize `num2'
				local numSUP "`2'"
				local numINF "`1'"	
				di as text "from `numINF' to `numSUP'"
			forvalues i=`numINF'(1)`numSUP' {	
				local l = log10(`i')
				local l = int(`l')
				local l = `l' + 1
				di ""
				di ""
				di as result "______________________________________________________"
				di as result "`i'"
				di as text "Numero decimali: " as result "`l'"
				mata factor_ns(`i')
				di as result "______________________________________________________"
			}
		}
		
		else if regexm("`0'", "-")==0 {
			foreach i in `num' {
				local l = log10(`i')
				local l = int(`l')
				local l = `l' + 1
				di ""
				di ""
				di as result "______________________________________________________"
				di as result "`i'"
				di as text "Numero decimali: " as result "`l'"
				mata factor_ns(`i')
				di as result "______________________________________________________"
			}
		}
end


mata:
function factor_ns(n_) {
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
		a=rows(a)
		printf("Univoci:")
		a
		}
	}
end	