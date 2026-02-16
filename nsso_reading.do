* This is the STATA Code for the Estimation of the Female Labor Force Participation Rate in India
*
* Using the 2011/12 Data form the Employment and Unemployment Report
*

* Getting the Data Together

* rename all variable to lowercase
* drop variables I dont need
* Bring in a 3 new Waves of Data - append - done
* try to append another year into the dataset - done for 3 years
* try to merge all years into the dataset - done for 3 year

* Define Directory for Files to be written to
clear all
global outputpath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/STATA/NSSO/essay2-FLFPR-Model/"
global factorpath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/pythondevelopment/worldvaluessurvey/"

*
* >>> Loading in 68th Round 2011/2012 Data <<<
*
global datapath   "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/68th Round - 2011-2012/NSS68_10/"

* Start with Household Level Blocks 1 and 2
use "${datapath}Block_1_2_Identification of sample household and particulars of field operation"
ds, varwidth(32)
sort HHID
gen year=2011

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

use "$datapath/Block_5_3_Time disposition during the week ended on ...............dta"
egen HHID_new = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)

* Calculating Other Members Weekly Earnings on a per capita basis
collapse(sum) weekly_earnings = Wage_and_Salary_Earnings_Total, by(HHID Person_Serial_No)
bysort HHID: egen HH_total_earnings = total(weekly_earnings)
gen other_members_earnings = HH_total_earnings - weekly_earnings

bysort HHID: gen hh_size = _N
gen other_members_count = hh_size - 1

gen other_members_earnings_pc = other_members_earnings / other_members_count

merge 1:1 HHID Person_Serial_No using "$outputpath/individual_temp", nogen
* rename HHID_new HHID
save "${outputpath}individual_temp", replace

import delimited "${factorpath}factors.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_factors.dta", replace
describe State


import delimited "${factorpath}wvs_averages.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_averages.dta", replace
describe State

* Final Merge - Combining Household and Individual Data
use "${outputpath}individual_temp"
merge m:1 HHID using "$outputpath/HH_combined", nogen
destring State, replace
describe State

merge m:1 State using "${outputpath}wva_factors.dta", nogen
merge m:1 State using "${outputpath}wva_averages.dta"

save "${outputpath}original", replace

*
* >>> Loading in 66th Round 2009/2010 Data <<<
*
global datapath   "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/66th Round - 2009-2010/NSS066_10/"

* Start with Household Level Blocks 1 and 2
use "${datapath}Block_1_2_Identification of sample household and particulars of field operation"
ds, varwidth(25)
sort HHID
gen year=2009
save "${outputpath}Block_1_2_fixed", replace

* First Merge with Block 3 Household Characteristics
use "${datapath}Block_3_Household characteristics"
capture drop HHID
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

use "$datapath/Block_5_3_Time disposition during the week ended on ...............dta"
egen HHID_new = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)

* Calculating Other Members Weekly Earnings on a per capita basis
collapse(sum) weekly_earnings = Wage_and_Salary_Earnings_Total, by(HHID Person_Serial_No)
bysort HHID: egen HH_total_earnings = total(weekly_earnings)
gen other_members_earnings = HH_total_earnings - weekly_earnings

bysort HHID: gen hh_size = _N
gen other_members_count = hh_size - 1

gen other_members_earnings_pc = other_members_earnings / other_members_count

merge 1:1 HHID Person_Serial_No using "$outputpath/individual_temp", nogen
* rename HHID_new HHID
save "${outputpath}individual_temp", replace


import delimited "${factorpath}factors.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_factors.dta", replace
describe State


import delimited "${factorpath}wvs_averages.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_averages.dta", replace
describe State

* Final Merge - Combining Household and Individual Data
use "${outputpath}individual_temp"
merge m:1 HHID using "$outputpath/HH_combined", nogen
destring State, replace
describe State

merge m:1 State using "${outputpath}wva_factors.dta", nogen
merge m:1 State using "${outputpath}wva_averages.dta"

save "${outputpath}new1", replace
append using "${outputpath}original"
save "${outputpath}combined", replace

*
* >>> Loading in 64th Round 2007/2008 Data <<<
*

global datapath   "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/66th Round - 2009-2010/NSS066_10/"

* Start with Household Level Blocks 1 and 2
use "${datapath}Block_1_2_Identification of sample household and particulars of field operation"
ds, varwidth(25)
sort HHID
gen year=2009
save "${outputpath}Block_1_2_fixed", replace

* First Merge with Block 3 Household Characteristics
use "${datapath}Block_3_Household characteristics"
capture drop HHID
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

use "$datapath/Block_5_3_Time disposition during the week ended on ...............dta"
egen HHID_new = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)

