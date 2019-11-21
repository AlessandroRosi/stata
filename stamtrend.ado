

cap program drop stamtrend
program define stamtrend
syntax, VARlist(string) [name(string) set(string) path(string) use(string)  HPSmooth(integer 10)  Year(integer 1990) save(string) hptrend HPYear(string) quite lag(integer 2) nograph]


if "`set'"!="" {
	foreach c in `varlist'{
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

	tokenize `varlist'
	use "`path'\\`1'.dta", clear
	foreach i in `varlist' {
		cap merge 1:1 year using "$path\\`2'.dta", nogen
		macro shift
	}
	qui drop if year>2018
	order year
	save "`path'\\`name'.dta", replace

exit
}

else if "`set'"=="" {
di as result "$S_FN" as text " in memory"
di ""
}



if "`use'"!="" {
use "`path'\\`use'.dta", clear
}

local n=1
foreach i in `varlist' {
local `i'`n' "`i'"
local n=`n' + 1
}


tokenize `hpyear'
local n=1
foreach i in `varlist' {
local y`i'  "``i'`n'' `1'"
local n = `n' + 1
macro shift
}






foreach i in `varlist' {
tokenize `y`i''
local c `1'
local hpy `2'
local nobs`i'=   `2' - 1960 + `lag'
local yearRatio = `lag' + `2'


	cap drop `c'_hp 
	cap drop `c'c
	cap drop f_`i'*
	
	di as result "`i'"
	
	if "`quite'"=="quite" {
		qui {
		tsset year
		tsfilter hp `c'_hp=`c' if year<=`hpy', smooth(`hpsmooth')
		gen `c'c=`c' - `c'_hp
		var `c'c
		local fstep = 2018 - `hpy'
		fcast compute f_, step(`fstep') 
		}
	}
	else if "`quite'"!="quite" {
		tsset year
		tsfilter hp `c'_hp=`c' if year<=`hpy', smooth(`hpsmooth')
		gen `c'c=`c' - `c'_hp
		var `c'c
		local fstep = 2018 - `hpy'
		fcast compute f_, step(`fstep'
	}
	
	
	if "`hptrend'"=="hptrend" {
	local trend "(line `c'c year if year>=`year', lcolor(black*.3))"
	}
	
	qui drop if year>2018
	
	
	if "`nograph'"!="" {
	twoway `trend' (line `c' year if year>=`year', lcolor(dknavy))  (line f_`c'c year if year>=`year', lpattern(dash) lcolor(dknavy*0.8)), name(`c', replace)
	}
	
	if "`save'"!="" {
	graph export "`path'\\`save'.png", replace
	}

}



foreach i in `varlist' {
local fgdp`i' = f_`i'c in `nobs`i''
local rgdp`i' = `i' in `nobs`i''
local ratio`i' =  1 - (`rgdp`i'' / `fgdp`i'')

di ""
di "_____________________________________________"
di as text "`i' (`yearRatio') :" as result "`ratio`i''"
di "_____________________________________________"
di ""

}



end

cls
exit


* stamtrend, var(USA EUU) set(API_NY.GDP.MKTP.KD_DS2_en_csv_v2_422136.csv) path(C:\Users\alessandror\Desktop\stamato) name(all)

* stamtrend,  var(EUU USA) hpy(2008 2007) hptrend results quite


stamtrend,  var(EUU USA) hpy(2008 2007) lag(3) hptrend quite nograph



forvalues n=1(1)8 {

stamtrend,  var(EUU USA) hpy(2008 2007) lag(`n') hptrend quite nograph


}




