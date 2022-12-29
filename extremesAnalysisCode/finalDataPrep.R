library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)


########################################################################################################################
# load the data first
setwd("~/Documents/supplyChain")

# load: changes data, largest supplier data, and all supplier data
igData           <- read.csv("data/companyData/igWithWeather.csv") #  %>% select(-X, -opInc_befDep) # before depreciation, things seem a bit more scarce

allSuppliers     <- read.csv("data/companyData/allIndirectWeather.csv")  %>% select(-X)  


dirIndir         <- read.csv("data/companyData/allDirIndir.csv") %>% select(-X)
estabAvgs         = read.csv("data/companyData/estabWtdWeather.csv") %>% select(-X)
dirIndir <- merge(estabAvgs,dirIndir)

########################################################################################################################
# clean the data, first pass 
data <- dirIndir # igData 
dim(data)


data = data[complete.cases(data$assetsLast) & complete.cases(data$profitTercile) & complete.cases(data$ageTercile) & complete.cases(data$sizeTercile),] %>% 
  # filter(indGroup %in% c('agForFish','construction','manu','mining','transportUtilities','wholesale','retail')) %>%
  mutate(totalRevenue = case_when(totalRevenue < 0 ~ 0, totalRevenue > 0 ~ totalRevenue),
         costGoodsSold = case_when(costGoodsSold < 0 ~ 0, costGoodsSold > 0 ~ costGoodsSold),
         sales = case_when(sales < 0 ~ 0, sales > 0 ~ sales),
         otherCosts = case_when(otherCosts < 0 ~ 0, otherCosts > 0 ~ costGoodsSold)
         ) %>% mutate(totalCosts = costGoodsSold + otherCosts)