* Calculating Other Members Weekly Earnings on a per capita basis
collapse(sum) weekly_earnings = Wage_and_Salary_Earnings_Total, by(HHID Person_Serial_No)
bysort HHID: egen HH_total_earnings = total(weekly_earnings)
gen other_members_earnings = HH_total_earnings - weekly_earnings

bysort HHID: gen hh_size = _N
gen other_members_count = hh_size - 1

gen other_members_earnings_pc = other_members_earnings / other_members_count

merge 1:1 HHID Person_Serial_No using "$outputpath/individual_temp", nogen
* rename HHID_new HHID
save "${outputpath}individual_temp", replace


import delimited "${factorpath}factors.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_factors.dta", replace
describe State


import delimited "${factorpath}wvs_averages.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_averages.dta", replace
describe State

* Final Merge - Combining Household and Individual Data
use "${outputpath}individual_temp"
merge m:1 HHID using "$outputpath/HH_combined", nogen
destring State, replace
describe State

merge m:1 State using "${outputpath}wva_factors.dta", nogen
merge m:1 State using "${outputpath}wva_averages.dta"

save "${outputpath}new1", replace
append using "${outputpath}original"
save "${outputpath}combined", replace


*
* >>> Loading in 64th Round 2007/2008 Data <<<
*

global datapath   "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/64th Round - 2007-2008/NSS64_10/"
* Start with Household Level Blocks 1 and 2
use "${datapath}Block-1-sample-household-identification-records" // CHANGED NAME
ds, varwidth(25)
gen HHID = key_Hhold // Created HHID
sort HHID
gen year=2007
save "${outputpath}Block_1_2_fixed", replace

* First Merge with Block 3 Household Characteristics
use "${datapath}Block-3-household-characteristics-ecords" // CHANGED NAME
capture rename B3_q1 HH_Size
capture rename B3_q2 NIC_2004
* capture rename B3_q3 nic3
capture rename B3_q5 Religion
capture rename B3_q6 Social_Group

capture drop HHID
gen HHID = Key_hhold // Created HHID
save "${outputpath}68_Block_3_fixed", replace

use "${outputpath}Block_1_2_fixed", clear
merge 1:1 HHID using "${outputpath}68_Block_3_fixed", nogen
save "${outputpath}HH_combined", replace

* Prepare Block 4 Individual Characteristics
* Renaming for NSSO 2007 Survey
use "${datapath}Block-4-demographic-usual-activity-members-records"

capture rename B4_c1 Person_Serial_No
capture rename B4_c4 Sex
capture rename B4_c5 Age
capture rename B4_c6 Marital_Status
capture rename B4_c7 General_Education
capture rename B4_c8 Technical_Education
capture rename B4_c9 Usual_Principal_Activity_Status
capture rename nss NSS
capture rename nsc NSC // CORRECTION
capture rename wgt_combined weight



gen HHID = key_hhold // Created HHID
sort HHID Person_Serial_No
save "${outputpath}individual_temp", replace

* Merging Block 5 with Block 4
* use "${datapath}Block_5pt_level_04"
* capture rename B5_c1 Person_Serial_No
* gen HHID = key_hhold // Created HHID
* merge 1:1 HHID Person_Serial_No using "$outputpath/individual_temp", nogen
* save "${outputpath}individual_temp", replace
* 
* use "$datapath/Block_5_3_Time disposition during the week ended on ...............dta"
* egen HHID_new = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)

* Calculating Other Members Weekly Earnings on a per capita basis
* collapse(sum) weekly_earnings = Wage_and_Salary_Earnings_Total, by(HHID Person_Serial_No)
* bysort HHID: egen HH_total_earnings = total(weekly_earnings)
* gen other_members_earnings = HH_total_earnings - weekly_earnings

* bysort HHID: gen hh_size = _N
* gen other_members_count = hh_size - 1

* gen other_members_earnings_pc = other_members_earnings / other_members_count

* merge 1:1 HHID Person_Serial_No using "$outputpath/individual_temp", nogen
* rename HHID_new HHID
* save "${outputpath}individual_temp", replace

* World Values Survey from Python Code
import delimited "${factorpath}factors.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_factors.dta", replace
describe State


import delimited "${factorpath}wvs_averages.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_averages.dta", replace
describe State

* Final Merge - Combining Household and Individual Data
use "${outputpath}individual_temp"
merge m:1 HHID using "$outputpath/HH_combined", nogen
rename state State
destring State, replace
describe State

merge m:1 State using "${outputpath}wva_factors.dta", nogen
merge m:1 State using "${outputpath}wva_averages.dta"

save "${outputpath}new2", replace
append using "${outputpath}combined"
save "${outputpath}combined", replace

*
* >>> Loading in 61st Round 2004/2005 Data <<<
*

