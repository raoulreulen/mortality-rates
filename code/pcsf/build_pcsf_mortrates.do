* Builds data/pcsf_mortrates_hmd_5x1.dta from the Human Mortality Database
* period death rates "deathrates_period_5x1" (age-by-year grid 5x1; mortality.org, free registration).
* Set the two paths below. Extracted from pcsfcohort-rr-14m-gu-expected-competing-mortality.do.
local hmd "deathrates_period_5x1.dta"          // the HMD file you downloaded/converted
local out "pcsf_mortrates_hmd_5x1.dta"

use "`hmd'", clear
decode popname, gen(pop)
keep if inlist(pop,"FRATNP","HUN","ITA","NLD","DNK","SWE") | inlist(pop,"NOR","FIN","ISL","SVN","CHE","GBR_NP")
gen int ccode = .
replace ccode = 11 if pop=="FRATNP"
replace ccode = 21 if pop=="HUN"
replace ccode = 31 if pop=="ITA"
replace ccode = 42 if pop=="NLD"
replace ccode = 51 if pop=="DNK"
replace ccode = 52 if pop=="SWE"
replace ccode = 53 if pop=="NOR"
replace ccode = 54 if pop=="FIN"
replace ccode = 55 if pop=="ISL"
replace ccode = 61 if pop=="SVN"
replace ccode = 71 if pop=="CHE"
replace ccode = 81 if pop=="GBR_NP"
assert !missing(ccode)
expand 2 if ccode==31, gen(dup)          // Italy hospital cohort (32) uses the Italian rates
replace ccode = 32 if dup==1
drop dup pop popname
keep ccode year age female male
rename age ageband
replace ageband = ageband + 127          // HMD age is stored as a byte offset by -127
assert inlist(ageband,0,1) | mod(ageband,5)==0
replace ageband = 0 if ageband==1        // ages 0 and 1-4 -> band 0
gen int yr = year
drop year
rename yr year
collapse (mean) female male, by(ccode year ageband)
rename (male female) (mortrate1 mortrate2)
reshape long mortrate, i(ccode year ageband) j(sex)    // 1 = male, 2 = female
keep if ageband<=85                      // 85 = ages 85-89
keep if year>=1900                       // earlier HMD years never match the cohort
order ccode sex ageband year mortrate
sort ccode year ageband sex
label data "PCSF cohort country mortality rates (HMD period 5x1, all-cause, per person-year)"
label var ccode    "PCSF country code"
label var sex      "1=male 2=female"
label var ageband  "Lower age of 5-year band (0, 5, ..., 85; 0 = ages 0-4)"
label var year     "Calendar year (HMD period rates)"
label var mortrate "All-cause mortality rate per person-year"
label define ccode 11 "France" 21 "Hungary" 31 "Italy (pop-based)" 32 "Italy (hospital cohort)" ///
  42 "Netherlands" 51 "Denmark" 52 "Sweden" 53 "Norway" 54 "Finland" 55 "Iceland" ///
  61 "Slovenia" 71 "Switzerland" 81 "UK"
label values ccode ccode
label define sexl 1 "Male" 2 "Female"
label values sex sexl
compress
isid ccode sex ageband year
saveold "`out'", version(13) replace
