cd ../supplyChain/data/companyData/
clear all




**************************************
set maxvar 100000
clear all
import delimited goodsData_withIndDefs

keep if year > 2000 & year < 2020
keep if worstsupplier_excessheat90plusem != .

encode yearqtr, generate(time)
encode indgroup, generate(industry)
* encode indseason, generate(indSeason)

destring qtr, replace

replace opincChange = opinc_befdep/(opinc_befdeplast)
gen opIncNormdPerc = opincnormd*100

**************************************
* do a bunch of tests here
quietly regress opIncNormdPerc c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plus) post
outreg2 using reg1_indir.xls, append ctitle("op inc heat - worst") label

quietly regress opIncNormdPerc c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessheat90plus) post
outreg2 using reg1_indir.xls, append ctitle("op inc heat - largest") label

quietly regress opIncNormdPerc c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plusemp) post
outreg2 using reg1_indir.xls, append ctitle("op inc heat - wtd") label


**************
quietly regress opIncNormdPerc c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrain) post
outreg2 using reg1_indir.xls, append ctitle("op inc rain - worst") label

quietly regress opIncNormdPerc c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessrainemp) post
outreg2 using reg1_indir.xls, append ctitle("op inc rain - largest") label

quietly regress opIncNormdPerc c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(wtdsupplier_excessrainemp) post
outreg2 using reg1_indir.xls, append ctitle("op inc rain - wtd") label




/*quietly regress costnormd c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - worst") label

quietly regress costnormd c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile  [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - largest") label

quietly regress costnormd c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile , cluster(gvkey)
margins, dydx(wtdsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - wtd") label */
