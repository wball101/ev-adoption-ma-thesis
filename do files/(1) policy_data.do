*do file for policy data append

cd "C:\Users\wball\OneDrive - CUNY\Hunter College\Thesis\EV\Data"

import excel "./policy_data.xlsx", firstrow clear


label define statefips_labels 1 "alabama"	
    2 "alaska"	
    4 "arizona"	
    5 "arkansas"	
    6 "california"	
    8 "colorado"	
    9 "connecticut"	
    10 "delaware"	
    11 "district"	
    12 "florida"	
    13 "georgia"	
    15 "hawaii"	
    16 "idaho"	
    17 "illinois"	
    18 "indiana"	
    19 "iowa"	
    20 "kansas"	
    21 "kentucky"	
    22 "louisiana"	
    23 "maine"	
    24 "maryland"	
    25 "massachusetts"	
    26 "michigan"	
    27 "minnesota"	
    28 "mississippi"	
    29 "missouri"	
    30 "montana"	    
    31 "nebraska"	
    32 "nevada"	
    33 "new hampshire"	
    34 "new jersey"	
    35 "new mexico"	
    36 "new york"	
    37 "north carolina"	
    38 "north dakota"	
    39 "ohio"	
    40 "oklahoma"
    41 "oregon"	
    42 "pennsylvania"	
    44 "rhode island"	
    45 "south carolina"	
    46 "south dakota "	
    47 "tennessee"	
    48 "texas"	
    49 "utah"	
    50 "vermont"	
    51 "virginia"	
    53 "washington"	
    54 "west virginia"	
    55 "wisconsin"	
    56 "wyoming"

label values statefip statefips_labels

tab statefip

save "./policy_data.dta", replace
