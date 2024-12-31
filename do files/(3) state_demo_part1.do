*Do file for demographic data append

cd "C:\Users\wball\OneDrive - CUNY\Hunter College\Thesis\EV\Data"

use "./cps_00012.dta", clear

sum

list county in 1/10

tab statefip

*drop if county==0


gen county_str = string(county)
replace county_str = "0" + county_str if strlen(county_str)==4
drop county

numlabel, add
tab month

*Create quarter variable============================
gen quarter=.
replace quarter =1 if inrange(month,1,3)
replace quarter = 2 if inrange(month,4,6)
replace quarter = 3 if inrange(month,7,9)
replace quarter = 4 if inrange(month, 10,12)

*Clean up sex so the collapsed avg indicates proportion male
sum sex
tab sex

replace sex=0 if sex==2
tab sex
label define sex 0 female, add
label define sex  1 male, add
label values sex sex

numlabel, add
tab sex


*Marital status recode===================================
tab marst

gen single= 1 if marst==6
replace single=0 if inrange(marst, 1, 5)
gen divorced=1 if marst==4
replace divorced=0 if inlist(marst, 1, 2, 3, 5, 6)
gen widowed =1 if marst==5
replace widowed=0 if inlist(marst, 1, 2, 3, 4, 6)
gen separated = 1 if marst==3
replace separated= 0 if inlist(marst, 1, 2, 4, 5, 6)
gen married = 1 if inlist(marst,1,2)
replace married=0 if inrange(marst, 3, 6)


tab single
tab divorced
tab widowed
tab separated
tab married




*employment recode ======================================
tab empstat

gen unempl=1 if inlist(empstat, 21, 22)
replace unempl=0 if inrange(empstat, 1, 12) | inrange(empstat, 23,36)
gen nilf =1 if inlist(empstat, 32, 34, 36)
replace nilf=0 if inrange(empstat, 1, 22)



*education recode========================================
tab educ, missing

gen hseduc=1 if inrange(educ, 73, 125)
replace hseduc=0 if inrange(educ, 2, 71) 
tab hseduc

gen highereduc=1 if inrange(educ, 91,125) //minimum associates degree aquired
replace highereduc=0 if inrange(educ, 2,81)
tab highereduc



*family income recode=====================================
tab faminc

*$48k and above is considered middle class and above so we'll recode so that 1=middle class or higher. But we have to go with $50k and above.

gen inc=1 if inrange(faminc, 820, 843)
replace inc=0 if inrange(faminc, 100, 740)
tab inc



*race recode
tab race
gen nonwhite=inrange(race, 200, 830)
tab nonwhite


*============================================================================
tab age

*NEED TO RECODE CATEGORICAL VARIABLES TO SEPARATE VARIABLES BEFORE SUMMING.

collapse (mean) age sex nonwhite married unempl highereduc inc, by(statefip county_str year)

label variable nonwhite "proportion non-white"
label variable inc "proportion with income >= $50k (middle class or above)"
label variable highereduc "proportion with a higher ed degree (including associates)"
label variable unempl "propotion unemployed"
label variable married "propotion married"
label variable sex "proportion male"
label variable age "average age"

save "./demo_data.dta", replace


