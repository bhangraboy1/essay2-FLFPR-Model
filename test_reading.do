* This is the STATA Code for the Estimation of the Female Labor Force Participation Rate in India
*
* Using the 2011/12 Data form the Employment and Unemployment Report
*


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
destring Social_Group, replace
destring Religion, replace
destring NIC_2008, replace
destring Sector, replace

* Generate Weights
generate weight = MLT/100 if (NSS==NSC)
replace weight = MLT/200 if (NSS!=NSC)

* Create Male Head of Housedhold Education Level
* Relation to Head is Spouse
gen h_educ_temp = General_Education if Relation_to_Head == 1 & Sex == 1
bysort HHID: egen General_Education_H = max(h_educ_temp)
drop h_educ_temp
* Check
* list HHID Person_Serial_No Sex General_Education General_Education_H in 1/15

*
* Create Number of Children in Two Age Groups
*
gen child_04_ind  = (Age >= 0 & Age <= 4)
gen child_514_ind = (Age >= 5 & Age <= 14)
bysort HHID: egen n_child_04  = total(child_04_ind)
bysort HHID: egen n_child_514 = total(child_514_ind)
drop child_04_ind child_514_ind


*
* Presence of Male Salaried Employee - Security of Household Income
*
gen male_salaried_ind = (Sex==1) & (Usual_Principal_Activity_Status==31)
bysort HHID: egen male_salaried = max(male_salaried_ind)
* list HHID Person_Serial_No Usual_Principal_Activity_Status male_salaried Sex Age in 1/15
 
* Share of Male Workers in Each Industry Type
egen dist_id = group(State District)

gen nic3 = floor(NIC_2008 / 100)
gen is_worker = (Usual_Principal_Activity_Status <= 51)
gen male_worker = (Sex == 1 & is_worker == 1)
bysort dist_id: egen dist_male_workers_w = total(male_worker * weight)

gen cat_agri  = (male_worker == 1 & (1 <= nic3 & nic3 <= 32))
gen cat_manu  = (male_worker == 1 & (101 <= nic3 & nic3 <= 332))
gen cat_const = (male_worker == 1 & (411 <= nic3 & nic3 <= 439))
gen cat_wsvc  = (male_worker == 1 & (620 <= nic3 & nic3 <= 829))
gen cat_othr  = (male_worker == 1 & cat_agri==0 & cat_manu==0 & cat_const==0 & cat_wsvc==0)

