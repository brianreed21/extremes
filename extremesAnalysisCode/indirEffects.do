cd ../supplyChain/data/companyData/
clear all


* net install regsave, from("https://raw.githubusercontent.com/reifjulian/regsave/master") replace


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

gen opincChange = opinc_befdep/(opinc_befdeplast)
gen revChange = totalrevenue/(totalrevenuelast)
gen costChange = costgoodssold/(costgoodssoldlast)

gen opIncNormdPerc = opincnormd*100


quietly regress lncostnormd c.worstsupplier_excessheat90plusem i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights] if ((indgroup!="construction") & (indgroup!="finance")) , cluster(gvkey)
margins, dydx(worstsupplier_excessheat90plusem) post

quietly regress lncostnormd c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post


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




**************************************
* do a bunch of tests here
tempfile results
* costnormd_take2 opincnormd revnormd costnormd lnstockclose lnopincnormd lnrevnormd lncostnormd lnopincnormdaf_take2 lnrevnormd_take2 lncostnormd_take2

local replace replace
foreach weather of varlist worstsupplier_excessheat90plusem worstsupplier_excessrainemp{
	foreach outcome of varlist opincnormdaf_take2 revnormd_take2   {
	display as text %12s "`outcome'"
	quietly regress `outcome' c.`weather' i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
	margins, dydx("`weather'") post
	regsave using "`results'", pval autoid `replace' addlabel(outcome,"`outcome'", weather, "`weather'") 
	local replace append

	* addlabel(rhs,"`rhs'",origin,"`type'") 
	
	/*display as text %12s "`outcome'"
	quietly regress `outcome' c.largestsupplier_excessheat90plus i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
	margins, dydx(largestsupplier_excessheat90plus) post

	display as text %12s "`outcome'"
	quietly regress `outcome' c.wtdsupplier_excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
	margins, dydx(wtdsupplier_excessheat90plusemp) post


	**************
	display as text %12s "`outcome'"
	quietly regress `outcome' c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
	margins, dydx(worstsupplier_excessrain) post

	display as text %12s "`outcome'"
	quietly regress `outcome' c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
	margins, dydx(largestsupplier_excessrainemp) post

	display as text %12s "`outcome'"
	quietly regress `outcome' c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
	margins, dydx(wtdsupplier_excessrainemp) post */
	}
}


* Format and outsheet results for use in PivotTable
use "`results'", clear
* replace var = subinstr(var,"foreign:","",.)
outsheet using results.csv, replace


/*quietly regress costnormd c.worstsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile [pweight = pweights], cluster(gvkey)
margins, dydx(worstsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - worst") label

quietly regress costnormd c.largestsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile  [pweight = pweights], cluster(gvkey)
margins, dydx(largestsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - largest") label

quietly regress costnormd c.wtdsupplier_excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile , cluster(gvkey)
margins, dydx(wtdsupplier_excessrainemp) post
* outreg2 using reg1_indir.xls, append ctitle("op inc rain - wtd") label */