global datapath   "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/61st Round - 2004-2005/NSS61_10/"
* Start with Household Level Blocks 1 and 2
use "${datapath}Block_1_2_and_3_level_01" // CHANGED NAME
ds, varwidth(25)
* gen HHID = key_Hhold // Created HHID
sort HHID
gen year=2004
save "${outputpath}HH_combined", replace

* Prepare Block 4 Individual Characteristics
use "$datapath/Block_4_level_03"
capture rename Personal_serial_no Person_Serial_No
sort HHID Person_Serial_No
save "${outputpath}individual_temp", replace

* Merging Block 5 with Block 4
use "${datapath}Block_5pt1_level_04"
capture rename Personal_serial_no Person_Serial_No
* capture rename B5_c1 Person_Serial_No
* gen HHID = key_hhold // Created HHID
merge 1:1 HHID Person_Serial_No using "${outputpath}individual_temp", nogen
rename Usual_principal_activity_status Usual_Principal_Activity_Status
save "${outputpath}individual_temp", replace

* use "${datapath}Block_5pt2_level_05"
* capture rename Serial_no Person_Serial_No
* merge 1:1 HHID Person_Serial_No using "${outputpath}individual_temp", nogen
* save "${outputpath}individual_temp", replace

use "${datapath}Block_5pt3_level_06"
capture rename Personal_srl_no Person_Serial_No
rename Wage_salary_earnings_total_durin Wage_and_Salary_Earnings_Total

* Calculating Other Members Weekly Earnings on a per capita basis
collapse(sum) weekly_earnings = Wage_and_Salary_Earnings_Total, by(HHID Person_Serial_No)
bysort HHID: egen HH_total_earnings = total(weekly_earnings)
gen other_members_earnings = HH_total_earnings - weekly_earnings

bysort HHID: gen hh_size = _N
gen other_members_count = hh_size - 1

gen other_members_earnings_pc = other_members_earnings / other_members_count

merge m:1 HHID Person_Serial_No using "${outputpath}individual_temp", nogen
save "${outputpath}individual_temp", replace

* World Values Survey from Python Code
import delimited "${factorpath}factors.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_factors.dta", replace
describe State

import delimited "${factorpath}wvs_averages.csv", clear
rename state State
destring State, replace
save "${outputpath}wva_averages.dta", replace
describe State

* Final Merge - Combining Household and Individual Data
use "${outputpath}individual_temp"
merge m:1 HHID using "${outputpath}HH_combined", nogen
* rename STATE_CODE State // CHANGED
destring State, replace
describe State

merge m:1 State using "${outputpath}wva_factors.dta", nogen
merge m:1 State using "${outputpath}wva_averages.dta"

rename General_education General_Education
rename Marital_status Marital_Status
rename SOCIAL_GRP Social_Group
rename HH_SIZE HH_Size

* rename NSS_SR NSS
* rename NSC_SR NSC

* CORRECTION
rename MLTSS MLT
rename RELIGION Religion
* rename MLTSR MLT

save "${outputpath}new3", replace
append using "${outputpath}combined"
save "${outputpath}combined", replace


display "DONE"

 
**************************************************************************************************************
**************************************************************************************************************
**************************************************************************************************************


* Destring all relevant variables
destring Usual_Principal_Activity_Status, replace
destring Marital_Status, replace
destring Sex, replace
destring Relation_to_Head, replace
destring General_Education, replace
destring State_Region, replace
destring State, replace
destring MLT, replace
destring Social_Group, replace
destring Religion, replace
destring NIC_2008, replace
destring Sector, replace
destring NIC_2004, replace

* Recoding General Education to match 2011 Survey
replace General_Education=5 if General_Education==6 & year==2007
replace General_Education=6 if General_Education==7 & year==2007
replace General_Education=7 if General_Education==8 & year==2007
replace General_Education=8 if General_Education==10 & year==2007
replace General_Education=10 if General_Education==11 & year==2007
replace General_Education=13 if General_Education==14 & year==2007

* CHECK
tabstat Age Sex Sector Social_Group Usual_Principal_Activity_Status General_Education, by(year) stats(mean N)


**************************************************************************************************************
* SECTION
* Make all Variable Names lowercase
* Make all coded variable names into something more sensible
* Drop all Variables not needed for Tables / Regressions
* 

rename Sex sex
rename Sector sector
rename Age age
rename HH_Size hhsize
rename Religion religion
rename NSS nss2
rename NSC nsc2
rename MLT mlt
rename Filler filler
rename Filler_1 filler_1
rename Filler_2 filler_2

rename v2  q29
rename v3  q209
rename v4  q210
rename v5  q211
rename v6  q212
rename v7  q32
rename v8  q33
rename v9  q35
rename v10 q189
rename v11 q191
rename v12 q137
rename v13 q30

* rename General_Education general_education
*
*
**************************************************************************************************************

