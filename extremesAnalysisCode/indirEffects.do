cd ../supplyChain/data/companyData/
clear all


**************************************
set maxvar 100000
clear all
import delimited supplierGoodsData, varnames(1)




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
quietly regress opincnormdbef_take2 c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plusem) post
outreg2 using reg1_indir.xls, append ctitle("heat - worst") label

quietly regress lnopincnormdbef_take2 c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(largestsupplier_excessheat90plus) post
outreg2 using reg1_indir.xls, append ctitle("heat - largest") label

quietly regress lnopincnormdbef_take2 c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plusemp) post
outreg2 using reg1_indir.xls, append ctitle("heat - wtd") label



**************
quietly regress lnopincnormdbef_take2 c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post
outreg2 using reg1_indir.xls, append ctitle("rain - worst") label


quietly regress lnopincnormdbef_take2 c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(largestsupplier_excessrainemp) post
outreg2 using reg1_indir.xls, append ctitle("rain - largest") label



quietly regress lnopincnormdbef_take2 c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(wtdsupplier_excessrainemp) post
outreg2 using reg1_indir.xls, append ctitle("rain - wtd") label

