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



********************************************************************************
* main results

********************
* DIR EFFECTS
replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in excessheat90plusemp excessrainemp {
	replace `v' = . if `v' == -500
}


* first heat - w/o and w/ controls
quietly regress opIncNormdPerc c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using regDir.csv, replace ctitle("excessheat90plus - no controls") label

quietly regress opIncNormdPerc c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using regDir.csv, append ctitle("excessheat90plus - controls") label


* next rain - w/o and w/ controls
quietly regress opIncNormdPerc c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using regDir.csv, append ctitle("excessrain - no controls") label 

quietly regress opIncNormdPerc c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using regDir.csv, append ctitle("excessrain - controls") label



********************
* INDIR EFFECTS
replace excessheat90plusemp = . if excessheat90plusemp == -500
foreach v in worstsupplier_excessheat90plusem largestsupplier_excessheat90plus wtdsupplier_excessheat90plusemp worstsupplier_excessrainemp largestsupplier_excessrainemp wtdsupplier_excessrainemp worstsupplier500k_excessheat90pl largestsupplier500k_excessheat90 wtdsupplier500k_excessheat90plus worstsupplier500k_excessrainemp largestsupplier500k_excessrainem wtdsupplier500k_excessrainemp worstsupplier_excessheat90plus worstsupplier_excessrain{
	replace `v' = . if `v' == -500
}

* do a bunch of tests here
quietly regress opIncNormdPerc c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post
outreg2 using regIndir.csv, replace ctitle("op inc heat - worst") label

quietly regress opIncNormdPerc c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessheat90plus) post
outreg2 using regIndir.csv, append ctitle("op inc heat - largest") label

quietly regress opIncNormdPerc c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plusemp) post
outreg2 using regIndir.csv, append ctitle("op inc heat - wtd") label


*****
quietly regress opIncNormdPerc c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post
outreg2 using regIndir.csv, append ctitle("op inc rain - worst") label

quietly regress opIncNormdPerc c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessrainemp) post
outreg2 using regIndir.csv, append ctitle("op inc rain - largest") label

quietly regress opIncNormdPerc c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier_excessrainemp) post
outreg2 using regIndir.csv, append ctitle("op inc rain - wtd") label




**********************************
* ROBUSTNESS CHECKS 1: LOG
* DIR EFFECTS
quietly regress lnopincnormdaf_take2 c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using regRobustLogs.csv, replace ctitle("excessheat90plus - controls") label


quietly regress lnopincnormdaf_take2 c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using regRobustLogs.csv, append ctitle("excessrain - controls") label


quietly regress lnopincnormdaf_take2 c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post
outreg2 using regRobustLogs.csv, append ctitle("op inc heat - worst") label


quietly regress lnopincnormdaf_take2 c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post
outreg2 using regRobustLogs.csv, append ctitle("op inc rain - worst") label



**********************************
* ROBUSTNESS CHECKS 2: HQs
* DIR EFFECTS
quietly regress opIncNormdPerc c.excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plus) post
outreg2 using regRobustHQs.csv, append ctitle("excessheat90plus - controls") label


quietly regress opIncNormdPerc c.excessrain i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrain) post
outreg2 using regRobustHQs.csv, append ctitle("excessrain - controls") label


quietly regress opIncNormdPerc c.worstsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post
outreg2 using regRobustHQs.csv, append ctitle("op inc heat - worst") label


quietly regress opIncNormdPerc c.worstsupplier_excessrain i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrain) post
outreg2 using regRobustHQs.csv, append ctitle("op inc rain - worst") label




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



