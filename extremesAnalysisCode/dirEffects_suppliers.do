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
quietly regress lnopincnormdbef_take2 c.excessheat90plusemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey) 
margins, dydx(excessheat90plusemp) post




quietly regress lnopincnormdaf_take2 c.excessrainemp i.industry#i.qtr i.time i.gvkey i.agetercile i.profittercile i.sizetercile, cluster(gvkey)
margins, dydx(excessrainemp) post

quietly regress lnrevnormd_take2 c.excessrainemp i.industry#i.qtr i.time i.gvkey [pweight = pweights], cluster(gvkey)
margins, dydx(excessrainemp) post

quietly regress lncostnormd_take2 c.excessrainemp i.industry#i.qtr i.time i.gvkey [pweight = pweights], cluster(gvkey)
margins, dydx(excessrainemp) post