* Generate Weights
replace weight = mlt/100 if ((nss2==nsc2) & ((year==2004) | (year==2009) | (year==2011)))
replace weight = mlt/200 if ((nss2!=nsc2) & ((year==2004) | (year==2009) | (year==2011)))

* Create Male Head of Housedhold Education Level
* Relation to Head is Spouse
gen h_educ_temp = General_Education if Relation_to_Head == 1 & sex == 1
bysort HHID: egen General_Education_H = max(h_educ_temp)
drop h_educ_temp
* Check
* list HHID Person_Serial_No Sex General_Education General_Education_H in 1/15

*
* Create Number of Children in Two Age Groups
*
gen child_04_ind  = (age >= 0 & age <= 4)
gen child_514_ind = (age >= 5 & age <= 14)
bysort HHID: egen n_child_04  = total(child_04_ind)
bysort HHID: egen n_child_514 = total(child_514_ind)
drop child_04_ind child_514_ind

*
* Presence of Male Salaried Employee - Security of Household Income
*
gen male_salaried_ind = (sex==1) & (Usual_Principal_Activity_Status==31)
bysort HHID: egen male_salaried = max(male_salaried_ind)
* list HHID Person_Serial_No Usual_Principal_Activity_Status male_salaried sex Age in 1/15
 
* Share of Male Workers in Each Industry Type
egen dist_id = group(State District)

gen nic3     = floor(NIC_2008 / 100) if year==2011
replace nic3 = floor(NIC_2004 / 100) if year==2009
replace nic3 = floor(NIC_2004 / 100) if year==2007
replace nic3 = floor(NIC_2004 / 100) if year==2004

gen is_worker = (Usual_Principal_Activity_Status <= 51)
gen male_worker = (sex == 1 & is_worker == 1)
bysort dist_id: egen dist_male_workers_w = total(male_worker * weight)

gen cat_agri  = (male_worker == 1 & (1 <= nic3 & nic3 <= 32))
gen cat_manu  = (male_worker == 1 & (101 <= nic3 & nic3 <= 332))
gen cat_const = (male_worker == 1 & (411 <= nic3 & nic3 <= 439))
gen cat_wsvc  = (male_worker == 1 & (620 <= nic3 & nic3 <= 829))
gen cat_othr  = (male_worker == 1 & cat_agri==0 & cat_manu==0 & cat_const==0 & cat_wsvc==0)

replace cat_agri  = (sex == 2 & (1 <= nic3 & nic3 <= 32))
replace cat_manu  = (sex == 2 & (101 <= nic3 & nic3 <= 332))
replace cat_const = (sex == 2 & (411 <= nic3 & nic3 <= 439))
replace cat_wsvc  = (sex == 2 & (620 <= nic3 & nic3 <= 829))
replace cat_othr  = (sex == 2 & cat_agri==0 & cat_manu==0 & cat_const==0 & cat_wsvc==0)

gen     cat_work = 1 if (cat_agri==1)
replace cat_work = 2 if (cat_manu==1)
replace cat_work = 3 if (cat_const==1)
replace cat_work = 4 if (cat_wsvc==1)
replace cat_work = 5 if (cat_othr==1)

label define work_label 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Services" 5 "Other"

