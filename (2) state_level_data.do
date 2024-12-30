*Do file for reading in state level data on EV counts

cd "C:\Users\wball\OneDrive - CUNY\Hunter College\Thesis\EV\Data\"


import delimited "state_level_counts.csv", clear

// List all variables
ds

// Loop over each variable
foreach var of varlist zev phev hev biodiesel eth_flex compressed_natural_gas propane hydrogen gas diesel unknown {
  
	// Replace commas with nothing
	replace `var' = subinstr(`var', ",", "", .)
	destring `var', replace
}

save "./state_level_counts.dta",replace

use "./state_level_counts.dta", clear

merge 1:m year statefip using "./policy_data.dta"

drop if year <=2015 | year >=2023

replace rebate =0 if rebate==.
replace credit =0 if credit==.

save "./state_data.dta",replace