* This is the STATA Code for the Estimation of the Female Labor Force Participation Rate in India
*
* Using the 2011/12 Data form the Employment and Unemployment Report
*

* Getting the Data Together

* rename all variable to lowercase
* possibly drop variables I dont need
* Bring in a new Wave of Data - merge
* try to append another year into the dataset
* try to merge all years into the dataset

* Define Directory for Files to be written to
clear all
global datapath   "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/data/NSSO/68th Round - 2011-2012/NSS68_10/"
global outputpath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/STATA/NSSO/essay2-FLFPR-Model/"
global factorpath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/pythondevelopment/worldvaluessurvey/"

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


rename Sex sex
rename Sector sector
rename Age age

gen age_bin = floor(age / 5) * 5
gen year=2011

* Generate Weights
generate weight = MLT/100 if (NSS==NSC)
replace weight = MLT/200 if (NSS!=NSC)

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

gen nic3 = floor(NIC_2008 / 100)
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

list dist_id Person_Serial_No sex NIC_2008 nic3 male_agri_share male_manu_share male_const_share male_wsvc_share male_othr_share in 1/35

* tabulate n_child_04
* tabulate n_child_514

*****
* Making Conversion from Survey Data to Relevant Categories for Analysis
*****

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

* Categorizing Religion / Caste from Survey
* Hindu Non SCST=OBC
generate socialgroup=1
* Hindu SCST
replace socialgroup=2 if(Social_Group==1) | (Social_Group==2)
* Mulsim
replace socialgroup=3 if (Religion==2)
* Hindu Other
replace socialgroup=4 if (Social_Group==9)

recast int socialgroup

save "${outputpath}final_combined", replace

tab _merge


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
tabulate employed

* tabstat other_members_earnings_pc if (other_members_earnings_pc > 0)

* NEEDS TO BE CORRECTED with Proper Imputation
replace other_members_earnings_pc=933 if (other_members_earnings_pc==0)

replace other_members_earnings_pc=ln(other_members_earnings_pc)

gen Political = (q29+q209+q210+q211+q212) / 5
gen Economic = (q32+q33) / 2
gen Education = (q30)
gen Violence = (q189+q191+q137) / 3

