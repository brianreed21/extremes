cd ../supplyChain/data/companyData/
clear all


set maxvar 100000
import delimited goodsData_0320
* goodsData_0208
keep if year != .
destring gvkey, replace
describe gvkey

destring qtr, replace

* import delimited customer_goodsData



encode yearqtr, generate(time)
encode indgroup, generate(industry)
encode indseason, generate(indSeason)
encode gsectordesc, generate(industrygics)

encode sic2desc, generate(industrysics2)
gen opIncNormdPerc = opincnormd*100

label define ages 1 "Youngest Tercile" 2 "Middle - Age Tercile" 3 "Oldest Tercile", replace
label values agetercile ages

label define profits 1 "Least Profitable Tercile" 2 "Middle Profitability Tercile" 3 "Most Profitable Tercile", replace
label values profittercile profits

label define sizes 1 "Smallest Tercile" 2 "Middle Size Tercile" 3 "Largest Tercile", replace
label values sizetercile sizes

label define quarters 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", replace
label values qtr quarters


********************************************************************************
* main results

********************
* DIR EFFECTS
replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in excessheat90plusemp excessrainemp {
	replace `v' = . if `v' == -500
}

label variable excessheat90plusemp "Days Above 90F, Establishment Wtd. Average"
label variable excessrainemp "Days Above 95th Percentile Rain, Establishment Wtd. Average"

* first heat - w/o and w/ controls
quietly regress opIncNormdPerc c.excessheat90plusemp i.industrygics#i.qtr i.time i.gvkey, cluster(gvkey)
estimates store m1_dir, title(Heat)
margins, dydx(excessheat90plusemp ) post noestimcheck

quietly regress opIncNormdPerc c.excessheat90plusemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_dir, title(Heat, Additional Controls)
margins, dydx(excessheat90plusemp ) post noestimcheck


* next rain - w/o and w/ controls
quietly regress opIncNormdPerc c.excessrainemp i.gvkey i.industrygics#i.qtr i.time, cluster(gvkey)
estimates store m3_dir, title(Precipitation)
margins, dydx(excessrainemp) post

quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m4_dir, title(Precipitation, Additional Controls)
margins, dydx(excessrainemp) post


* quietly regress opIncNormdPerc c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
* margins, dydx(excessrainemp ) post
* outreg2 using regDir.csv, append ctitle("excessrain - controls") label

esttab m1_dir m2_dir m3_dir m4_dir using "dirEffects.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) replace mtitles label 

	
*******************************************************************************
* appendix tables: snow + hurricane
quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey if !(((qtr == 4) | (qtr == 3)) & (state == "FL") | (state == "GA") | (state == "AL") | (state == "LA")), cluster(gvkey)
estimates store m1_hurricane, title(Precip., No Hurricane Zones)
margins, dydx(excessrainemp) post

quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if !(((qtr == 4) | (qtr == 3)) & (state == "FL") | (state == "GA") | (state == "AL") | (state == "LA")), cluster(gvkey)
estimates store m2_hurricane, title(Precip., No Hurricane Zones, Addt'l Controls)
margins, dydx(excessrainemp) post

* not during the winter in one of the cold places !((weightedtempqtr < 5))
quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey if !((weightedtempqtr < 10) & (qtr != 1)), cluster(gvkey)
estimates store m3_snowWtdAvg, title(Precip., No Snow Zones)
margins, dydx(excessrainemp) post

quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if !((weightedtempqtr < 10) & (qtr != 1)), cluster(gvkey)
estimates store m4_snowWtdAvg, title(Precip., No Snow Zones, Addt'l Controls)
margins, dydx(excessrainemp) post


esttab m1_hurricane m2_hurricane m3_snowWtdAvg m4_snowWtdAvg using "dirEffects_robustness.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessrainemp *tercile* *qtr* ) replace mtitles label 


* in neither of those
quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if !(((qtr == 4) | (qtr == 3)) & (state == "FL") | (state == "GA") | (state == "AL") | (state == "LA")) & !((weightedtempqtr < 10) & (qtr != 1)), cluster(gvkey)
estimates store m_snowPlusCane, title(Precip., No Snow and No Hurricane)
margins, dydx(excessrainemp) post

	
	
********************
* INDIR EFFECTS
replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in worstsupplier_excessheat90plusem largestsupplier_excessheat90plus wtdsupplier_excessheat90plusemp worstsupplier_excessrainemp largestsupplier_excessrainemp wtdsupplier_excessrainemp worstsupplier500k_excessheat90pl largestsupplier500k_excessheat90 wtdsupplier500k_excessheat90plus worstsupplier500k_excessrainemp largestsupplier500k_excessrainem wtdsupplier500k_excessrainemp worstsupplier_excessheat90plus worstsupplier_excessrain{
	replace `v' = . if `v' == -500
}

label variable worstsupplier_excessheat90plusem "Worst Heat Across Suppliers"
label variable wtdsupplier_excessheat90plusemp "Average Heat Across Suppliers"
label variable worstsupplier_excessrainemp "Worst Rain Across Suppliers"
label variable wtdsupplier_excessrainemp "Average Rain Across Suppliers"

* do a bunch of tests here
quietly regress opIncNormdPerc c.worstsupplier_excessheat90plusem i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m1, title(Heat, Supplier-Worst)
margins, dydx(worstsupplier_excessheat90plus) post
* outreg2 using regIndir.csv, replace ctitle("op inc heat - worst") label


quietly regress opIncNormdPerc c.wtdsupplier_excessheat90plusemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m2, title(Heat, Supplier Avg.)
margins, dydx(wtdsupplier_excessheat90plusemp) post
* outreg2 using regIndir.csv, append ctitle("op inc heat - wtd") label


*****
quietly regress opIncNormdPerc c.worstsupplier_excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m3, title(Precipitation, Supplier-Worst)
margins, dydx(worstsupplier_excessrainemp) post

quietly regress opIncNormdPerc c.wtdsupplier_excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m4, title(Precipitation, Supplier Avg.)
margins, dydx(wtdsupplier_excessrainemp) post
* outreg2 using regIndir.csv, replace
* append ctitle("op inc rain - wtd") label


esttab m1 m2 m3 m4 using "indirEffects.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(worstsupplier_excessheat90plusem wtdsupplier_excessheat90plusemp worstsupplier_excessrainemp wtdsupplier_excessrainemp *tercile* *qtr* ) mtitles label replace

	
	
************
* check 500k
* 500k 
label variable worstsupplier500k_excessheat90pl "Worst Heat Across Suppliers >500km from Customer"
label variable wtdsupplier500k_excessheat90plus "Average Heat Across Suppliers >500km from Customer"
label variable worstsupplier500k_excessrainemp "Worst Rain Across Suppliers >500km from Customer"
label variable wtdsupplier500k_excessrainemp "Average Rain Across Suppliers >500km from Customer"

replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in excessheat90plusemp excessrainemp {
	replace `v' = . if `v' == -500
}

replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in worstsupplier_excessheat90plusem largestsupplier_excessheat90plus wtdsupplier_excessheat90plusemp worstsupplier_excessrainemp largestsupplier_excessrainemp wtdsupplier_excessrainemp worstsupplier500k_excessheat90pl largestsupplier500k_excessheat90 wtdsupplier500k_excessheat90plus worstsupplier500k_excessrainemp largestsupplier500k_excessrainem wtdsupplier500k_excessrainemp {
	replace `v' = . if `v' == -500
}
	

quietly regress opIncNormdPerc c.wtdsupplier500k_excessheat90plus i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m1, title(Heat, Supplier Average)
margins, dydx(wtdsupplier500k_excessheat90plus) post

quietly regress opIncNormdPerc c.worstsupplier500k_excessheat90pl i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m2, title(Heat, Supplier-Worst)
margins, dydx(worstsupplier500k_excessheat90pl) post

quietly regress opIncNormdPerc c.wtdsupplier500k_excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m3, title(Precipitation, Supplier Average)
margins, dydx(wtdsupplier500k_excessrainemp) post

quietly regress opIncNormdPerc c.worstsupplier500k_excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m4, title(Precipitation, Supplier-Worst)
margins, dydx(worstsupplier500k_excessrainemp) post


esttab m2 m4 using "indirEffects_robustness.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(worstsupplier500k_excessheat90pl worstsupplier500k_excessrainemp *tercile* *qtr* ) mtitles label replace

	
hist excessheat90plusemp
	
	
**********************************
* ROBUSTNESS CHECKS 1: LOG
* DIR EFFECTS
quietly regress lnopincnormdaf_take2 c.excessheat90plusemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_log, title(Heat, Direct)
margins, dydx(excessheat90plusemp) post


quietly regress lnopincnormdaf_take2 c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_log, title(Precipitation, Direct)
margins, dydx(excessrainemp) post


quietly regress lnopincnormdaf_take2 c.worstsupplier_excessheat90plusem i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m3_log, title(Heat, Indirect Effect)
margins, dydx(worstsupplier_excessheat90plus) post


quietly regress lnopincnormdaf_take2 c.worstsupplier_excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m4_log, title(Precipitation, Indirect Effect)
margins, dydx(worstsupplier_excessrainemp) post

esttab m1_log m2_log m3_log m4_log using "logEffects.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp worstsupplier_excessheat90plus worstsupplier_excessrainemp *tercile* *qtr* ) mtitles label replace


**********************************
* ROBUSTNESS CHECKS 2: HQs
* DIR EFFECTS
quietly regress opIncNormdPerc c.excessheat90plus i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_hq, title(Heat, Direct Effect)
margins, dydx(excessheat90plus) post


quietly regress opIncNormdPerc c.excessrain i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_hq, title(Precip., Direct Effect)
margins, dydx(excessrain) post



quietly regress opIncNormdPerc c.worstsupplier_excessheat90plus i.industrygics#i.qtr i.time i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m3_hq, title(Heat, Indirect Effect)
margins, dydx(worstsupplier_excessheat90plus) post


quietly regress opIncNormdPerc c.worstsupplier_excessrain i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
estimates store m4_hq, title(Precip., Indirect Effect)
margins, dydx(worstsupplier_excessrain) post

esttab m1_hq m2_hq m3_hq m4_hq using "hqEffects.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plus excessrain worstsupplier_excessheat90plus worstsupplier_excessrain *tercile* *qtr* ) mtitles label replace

	

	
	


**********************************
* MECHANISMS: revenues
quietly regress revnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using regRevs.csv, append ctitle("excessheat90plus - controls") label


quietly regress revnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using regRevs.csv, append ctitle("excessrain - controls") label


quietly regress revnormd c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post
outreg2 using regRevs.csv, append ctitle("op inc heat - worst") label


quietly regress revnormd c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post
outreg2 using regRevs.csv, append ctitle("op inc rain - worst") label


* MECHANISMS: costs
quietly regress costnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using regCosts.csv, append ctitle("excessheat90plus - controls") label


quietly regress costnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using regCosts.csv, append ctitle("excessrain - controls") label


quietly regress costnormd c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post
outreg2 using regCosts.csv, append ctitle("op inc heat - worst") label


quietly regress costnormd c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
outreg2 using regCosts.csv, replace
*  append ctitle("op inc rain - worst") label

margins, dydx(worstsupplier_excessrainemp) post
outreg2 using regCosts.csv, append ctitle("op inc rain - worst") label


********************
quietly regress lnrevnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post

quietly regress lncostnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post




quietly regress lnrev c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post

quietly regress lncost c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post









revNormd    = (totalRevenue + 0.001)/(assetsLast + 0.001),
costNormd   = (costGoodsSold + 0.001)/(assetsLast + 0.001),



