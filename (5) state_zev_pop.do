*Do file for reading in state level population data

cd "C:\Users\wball\OneDrive - CUNY\Hunter College\Thesis\EV\Data\"


import delimited "state_level_pop.csv", clear

reshape long year, i(state) j(yearvalue) string
rename year pop
rename yearvalue year
destring year, replace

merge m:m year statefip using "./state_level_counts.dta"

drop if zev ==.

tab statefip

merge m:m statefip year using "./policy_data.dta",
drop _merge

save "./state_pop", replace