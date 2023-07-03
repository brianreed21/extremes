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
gen opIncNormdPerc = opincnormd*100
gen revPerc        = revnormd*100
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
estimates store m1, title(Profitability - Heat)

quietly regress opIncNormdPerc c.excessheatemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2, title(Profitability - Heat)

quietly regress opIncNormdPerc c.heatanomalydaily_wtd i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m3, title(Profitability - Heat)

quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m4, title(Profitability - Precipitation)

quietly regress opIncNormdPerc c.precipanomalydaily_wtd i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m5, title(Profitability - Precipitation)



esttab m1 m2 m3 m4 m5 using "otherWeatherDefs.tex", star(* 0.10 ** 0.05 *** 0.01) ///
	cells(b(star fmt(3)) se(par fmt(2))) drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
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
estimates store m1_backgroundCli, title(Profitability - Heat by Climate)


quietly regress opIncNormdPerc c.excessrainemp##i.preciptercilewtd i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_backgroundCli, title(Profitability - Precipitation by Climate)



esttab m1_backgroundCli m2_backgroundCli using "weatherByCli.tex", star(* 0.10 ** 0.05 *** 0.01) ///
	cells(b(star fmt(3)) se(par fmt(2))) drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace

	
********************************************************************************
* table 3.3
label define quarters 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4", replace
label values qtr quarters

quietly regress opIncNormdPerc c.excessheat90plusemp##i.qtr i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_byQtr, title(Profitability - Heat by Quarter)


quietly regress opIncNormdPerc c.excessrainemp##i.qtr i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_byQtr, title(Profitability - Precipitation by Quarter)



esttab m1_byQtr m2_byQtr using "weatherByQtr.tex", star(* 0.10 ** 0.05 *** 0.01) ///
	cells(b(star fmt(3)) se(par fmt(2))) drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace

	
********************************************************************************
* table 3.4
quietly regress opIncNormdPerc c.excessheat90plusemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m1_byQtr, title(Profitability - Heat by Industry)


quietly regress opIncNormdPerc c.excessrainemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
estimates store m2_byQtr, title(Profitability - Precipitation by Industry)



esttab m1_byQtr m2_byQtr using "weatherByInd.tex", star(* 0.10 ** 0.05 *** 0.01) ///
	cells(b(star fmt(3)) se(par fmt(2))) drop(*gvkey 1*1.qtr 2*4.qtr 3*4.qtr 4*4.qtr ///
	5*4.qtr 6*4.qtr 7*4.qtr 8.industry* 1.profit* 1.age* 1.size* *time) ///
	order(excessheat90plusemp excessrainemp *tercile* *qtr* ) mtitles label replace

	