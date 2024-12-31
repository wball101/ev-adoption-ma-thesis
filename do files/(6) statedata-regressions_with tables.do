clear all

capture cd "C:\Users\wball\OneDrive - CUNY\Hunter College\Thesis\EV\Do files"

use "..\Data\state_data_20240306.dta" 
drop _merge

merge 1:1 statefip year using "..\Data\state_pop.dta"
drop _merge
drop urban

*combine diesel and biodiesel... Biodiesel gets added as a breakout of diesel in 2021
tab year, sum(diesel)
tab year, sum(biodiesel)

replace diesel = diesel+biodiesel

duplicates report statefip year // one obs per state per year
table statefip year, stat(mean rebate) nototal // some states are always treated
table statefip year, stat(mean credit) nototal // no states start credit in the period?  Does this make sense

egen rebateyrs = sum(rebate), by(statefip)
tab rebateyrs // for technical reasons, always treated states should be dropped (or maybe not)

egen allv = rowtotal( zev phev hev biodiesel eth_flex compressed_natural_gas propane hydrogen methanol gas diesel unknown)

gen zevpct = zev/allv*1000
sum zevpct, d

gen zevpercap = zev/pop*1000
sum zevpercap, d

areg zevpct rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store zpct_nocntrl

areg zevpercap rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store zpcap_nocntrl

areg zevpct rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store zpct_cntrl

areg zevpercap rebate empl i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)

areg zevpercap rebate empl black i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)

areg zevpercap rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store zpcap_cntrl
margins, dydx(rebate empl black hhincome)
marginsplot
*graph export "../outputs/marginsplot_evpercap.png", replace

esttab zpct_nocntrl zpcap_nocntrl zpct_cntrl zpcap_cntrl using "../outputs/zev_table.tex", drop(_cons 2016.year 2017.year 2018.year 2019.year 2020.year 2021.year 2022.year)se booktabs replace starlevels(* .10 ** .05 *** .01)
esttab zpct_nocntrl zpcap_nocntrl zpct_cntrl zpcap_cntrl, se replace starlevels(* .10 ** .05 *** .01)




gen hevpercap = hev/pop*1000
gen phevpercap = phev/pop*1000
gen dieselpercap = diesel/pop*1000
gen hphevpercap = (hev+phev)/pop*1000
gen gaspercap = gas/pop*1000
gen gaspct = gas/allv*1000
gen dieselpct = diesel/allv*1000

areg hphevpercap rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)

areg hevpercap rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)

areg phevpercap rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)

areg dieselpercap rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store dieselcap_cntrl

areg dieselpercap rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store dieselcap_nocntrl

areg dieselpct rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store dieselpct_cntrl

areg dieselpct rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store dieselpct_nocntrl

esttab dieselpct_nocntrl dieselcap_nocntrl dieselpct_cntrl dieselcap_cntrl using"../outputs/diesel_table.tex", drop(_cons 2016.year) se booktabs replace starlevels(* .10 ** .05 *** .01)

esttab dieselpct_nocntrl dieselcap_nocntrl dieselpct_cntrl dieselcap_cntrl, se replace


areg gaspercap rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip) // rebate has a negative effect on gas adoption, so evs are a substitute with gas vehicles
estimates store gascap_cntrl

areg gaspercap rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip) 
estimates store gascap_nocntrl

areg gaspct rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip) 
estimates store gaspct_cntrl

areg gaspct rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip) 
estimates store gaspct_nocntrl

esttab gaspct_nocntrl gascap_nocntrl gaspct_cntrl gascap_cntrl using "../outputs/gas_table.tex", drop(_cons 2016.year) se booktabs replace starlevels(* .10 ** .05 *** .01)

esttab gaspct_nocntrl gascap_nocntrl gaspct_cntrl gascap_cntrl, se replace


*What if we add all hevs and evs into the dependent var:
gen evspercap = (zev+hev+phev)/pop*1000
gen evspct = (zev+hev+phev)/allv*1000

areg evspercap rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store evs_cntrl

areg evspercap rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store evs_nocntrl

areg evspct rebate empl black hhincome i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store evspct_cntrl

areg evspct rebate i.year if rebateyrs!=7, absorb(statefip) vce(cluster statefip)
estimates store evspct_nocntrl

