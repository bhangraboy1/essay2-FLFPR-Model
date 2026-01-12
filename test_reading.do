* This is the STATA Code for the Driving in Saudi Arabia article
*
*
* New Comment
* New Comment

// Define Directory for Files to be written to

clear all
global datapath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/68th Round - 2011-2012/NSS68_10/"
cd "$datapath"

use "Block_1_2_Identification of sample household and particulars of field operation"
ds, varwidth(25)

clear all

use "Block_5_1_Usual principal activity particulars of household members"
destring Usual_Principal_Activity_Status, replace


ds, varwidth(32)
* Cuts group in to Age cohort from 25-54

drop if Age < 25
drop if Age > 54

tabstat Age, stats(count mean)
tabstat Usual_Principal_Activity_Status, stats(count mean sd) by( Usual_Principal_Activity_Status)

tabulate Usual_Principal_Activity_Status
