cd ../supplyChain/data/companyData/
clear all


**************************************
set maxvar 100000
clear all
import delimited supplierGoodsData, varnames(1)

encode yearqtr, generate(time)
encode indgroup, generate(industry)

quietly regress lnopincnormdbef_take2 c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post


quietly regress lnopincnormdbef_take2 c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post


**************************************
set maxvar 100000
clear all
import delimited indirSubset

keep if year > 2000 & year < 2020


encode yearqtr, generate(time)
encode indgroup, generate(industry)
* encode indseason, generate(indSeason)



**************************************
* do a bunch of tests here
quietly regress lnopincnormdbef_take2 c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plusem) post

quietly regress lnopincnormdbef_take2 c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(largestsupplier_excessheat90plus) post

quietly regress lnopincnormdbef_take2 c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plusemp) post


* just the hqs here
quietly regress lnopincnormdbef_take2 c.worstsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post

quietly regress lnopincnormdbef_take2 c.wtdsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plus) post

 
**************
* do a bunch of tests here


quietly regress lnopincnormdbef_take2 c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post


quietly regress lnopincnormdbef_take2 c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(largestsupplier_excessrainemp) post



quietly regress lnopincnormdbef_take2 c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(wtdsupplier_excessrainemp) post


