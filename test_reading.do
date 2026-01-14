* This is the STATA Code for the Driving in Saudi Arabia article
*
*
* New Comment

* Getting the Data Together

* Define Directory for Files to be written to
clear all
global datapath   "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/68th Round - 2011-2012/NSS68_10/"
global outputpath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/STATA/NSSO/essay2-FLFPR-Model/"

* Start with Household Level Blocks 1 and 2
use "${datapath}Block_1_2_Identification of sample household and particulars of field operation"
ds, varwidth(25)
sort HHID
save "${outputpath}Block_1_2_fixed", replace

* First Merge with Block 3 Household Characteristics
use "${datapath}Block_3_Household characteristics"

egen HHID = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)
save "${outputpath}68_Block_3_fixed", replace

use "${outputpath}Block_1_2_fixed", clear
merge 1:1 HHID using "${outputpath}68_Block_3_fixed", nogen
save "${outputpath}HH_combined", replace

* Prepare Block 4 Individual Characteristics
use "$datapath/Block_4_Demographic particulars of household members"
* capture rename Person_Serial_No person_serial_no
sort HHID Person_Serial_No
save "${outputpath}individual_temp", replace

* Merging Block 5 with Block 4
use "$datapath/Block_5_1_Usual principal activity particulars of household members"
merge 1:1 HHID Person_Serial_No using "$outputpath/individual_temp", nogen
save "${outputpath}individual_temp", replace

* Final Merge - Combining Household and Individual Data
use "${outputpath}individual_temp"
merge m:1 HHID using "$outputpath/HH_combined"

* Destring all relevant variables
destring Usual_Principal_Activity_Status, replace
destring Marital_Status, replace
destring Sex, replace
destring Relation_to_Head, replace
destring General_Education, replace
destring State_Region, replace
destring State, replace
destring MLT, replace

* Generate Weights
generate weight = MLT/100 if (NSS==NSC)
replace weight = MLT/200 if (NSS!=NSC)

generate educ=1
replace  educ=2 if (General_Education == 2) | (General_Education==3) | (General_Education==4) | (General_Education==5)
replace  educ=3 if (General_Education==6)
replace  educ=4 if(General_Education==7)
replace  educ=5 if (General_Education==8) | (General_Education==10) | (General_Education==11)
replace  educ=6 if (General_Education==12) | (General_Education==13)

save "${outputpath}final_combined", replace

tab _merge

* Filter Variables Down
* Cuts group in to Age cohort from 25-54
drop if Age < 25               // exclude under 25
drop if Age > 54               // exclude over 54
drop if Marital_Status != 2.   // keep only Married
drop if Sex == 1               // exclude Males
drop if Relation_to_Head == 1  // exclude Female Head of Household Self

* tabstat Usual_Principal_Activity_Status, stats(count mean)

tabulate Usual_Principal_Activity_Status
* 11 - self employed
* 21 - unpaid work
* 31 - regular employee
* 41 - casual worker
* 51 - casual worker
* 81 - unemployed

generate employed=0
replace employed=1 if (Usual_Principal_Activity_Status==11) | (Usual_Principal_Activity_Status==21) | (Usual_Principal_Activity_Status==31) | (Usual_Principal_Activity_Status==41) | (Usual_Principal_Activity_Status==51) | (Usual_Principal_Activity_Status==81)

generate Age2 = Age * Age
tabulate employed

******
* Running the Regression Models
******

* Probit Model + Marginal Effects
probit employed  i.educ Age Age2 i.State [pweight = weight]
margins, dydx(*) post
local years 2011
foreach i in `years' {
  estimates store yr`years'
}

estout yr2011
esttab yr2011 using "${outputpath}latex/table1.tex", replace ///
   label booktabs b(%6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.4f %6.3f) se(%6.3f) star(* 0.1 ** 0.05 *** 0.01) ///
   title("Probit Estimation Results (Average Margial Effects)") ///
   drop(*.State 1.educ) ///
   mtitles("Model 2011") ///
   refcat(2.educ "Own Education (Ref = Illiterate)", nolabel) ///
   coeflabels(2.educ "Literate" 3.educ "Primary" 4.educ "Middle" 5.educ "Secondary" ///
   6.educ "Graduate" Age "Age" Age2 "Age Squared"  _cons "Constant")


* Create Averages across Variables
* tabstat employed General_Education

* ds, varwidth(32)


exit










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
