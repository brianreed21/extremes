cd ../supplyChain/data/companyData/
clear all




**************************************
set maxvar 100000
clear all
import delimited goodsData_0104
destring year, replace

keep if year != .
destring gvkey, replace
describe gvkey

destring qtr, replace
destring worstsupplier_excessheat90plusem, replace

encode yearqtr, generate(time)
encode indgroup, generate(industry)
* encode indseason, generate(indSeason)

* replace opincChange = opinc_befdep/(opinc_befdeplast)
gen opIncNormdPerc = opincnormd*100

**************************************
* do a bunch of tests here
quietly regress opIncNormdPerc c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post
* outreg2 using reg1_indir.xls, append ctitle("op inc heat - worst") label

quietly regress opIncNormdPerc c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessheat90plus) post
* outreg2 using reg1_indir.xls, append ctitle("op inc heat - largest") label

quietly regress opIncNormdPerc c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plusemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc heat - wtd") label


**************
quietly regress opIncNormdPerc c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - worst") label

quietly regress opIncNormdPerc c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - largest") label

quietly regress opIncNormdPerc c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - wtd") label





********************************************************************************
* check 1 - what if we filter on distance?
* do a bunch of tests here
quietly regress opIncNormdPerc c.worstsupplier500k_excessheat90pl i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier500k_excessheat90pl) post
* outreg2 using reg1_indir.xls, append ctitle("op inc heat - worst") label

quietly regress opIncNormdPerc c.largestsupplier500k_excessheat90 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier500k_excessheat90) post
* outreg2 using reg1_indir.xls, append ctitle("op inc heat - largest") label

quietly regress opIncNormdPerc c.wtdsupplier500k_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier500k_excessheat90plus) post
* outreg2 using reg1_indir.xls, append ctitle("op inc heat - wtd") label


**************
quietly regress opIncNormdPerc c.worstsupplier500k_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier500k_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - worst") label

quietly regress opIncNormdPerc c.largestsupplier500k_excessrainem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier500k_excessrainem) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - largest") label

quietly regress opIncNormdPerc c.wtdsupplier500k_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier500k_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - wtd") label