foreach var of varlist cat_agri cat_manu cat_const cat_wsvc cat_othr {
	local name = substr("`var'", 5, .)
	bysort dist_id: egen male_`name'_w = total(`var' * weight)
    gen male_`name'_share = male_`name'_w / dist_male_workers_w
    replace male_`name'_share = 0 if dist_male_workers_w == 0
}

* list dist_id Person_Serial_No Sex NIC_2008 nic3 cat_agri cat_manu cat_const cat_wsvc cat_othr in 1/35 if(sex==1)

quietly list dist_id Person_Serial_No sex NIC_2008 nic3 male_agri_share male_manu_share male_const_share male_wsvc_share male_othr_share in 1/35

* tabulate n_child_04
* tabulate n_child_514

**************************************************************************************************************
* Making Conversion from Survey Data to Relevant Categories for Analysis
**************************************************************************************************************

tabstat age sector Usual_Principal_Activity_Status General_Education, by(year) stats(mean N)

* Converting Education Variable from Survey to Categories
* This could also be done after dropping Males
generate educ=1
replace  educ=2 if (General_Education == 2) | (General_Education==3) | (General_Education==4) | (General_Education==5)
replace  educ=3 if (General_Education==6)
replace  educ=4 if (General_Education==7)
replace  educ=5 if (General_Education==8) | (General_Education==10) | (General_Education==11)
replace  educ=6 if (General_Education==12) | (General_Education==13)

label define educ_label 1 "Illiterate" 2 "Lit. No Sch" 3 "Primary" 4 "Middle" 5 "Secondary" 6 "Graduate"
label define religion_label 1 "Hindu" 2 "Muslim" 3 "Christianity" 4 "Sikh" 5 "Jain" 6 "Buddhist" 7 "Zoroastrian" 9 "Other"

* Converting Education Variable from Survey for Husband to Categories
* This must be done now
generate educ_h=1
replace  educ_h=2 if (General_Education_H==2) | (General_Education_H==3) | (General_Education_H==4) | (General_Education_H==5)
replace  educ_h=3 if (General_Education_H==6)
replace  educ_h=4 if (General_Education_H==7)
replace  educ_h=5 if (General_Education_H==8) | (General_Education_H==10) | (General_Education_H==11)
replace  educ_h=6 if (General_Education_H==12) | (General_Education_H==13)

* Categorizing Caste from Survey

* Hindu SCST
generate socialgroup=1 if(Social_Group==1) | (Social_Group==2)
* OBC
replace socialgroup=2 if (Social_Group==3)
* Hindu Other
replace socialgroup=3 if (Social_Group==9)

recast int socialgroup

* save "${outputpath}final_combined", replace
* tab _merge
* tabstat Usual_Principal_Activity_Status, stats(count mean)

*****
* Generate Key Dependent Dummy Variable
*****
tabulate Usual_Principal_Activity_Status
* 11 - self employed
* 21 - unpaid work
* 31 - regular employee
* 41 - casual worker
* 51 - casual worker
* 81 - unemployed

* 12 - employer
* 91 - studying
* 92 - domestic duties only
* 93 - weaving for household
* 94 - rentiers, pensioners
* 95 - not able to work
* 97 - other - begging prostitution

generate employed=0
replace employed=1 if (Usual_Principal_Activity_Status==11) | (Usual_Principal_Activity_Status==21) | (Usual_Principal_Activity_Status==31) | (Usual_Principal_Activity_Status==41) | (Usual_Principal_Activity_Status==51) | (Usual_Principal_Activity_Status==81)

generate kind_employment=3
replace  kind_employment=1 if (Usual_Principal_Activity_Status==31)
replace  kind_employment=2 if (Usual_Principal_Activity_Status==41) | (Usual_Principal_Activity_Status==51)

generate age2 = age * age
quietly tabulate employed

* tabstat other_members_earnings_pc if (other_members_earnings_pc > 0)

* NEEDS TO BE CORRECTED with Proper Imputation - CORRECTION
replace other_members_earnings_pc=933 if (other_members_earnings_pc==0)

replace other_members_earnings_pc=ln(other_members_earnings_pc)

gen Political = (q29+q209+q210+q211+q212) / 5
gen Economic = (q32+q33) / 2
gen Education = (q30)
gen Violence = (q189+q191+q137) / 3

**************************************************************************************************************
* This is the STATA Code for the Estimation of the Female Labor Force Participation Rate in India
*
*
* Putting together some basic Data Vizualizations and Tables
* First with all the data
* Second only with Filtered Data
*
*
**************************************************************************************************************
* 11 - self employed
* 21 - unpaid work
* 31 - regular employee
* 41 - casual worker
* 51 - casual worker
* 81 - unemployed

* CHECK
display "CHECKING TABSTAT"
tabstat age sex sector Usual_Principal_Activity_Status General_Education, by(year) stats(mean N)

* Filter Variables Down
drop if age < 25               // exclude under 25
drop if age > 54               // exclude over 54
drop if Marital_Status != 2.   // keep only Married

capture drop rural_male urban_male rural_female urban_female
capture drop lfpr_rm lfpr_um lfpr_rf lfpr_uf

gen rural_male   = (sector == 1) & (sex == 1)
gen urban_male   = (sector == 2) & (sex == 1)
gen rural_female = (sector == 1) & (sex == 2)
gen urban_female = (sector == 2) & (sex == 2)

gen lfpr_rm = employed if rural_male   ==1
gen lfpr_um = employed if urban_male   ==1
gen lfpr_rf = employed if rural_female ==1
gen lfpr_uf = employed if urban_female ==1

* CHECK
display "CHECKING TABSTAT"
tabstat age sex sector Usual_Principal_Activity_Status General_Education, by(year) stats(mean N)

levelsof year, local(years)
foreach y in `years' {
	quietly estpost summarize lfpr_rm lfpr_um lfpr_rf lfpr_uf [aweight=weight]  if year==`y'
	estimate store year_`y'
}

esttab year_* using "${outputpath}summary_table1.tex", replace ///
    cells("mean(fmt(2))") ///
	varlabels(lfpr_rm "Rural Male" lfpr_rf "Rural Female" lfpr_um "Urban Male" lfpr_uf "Urban Female") ///
	mtitles("2004" "2007" "2009" "2011") ///
	collabels(none) ///
    nonumber label booktabs ///
	stats(N, labels("Observations"))
	
