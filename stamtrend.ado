
program define stamtrend, rclass
syntax, vars(string) [name(string) set(string) path(string)  HPSmooth(integer 10)  Year(integer 1990) save(string) hptrend HPYear(string) quite noise lag(integer 2) VALyear(string) graph]

/*============================================================================*/
qui {

/*\	
------------------------------ LOAD DATASET ------------------------------------
\*/

	foreach c in `vars'{
		import delimited "`path'\\`set'", encoding(UTF-8) clear
		keep if v2=="`c'" 
		drop  v64 v65 v1 v3 v4 
		rename v2 country_code
		reshape long v, i(country_code) 
		gen year=1959 + _n
		drop  _j country_code
		rename v `c'
		label var `c' "GDP (constant 2010 US$)"
		save "`path'\\`c'.dta", replace
	}

	local w = wordcount("`vars'")
	tokenize `vars'
	use "`path'\\`1'.dta", clear
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
		local nobs`i' =   `2' - 1960 + `lag' + 1 
		local bnobs`i' = `2' - 1960 + 1
		local yearRatio`i' = `lag' + `2'


		local obs`i' = `2' - 1960 + 1 
		local base`i' = `i' in `obs`i''
		replace `i' = (`i' / `base`i'')  * 100

		cap drop `c'_hp 
		cap drop `c'c
		cap drop f_`i'*
			
		*noi di as result "`i'"
			
	
	
	
/*\	
--------------------------- ESTIMATE TREND -------------------------------------
\*/
			
		if "`quite'"=="quite" {
			qui {
			tsset year
			tsfilter hp `c'_hp=`c' if year<=`hpyear' & year>=1960, smooth(`hpsmooth')
			gen `c'c=`c' - `c'_hp
			var `c'c
			local fstep = 2018 - `hpyear'
			fcast compute f_, step(`fstep') 
			}
		}
		
		else if "`quite'"!="quite" {
			noi	tsset year
			noi	tsfilter hp `c'_hp=`c' if year<=`hpyear' & year >= 1960, smooth(`hpsmooth')
			gen `c'c=`c' - `c'_hp
			noi	var `c'c
			local fstep = 2018 - `hpyear'
			noi	fcast compute f_, step(`fstep')
		}
	
	
	
/*\	
--------------------------- DRAW COMBINED GRAPH --------------------------------
\*/
			
		if "`hptrend'"=="hptrend" {
			local trend "(line `c'c year if year>=`year', lcolor(black*.3))"
		}
			
		*qui drop if year>2018
			
			
		if "`graph'"=="graph" {
			twoway `trend' 														///
			(line `c' year if year>=`year', lcolor(dknavy)) 					///
			(line f_`c'c year if year>=`2', lpattern(dash) lcolor(dknavy*0.8)) 	///
			, name(`c', replace) 												///
			xlabel(1990(1)2018, labsize(medsmall) angle(forty_five))
		}
			
		if "`save'"!="" {
			graph export "`path'\\`save'.png", replace
		}
	}


	
	
/*\	
---------------------- COMPUTE THE TFP GDP DIFFERENCE RATIO --------------------
\*/

	foreach i in `vars' {
		local pot_gdp`i' = f_`i'c in `nobs`i''
		local act_gdp`i' = `i' in `nobs`i''
		local tratio`i' =  `act_gdp`i'' - `pot_gdp`i'' 
		return local `i'_`yearRatio`i'' "`tratio`i''"


		di ""
		noi di  as result "	───────────────────────────────────────"
		noi di as text "	`i' (`yearRatio`i'') :" as result " `tratio`i''"
		noi di  as result "	───────────────────────────────────────"
		di ""
	}
}
/*============================================================================*/
end
