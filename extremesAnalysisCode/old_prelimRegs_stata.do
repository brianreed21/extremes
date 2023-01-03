cd ../supplyChain/data/companyData/


clear all
set maxvar 100000
import delimited goodsData_withIndDefs
* import delimited goodsData



encode yearqtr, generate(time)
encode indgroup, generate(industry)
encode indseason, generate(indSeason)



*************
* do a bunch of tests here
quietly regress lnopincnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post

quietly regress lnopincnormdaf_take2 c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post

quietly regress lnopincnormdbef_take2 c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post


quietly regress lnopincnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) post

quietly regress lnopincnormdaf_take2 c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) post


quietly regress lnopincnormdbef_take2 c.excessrain i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrain) post

quietly regress lnopincnormdbef_take2 c.excessheat90plus i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plus) post




*************
* reg 1 - main results
* do the hqs
log using table1.log, replace

* first heat - w/o and w/ controls
quietly regress lnopincnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg1.xls, append ctitle("excessheat90plusemp - no controls") label

quietly regress lnopincnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg1.xls, append ctitle("excessheat90plusemp - controls") label


* next rain - w/o and w/ controls
quietly regress lnopincnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using reg1.xls, append ctitle("excessrainemp - no controls") label

quietly regress lnopincnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using reg1.xls, append ctitle("excessrainemp - controls") label



*************
* reg 2 - by background climate
quietly regress lnopincnormd c.excessheat90plusemp##i.temptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(temptercile) post
outreg2 using reg2.xls, append ctitle("excessheat90plusemp - controls") label


* next rain
quietly regress lnopincnormd c.excessrainemp##i.preciptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercile) post
outreg2 using reg2.xls, append ctitle("excessrainemp - controls") label


*************
* reg 3 - by qtr
quietly regress lnopincnormd c.excessheat90plusemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("excessheat90plusemp - controls") label


* next rain
quietly regress lnopincnormd c.excessrainemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("excessrainemp - controls") label



*************
* reg 4 - abs v rel, by qtr by tercile
quietly regress lnopincnormd c.excessheatemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheatemp) post
outreg2 using reg3.xls, append ctitle("relative heat") label


quietly regress lnopincnormd c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
outreg2 using reg3.xls, append ctitle("absolute heat") label



quietly regress lnopincnormd c.excessheatemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheatemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("relative heat - qtr") label


quietly regress lnopincnormd c.excessheat90plusemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("absolute heat - qtr") label



quietly regress lnopincnormd c.excessheatemp##i.qtr##i.temptercile_byqtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheatemp) over(temptercile_byqtr qtr) post
outreg2 using reg3.xls, append ctitle("relative heat - qtr tercile") label


quietly regress lnopincnormd c.excessheat90plusemp##i.qtr##i.temptercile_byqtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(temptercile_byqtr qtr) post
outreg2 using reg3.xls, append ctitle("absolute heat - qtr tercile") label





****************************
* next rain - relative v absolute
quietly regress lnopincnormd c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post
outreg2 using reg3.xls, append ctitle("relative rain") label


quietly regress lnopincnormd c.excessrainnationalemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainnationalemp) post
outreg2 using reg3.xls, append ctitle("absolute rain") label


****** by qtr
quietly regress lnopincnormd c.excessrainemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("relative rain - qtr") label


quietly regress lnopincnormd c.excessrainnationalemp##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainnationalemp) over(qtr) post
outreg2 using reg3.xls, append ctitle("absolute rain - qtr") label

***** by tercile
quietly regress lnopincnormd c.excessrainemp##i.preciptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercile) post
outreg2 using reg3.xls, append ctitle("relative rain - qtr") label


quietly regress lnopincnormd c.excessrainnationalemp##i.preciptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainnationalemp) over(preciptercile) post
outreg2 using reg3.xls, append ctitle("absolute rain - tercile") label


***** by qtr - by tercile
quietly regress lnopincnormd c.excessrainemp##i.qtr##i.preciptercile_byqtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(preciptercile_byqtr qtr) post
outreg2 using reg3.xls, append ctitle("relative rain - qtr tercile") label


quietly regress lnopincnormd c.excessrainnationalemp##i.qtr##i.preciptercile_byqtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainnationalemp) over(preciptercile_byqtr qtr) post
outreg2 using reg3.xls, append ctitle("absolute rain - qtr tercile") label




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
quietly regress lnopincnormd c.excessheat90plusemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(industrygics) post
outreg2 using reg3.xls, append ctitle("excessheat90plusemp") label