* EXIT EXIT EXIT
* exit
* EXIT EXIT EXIT

capture drop emp_reg emp_cas emp_self
capture drop um_* uf_* rm_* rf_*

gen emp_reg  = (kind_employment == 1) if (employed == 1)
gen emp_cas  = (kind_employment == 2) if (employed == 1)
gen emp_self = (kind_employment == 3) if (employed == 1)

foreach segment in reg cas self {
	gen um_`segment' = emp_`segment' if urban_male   == 1
	gen uf_`segment' = emp_`segment' if urban_female == 1
	gen rm_`segment' = emp_`segment' if rural_male   == 1
	gen rf_`segment' = emp_`segment' if rural_female == 1
}

levelsof year, local(years)
foreach y in `years' {
	estpost summarize   rm_reg  rf_reg  um_reg  uf_reg  ///
					rm_cas  rf_cas  um_cas  uf_cas  ///
					rm_self rf_self um_self uf_self [aweight=weight] if year == `y'
	estimate store b_year_`y'
}

esttab b_year_* using "${outputpath}summary_table2.tex", replace ///
    cells("mean(fmt(2))") ///
	refcat(rm_reg "\textbf{Regular Employment}" rm_cas "\textbf{Casual Worker}" rm_self "\textbf{Self Employed}", nolabel) ///
	varlabels(  rm_reg  "Rural Male" rf_reg  "Rural Female" um_reg  "Urban Male" uf_reg  "Urban Female" ///
				rm_cas  "Rural Male" rf_cas  "Rural Female" um_cas  "Urban Male" uf_cas  "Urban Female"  ///
				rm_self "Rural Male" rf_self "Rural Female" um_self "Urban Male" uf_self "Urban Female") ///
	mtitles("2004" "2007" "2009" "2011") ///
	collabels(none) ///
    nonumber label booktabs ///
	stats(N, labels("Observations"))
	
	
* Filter Variables Down
* Only include Females
* Exlcude Female Head of Household
* Urban
drop if sex == 1               // exclude Males
drop if Relation_to_Head == 1  // exclude Female Head of Household Self
drop if sector==1  


tabstat employed, by(educ)
label values educ educ_label
label values cat_work work_label
label values religion religion_label

tabstat employed [aweight=weight], by(educ)

* graph bar employed, over(educ) b1title("Education") ytitle("FLFPR (%)") bar(1, fcolor(black))

graph bar (mean) employed [aweight=weight], ///
    over(year, label(angle(45))) ///
    over(educ) ///
    bar(1, fcolor(gs12)) bar(2, fcolor(gs8)) bar(3, fcolor(black)) ///
    ytitle("FLFPR (%)") ///
    legend(label(1 "2007") label(2 "2009") label(3 "2011")) ///
    b1title("Education Level")

graph export "${outputpath}flfpr_education.jpg", replace

tabstat employed [aweight=weight], by(educ)

gen age_bin = floor(age / 3) * 3

preserve
	collapse (mean) employed (semean) se_emp=employed [aweight=weight], by(age_bin year)
	replace employed = employed
	replace se_emp = se_emp
	gen upper = (employed + 1.96 * se_emp)
	gen lower = (employed - 1.96 * se_emp)
	twoway	(rarea upper lower age_bin, fcolor(gs14) lcolor(none)) ///
			(line employed age_bin if year == 2004 , sort lcolor(black) lwidth(medium) lpattern(dash)) ///
			(line employed age_bin if year == 2007 , sort lcolor(black) lwidth(medium) lpattern(dash)) ///
			(line employed age_bin if year == 2009 , sort lcolor(gs8)   lwidth(medium) lpattern(shortdash)) ///
			(line employed age_bin if year == 2011 , sort lcolor(gs4)   lwidth(thick) ), ///
		xtitle("Age Group") ///
		ytitle("FLFPR(%)") ///
		legend(order(2 3 4 5 1) label (1 "95% CI(2011)") label(2 "2004") label(3 "2007") label(4 "2009") label(5 "2011"))
	graph export "${outputpath}flfpr_age.jpg", replace
restore


* 1. Create dummy variables for your categorical groups
* This creates variables like sg_1, sg_2, etc.
cap drop sg_* rel_* educ_* work_*
tab socialgroup, gen(sg_)
* tab Religion,    gen(rel_)
gen rel_hindu       = (religion==1) if !missing(religion)
gen rel_muslim      = (religion==2) if !missing(religion)
gen rel_christian   = (religion==3) if !missing(religion)
gen rel_sikh        = (religion==4) if !missing(religion)
gen rel_jain        = (religion==5) if !missing(religion)
gen rel_buddhist    = (religion==6) if !missing(religion)
gen rel_zoroastrian = (religion==7) if !missing(religion)
gen rel_other       = (religion==9) if !missing(religion)

* tab educ,        gen(educ_)
gen educ_illiterate = (educ==1) if !missing(educ)
gen educ_literate   = (educ==2) if !missing(educ)
gen educ_primary    = (educ==3) if !missing(educ)
gen educ_middle     = (educ==4) if !missing(educ)
gen educ_secondary  = (educ==5) if !missing(educ)
gen educ_graduate   = (educ==6) if !missing(educ)

tab cat_work,    gen(work_)

* 2. Summarize everything at once
* The mean of 'sg_1' is the proportion of the sample in that group
levelsof year, local(years)
foreach y in `years' {
	estpost summarize age hhsize other_members_earnings sg_*  rel_* educ_illiterate educ_literate educ_primary educ_middle educ_secondary educ_graduate work_* [aweight=weight]  if year==`y'
	estimate store year_`y'
}

