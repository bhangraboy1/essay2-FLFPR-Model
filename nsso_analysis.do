* This is the STATA Code for the Estimation of the Female Labor Force Participation Rate in India
*
* Using the 2011/12 Data form the Employment and Unemployment Report
*
* Putting together some basic Data Vizualizations and Tables
* First with all the data
* Second only with Filtered Data
*
*

tabulate Usual_Principal_Activity_Status
* 11 - self employed
* 21 - unpaid work
* 31 - regular employee
* 41 - casual worker
* 51 - casual worker
* 81 - unemployed

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

estpost summarize lfpr_rm lfpr_um lfpr_rf lfpr_uf if year==2011
estimate store year_2011

esttab year_2011 using "${outputpath}summary_table1.tex", replace ///
    cells("mean(fmt(2))") ///
	varlabels(lfpr_rm "Rural Male" lfpr_rf "Rural Female" lfpr_um "Urban Male" lfpr_uf "Urban Female") ///
	mtitles("2011") ///
    nonumber label booktabs ///
	stats(N, labels("Observations"))

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

estpost summarize   rm_reg  rf_reg  um_reg  uf_reg  ///
					rm_cas  rf_cas  um_cas  uf_cas  ///
					rm_self rf_self um_self uf_self if year == 2011
estimate store b_year_2011

esttab b_year_2011 using "${outputpath}summary_table2.tex", replace ///
    cells("mean(fmt(2))") ///
	refcat(rm_reg "\textbf{Regular Employment}" rm_cas "\textbf{Casual Worker}" rm_self "\textbf{Self Employed}", nolabel) ///
	varlabels(  rm_reg  "Rural Male" rf_reg  "Rural Female" um_reg  "Urban Male" uf_reg  "Urban Female" ///
				rm_cas  "Rural Male" rf_cas  "Rural Female" um_cas  "Urban Male" uf_cas  "Urban Female"  ///
				rm_self "Rural Male" rf_self "Rural Female" um_self "Urban Male" uf_self "Urban Female") ///
	mtitles("2011") ///
    nonumber label booktabs ///
	stats(N, labels("Observations"))

exit
	
* Filter Variables Down
* Cuts group in to Age cohort from 25-54
drop if sex == 1               // exclude Males
drop if Relation_to_Head == 1  // exclude Female Head of Household Self
drop if sector==1              // exclude Rural


tabstat employed, by(educ)
label values educ educ_label
label values cat_work work_label
label values Religion religion_label

tabstat employed, by(educ)

graph bar employed, over(educ) b1title("Education") ytitle("FLFPR (%)") bar(1, fcolor(black))
graph export "${outputpath}flfpr_education.jpg", replace

tabstat employed, by(educ)


graph bar employed, over(cat_work) b1title("Sector") ytitle("FLFPR (%)") bar(1, fcolor(black))
graph export "${outputpath}flfpr_sector.jpg", replace

preserve
	collapse (mean) employed, by(age_bin)
	replace employed = employed * 100
	twoway (line employed age_bin, sort lcolor(black) lwidth(medium) xtitle("Age") ytitle("FLFPR (%)"))
	graph export "${outputpath}flfpr_age.jpg", replace
restore

* 1. Create dummy variables for your categorical groups
* This creates variables like sg_1, sg_2, etc.
cap drop sg_* rel_* educ_* work_*
tab socialgroup, gen(sg_)
tab Religion,    gen(rel_)
tab educ,        gen(educ_)
tab cat_work,    gen(work_)

* 2. Summarize everything at once
* The mean of 'sg_1' is the proportion of the sample in that group
estpost summarize age HH_Size sg_* rel_* educ_* work_*, listwise

* 3. Export to LaTeX
esttab using "${outputpath}summary_table3.tex", replace ///
    cells("mean(fmt(2))") stats(N, labels("Observations")) ///
    label booktabs nonumber ///
	mtitles("2011") ///
	refcat(sg_1 "\textbf{Social Group}" rel_1 "\textbf{Religion}" educ_1 "\textbf{Education}" work_1 "\textbf{Employment}", nolabel) ///
	varlabels(sg_1 "ST" sg_2 "SC" sg_3 "OBC" sg_4 "Other" rel_1 "Hindu" rel_2 "Muslim" rel_3 "Christianity" rel_4 "Sikh" rel_5 "Jain" rel_6 "Buddhist" rel_7 "Zoroastrian" rel_8 "Other" educ_1 "Illiterate" educ_2 "Literate" educ_3 "Primary" educ_4 "Middle" educ_5 "Secondary" educ_6 "Graduate" work_1 "Agriculture" work_2 "Manufacturing" work_3 "Construction" work_4 "Services" work_5 "Other")

//     cells("mean(fmt(2))" "sd(par fmt(2))") ///

// graph bar employed if cat_work==1, over(educ) b1title("Education") ytitle("FLFPR(%)") bar(1, fcolor(black))
// graph export "${outputpath}flfpr_sector1.jpg", replace

// graph bar employed if cat_work==2, over(educ) b1title("Education") ytitle("FLFPR(%)") bar(1, fcolor(black))
// graph export "${outputpath}flfpr_sector2.jpg", replace
