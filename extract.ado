program define extract, rclass
version 16

						gettoken f 0:0
						if "`f'"=="help" {
							di ""
							di "___________________________________________________________________________________________________________________________"
							di as result "extract" as text " salva per ogni blocco un dta con n variabili (attributi) spalmate per le x osservazioni dei vettori estratti"
							di as text "I blocchi devono essere uguali nella struttura, alla stessa distanza e di lungheza uguale" 
							di as text "il primo blocco deve iniziare da 1"
							di ""
							di "___________________________________________________________________________________________________________________________"
							di 	as result "interval("as text"integer-integer"as result")" as text " prima osservazione e ultima osservazione del vettore da estrarre dal primo blocco"
							di 	as result "block("as text"integer"as result")"  as text " lunghezza complessiva del blocco (spazio tra la fine del primo blocco e l'inizio del successivo incluso)"
							di 	as result "nblock("as text"integer"as result")" as text " numero di blocchi"
							di 	as result "xatt("as text"integer integer ..."as result")" as text " x del primo attributo, x del secondo attributo ecc."
							di 	as result "yatt("as text"string string ..."as result")" as text " y del primo attributo, y del secondo attributo ecc. (usa nome variabile)"
							di 	as result "latt("as text"string string ..."as result")" as text " nome variabile primo attributo nome variabile secondo attributo ecc."
							di 	as result "xlvar("as text"integer"as result")" as text " numero riga dove si trovano i nomi delle variabili del primo blocco"
							di 	as result "path("as text"string"as result")" as text " percorso dove si trova il file e dove verranno salvati i dta"
							di ""
						exit
									
							clear all
							use prova/provaprova, clear
							extract var1 var2 var3 var4, xatt(1 2) yatt(var1 var1) latt(sesso anno) xlvar(3) interval(4-8) block(9) nblock(6) path(prova/provaprova) 
						
						}
	

	
	
syntax varlist, xatt(string) yatt(string) latt(string) xlvar(integer) interval(string) block(integer) nblock(integer) path(string)

	use `path', clear

	local num = "`interval'"
		if regexm("`num'", "(^[0-9])(-)([0-9]$)") {
			local to "`=regexs(3)'"
			local from "`=regexs(1)'"	
		}
		else if regexm("`num'", "(^[0-9])(-)([0-9][0-9]$)") {
			local to "`=regexs(3)'"
			local from "`=regexs(1)'"	
		}
		else if regexm("`num'", "(^[0-9])(-)([0-9][0-9][0-9]$)") {
			local to "`=regexs(3)'"
			local from "`=regexs(1)'"	
		}
		else if regexm("`num'", "(^[0-9])(-)([0-9][0-9]$)") {
			local to "`=regexs(3)'"
			local from "`=regexs(1)'"	
		}
		else if regexm("`num'", "(^[0-9][0-9])(-)([0-9][0-9][0-9]$)") {
			local to "`=regexs(3)'"
			local from "`=regexs(1)'"	
		}
		else if regexm("`num'", "(^[0-9][0-9][0-9])(-)([0-9][0-9][0-9]$)") {
			local to "`=regexs(3)'"
			local from "`=regexs(1)'"	
		}

		
		cap frame drop temp_frame
		
		local lenght= `to'-`from'+1
		local INTERVAL=`block'
		local nblock= `nblock'-1
		local end= `from'+`block'*`nblock'

		
		/* inizio ciclo su blocchi */
		forvalues i=`from'(`INTERVAL')`end'{

			frame create temp_frame
			frame temp_frame: qui set obs `lenght'
			
			
			
			/* trova il nome delle variabili da estrarre usando come 'x' xlvar */
				foreach i in `varlist' {

					local varn_`i' = `i' in `xlvar'
					/* fix spazio e numeri nel nome variabile */
					local varn_`i'=regexr("`varn_`i''", " ", "_")
					if regexm("`varn_`i''", "^[0-9]") local varn_`i'= "_`varn_`i''"
					local varnames `varnames' `varn_`i'' 
				}
		

			/* definisce il nome e la posizione degli attributi da spalmare */
				cap macro drop _attvar
				cap macro drop _savename
				
				tokenize `yatt'
				foreach i in `xatt' {
					local attvar_`1'_`i' = `1' in `i'
					macro shift	
				}
				
				tokenize `yatt'
				foreach i in `xatt' {
					local attvar `attvar' `attvar_`1'_`i''
					local savename = regexr("`attvar'", " ", "_")
					macro shift
				}
			
			
			
			/* estrae gli attributi da spalmare */
				tokenize `latt'
				foreach i in `attvar' {
				local att `i'
				mata: extract_att() 												/*MATA*/
				frame temp_frame: rename attvar `1'
				macro shift
				}
			
			/* estrae le variabili */
				tokenize `varnames'
				foreach i in `varlist' {
					mata: extract(`"`i'"')  										/*MATA*/
					frame temp_frame: rename varn `1'
					macro shift
				}	
				frame temp_frame: save "`path'_`savename'", replace
				frame drop temp_frame
						
			/* aggiorna le local di riferimento per il blocco successivo */
				local xlvar= `xlvar'+`block'
				mata: xattrefresh() 												/* MATA */
			
		
	}	
end








/******************************************************************************/
mata:
mata clear
function extract_att() {
	j=st_local("lenght")
	j=strtoreal(j)
	X=J(j,1, st_local("att"))	
	X 
	attvar=X
	stata("cwf temp_frame")
	newvars=st_addvar("strL","attvar")
	st_sstore(.,newvars,attvar)	
	stata("cwf default") 
}
	
	
function extract(string vvar) {
	j=st_local("lenght")
	s=st_local("from")
	j=strtoreal(j)
	s=strtoreal(s)
	N=st_sdata(.,vvar)
	R=J(j,1, "" )
	a=s+j-1
	t=0
	w=j+1
	for(i=s;i<=a;i++) {
		x=j-t
		y=w-x
		R[y,1]=N[i]	
		t=t+1	
	}	
	R
	varn=R
	stata("cwf temp_frame")	
	newvars=st_addvar("strL","varn")
	st_sstore(.,newvars,varn)
	stata("cwf default") 		
}


function xattrefresh()  {
	I=st_local("INTERVAL")
	I=strtoreal(I)
	X=st_local("xatt")
	Y=tokens(X," ")
	Y=strtoreal(Y)
	Y=Y'
	j=rows(Y)
	I=J(j,1, I)	
	Y=Y+I
	Y=Y'
	Y=strofreal(Y)
	st_local("xatt", invtokens(Y))
}			
end
/******************************************************************************/


