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


*********************
* ch 3 - other weather specs
local mainSpec       excessheat90plusemp excessrainemp
local otherDailyHeat heatanomalydaily_wtd excessheatemp
local otherDailyRain precipanomalydaily_wtd precipanomaly_natl_wtd precip95national_wtd
local quarterly      heatanomalyquarterly_wtd extremeheatquarterly_wtd precipanomalyquarterly_wtd extremeprecipquarterly_wtd

local allWeather `mainSpec' `otherDailyHeat' `otherDailyRain' `quarterly'

foreach var of local allWeather {
	quietly regress opIncNormdPerc c.`var' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`var') post
	outreg2 using ch3_weatherTypes.xls, append ctitle("`var'") label
}


*************
* by background climate
local heat       excessheat90plusemp heatanomalydaily_wtd excessheatemp heatanomalyquarterly_wtd extremeheatquarterly_wtd
local rain       excessrainemp precipanomalydaily_wtd precipanomaly_natl_wtd precip95national_wtd precipanomalyquarterly_wtd extremeprecipquarterly_wtd

foreach var of local heat {
	quietly regress opIncNormdPerc c.`var'##i.temptercilewtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`var') over(temptercilewtd) post
	outreg2 using ch3_byCli.xls, append ctitle("`var'") label
}

foreach var of local rain {
	quietly regress opIncNormdPerc c.`var'##i.preciptercilewtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`var') over(preciptercilewtd) post
	outreg2 using ch3_byCli.xls, append ctitle("`var'") label
}


*************
* by qtr
local mainSpec       excessheat90plusemp excessrainemp
local otherDailyHeat heatanomalydaily_wtd excessheatemp
local otherDailyRain precipanomalydaily_wtd precipanomaly_natl_wtd precip95national_wtd
local quarterly      heatanomalyquarterly_wtd extremeheatquarterly_wtd precipanomalyquarterly_wtd extremeprecipquarterly_wtd

local allWeather `mainSpec' `otherDailyHeat' `otherDailyRain' `quarterly'

foreach var of local allWeather {
	quietly regress opIncNormdPerc c.`var'##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`var') over(qtr) post
	outreg2 using ch3_qtr.xls, append ctitle("`var'") label

	
}


*************
* by industry

****
* use the gics for now. can come back to this maybe later as well but for now - 
* just follow the ortiz-bobea ish about how it best explains financial outcomes, etc

local mainSpec       excessheat90plusemp excessrainemp
local otherDailyHeat heatanomalydaily_wtd excessheatemp
local otherDailyRain precipanomalydaily_wtd precipanomaly_natl_wtd precip95national_wtd
local quarterly      heatanomalyquarterly_wtd extremeheatquarterly_wtd precipanomalyquarterly_wtd extremeprecipquarterly_wtd

local allWeather `mainSpec' `otherDailyHeat' `otherDailyRain' `quarterly'

foreach var of local allWeather {
	quietly regress opIncNormdPerc c.`var'##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`var') over(industrygics) post
	outreg2 using ch3_ind.xls, append ctitle("`var'") label

	
}

*************
* by industry - qtr

****
* use the gics for now. can come back to this maybe later as well but for now - 
* just follow the ortiz-bobea ish about how it best explains financial outcomes, etc

local mainSpec       excessheat90plusemp excessrainemp
local otherDailyHeat heatanomalydaily_wtd excessheatemp
local otherDailyRain precipanomalydaily_wtd precipanomaly_natl_wtd precip95national_wtd
local quarterly      heatanomalyquarterly_wtd extremeheatquarterly_wtd precipanomalyquarterly_wtd extremeprecipquarterly_wtd

local allWeather `mainSpec' `otherDailyHeat' `otherDailyRain' `quarterly'

foreach var of local allWeather {
	quietly regress opIncNormdPerc c.`var'##i.industrygics##i.qtr i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`var') over(industrygics qtr) post
	outreg2 using ch3_indQtr.xls, append ctitle("`var'") label

	
}

*************
* by industry - alt outcomes

****
* use the gics for now. can come back to this maybe later as well but for now - 
* just follow the ortiz-bobea ish about how it best explains financial outcomes, etc

foreach outcome of varlist revPerc costPerc {
	quietly regress `outcome' c.excessheat90plusemp##i.industrygics i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessheat90plusemp) over(industrygics) post
	outreg2 using ch3_outcomesByInd.xls, append ctitle("`outcome' - 90+ estabs") label

	quietly regress `outcome' c.excessrainemp##i.industrygics i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessrainemp) over(industrygics) post
	outreg2 using ch3_outcomesByInd.xls, append ctitle("`outcome' - rain estabs") label
}

foreach outcome of varlist revnormd costnormd {
	quietly regress `outcome' c.excessheat90plus##i.industrygics i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessheat90plus) over(industrygics) post
	outreg2 using ch3_outcomesByInd.xls, append ctitle("`outcome' - 90+ hqs") label

	quietly regress `outcome' c.excessrain##i.industrygics i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessrain) over(industrygics) post
	outreg2 using ch3_outcomesByInd.xls, append ctitle("`outcome' - rain hqs") label
}



