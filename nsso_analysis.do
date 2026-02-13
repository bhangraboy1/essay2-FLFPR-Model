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

estpost summarize lfpr_rm lfpr_um lfpr_rf lfpr_uf [aweight=weight]  if year==2011
estimate store year_2011

esttab year_2011 using "${outputpath}summary_table1.tex", replace ///
    cells("mean(fmt(2))") ///
	varlabels(lfpr_rm "Rural Male" lfpr_rf "Rural Female" lfpr_um "Urban Male" lfpr_uf "Urban Female") ///
	mtitles("2011") ///
	collabels(none) ///
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
					rm_self rf_self um_self uf_self [aweight=weight] if year == 2011
estimate store b_year_2011

esttab b_year_2011 using "${outputpath}summary_table2.tex", replace ///
    cells("mean(fmt(2))") ///
	refcat(rm_reg "\textbf{Regular Employment}" rm_cas "\textbf{Casual Worker}" rm_self "\textbf{Self Employed}", nolabel) ///
	varlabels(  rm_reg  "Rural Male" rf_reg  "Rural Female" um_reg  "Urban Male" uf_reg  "Urban Female" ///
				rm_cas  "Rural Male" rf_cas  "Rural Female" um_cas  "Urban Male" uf_cas  "Urban Female"  ///
				rm_self "Rural Male" rf_self "Rural Female" um_self "Urban Male" uf_self "Urban Female") ///
	mtitles("2011") ///
	collabels(none) ///
    nonumber label booktabs ///
	stats(N, labels("Observations"))
	
* Filter Variables Down
* Only include Females
* Exlcude Female Head of Household
* Urban
drop if sex == 1               // exclude Males
drop if Relation_to_Head == 1  // exclude Female Head of Household Self
drop if sector==1              // exclude Rural


tabstat employed, by(educ)
label values educ educ_label
label values cat_work work_label
label values Religion religion_label

tabstat employed [aweight=weight], by(educ)

graph bar employed, over(educ) b1title("Education") ytitle("FLFPR (%)") bar(1, fcolor(black))
graph export "${outputpath}flfpr_education.jpg", replace

tabstat employed [aweight=weight], by(educ)


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
estpost summarize age HH_Size sg_* rel_* educ_* work_* [aweight=weight], listwise

* 3. Export to LaTeX
esttab using "${outputpath}summary_table3.tex", replace ///
    cells("mean(fmt(2))") stats(N, labels("Observations")) ///
    label booktabs nonumber ///
	mtitles("2011") ///
	collabels(none) ///
	refcat(sg_1 "\textbf{Social Group}" rel_1 "\textbf{Religion}" educ_1 "\textbf{Education}" work_1 "\textbf{Employment}", nolabel) ///
	varlabels(sg_1 "ST" sg_2 "SC" sg_3 "OBC" sg_4 "Other" rel_1 "Hindu" rel_2 "Muslim" rel_3 "Christianity" rel_4 "Sikh" rel_5 "Jain" rel_6 "Buddhist" rel_7 "Zoroastrian" rel_8 "Other" educ_1 "Illiterate" educ_2 "Literate" educ_3 "Primary" educ_4 "Middle" educ_5 "Secondary" educ_6 "Graduate" work_1 "Agriculture" work_2 "Manufacturing" work_3 "Construction" work_4 "Services" work_5 "Other")

	
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

estpost tabstat employed [aweight=weight], by(state_order) stats(mean)
esttab using "${outputpath}summary_table4.tex", replace ///
    cells("mean(fmt(2))") stats(N, labels("Observations")) ///
    label booktabs nonumber ///
	mtitles("2011") ///
	collabels(none) ///
	refcat(100 "\textbf{Southern States}" 201 "\textbf{Northern States}" 300 "\textbf{Eastern Region}" 400 "\textbf{Western Region}" 500 "\textbf{Central Region}" 600 "\textbf{North East}", nolabel) ///
	varlabels(1 "Jammu / Kashmir" 2 "Himachal Pradesh" 3 "Punjab" 4 "Chandigargh" 5 "Uttaranchal" 6 "Haryana" 7 "Delhi" 8 "Rajasthan" 9 "Uttar Pradesh" 10 "Bihar" 11 "Sikkim" 12 "Arrunachal Pradesh" 13 "Nagaland" 14 "Manipur" 15 "Mizoram" 16 "Tripura" 17 "Maghalaya" 18 "Assam" 19 "West Bengal" 20 "Jharkand" 21 "Orissa" 22 "Chattisgargh" 23 "Madhya Pradesh" 24 "Gujurat" 25 "Daman / Diu" 26 "D/N Haveli" 27 "Maharashtra" 28 "Andhra Pradesh" 29 "Karnataka"  33 "Tamil Nadu" 30 "Goa" 31 "Lakshadweep" 32 "Kerala" 34 "Pondicherry" 35 "A N Islands" 100 "Andhra Pradesh" 101 "Karnataka" 102 "Kerala" 103 "Lakshadweep" 104 "Pondicherry" 105 "Tamil Nadu" 200 "Haryana" 201 "Himachal Pradesh" 202 "Punjab" 203 "Rajasthan" 204 "Himachal Pradesh" 205 "Jammu / Kashmir" 206 "Punjab" 207 "Rajasthan" 208 "Uttaranchal" 300 "Andaman Nicobar Islands" 301 "Bihar" 302 "Jharkand" 303 "Orissa" 304 "West Bengal" 400 "Daman / Diu" 401 "D/N Haveli" 402 "Goa" 403 "Gujurat" 404 "Maharashtra" 500 "Chattisgargh" 501 "Madhya Prdesh" 502 "Uttar Pradesh" 600 "Arunachal Pradesh" 601 "Assam" 602 "Manipur" 603 "Meghalaya" 604 "Mizoram" 605 "Nagaland" 606 "Sikkim" 607 "Tripura")

tabstat employed [aweight=weight], by(state_group)
	
	
	