* 3. Export to LaTeX
esttab year_* using "${outputpath}summary_table3.tex", replace ///
    cells("mean(fmt(2))") stats(N, labels("Observations")) ///
    label booktabs nonumber ///
	mtitles("2004" "2007" "2009" "2011") ///
	collabels(none) ///
	refcat(sg_1 "\textbf{Social Group}" rel_hindu "\textbf{Religion}" educ_illiterate "\textbf{Education}" work_1 "\textbf{Employment}", nolabel) ///
	varlabels(other_members_earnings "Other Earnings (INR) (wk)" sg_1 "ST" sg_2 "SC" sg_3 "OBC" sg_4 "Other" rel_hindu "Hindu" rel_muslim "Muslim" rel_christian "Christianity" rel_sikh "Sikh" rel_jain "Jain" rel_buddhist "Buddhist" rel_zoroastrian "Zoroastrian" rel_other "Other" educ_illiterate "Illiterate" educ_literate "Literate" educ_primary "Primary" educ_middle "Middle" educ_secondary "Secondary" educ_graduate "Graduate" work_1 "Agriculture" work_2 "Manufacturing" work_3 "Construction" work_4 "Services" work_5 "Other")

	
* By State
capture drop state_order
gen state_order = State
replace state_order=100 if State == 28 // Andhra Pradesh
replace state_order=101 if State == 29 // Karnataka
replace state_order=102 if State == 32 // Kerala
replace state_order=103 if State == 31 // Lakshadweep
replace state_order=104 if State == 34 // Pondicherry
replace state_order=105 if State == 33 // Tamil Nadu

replace state_order=201 if State == 4 // Chandigargh
replace state_order=202 if State == 7 // Delhi
replace state_order=203 if State == 6 // Haryana
replace state_order=204 if State == 2 // Himachal Pradesh
replace state_order=205 if State == 1 // J&K
replace state_order=206 if State == 3 // Punjab
replace state_order=207 if State == 8 // Rajashtan
replace state_order=208 if State == 5 // Uttaranchal

replace state_order=300 if State == 35 // Andaman Nicobar Islands
replace state_order=301 if State == 10 // Bihar
replace state_order=302 if State == 20 // Jharkand
replace state_order=303 if State == 21 // Orissa
replace state_order=304 if State == 19 // West Bengal

replace state_order=400 if State == 25 // Daman and Diu
replace state_order=401 if State == 26 // D & N Haveli
replace state_order=402 if State == 30 // Goa
replace state_order=403 if State == 24 // Gujurat
replace state_order=404 if State == 27 // Maharashtra

replace state_order=500 if State == 22 // Chattisgargh
replace state_order=501 if State == 23 // Madhya Pradesh
replace state_order=502 if State == 9  // Uttar Pradesh

replace state_order=600 if State == 12 // Arunachal Pradesh
replace state_order=601 if State == 18 // Assam
replace state_order=602 if State == 14 // Manipur
replace state_order=603 if State == 17 // Meghalaya 
replace state_order=604 if State == 15 // Mizoram 
replace state_order=605 if State == 13 // Nagaland
replace state_order=606 if State == 11 // Sikkim
replace state_order=607 if State == 16 // Tripura