quietly regress lnopincnormd c.excessrainemp##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(industrygics) post
outreg2 using reg3.xls, append ctitle("excessrainemp") label









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



	
******
* do main heat and rain results, w/ and w/o controls

foreach weather of varlist excessheat excessrain {		
	quietly regress lnopincnormd c.`weather' i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
	margins, dydx(`weather') post
	
	outreg2 using reg1.csv, append ctitle("`weather' - no controls") label
	
	quietly regress lnopincnormd c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`weather') post
	
	outreg2 using reg1.csv, append ctitle("`weather' - controls") label
	
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

*******
* by outcome by quarter
foreach weather of varlist excessheat excessheatemp excessheat90plus excessheat90plusemp extremeheatquarterly extremeheatquarterly_wtd excessrain excessrainemp excessrainnational excessrainnationalemp extremeprecipquarterly extremeprecipquarterly_wtd {
	foreach outcome of varlist lnopincnormd lnrevnormd lncostnormd lnstockclose{		
		quietly regress `outcome' c.`weather'##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx(`weather') over(qtr) post
		
		outreg2 using reg2_`outcome'.xls, append ctitle("`weather'") label
	}
}




*********** now do by tercile and tercile-quarter
drop industry
encode indgroup, generate(industry)

foreach weather of varlist excessheat excessheatemp excessheat90plus extremeheatquarterly {
	
	quietly regress lnopincnormd c.`weather'##i.temptercile i.industry##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`weather') over(temptercile) post
	
	outreg2 using all_byTempTercile.xls, append ctitle("`weather'") label
	
	
	quietly regress lnopincnormd c.`weather'##i.temptercile##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`weather') over(qtr temptercile) post
	
	outreg2 using all_byTempTercileQtr.xls, append ctitle("`weather'") label
		
}


foreach weather of varlist excessrain excessrainemp excessrainnational extremeprecipquarterly {
	
	quietly regress lnopincnormd c.`weather'##i.preciptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`weather') over(preciptercile) post
	
	outreg2 using all_byPrecipTercile.xls, append ctitle("`weather'") label
	
	quietly regress lnopincnormd c.`weather'##i.preciptercile##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`weather') over(qtr preciptercile) post
	
	outreg2 using all_byPrecipTercileQtr.xls, append ctitle("`weather'") label
		
}


*******

* set matsize 800
/* set more off
quietly regress lnopincnormd c.excessrainemp##i.industry i.indSeason i.time i.gvkey, cluster(gvkey)
margins, dydx(excessrainemp) over(industry) */


set more off
*  sic2desc  ggroupdesc and gsectordesc
* do these still: ggroupdesc  indgroup gsectordesc
foreach industryType of varlist  gsubinddesc{
	foreach weather of varlist excessheat excessheatemp excessheat90plus excessheat90plusemp extremeheatquarterly extremeheatquarterly_wtd excessrain excessrainemp excessrainnational excessrainnationalemp extremeprecipquarterly extremeprecipquarterly_wtd {
		drop industry
		encode `industryType', generate(industry)
		
		
		quietly regress lnopincnormd c.`weather'##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx(`weather') over(industry) post
		estimates store `industryType'
		outreg2 using `industryType'.xls, append ctitle("`weather'") label
		
		
		/*quietly regress lnopincnormd c.`weather'##i.industry##i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx(`weather') over(industry qtr) post
		estimates store `industryType'
		outreg2 using `industryType'_quarterly.xls, append ctitle("`weather'") label*/
		
	}
}
log close
label



*********** now just try doing by industry
foreach industryType of varlist indgroup gsectordesc {
	foreach weather of varlist excessheat excessheatemp excessheat90plus extremeheatquarterly excessrain excessrainemp excessrainnational extremeprecipquarterly {
		drop industry
		encode `industryType', generate(industry)
		
		
		quietly regress lnopincnormd c.`weather'##i.qtr  i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx(`weather') over(qtr) post

		
		outreg2 using all_quarterly.xls, append ctitle("`weather' - `industryType'") label
		
	}
}




*************** just do the main results
set more off
*  sic2desc  ggroupdesc and gsectordesc
* do these still: ggroupdesc gsubinddesc
foreach weather of varlist excessheat excessheatemp excessheat90plus extremeheatquarterly excessrain excessrainemp excessrainnational extremeprecipquarterly {
	drop industry
	encode indgroup, generate(industry)
		
	quietly regress lnopincnormd c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`weather') post
	outreg2 using mainSpecs.xls, append ctitle("`weather'") label
	
}



estimates restore excessheatIndustry
margins
outreg2 using testIndustry.xls

