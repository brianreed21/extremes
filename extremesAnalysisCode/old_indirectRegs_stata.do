clear all
* cd ../supplyChain/data/companyData/


set maxvar 100000
import delimited customer_goodsData


encode yearqtr, generate(time)
encode indgroup, generate(industry)


*************
* reg 1 - main results
* do the hqs

* first heat - w/o and w/ controls
quietly regress lnopincnormd c.worstsupplier_excessheat90plusem c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plusem) post

quietly regress lnopincnormd c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(largestsupplier_excessheat90plus) post

quietly regress lnopincnormd c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plusemp) post

quietly regress lnrevnormd c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plusem) post

quietly regress lnrevnormd c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(largestsupplier_excessheat90plus) post

quietly regress lnrevnormd c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(wtdsupplier_excessheat90plusemp) post


*************
* reg 1 - main results
* do the hqs

* first heat - w/o and w/ controls
quietly regress lnopincnormd c.worstsupplier_excessrain90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(worstsupplier_excessrain90plusem) post

quietly regress lnopincnormd c.largestsupplier_excessrain90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(largestsupplier_excessrain90plus) post

quietly regress lnopincnormd c.wtdsupplier_excessrain90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(wtdsupplier_excessrain90plusemp) post


quietly regress lnrevnormd c.worstsupplier_excessrain90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(worstsupplier_excessrain90plusem) post

quietly regress lnrevnormd c.largestsupplier_excessrain90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(largestsupplier_excessrain90plus) post

quietly regress lnrevnormd c.wtdsupplier_excessrain90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(wtdsupplier_excessrain90plusemp) post



outreg2 using reg1.xls, append ctitle("excessheat90plusemp - no controls") label
