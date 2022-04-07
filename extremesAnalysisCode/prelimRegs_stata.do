cd "~/Documents/supplyChain/data/companyData"

import delimited goodsData

encode yearqtr, generate(time)
encode roatier, generate(roaTier)
encode profittier, generate(profitTier)
tostring gvkey, generate(company)
encode company, generate(companyCode)
set matsize 800


regress revenuechange precip_monthlyquant_10 temp_monthlyquant_10 i.time ///
	i.wettier i.hottier ///
	i.agetier i.profitTier i.roaTier ///
	i.variedwet i.variedhot, cluster(gvkey)
	
	
regress revenuechange precip_annualquant_10 temp_annualquant_10 i.time ///
	i.wettier i.hottier ///
	i.agetier i.profitTier i.roaTier ///
	i.variedwet i.variedhot, cluster(gvkey)


regress revenuechange precip_zipquant_10 temp_zipquant_10 i.time ///
	i.wettier i.hottier ///
	i.agetier i.profitTier i.roaTier ///
	i.variedwet i.variedhot, cluster(gvkey)
