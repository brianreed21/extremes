cd ../supplyChain/data/companyData/
clear all


set maxvar 100000
import delimited goodsData 
* _withIndDefs
keep if year != .
destring gvkey, replace
destring qtr, replace
describe gvkey



encode yearqtr, generate(time)
encode indgroup, generate(industry)
encode indseason, generate(indSeason)

keep if ((indgroup!="services") & (indgroup!="finance"))

* encode gsectordesc, generate(industrygics)

********************************************************************************
* this website has the regsave info: # https://julianreif.com/regsave/


* tempfile results
* costnormd_take2 opincnormd revnormd costnormd lnstockclose lnopincnormd lnrevnormd lncostnormd lnopincnormdaf_take2 lnrevnormd_take2 lncostnormd_take2
* opincnormdaf_take2 opincnormdbef_take2 revnormd_take2 costnormd_take2 lnstockclose lnrevnormd lncostnormd lnopincnormdaf_take2 lnopincnormdbef_take2 lnrevnormd_take2 lncostnormd_take2
* salesnormd revnormd costnormd othercostnormd totalcostnormd lnsalesnormd_take2 lnothercostnormd_take2 lntotalcostnormd_take2 lncostnormd_take2 lnrevnormd_take2 lnnetincnormd_take2

* local replace replace
foreach weather of varlist excessrainemp excessheat90plusemp{
	foreach outcome of varlist salesbyshare salesnormd costbyshare costnormd lnsalesnormd_take2 lncostnormd_take2  lnsalesnormd lncostnormd   {
	display as text %12s "`outcome'"
	
	/* all cos
	quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
	margins, dydx("`weather'") post
	regsave using "`results'", pval autoid `replace' addlabel(outcome,"`outcome'", weather, "`weather'", subsample, "all") 
	local replace append*/

	/* nonfin cos
	quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if indgroup!="finance", cluster(gvkey)
	margins, dydx("`weather'") post
	regsave using "`results'", pval autoid `replace' addlabel(outcome,"`outcome'", weather, "`weather'", subsample, "nonfin")*/ 
	
	* nonfin, nonserv cos
	quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey, cluster(gvkey)
	margins, dydx("`weather'") post
	* regsave using "`results'", pval autoid `replace' addlabel(outcome,"`outcome'", weather, "`weather'", subsample, "nonfin nonserv") 
	
	/*quietly regress `outcome' c.`weather'##i.industrygics i.industrygics#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile if ((indgroup!="services") & (indgroup!="finance")), cluster(gvkey)
	margins, dydx("`weather'") over(industrygics) post
	regsave using "`results'", pval autoid `replace' addlabel(outcome,"`outcome'", weather, "`weather'", subsample, "nonfin nonserv by ind") */
	
	}
}

* Format and outsheet results for use in PivotTable
use "`results'", clear
* replace var = subinstr(var,"foreign:","",.)
outsheet using results.csv, replace
