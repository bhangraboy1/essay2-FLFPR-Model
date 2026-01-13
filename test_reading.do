* This is the STATA Code for the Driving in Saudi Arabia article
*
*
* New Comment
* New Comment

// Define Directory for Files to be written to

clear all
global datapath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/68th Round - 2011-2012/NSS68_10/"
global outputpath "/Users/ashbelur/Documents/ashbelur/BIGPROJECTS/phd/STATA/NSSO/essay2-FLFPR-Model/"

* Start with Household Level Blocks 1 and 2
use "$datapath/Block_1_2_Identification of sample household and particulars of field operation"
ds, varwidth(25)
sort HHID

* First Merge with Block 3 Household Characteristics
use "$datapath/Block_3_Household characteristics"
egen HHID = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)
save "$outputpath/68_Block_3_fixed"
merge 1:1 HHID using "$outputpath/68_Block_3_fixed", nogen
save "$outputpath/HH_combined"

exit

* Prepare Block 4 Individual Characteristics
use "$datapath/Block_4_Demographic particulars of household members"
* capture rename Person_Serial_No person_serial_no
sort HHID Person_Serial_No
save "$outputpath/individual_temp"

* Merging Block 5 with Block 4
use "$datapath/Block_5_1_Usual principal activity particulars of household members"
merge 1:1 HHID Person_Serial_No using "$outputpath/individual_temp", nogen
save "$outputpath/individual_temp"

* Final Merge - Combining Household and Individual Data
merge m:1 HHID using "$outputpath/HH_combined"
save "$outputpath/final_combined"

tab _merge

exit

use "$datapath/Block_8_Household_consumer_expenditure"



* destring HHID, replace


clear all

use "Block_5_1_Usual principal activity particulars of household members"
destring Usual_Principal_Activity_Status, replace

ds, varwidth(32)

list Round Level HHID  FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No Person_Serial_No in 1/10

* Using Strings
* generate HHID = FSU_Serial_No + Hamlet_Group_Sub_Block_No + Second_Stage_Stratum_No + Sample_Hhld_No
* generate PID = HHID + Person_Serial_No

* merge 1:1 HHID using 

exit

* Level 1 and 2 deals with Household Information
* Level 3+ deals with Individual Information

* Rename all relevant variables
* Age, State, NSS, NSC, MLT, Usual_Principal_Activity_Status
* To Generate HHID
* - HHID
*  - FSU_Serial_No
*  - Hamlet_Group_Sub_Block_No
*  - Second_Stage_Stratum_No
*  - Sample_Hhld_No
*
* To Generate PID
* - PID
*  - HHID
*  - Person_Serial_No
*
* Level
* Round
* State, District_code

* Drop irrelevant variables

list Round Level HHID Person_Serial_No FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No in 1/10
* Filter Variables Down
* Cuts group in to Age cohort from 25-54

drop if Age < 25
drop if Age > 54
tabstat Age, stats(count mean)

* Generate Weight
* destring MLT, replace
* generate weight = MLT/100 if (NSS==NSC)
* replace weight = MLT/200 if (NSS!=NSC)

exit


tabstat Age, stats(count mean)
tabstat Usual_Principal_Activity_Status, stats(count mean sd) by( Usual_Principal_Activity_Status)

tabulate Usual_Principal_Activity_Status

* Probit Model (N=27306)
*
* Data is Married Women Ages 25-54
* - Excluding those households where the women is reported as the Head of Household
* - Married
* - Age 25-54

* Independent Variables
* 
* Own Education Dummies
* - Illiterate, Literate, Primary, Middle, Secondary, Graduate
*
* Household Head Education
* - Illiterate, Literate, Primary, Middle, Secondary, Graduate
* 
* Social Group
* SCST, Muslim, Other
*
* Age, Age-squared
*
* Children 0-4, Children 5-14
*
*
* District Male Employment Share
* - Agriculture, Manufacturing, Services, White Collar Services, Grad Share
* Log Income
*

*
* 
* Male Salaried Employment



* Sample Means / Std Deviations
*
*