esttab evspct_nocntrl evs_nocntrl evspct_cntrl evs_cntrl using "../outputs/evs_table.tex", drop(_cons 2016.year) se booktabs replace starlevels(* .10 ** .05 *** .01)
esttab evspct_nocntrl evs_nocntrl evspct_cntrl evs_cntrl, se replace


*The above seems to be the most promising. shows that rebates have a relatively statistical significant relationship with the adoption of ALL types of low emission vehicles (electic, plug-in hybrid, and hybrid).


*---------------------- Summary Stats -----------------------------------

estpost summarize rebate zevpct zevpercap dieselpct dieselpercap gaspct gaspercap evspct evspercap empl black hhincome year, listwise
esttab . , cells("count mean sd min max") replace

estpost summarize rebate zevpct zevpercap dieselpct dieselpercap gaspct gaspercap evspct evspercap empl black hhincome year, listwise
esttab . using "../outputs/sumstats.tex", cells("count mean sd min max") title("Summary Statistics") replace

numlabel, add
table state year if rebateyrs!=0 & rebateyrs!=7, stat(mean rebate) nototal


tab year
estpost tab year
eststo year_obs
esttab year_obs using "../outputs/year_obs.tex", title("State Counts by Year") replace


*---------------------- Figures ------------------------------------------
*kdensity zevpercap
*graph export "../outputs/zevcapdensity.png", replace

preserve
gen zevs = (zev + phev + hev)/100
replace zev = zev/100
replace diesel = diesel/100
gen gas_friendly = gas/1000
format zev zevs diesel gas_friendly %15.0fc
collapse (mean) zev zevs diesel gas_friendly, by (year)
twoway (line zev zevs diesel gas_friendly year),  ///
ytitle("Vehicle Count in Hundreds", size(small)) ylabel(0 (500)4000, /// 
axis(1) labsize(small)) xlab(0(0.1)1, nogrid) ylab(0(1000)5000, nogrid) ///
xtitle("Year", size(small)) xlabel(, labsize(small)) xlabel(2016 (1) 2022) ///
legend(off) aspect(.7) text(4600 2017 "Gas Vehicles / 10", size(small)) ///
text(1740 2018 "Diesel Vehicles", size(small)) ///
text(1050 2020 "Low Emission Vehicles", size(small)) ///
text(109 2021 "Electric Vehicles", size(small)),
graph export "../outputs/vehiclecounts.pdf", replace
restore

graph bar phevpercap zevpercap hevpercap, over(year) over(rebate) blabel(bar) ///
ytitle("Low Emission Vehicles per Capita") legend(label(1 "PHEVs") label(2 "EVs") label(3 "HEVs")) blabel(, format(%4.2f))

graph bar hhincome, over(rebate)

graph bar zevpercap evspercap dieselpercap if rebate == 1, over(year) blabel(bar) ///
ytitle("Number of Vehicles per Capita") legend(label(1 "Number of EVs per Capita") label(2 "Number of LEVs per Capita") label(3 "Number of Diesel Vehicles per Capita") symysize(3) size(small)) blabel(,format(%9.2f))

graph bar zevpercap evspercap dieselpercap if rebate == 0, over(year) blabel(bar) ///
ytitle("Number of Vehicles per Capita") legend(label(1 "Number of EVs per Capita") label(2 "Number of LEVs per Capita") label(3 "Number of Diesel Vehicles per Capita") symysize(3) size(small)) blabel(,format(%9.2f))

preserve
*ALL VALUES ARE SET TO TRU PER CAPITA VALUES, BUT GAS IS DEVIDED BY 10 TO BRING IT INTO GRAPH
gen gascap_friendly = gaspercap/1000
gen zevcap_friendly = zevpercap/100
gen evscap_friendly = evspercap/100
gen dieselcap_friendly = dieselpercap/100
collapse (mean) gascap_friendly zevcap_friendly evscap_friendly dieselcap_friendly, by(year rebate)
twoway (line gascap_friendly zevcap_friendly evscap_friendly dieselcap_friendly year if rebate == 0, lcolor(orange blue red green)) (line gascap_friendly zevcap_friendly evscap_friendly dieselcap_friendly year if rebate == 1, lcolor(orange blue red green) lpattern(dash dash dash dash))
ytitle("Vehicles per capita")
graph export "../outputs/line.png", replace
restore






save "../Data/after_regs_final_0512.dta", replace