***************
* by industry - 


****
* go one layer deeper
quietly regress opIncNormdPerc c.excessheat90plusemp##i.industrygics_level2Detail i.industrygics_level2Detail#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(industrygics_level2Detail) post
outreg2 using ch3_ind2.xls, append ctitle("90+ gics level 2") label

quietly regress opIncNormdPerc c.excessrainemp##i.industrygics_level2Detail i.industrygics_level2Detail#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(industrygics_level2Detail) post
outreg2 using ch3_ind2.xls, append ctitle("rain gics level 2") label


****
* and one layer deeper
quietly regress opIncNormdPerc c.excessheat90plusemp##i.industrygics_level3Detail i.industrygics_level3Detail#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(industrygics_level3Detail) post
outreg2 using ch3_ind3.xls, append ctitle("90+ gics level 3") label

quietly regress opIncNormdPerc c.excessrainemp##i.industrygics_level3Detail i.industrygics_level3Detail#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(industrygics_level3Detail) post
outreg2 using ch3_ind3.xls, append ctitle("rain gics level 3") label

/*quietly regress opIncNormdPerc c.excessheat90plusemp##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) over(industry) post
* outreg2 using reg5_0102.xls, append ctitle("excessheat90 hq sic2") label

quietly regress opIncNormdPerc c.excessrainemp##i.industrysics2 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) over(industrysics2) post
* outreg2 using reg5_0102.xls, append ctitle("excessrain hq sic2") label */





********************************************************************************
* reg 1a - effects by rev, cost
foreach outcome of varlist revnormd costnormd {
	*lnstockclose lnrevnormd lncostnormd  {

	quietly regress `outcome' c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessheat90plusemp) post
	outreg2 using ch3_otherVars.xls, append ctitle("`outcome' 90+") label

	quietly regress `outcome' c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessrainemp) post
	outreg2 using ch3_otherVars.xls, append ctitle("`outcome' rain") label
	
	
	/*quietly regress `outcome' c.excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessheat90plus) post
	outreg2 using ch3_otherVars.xls, append ctitle("`outcome' - hqs") label

	quietly regress `outcome' c.excessrain i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(excessrain) post
	outreg2 using ch3_otherVars.xls, append ctitle("`outcome', excessrain - hqs") label*/

}





**********************************
* quarterly extremes & averages
* heat: 
* rainfall: 

***************
* above average rain and heat
quietly regress opIncNormdPerc c.heatanomalyquarterly_wtd   i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(heatanomalyquarterly_wtd) post
* outreg2 using reg1_0102.xls, append ctitle("excessheat90plus - controls") label

quietly regress opIncNormdPerc c.precipanomalyquarterly_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(precipanomalyquarterly_wtd) post


***************
* extreme rain and heat
quietly regress opIncNormdPerc c.extremeheatquarterly_wtd   i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(extremeheatquarterly_wtd) post
* outreg2 using reg1_0102.xls, append ctitle("excessheat90plus - controls") label

quietly regress opIncNormdPerc c.extremeprecipquarterly_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(extremeprecipquarterly_wtd) post




**********************************
* def of extremes: rel v absolute
* heat: lose all significance, effect size shrinks
* rainfall: lose significance, effect size similar; maybe just fewer instances,
* more concentrated in certain areas

***************
* heat 
* used in paper
quietly regress opIncNormdPerc c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plusemp) post
* outreg2 using reg1_0102.xls, append ctitle("excessheat90plus - controls") label

* 95th percentile - local
quietly regress opIncNormdPerc c.extremeheatdays_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(extremeheatdays_wtd) post

* 99th percentile - local
quietly regress opIncNormdPerc c.extremeheatdays_wtd99 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(extremeheatdays_wtd99) post


* 95th percentile - national
quietly regress opIncNormdPerc c.heat95national_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(heat95national_wtd) post

* 99th percentile - national
quietly regress opIncNormdPerc c.heat99national_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(heat99national_wtd) post



***************
* do the same for precipitation
* used in paper
quietly regress opIncNormdPerc c.extremeprecipdays_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(extremeprecipdays_wtd) post

* 99th percentile - local
quietly regress opIncNormdPerc c.extremeprecipdays_wtd99 i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(extremeprecipdays_wtd99) post


* 95th percentile - national
quietly regress opIncNormdPerc c.precip95national_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(precip95national_wtd) post

* look at the 99th percentile - national
quietly regress opIncNormdPerc c.precip99national_wtd i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(precip99national_wtd) post






log close 


********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************


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
	
	quietly regress lnopincnormd c.`weather'##i.temptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx(`weather') over(temptercile) post
	
	outreg2 using all_byTempTercile.xls, append ctitle("`weather'") label
			
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

