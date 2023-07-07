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


foreach var of varlist worstsupplier500k_excessrain v207 {
cap replace `var' = "." if `var'=="NA"
destring `var', replace
}

********************************************************************************
* try some cleaning
replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in excessheat90plusemp excessrainemp {
	replace `v' = . if `v' == -500
}

replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in worstsupplier_excessheat90plusem largestsupplier_excessheat90plus wtdsupplier_excessheat90plusemp worstsupplier_excessrainemp largestsupplier_excessrainemp wtdsupplier_excessrainemp worstsupplier500k_excessheat90pl largestsupplier500k_excessheat90 wtdsupplier500k_excessheat90plus worstsupplier500k_excessrainemp largestsupplier500k_excessrainem wtdsupplier500k_excessrainemp worstsupplier_excessheat90plus worstsupplier_excessrain v207 worstsupplier500k_excessrain {
	replace `v' = . if `v' == -500
}



********************************************************************************
* precip results: check that winter and hurricane season don't drive the results

********************
* direct effects
* check that it's not one of the southeast states during the hurricane months
quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if !(((qtr == 4) | (qtr == 3)) & (state == "FL") | (state == "GA") | (state == "AL") | (state == "LA")), cluster(gvkey)
margins, dydx(excessrainemp) post
* outreg2 using regDir.csv, append ctitle("excessrain - controls") label

* not during the winter in one of the cold places !((weightedtempqtr < 5))
quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if !((quarterly_avg_temp < 10) & (qtr != 1)), cluster(gvkey)
margins, dydx(excessrainemp) post

quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if !((weightedtempqtr < 10) & (qtr != 1)), cluster(gvkey)
margins, dydx(excessrainemp) post


* in neither of those
quietly regress opIncNormdPerc c.excessrainemp i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if !(((qtr == 4) | (qtr == 3)) & (state == "FL") | (state == "GA") | (state == "AL") | (state == "LA")) & !((qtr == 1) & (temptercilewtd == 1)), cluster(gvkey)
margins, dydx(excessrainemp) post


********************
* INDIR EFFECTS - test 500k ish
encode ggroupdesc,  generate(industrygics_level2Detail)

quietly regress opIncNormdPerc c.largestsupplier500k_excessheat90 i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier500k_excessheat90) post


quietly regress opIncNormdPerc c.wtdsupplier500k_excessheat90plus i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier500k_excessheat90plus) post

quietly regress opIncNormdPerc c.worstsupplier500k_excessheat90pl i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier500k_excessheat90pl) post
* outreg2 using regIndir.csv, append ctitle("op inc heat - largest") label

quietly regress opIncNormdPerc c.worstsupplier500k_excessrain i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier500k_excessrainemp) post
* outreg2 using regIndir.csv, replace ctitle("op inc heat - worst") label




quietly regress opIncNormdPerc c.v207 i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(v207) post
* outreg2 using regIndir.csv, append ctitle("op inc heat - largest") label

quietly regress opIncNormdPerc c.worstsupplier500k_excessrain i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier500k_excessrain) post
* outreg2 using regIndir.csv, replace ctitle("op inc heat - worst") label






********************************************************************************
* try some with lags here
clear all
import delimited goodsData_withLags_large
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




* same period only
quietly regress opIncNormdPerc empwt_precip_zipquarter_95 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(empwt_precip_zipquarter_95) post

quietly regress opIncNormdPerc empwt_days90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(empwt_days90plus) post



* 1 period of lags
quietly regress opIncNormdPerc empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95) post

quietly regress opIncNormdPerc empwt_days90plus empwt_lag1_days90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(empwt_days90plus empwt_lag1_days90plus) post





* 3 periods of lags
quietly regress opIncNormdPerc empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95 empwt_lag2_precip_zipquarter_95 empwt_lag3_precip_zipquarter_95 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95 empwt_lag2_precip_zipquarter_95 empwt_lag3_precip_zipquarter_95) post

quietly regress opIncNormdPerc empwt_days90plus empwt_lag1_days90plus empwt_lag2_days90plus empwt_lag3_days90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(empwt_days90plus empwt_lag1_days90plus empwt_lag2_days90plus empwt_lag3_days90plus) post




* try 3 periods for a bunch of different outcome variables
local outcomeVars revnormd lnrevnormd costnormd lncostnormd

foreach var of local outcomeVars {
	quietly regress `var' empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95 empwt_lag2_precip_zipquarter_95 empwt_lag3_precip_zipquarter_95 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95 empwt_lag2_precip_zipquarter_95 empwt_lag3_precip_zipquarter_95) post

	quietly regress `var' empwt_days90plus empwt_lag1_days90plus empwt_lag2_days90plus empwt_lag3_days90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(empwt_days90plus empwt_lag1_days90plus empwt_lag2_days90plus empwt_lag3_days90plus) post
		
}



* try 3 periods for a bunch of different outcome variables
local outcomeVars lnrev lncost

foreach var of local outcomeVars {
	display("******************** - `var' - ********************")
	quietly regress `var' empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95 empwt_lag2_precip_zipquarter_95 empwt_lag3_precip_zipquarter_95 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(empwt_precip_zipquarter_95 empwt_lag1_precip_zipquarter_95 empwt_lag2_precip_zipquarter_95 empwt_lag3_precip_zipquarter_95) post

	quietly regress `var' empwt_days90plus empwt_lag1_days90plus empwt_lag2_days90plus empwt_lag3_days90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(empwt_days90plus empwt_lag1_days90plus empwt_lag2_days90plus empwt_lag3_days90plus) post
		
}









