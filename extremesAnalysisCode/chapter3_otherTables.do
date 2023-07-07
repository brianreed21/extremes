cd ../supplyChain/data/companyData/
clear all


set maxvar 100000
import delimited goodsData_0328
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
encode ggroupdesc,  generate(industrygics_level2Detail)
encode ginddesc,    generate(industrygics_level3Detail)

encode sic2desc, generate(industrysics2)
gen opIncNormdPerc  = opincnormd*100
gen revPerc         = revnormd*100
gen costPerc        = costnormd*100


********************************************************************************
* main results

********************
* DIR EFFECTS
replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in excessheat90plusemp excessrainemp {
	replace `v' = . if `v' == -500
}


********************************************************************************
* table 3.1
label variable excessheat90plusemp "Days >90F"
label variable excessheatemp "Days >95th Pctl Heat"
label variable heatanomalydaily_wtd "Days >50th Pctl Heat"

label variable excessrainemp "Days >95th Pctl Precipitation"
label variable precipanomalydaily_wtd "Days >50th Pctl Precipitation"


* do a bunch of tests here
quietly regress opIncNormdPerc c.excessheat90plusemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1, title(Heat, 90F+ Weighted)
margins, dydx(excessheat90plusemp) post

quietly regress opIncNormdPerc c.excessheatemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2, title(Heat - 95th Pctl Weighted)
margins, dydx(excessheatemp) post

quietly regress opIncNormdPerc c.heatanomalydaily_wtd i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m3, title(Heat, 50th Pctl Weigthed)
margins, dydx(heatanomalydaily_wtd) post

quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m4, title(Precip., 95th Pctl Weighted)
margins, dydx(excessrainemp) post

quietly regress opIncNormdPerc c.precipanomalydaily_wtd i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m5, title(Precip., 50th Pctl Weighted)
margins, dydx(precipanomalydaily_wtd) post



esttab m1 m2 m3 m4 m5 using "otherWeatherDefs.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessheatemp heatanomalydaily_wtd excessheatemp heatanomalydaily_wtd *tercile* *qtr* ) mtitles label replace

	
	
	
********************************************************************************
* table 3.2
label define backgroundTemps 1 "Coolest Tercile" 2 "Middle Tercile Weather" 3 "Warmest Tercile Weather", replace
label values temptercilewtd backgroundTemps

label define backgroundPrecips 1 "Driest Tercile Weather" 2 "Middle Tercile Weather" 3 "Wettest Tercile Weather", replace
label values preciptercilewtd backgroundPrecips


* do a bunch of tests here
quietly regress opIncNormdPerc c.excessheat90plusemp##i.temptercilewtd i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_backgroundCli, title(Heat by Climate)
margins, dydx(excessheat90plusemp) over(temptercilewtd) post

quietly regress opIncNormdPerc c.excessrainemp##i.preciptercilewtd i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_backgroundCli, title(Precipitation by Climate)
margins, dydx(excessrainemp) over(preciptercilewtd) post



esttab m1_backgroundCli m2_backgroundCli using "weatherByCli.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace

	
********************************************************************************
* table 3.3
label define quarters 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", replace
label values qtr quarters

quietly regress opIncNormdPerc c.excessheat90plusemp##i.qtr i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_byQtr, title(Profitability - Heat by Quarter)
margins, dydx(excessheat90plusemp) over(qtr) post


quietly regress opIncNormdPerc c.excessrainemp##i.qtr i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_byQtr, title(Profitability - Precipitation by Quarter)
margins, dydx(excessrainemp) over(qtr) post



esttab m1_byQtr m2_byQtr using "weatherByQtr.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace

	
********************************************************************************
* table 3.4
quietly regress opIncNormdPerc c.excessheat90plusemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_byInd, title(Profitability - Heat by Industry)
margins, dydx(excessheat90plusemp) over(industrygics) post


quietly regress opIncNormdPerc c.excessrainemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_byInd, title(Profitability - Precipitation by Industry)
margins, dydx(excessrainemp) over(industrygics) post



esttab m1_byInd m2_byInd using "weatherByInd.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace

	
	
********************************************************************************
* table 3.6, revs + costs
quietly regress revPerc c.excessheat90plusemp i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_rev, title(Revenue - Heat)
margins, dydx(excessheat90plusemp) post


quietly regress revPerc c.excessrainemp i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_rev, title(Revenue - Precipitation)
margins, dydx(excessrainemp) post


quietly regress costPerc c.excessheat90plusemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_cost, title(Cost - Heat)
margins, dydx(excessheat90plusemp) post


quietly regress costPerc c.excessrainemp i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_cost, title(Cost - Precipitation)
margins, dydx(excessrainemp) post



esttab m1_rev m2_rev m1_cost m2_cost using "altOutcomes.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace



********************************************************************************
* table 3.7, revs + costs by industry
quietly regress revPerc c.excessheat90plusemp##i.industrygics i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_revByInd, title(Revenue - Heat by Industry)
margins, dydx(excessheat90plusemp) over(industrygics) post


quietly regress revPerc c.excessrainemp##i.industrygics i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_revByInd, title(Revenue - Precipitation by Industry)
margins, dydx(excessrainemp) over(industrygics) post


quietly regress costPerc c.excessheat90plusemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_costByInd, title(Cost - Heat by Industry)
margins, dydx(excessheat90plusemp) over(industrygics) post


quietly regress costPerc c.excessrainemp##i.industrygics i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_costByInd, title(Cost - Precipitation by Industry)
margins, dydx(excessrainemp) over(industrygics) post



esttab m1_revByInd m2_revByInd m1_costByInd m2_costByInd using "altOutcomesByInd.tex", se wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace


	
********************************************************************************
* table 3.4, slightly different mod
quietly regress opIncNormdPerc c.excessheat90plusemp##i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
* estimates store m1_byInd, title(Profitability - Heat by Industry)
margins, dydx(excessheat90plusemp) over(industrygics) post


quietly regress opIncNormdPerc c.excessrainemp##i.industrygics##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
* estimates store m2_byInd, title(Profitability - Precipitation by Industry)
margins, dydx(excessrainemp) over(industrygics) post



esttab m1_byInd m2_byInd using "weatherByInd.tex", wide star(* 0.10 ** 0.05 *** 0.01) ///
	drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace
	
	
********************************************************************************
* table 3.4
	
********************************************************************************
* table 3.4
* industry - old
quietly regress opIncNormdPerc c.excessheat90plusemp##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
* estimates store m1_byInd, title(Profitability - Heat by Industry)
margins, dydx(excessheat90plusemp) over(industry) post


quietly regress opIncNormdPerc c.excessrainemp##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
* estimates store m2_byInd, title(Profitability - Precipitation by Industry)
margins, dydx(excessrainemp) over(industry) post

	
	