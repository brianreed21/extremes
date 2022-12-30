cd ../supplyChain/data/companyData/hqsOnly/
clear all


set maxvar 100000
import delimited goodsData_dirEffects.csv 
* import delimited goodsData_allSupplierData_dirEffects
* import delimited goodsData_allCustomerData_indirEffects 

* _withIndDefs
keep if year != .
destring gvkey, replace
destring qtr, replace
describe gvkey



encode yearqtr, generate(time)
encode indgroup, generate(industry)
* encode indseason, generate(indSeason)

keep if ((indgroup!="services") & (indgroup!="finance"))

* encode gsectordesc, generate(industrygics)


* different weather variables
* supplier_extremeheat supplier_heat90plus supplier_extremeprecip
* extremeprecip heat90plus extremeheat
* supplier_extremeheat supplier_heat90plus supplier_extremeprecip


tempfile results
local replace replace
foreach weather of varlist days90_orextreme days90_ifextreme  {
	display as text %12s "`weather' ***********************************"
	* revnormd  costnormd opincnormd lnrevnormd_take2 lncostnormd_take2 lnopincnormd_take2
	foreach outcome of varlist opincnormd revnormd  costnormd  {
		display as text %12s "`outcome'"

		quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx("`weather'") post
		regsave using "`results'", pval autoid `replace' addlabel(outcome,"`outcome'", weather, "`weather'", hqs_v_estabs, "hqs, no conc reqt", otherNotes, "allCos - nonfin, nonserv") 

		local replace append
		
	}
}
	
* Format and outsheet results for use in PivotTable
use "`results'", clear
* replace var = subinstr(var,"foreign:","",.)
outsheet using results_allCos_newVars.csv, replace
	
********************************************************************************
* this website has the regsave info: # https://julianreif.com/regsave/


*************
* reg 2 - by background climate
quietly regress opincnormd c.excessheat90plus##i.temptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plus) over(temptercilewtd) post
outreg2 using reg2_hqs.xls, append ctitle("excessheat90plus - controls") label


* next rain
quietly regress opincnormd c.excessrain##i.preciptercile i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrain) over(preciptercile) post
outreg2 using reg2_hqs.xls, append ctitle("excessrain - controls") label


*************
* reg 3 - by qtr
quietly regress opincnormd c.excessheat90plus##i.qtr i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessheat90plus) over(qtr) post
outreg2 using reg3_hqs.xls, append ctitle("excessheat90plus - controls") label


*************
* reg 5 - by industry
* next rain
tempfile results
local replace replace
foreach weather of varlist extremeprecip heat90plus extremeheat {
	display as text %12s "`weather' ***********************************"
	* revnormd  costnormd opincnormd lnrevnormd_take2 lncostnormd_take2 lnopincnormd_take2
	foreach outcome of varlist revnormd costnormd opincnormd {
		display as text %12s "`outcome'"
		
		quietly regress `outcome' c.`weather'##i.industry i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
		margins, dydx(`weather') over(industry) post
		
		regsave using "`results'", pval autoid `replace' addlabel(outcome,"`outcome'", weather, "`weather'", hqs_v_estabs, "hqs by ind", otherNotes, "allCos - nonfin, nonserv") 
		
		* outreg2 using reg5_hqs.xls, append ctitle("`outcome' - `weather'") label
		local replace append

	}
}


* Format and outsheet results for use in PivotTable
use "`results'", clear
* replace var = subinstr(var,"foreign:","",.)
outsheet using results_byInd.csv, replace
