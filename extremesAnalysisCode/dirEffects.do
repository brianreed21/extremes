cd ../supplyChain/data/companyData/
clear all


set maxvar 100000
import delimited goodsData_withIndDefs
keep if year != .
destring gvkey, replace
destring qtr, replace
describe gvkey
* import delimited customer_goodsData



encode yearqtr, generate(time)
encode indgroup, generate(industry)
encode indseason, generate(indSeason)
encode gsectordesc, generate(industrygics)


*************
* reg 1 - main results
* do the hqs
log using table1.log, replace

* first heat - w/o and w/ controls
quietly regress opincnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg1.xls, append ctitle("excessheat90plus - no controls") label

quietly regress opincnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg1.xls, append ctitle("excessheat90plus - controls") label


* next rain - w/o and w/ controls
quietly regress opincnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrain) post
outreg2 using reg1.xls, append ctitle("excessrain - no controls") label

quietly regress opincnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using reg1.xls, append ctitle("excessrain - controls") label



*************
* reg 1a - by background climate
******
* do main heat and rain results, w/ and w/o controls
foreach weather of varlist excessrain excessrainemp excessheat90plus excessheat90plusemp{
	foreach outcome of varlist revnormd costnormd lnstockclose lnrevnormd lncostnormd lnrevnormd_take2 lncostnormd_take2  {
		quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx(`weather') post
		outreg2 using reg1_diffOutcomes.xls, append ctitle("`weather' `outcome'") label
	}

}



*******
* do by outcome
foreach weather of varlist excessheat excessheatemp excessheat90plus excessheat90plusemp extremeheatquarterly extremeheatquarterly_wtd excessrain excessrainemp excessrainnational excessrainnationalemp extremeprecipquarterly extremeprecipquarterly_wtd {
	foreach outcome of varlist lnopincnormd lnrevnormd lncostnormd lnstockclose{		
		quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx(`weather') post
		
		outreg2 using reg1_`outcome'.xls, append ctitle("`weather'") label
	}
}

*************
* reg 2 - by background climate
quietly regress opincnormd c.excessheat90plusemp##i.temptercilewtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(temptercilewtd) post
outreg2 using reg2.xls, append ctitle("excessheat90plus - controls") label


* next rain
quietly regress opincnormd c.excessrainemp##i.preciptercilewtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercilewtd) post
outreg2 using reg2.xls, append ctitle("excessrain - controls") label


*************
* reg 3 - by qtr
quietly regress opincnormd c.excessheat90plusemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("excessheat90plus hq - controls") label


* next rain
quietly regress opincnormd c.excessrainemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("excessrain hq - controls") label



*************
* reg 4 - abs v rel, by qtr by tercile
/*quietly regress lnopincnormd c.excessheatemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheatemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("relative heat - qtr") label

quietly regress lnopincnormd c.excessheatemp##i.qtr##i.temptercile_byqtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheatemp) over(temptercile_byqtr qtr) post
outreg2 using reg3.xls, append ctitle("relative heat - qtr tercile") label*/


quietly regress opincnormd c.excessheat90plusemp##i.qtr##i.temptercilewtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
outreg2 using reg4.xls, append ctitle("absolute heat hq - qtr tercile") label


**
* next rain - relative v absolute
quietly regress opincnormd c.excessrainemp##i.qtr##i.preciptercilewtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercilewtd qtr) post
outreg2 using reg4.xls, append ctitle("relative rain hq - qtr tercile") label




*************
* reg 5 - by industry
/*quietly regress lnopincnormd c.excessheat90plusemp##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(industry) post
outreg2 using reg3.xls, append ctitle("excessheat90plusemp") label

quietly regress lnopincnormd c.excessrainemp##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(industry) post
outreg2 using reg3.xls, append ctitle("excessrainemp") label*/

****
* use the gics for now. can come back to this maybe later as well but for now - 
* just follow the ortiz-bobea ish about how it best explains financial outcomes, etc


* encode gsectordesc, generate(industrygics)
quietly regress opincnormd c.excessheat90plusemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(industrygics) post
outreg2 using reg5.xls, append ctitle("excessheat90plus hq gics") label

quietly regress opincnormd c.excessrainemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(industrygics) post
outreg2 using reg5.xls, append ctitle("excessrain hq gics") label


quietly regress opincnormd c.excessheat90plusemp##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(industry) post
outreg2 using reg5.xls, append ctitle("excessheat90 hq sic2") label

quietly regress lnopincnormdbef_take2 c.excessrainemp##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(industry) post
outreg2 using reg5.xls, append ctitle("excessrain hq sic2") label



*************
* other results
quietly regress lnopincnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg2.xls, append ctitle("excessheat90plusemp - controls") label

quietly regress lnrevnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg2.xls, append ctitle("excessheat90plusemp - controls") label


quietly regress lncostnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg2.xls, append ctitle("excessheat90plusemp - controls") label




quietly regress lnopincnormd c.excessheat90plusemp##i.temptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(temptercile) post

quietly regress lnrevnormd c.excessheat90plusemp##i.temptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(temptercile) post

quietly regress lncostnormd c.excessheat90plusemp##i.temptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(temptercile) post



quietly regress lnopincnormd c.excessheatemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheatemp) post

quietly regress lnrevnormd c.excessheatemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheatemp) over(temptercile) post

quietly regress lncostnormd c.excessheatemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheatemp) post


quietly regress lnopincnormd c.excessheatemp##i.temptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheatemp) over(temptercile) post

quietly regress lnrevnormd c.excessheatemp##i.temptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheatemp) over(temptercile) post

quietly regress lncostnormd c.excessheatemp##i.temptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheatemp) over(temptercile) post
log close 

********************************************************************************
* now do everything with rain as well	
log using rainMain.log, replace


quietly regress lnopincnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) post

quietly regress lnrevnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) post

quietly regress lncostnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) post

quietly regress lnopincnormd c.excessrainemp##i.preciptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercile) post

quietly regress lnrevnormd c.excessrainemp##i.preciptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercile) post

quietly regress lncostnormd c.excessrainemp##i.preciptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercile) post


quietly regress lnopincnormd c.excessrainnationalemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainnationalemp) post

quietly regress lnrevnormd c.excessrainnationalemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainnationalemp) post

quietly regress lncostnormd c.excessrainnationalemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainnationalemp) post

quietly regress lnopincnormd c.excessrainnationalemp##i.preciptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainnationalemp) over(preciptercile) post

quietly regress lnrevnormd c.excessrainnationalemp##i.preciptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainnationalemp) over(preciptercile) post

quietly regress lncostnormd c.excessrainnationalemp##i.preciptercile i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainnationalemp) over(preciptercile) post


log close

log using rainMain.log, replace


	