gen state_group = floor(state_order / 100)
levelsof year, local(years)
foreach y in `years' {
	estpost tabstat employed [aweight=weight] if year==`y', by(state_order) stats(mean)
	estimate store year_`y'
}

esttab year_* using "${outputpath}summary_table4.tex", replace ///
    cells("mean(fmt(2))") stats(N, labels("Observations")) ///
    label booktabs nonumber ///
	mtitles("2004" "2007" "2009" "2011") ///
	collabels(none) ///
	refcat(100 "\textbf{Southern States}" 201 "\textbf{Northern States}" 300 "\textbf{Eastern Region}" 400 "\textbf{Western Region}" 500 "\textbf{Central Region}" 600 "\textbf{North East}", nolabel) ///
	varlabels(1 "Jammu / Kashmir" 2 "Himachal Pradesh" 3 "Punjab" 4 "Chandigargh" 5 "Uttaranchal" 6 "Haryana" 7 "Delhi" 8 "Rajasthan" 9 "Uttar Pradesh" 10 "Bihar" 11 "Sikkim" 12 "Arrunachal Pradesh" 13 "Nagaland" 14 "Manipur" 15 "Mizoram" 16 "Tripura" 17 "Maghalaya" 18 "Assam" 19 "West Bengal" 20 "Jharkand" 21 "Orissa" 22 "Chattisgargh" 23 "Madhya Pradesh" 24 "Gujurat" 25 "Daman / Diu" 26 "D/N Haveli" 27 "Maharashtra" 28 "Andhra Pradesh" 29 "Karnataka"  33 "Tamil Nadu" 30 "Goa" 31 "Lakshadweep" 32 "Kerala" 34 "Pondicherry" 35 "A N Islands" 100 "Andhra Pradesh" 101 "Karnataka" 102 "Kerala" 103 "Lakshadweep" 104 "Pondicherry" 105 "Tamil Nadu" 200 "Haryana" 201 "Himachal Pradesh" 202 "Punjab" 203 "Rajasthan" 204 "Himachal Pradesh" 205 "Jammu / Kashmir" 206 "Punjab" 207 "Rajasthan" 208 "Uttaranchal" 300 "Andaman Nicobar Islands" 301 "Bihar" 302 "Jharkand" 303 "Orissa" 304 "West Bengal" 400 "Daman / Diu" 401 "D/N Haveli" 402 "Goa" 403 "Gujurat" 404 "Maharashtra" 500 "Chattisgargh" 501 "Madhya Prdesh" 502 "Uttar Pradesh" 600 "Arunachal Pradesh" 601 "Assam" 602 "Manipur" 603 "Meghalaya" 604 "Mizoram" 605 "Nagaland" 606 "Sikkim" 607 "Tripura")

tabstat employed [aweight=weight], by(state_group)



**************************************************************************************************************
*
* REGRESSIONS
*
**************************************************************************************************************
* Two Way Fixed Effects
* State fixed Effects and Year fixed-effects
* State Fixed Effects account for time-invariant effects
* Time  Fixed Effects account for factors that affeact each particular year
**************************************************************************************************************

* other_members_earnings_pc << Check this variabler for 2007

probit employed i.educ  male_salaried i.educ_h i.socialgroup age age2 n_child_04 n_child_514 male_agri_share male_manu_share male_wsvc_share male_othr_share i.State i.year [pweight = weight]
  margins, dydx(*) post
  
  estimates store yr`year'
  estimates store m0_`year'
  estout yr`year'
  esttab yr`year' using "${outputpath}latex/table1.tex", replace ///
   label booktabs b(%6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.4f %6.3f) se(%6.3f) star(* 0.1 ** 0.05 *** 0.01) ///
   prehead(`"\begin{table}[htbp]\centering"' `"\footnotesize"' ///
            `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
            `"\caption{Probit Estimation Results - Urban (Average Marginal Effects)}"' ///
            `"\begin{tabular}{l*{@M}{c}}"' ///
            `"\toprule"' ) ///
   title("Probit Estimation Results (Average Marginal Effects)") ///
   drop(*.State 1.educ 1.educ_h 1.socialgroup) ///
   mtitles("2011") ///
   refcat(2.socialgroup "\textbf{Social Group (Ref=Hindu OBC)}" 2.educ "\textbf{Own Education (Ref = Illiterate)}" other_members_earnings_pc "\textbf{Securtity}" 2.educ_h "\textbf{Household Head Education (Ref=Illiterate)}" male_agri_share "\textbf{District Male Employment Share (Ref=Construction)}", nolabel) ///
   coeflabels(2.educ "Literate" 3.educ "Primary" 4.educ "Middle" 5.educ "Secondary" 6.educ "Graduate" ///
   other_members_earnings_pc "Log Income (pc)" male_salaried "Male Salaried Emp." ///
   2.educ_h "Literate" 3.educ_h "Primary" 4.educ_h "Middle" 5.educ_h "Secondary" 6.educ_h "Graduate" ///
   2.socialgroup "SCST" 3.socialgroup "Muslim" 4.socialgroup "Hindu Other" Age "Age" age2 "Age Squared"  ///
   n_child_04 "Children 0-4" n_child_514 "Children 5-14" male_agri_share "Agriculture" male_manu_share "Manufacturing" male_wsvc_share "Services" male_othr_share "Other" _cons "Constant")