foreach var of varlist cat_agri cat_manu cat_const cat_wsvc cat_othr {
	local name = substr("`var'", 5, .)
	bysort dist_id: egen male_`name'_w = total(`var' * weight)
    gen male_`name'_share = male_`name'_w / dist_male_workers_w
    replace male_`name'_share = 0 if dist_male_workers_w == 0
}

* list dist_id Person_Serial_No Sex NIC_2008 nic3 cat_agri cat_manu cat_const cat_wsvc cat_othr in 1/35 if(Sex==1)

list dist_id Person_Serial_No Sex NIC_2008 nic3 male_agri_share male_manu_share male_const_share male_wsvc_share male_othr_share in 1/35

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

save "${outputpath}final_combined", replace

tab _merge

* Filter Variables Down
* Cuts group in to Age cohort from 25-54
drop if Age < 25               // exclude under 25
drop if Age > 54               // exclude over 54
drop if Marital_Status != 2.   // keep only Married
drop if Sex == 1               // exclude Males
drop if Relation_to_Head == 1  // exclude Female Head of Household Self
drop if Sector==1              // exclude Rural

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

* tabstat other_members_earnings_pc if (other_members_earnings_pc > 0)

* NEEDS TO BE CORRECTED with Proper Imputation
replace other_members_earnings_pc=933 if (other_members_earnings_pc==0)

replace other_members_earnings_pc=ln(other_members_earnings_pc)


*****
* Running the Regression Models
*****

* Probit Model + Marginal Effects


local years 2011

foreach year in `years' {
  probit employed i.educ other_members_earnings_pc male_salaried i.educ_h i.socialgroup Age Age2 n_child_04 n_child_514 male_agri_share male_manu_share male_wsvc_share male_othr_share i.State [pweight = weight]
  margins, dydx(*) post
  
  estimates store yr`year'
  estout yr`year'
  esttab yr`year' using "${outputpath}latex/table1.tex", replace ///
   label booktabs b(%6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.4f %6.3f) se(%6.3f) star(* 0.1 ** 0.05 *** 0.01) ///
   prehead(`"\begin{table}[htbp]\centering"' `"\footnotesize"' ///
            `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
            `"\caption{Probit Estimation Results - Urban (Average Margial Effects)}"' ///
            `"\begin{tabular}{l*{@M}{c}}"' ///
            `"\toprule"' ) ///
   title("Probit Estimation Results (Average Margial Effects)") ///
   drop(*.State 1.educ 1.educ_h 1.socialgroup) ///
   mtitles("2011") ///
   refcat(2.socialgroup "Social Group (Ref=Hindu OBC)" 2.educ "Own Education (Ref = Illiterate)" 2.educ_h "Household Head Education (Ref=Illiterate)" male_agri_share "District Male Employment Share (Ref=Construction)", nolabel) ///
   coeflabels(2.educ "Literate" 3.educ "Primary" 4.educ "Middle" 5.educ "Secondary" 6.educ "Graduate" ///
   other_members_earnings_pc "Log Income (pc)" male_salaried "Male Salaried Emp." ///
   2.educ_h "Literate" 3.educ_h "Primary" 4.educ_h "Middle" 5.educ_h "Secondary" 6.educ_h "Graduate" ///
   2.socialgroup "SCST" 3.socialgroup "Muslim" 4.socialgroup "Hindu Other" Age "Age" Age2 "Age Squared"  ///
   n_child_04 "Children 0-4" n_child_514 "Children 5-14" male_agri_share "Agriculture" male_manu_share "Manufacturing" male_wsvc_share "Services" male_othr_share "Other" _cons "Constant")

     probit employed i.educ other_members_earnings_pc male_salaried i.educ_h i.socialgroup Age Age2 n_child_04 n_child_514 male_agri_share male_manu_share male_wsvc_share male_othr_share [pweight = weight]
  margins, dydx(*) post
  
  estimates store yr`year'
  estout yr`year'
  esttab yr`year' using "${outputpath}latex/table2.tex", replace ///
   label booktabs b(%6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.4f %6.3f) se(%6.3f) star(* 0.1 ** 0.05 *** 0.01) ///
   prehead(`"\begin{table}[htbp]\centering"' `"\footnotesize"' ///
            `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
            `"\caption{Probit Estimation Results - Urban (Average Margial Effects)}"' ///
            `"\begin{tabular}{l*{@M}{c}}"' ///
            `"\toprule"' ) ///
   title("Probit Estimation Results (Average Margial Effects)") ///
   drop(1.educ 1.educ_h 1.socialgroup) ///
   mtitles("2011") ///
   refcat(2.socialgroup "Social Group (Ref=Hindu OBC)" 2.educ "Own Education (Ref = Illiterate)" 2.educ_h "Household Head Education (Ref=Illiterate)" male_agri_share "District Male Employment Share (Ref=Construction)", nolabel) ///
   coeflabels(2.educ "Literate" 3.educ "Primary" 4.educ "Middle" 5.educ "Secondary" 6.educ "Graduate" ///
   other_members_earnings_pc "Log Income (pc)" male_salaried "Male Salaried Emp." ///
   2.educ_h "Literate" 3.educ_h "Primary" 4.educ_h "Middle" 5.educ_h "Secondary" 6.educ_h "Graduate" ///
   2.socialgroup "SCST" 3.socialgroup "Muslim" 4.socialgroup "Hindu Other" Age "Age" Age2 "Age Squared"  ///
   n_child_04 "Children 0-4" n_child_514 "Children 5-14" male_agri_share "Agriculture" male_manu_share "Manufacturing" male_wsvc_share "Services" male_othr_share "Other" _cons "Constant")
   
  
}



* Create Averages across Variables
* tabstat employed General_Education

* ds, varwidth(32)
