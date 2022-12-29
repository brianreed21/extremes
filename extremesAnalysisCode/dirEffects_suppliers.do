cd ../supplyChain/data/companyData/
clear all


set maxvar 100000
import delimited goodsData_withIndDefs
keep if year != .

keep if issupplier == "True"

destring gvkey, replace
destring qtr, replace



encode yearqtr, generate(time)
encode indgroup, generate(industry)
encode indseason, generate(indSeason)
encode gsectordesc, generate(industrygics)


*************
foreach weather of varlist excessrain excessrainemp excessheat90plus excessheat90plusemp{
	foreach outcome of varlist revnormd costnormd lnstockclose lnrevnormd lncostnormd lnrevnormd_take2 lncostnormd_take2  {
		display as text %12s "`outcome'"
		quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
		margins, dydx(`weather') post
		outreg2 using reg1_diffOutcomes.xls, append ctitle("`weather' `outcome'") label
	}

}