########################################################################################################################
# run this to get data across all firms
goodsData = data  %>%  mutate(
         ageTercile    = ntile(earliestYear,3),
         profitTercile = ntile(roa_lagged,3),
         sizeTercile   = ntile(assetsLagged,3),
         
         ###########################################################
         # do this the old fashioned way: winsorize, etc
         salesByShare    = sales/shares,
         costByShare     = costGoodsSold/shares,
         
         
         salesNormd       = (sales + 0.001)/(assetsLast + 0.001),
         # revNormd         = (totalRevenue + 0.001)/(assetsLast + 0.001),
         costNormd        = (costGoodsSold + 0.001)/(assetsLast + 0.001),
         # otherCostNormd   = (otherCosts + 0.001)/(assetsLast + 0.001),
         # totalCostNormd   = (totalCosts + 0.001)/(assetsLast + 0.001),
         netIncNormd      = (netIncome + 0.001)/(assetsLast + 0.001),
         opIncNormd       = (opInc_afDep + 0.001)/(assetsLast + 0.001),
         
         lnSales = log(sales + 0.001),
         # lnRev  = log(totalRevenue + 0.001),
         lnCost = log(costGoodsSold + 0.001),
         # lnOtherCost = log(otherCosts + 0.001),
         # lnTotalCost = log(totalCosts + 0.001),
         
         lnCostNormd          = log(costNormd),
         # lnOtherCostNormd     = log(otherCostNormd),
         # lnTotalCostNormd     = log(totalCostNormd),
         lnSalesNormd         = log(salesNormd),
         # lnRevNormd           = log(revNormd),
         lnStockClose         = log(priceClose + 1),
         
         # lnNetIncNormd        = case_when((netIncNormd <= 0) ~ -1,
         #                                 (netIncNormd  > 0) ~ log(netIncome/assetsLast + 1)),
         # lnOpIncNormd         = case_when((opIncNormd <= 0) ~ -1,
         #                                 ((opIncNormd + 0.001)/(assetsLast + 0.001) > 0) ~ log(opInc_afDep/assetsLast + 1)),
         earningsPerShare  = Winsorize(earningsPerShare, probs = c(0.01, 0.99),  na.rm = TRUE),
         salesByShare      = Winsorize(salesByShare, probs = c(0.01, 0.99),  na.rm = TRUE),
         costByShare       = Winsorize(costByShare, probs = c(0.01, 0.99),  na.rm = TRUE),
  
         salesNormd        = Winsorize(salesNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         # revNormd          = Winsorize(revNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         costNormd         = Winsorize(costNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         # otherCostNormd    = Winsorize(otherCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         # totalCostNormd    = Winsorize(totalCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         # netIncNormd       = Winsorize(netIncNormd, probs = c(0.01, 0.99),na.rm = TRUE),
         # opIncNormd        = Winsorize(opIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
  
  
         lnCostNormd         = Winsorize(lnCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         # lnOtherCostNormd    = Winsorize(lnCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         # lnTotalCostNormd    = Winsorize(lnCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         lnSalesNormd        = Winsorize(lnSalesNormd, probs  = c(0.01, 0.99),   na.rm = TRUE),
         # lnRevNormd          = Winsorize(lnRevNormd, probs    = c(0.01, 0.99),   na.rm = TRUE),
         # lnNetIncNormd       = Winsorize(lnNetIncNormd, probs = c(0.01, 0.99),na.rm = TRUE),
         # lnOpIncNormd        = Winsorize(lnOpIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         lnStockClose        = Winsorize(lnStockClose, probs = c(0.01, 0.99), na.rm = TRUE),
        
        
        
         ##############################################################
         # now do this the other way 
         revNormd_take2     = (totalRevenue/assetsLast) ,
         costNormd_take2    = (costGoodsSold/assetsLast) ,
         netIncNormd_take2  = (netIncome/assetsLast) ,
         opIncNormdAf_take2 = (opInc_afDep/assetsLast) ,
         opIncNormdBef_take2 = (opInc_befDep/assetsLast) ,
         
         salesNormd_take2       = (sales)/(assetsLast),
         revNormd_take2         = (totalRevenue)/(assetsLast),
         costNormd_take2        = (costGoodsSold)/(assetsLast),
         otherCostNormd_take2   = (otherCosts)/(assetsLast),
         totalCostNormd_take2   = (totalCosts)/(assetsLast),
         netIncNormd_take2      = (netIncome)/(assetsLast),
         opIncNormd_take2       = (opInc_afDep)/(assetsLast),
         
         lnSalesNormd_take2      = log(Winsorize(salesNormd_take2 + 1, probs     = c(0.01, 0.99),  na.rm = TRUE)),
         lnOtherCostNormd_take2  = log(Winsorize(otherCostNormd_take2 + 1, probs     = c(0.01, 0.99),  na.rm = TRUE)),
         lnTotalCostNormd_take2  = log(Winsorize(totalCostNormd_take2 + 1, probs     = c(0.01, 0.99),  na.rm = TRUE)),
         lnCostNormd_take2       = log(Winsorize(costNormd_take2 + 1, probs     = c(0.01, 0.99),  na.rm = TRUE)),
         lnRevNormd_take2        = log(Winsorize(revNormd_take2 + 1, probs      = c(0.01, 0.99),   na.rm = TRUE)),
         lnNetIncNormd_take2     = log(Winsorize(netIncNormd_take2 + 1, probs   = c(0.025, 0.99),na.rm = TRUE)),
         lnOpIncNormdAf_take2    = log(Winsorize(opIncNormdAf_take2 + 1, probs  = c(0.025, 0.99), na.rm = TRUE)),
         lnOpIncNormdBef_take2   = log(Winsorize(opIncNormdBef_take2 + 1, probs = c(0.025, 0.99), na.rm = TRUE)),
         
         
         yearQtr = paste0(year,"_",qtr), firmQtr = paste0(gvkey,'_',qtr), 
         ageQtr  = paste0(ageTercile,"_",yearQtr),
         sizeQtr  = paste0(sizeTercile,"_",yearQtr), 
         profitQtr  = paste0(profitTercile,"_",yearQtr), 
         indQtr  = paste0(indGroup,yearQtr)
         ) %>%
  
  # for direct effects
    mutate(extremeHeatQuarterly  = temp_zipQuarter95   + lag1_temp_zipQuarter95,
      extremePrecipQuarterly     = precip_zipQuarter95      + lag1_precip_zipQuarter95,
      
      extremeHeatQuarterly_max   = empMx_temp_zipQuarter_95   + empMx_lag1_temp_zipQuarter_95,
      extremePrecipQuarterly_max = empMx_precip_zipQuarter_95 + empMx_lag1_precip_zipQuarter_95,
      
      extremeHeatQuarterly_wtd   = empWt_temp_zipQuarter_95   + empWt_lag1_temp_zipQuarter_95,
      extremePrecipQuarterly_wtd = empWt_precip_zipQuarter_95      + empWt_lag1_precip_zipQuarter_95,
      
      heatAnomalyQuarterly   = temp_zipQuarter50     + lag1_temp_zipQuarter50,
      precipAnomalyQuarterly = precip_zipQuarter50   + lag1_precip_zipQuarter50,
      
      extremeHeatDaily   = temp_zipQuarter_95   + lag1_temp_zipQuarter_95,
      extremePrecipDaily = precip_zipQuarter_95 + lag1_precip_zipQuarter_95,
      
      heatAnomalyDaily   = temp_zipQuarter_50     + lag1_temp_zipQuarter_50,
      precipAnomalyDaily = precip_zipQuarter_50   + lag1_precip_zipQuarter_50,
      
      heatDays90Plus    = days90Plus + lag1_days90Plus,
      streak90Plus  = streak90Plus   + lag1_streak90Plus,
      
      heatDays90Plus_wtd    = empWt_days90Plus     + empWt_lag1_days90Plus,
      heatDays90Plus_max    = empMx_days90Plus     + empMx_lag1_days90Plus,
      
      precip95National     = precip_annual_95 + lag1_precip_annual_95,
      precip95National_wtd = empWt_precip_annual_95 + empWt_lag1_precip_annual_95,
      precip95National_max = empMx_precip_annual_95 + empMx_lag1_precip_annual_95,

      precip99National = precip_annual_99 + lag1_precip_annual_99,
      heat99National   = temp_annual_99   + lag1_temp_annual_99,
      
      extremeHeatDays_wtd =  empWt_temp_zipQuarter_95    + empWt_lag1_temp_zipQuarter_95,
      extremePrecipDays_wtd = empWt_precip_zipQuarter_95 + empWt_lag1_precip_zipQuarter_95,
      
      extremeHeatDays_max =  empMx_temp_zipQuarter_95    + empMx_lag1_temp_zipQuarter_95,
      extremePrecipDays_max = empMx_precip_zipQuarter_95 + empMx_lag1_precip_zipQuarter_95,
      
      tempTercile   = ntile(quarterly_avg_temp,3), 
      precipTercile = ntile(quarterly_avg_precip,3),
      
      tempHalfWtd   = ntile(weightedTempQtr,2),
      precipHalfWtd = ntile(weightedPrecipQtr,2),
      
      tempTercileWtd   = ntile(weightedTempQtr,3),
      precipTercileWtd = ntile(weightedPrecipQtr,3),
      
      tempQuintile   = ntile(quarterly_avg_temp,5), 
      precipQuintile = ntile(quarterly_avg_precip,5),
      
      tempDecile   = ntile(quarterly_avg_temp,10), 
      precipDecile = ntile(quarterly_avg_precip,10),
      
      tempHalf   = ntile(quarterly_avg_temp,2), 
      precipHalf = ntile(quarterly_avg_precip,2), 
  
      excessHeat = extremeHeatDaily - 9,
      excessRain = extremePrecipDaily - 9,
      
      excessHeatEmp = extremeHeatDays_wtd - 9,
      excessRainEmp = extremePrecipDays_wtd - 9,
      
      excessHeatMax = extremeHeatDays_max - 9,
      excessRainMax = extremePrecipDays_max - 9,
      
      excessHeat90Plus = heatDays90Plus - 9,
      excessRainNational = precip95National - 9,
      
      excessHeat90PlusEmp   = heatDays90Plus_wtd - 9,
      excessRainNationalEmp = precip95National_wtd - 9,
      
      
      indSeason = paste0(indGroup,qtr)) %>%

  
  group_by(qtr) %>%
  
  mutate(tempTercile_byQtr   = ntile(quarterly_avg_temp,3), 
         precipTercile_byQtr = ntile(quarterly_avg_precip,3),
         
         tempQuintile_byQtr   = ntile(quarterly_avg_temp,5), 
         precipQuintile_byQtr = ntile(quarterly_avg_precip,5),
         
         tempDecile_byQtr   = ntile(quarterly_avg_temp,10), 
         precipDecile_byQtr = ntile(quarterly_avg_precip,10)) %>%
  
  
  # next for indirect effects
  mutate(worstSupplier_excessHeat90PlusEmp   = worst_supplier_empWt_days90Plus   + worst_supplier_empWt_lag1_days90Plus - 9,
         largestSupplier_excessHeat90PlusEmp = largest_supplier_empWt_days90Plus + largest_supplier_empWt_lag1_days90Plus - 9,
         wtdSupplier_excessHeat90PlusEmp     = wtd_supplier_empWt_days90Plus     + wtd_supplier_empWt_lag1_days90Plus - 9,
         
         worstSupplier_excessRainEmp   = worst_supplier_empWt_precip_zipQuarter_95   + worst_supplier_empWt_precip_zipQuarter_95 - 9,
         largestSupplier_excessRainEmp = largest_supplier_empWt_precip_zipQuarter_95 + largest_supplier_empWt_precip_zipQuarter_95 - 9,
         wtdSupplier_excessRainEmp     = wtd_supplier_empWt_precip_zipQuarter_95     + wtd_supplier_empWt_precip_zipQuarter_95 - 9,
         
         worstSupplier_excessHeat90Plus   = worst_supplier_days90Plus   + worst_supplier_lag1_days90Plus - 9,
         largestSupplier_excessHeat90Plus = largest_supplier_days90Plus + largest_supplier_lag1_days90Plus - 9,
         wtdSupplier_excessHeat90Plus     = wtd_supplier_days90Plus     + wtd_supplier_lag1_days90Plus - 9,
         
         worstSupplier_excessRain   = worst_supplier_precip_zipQuarter_95   + worst_supplier_precip_zipQuarter_95 - 9,
         largestSupplier_excessRain = largest_supplier_precip_zipQuarter_95 + largest_supplier_precip_zipQuarter_95 - 9,
         wtdSupplier_excessRain     = wtd_supplier_precip_zipQuarter_95     + wtd_supplier_precip_zipQuarter_95 - 9)

goodsData <- goodsData[complete.cases(goodsData$empMx_temp_zipQuarter_95) & 
                        complete.cases(goodsData$earningsPerShare) &
                        complete.cases(goodsData$salesByShare) &
                        complete.cases(goodsData$salesNormd) &
                        complete.cases(goodsData$costGoodsSold) & 
                        complete.cases(goodsData$costByShare) &
                         complete.cases(goodsData$costNormd) &
                        complete.cases(goodsData$opInc_afDep) &
                        complete.cases(goodsData$gvkey) & 
                        (goodsData$indGroup != ""), ]

freqWeights = goodsData %>%
  count(indGroup, sizeTercile) %>%
  mutate(freq = round(n / sum(n), 4)) %>% select(-n) %>% merge(
    (goodsData %>% filter(isSupplier == "True") %>%
       count(indGroup, sizeTercile) %>%
       mutate(freq = round(n / sum(n), 4)) %>% 
       select(-n) %>% rename(freqSuppliers = freq))) %>% 
  mutate(pweights = freq/freqSuppliers) %>% select(-c(freq,freqSuppliers))

dim(goodsData)

# goodsData = goodsData %>% merge(freqWeights, how = 'left')     

dim(goodsData)


write.csv(goodsData,"data/companyData/goodsData.csv")

write.csv(goodsData[goodsData$isSupplier == 'True',],"data/companyData/supplierGoodsData.csv")

