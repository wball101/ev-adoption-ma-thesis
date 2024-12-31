clear

cd "C:\Users\wball\OneDrive - CUNY\Hunter College\Thesis\EV\Data"

use "./state_demo.dta", replace

numlabel, add

summarize
describe

tab year
tab metro
tab race
tab occ2010

gen urban = 1 if metro ==2
replace urban = 0 if inlist(metro, 1,3)

collapse (mean) urban , by(year statefip)

tempfile urbandata
save `urbandata'


use "./state_demo.dta", replace

numlabel, add

collapse (mean) hhincome, by(statefip year)
replace hhincome = hhincome/1000
tempfile income
save `income'


use "./state_demo.dta", replace

numlabel, add

tab race

gen black = 1 if race == 200
replace black = 0 if race != 200

collapse (mean) black, by(statefip year)
tempfile race
save `race'

use "./state_demo.dta", replace

numlabel, add
tab empstat
gen empl = 0 if inrange(empstat, 21,22)
replace empl = 1 if inrange(empstat,1,12)
tab empl
collapse (mean) empl, by(statefip year)

tempfile empl
save `empl'

merge 1:1 statefip year using `race'
drop _merge
merge 1:1 statefip year using `income'
drop _merge
merge 1:1 statefip year using `urbandata'
drop _merge
tempfile all
save `all'


use "./state_data.dta", clear
drop _merge

merge 1:1 statefip year using `all'

drop if _merge ==2

save "./state_data_20240306.dta",replace



