
program define stamtfp, rclass
syntax, vars(string) [name(string) set(string) path(string)  HPSmooth(integer 10)  Year(integer 1990) save(string) hptrend HPYear(integer 0) quite lag(integer 2) VALyear(integer 0) graph]

/*============================================================================*/
qui {

/*\	
------------------------------ LOAD DATASET ------------------------------------
\*/
	foreach c in `vars'{
		import delimited "`path'\\`set'", encoding(UTF-8) clear
		gen year= substr(date,1,4)
		destring year, replace
		qui ds
		tokenize `r(varlist)'
		rename `2' `c'tfp
		keep year `c'tfp
		drop if year<1960
		label var `c' "TFP"
		save "`path'\\`c'tfp.dta", replace
	}

	local w = wordcount("`vars'")
	tokenize `vars'
	use "`path'\\`1'tfp.dta", clear
	local im = 2
		
	while `im'<=`w' {
		merge 1:1 year using "`path'\\``im''.dta", nogen
		local im = `im' + 1
	}
		
	qui drop if year>2018
	order year `vars'
	save "`path'\\`name'.dta", replace


		
		
		
/*\	
---------------------------- PROGRAM MACROS ------------------------------------
\*/

	local n=1
		foreach i in `vars' {
		local `i'`n' "`i'"
		local n=`n' + 1
	}


	tokenize `valyear'
	local n=1
	foreach i in `vars' {
		local y`i'  "``i'`n'' `1'"
		local n = `n' + 1
		macro shift
	}



	
	
/*\	
---------------------------- SET DATA TO THE BASE YEAR -------------------------
\*/

	foreach i in `vars' {
	
		tokenize `y`i''
		local c `1'
		local hpy `2'
		local nobs`i'tfp =   `2' - 1960 + `lag' + 1
		local bnobs`i'tfp = `2' - 1960 + 1
		local yearRatio`i'tfp = `lag' + `2'

		local obs`i'tfp = `2' - 1960 + 1
		local base`i'tfp = `i'tfp in `obs`i'tfp'
		replace `i'tfp = (`i'tfp / `base`i'tfp' ) * 100 
		 
		cap drop `c'tfp_hp 
		cap drop `c'tfpc
		cap drop f_`i'*
			
		*noi di as result "`i'"
			
	
	
	
/*\	
--------------------------- ESTIMATE TREND -------------------------------------
\*/
			
		if "`quite'"=="quite" {
		qui {
			tsset year
			tsfilter hp `c'tfp_hp=`c'tfp if year<=`hpyear' & year>=1960, smooth(`hpsmooth')
			gen `c'tfpc=`c'tfp - `c'tfp_hp
			var `c'tfpc
			local fstep = 2018 - `hpyear' - 1
			fcast compute f_, step(`fstep') 
		}
		}
		
		else if "`quite'"!="quite" {
		noi	tsset year
		noi	tsfilter hp `c'tfp_hp=`c'tfp if year<=`hpyear' & year>=1960, smooth(`hpsmooth')
			gen `c'tfpc=`c'tfp - `c'tfp_hp
		noi	var `c'tfpc
			local fstep = 2018 - `hpyear' - 1
		noi	fcast compute f_, step(`fstep')
		}
			
	
	
	
/*\	
--------------------------- DRAW COMBINED GRAPH --------------------------------
\*/

		if "`hptrend'"=="hptrend" {
			local trend "(line `c'tfpc year if year>=`year', lcolor(black*.3))"
		}
			
		if "`graph'"=="graph" {
			twoway `trend'															 ///
			(line `c'tfp year if year>=`year', lcolor(dknavy)) 		 				 ///
			(line f_`c'tfpc year if year>=`year', lpattern(dash) lcolor(dknavy*0.8)) ///
			, name(`c'tfp, replace)													 ///
			xlabel(1990(1)2018, labsize(medsmall) angle(forty_five))
		}
			
		if "`save'"=="save" {
			graph export "`path'\\`save'.png", replace
		}
	}



	
	
/*\	
---------------------- COMPUTE THE TFP GDP DIFFERENCE RATIO --------------------
\*/

		foreach i in `vars' {
			local pot_tfp`i' = f_`i'tfpc in `nobs`i'tfp'
			local act_tfp`i' = `i'tfp in `nobs`i'tfp'
			local tratio`i' =  `act_tfp`i'' -  `pot_tfp`i'' 
			return local `i'tfp_`yearRatio`i'tfp' "`tratio`i''"

			di ""
			noi di  as result "	───────────────────────────────────────"
			noi di as text "	`i' tfp (`yearRatio`i'tfp') :" as result " `tratio`i''"
			noi di  as result "	───────────────────────────────────────"
			di ""
		}
}
/*============================================================================*/
end

