library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)


########################################################################################################################
# load the data first
setwd("~/Documents/supplyChain")

# load: changes data, largest supplier data, and all supplier data
igData           <- read.csv("data/companyData/igWithWeather.csv") #  %>% select(-X, -opInc_befDep) # before depreciation, things seem a bit more scarce

# largestSuppliers <- read.csv("data/companyData/largestSuppliersWithWeather_more500K.csv") %>% select(-X)
# allSuppliers     <- read.csv("data/companyData/allSupplierData.csv")  %>% select(-X)  


########################################################################################################################
# clean the data, first pass 
data <- igData 
dim(data)


data = data[complete.cases(data$assetsLast) & complete.cases(data$profitTercile) & complete.cases(data$ageTercile) & complete.cases(data$sizeTercile),] %>% 
  filter(indGroup %in% c('agForFish','construction','manu','mining','transportUtilities','wholesale','retail')) %>%
  mutate(totalRevenue = case_when(totalRevenue < 0 ~ 0, totalRevenue > 0 ~ totalRevenue),
         costGoodsSold = case_when(costGoodsSold < 0 ~ 0, costGoodsSold > 0 ~ costGoodsSold))
# %>% filter(assets > 0, assetsLast > 0) 
dim(data)

data %>% mutate(log((opInc_afDep)/(assetsLast) + 1))

sum(data$netIncome/data$assetsLast + 1<0, na.rm = TRUE)/dim(data)[1]


########################################################################################################################
# run this to get data across all firms
goodsData = data  %>%  
  mutate(ageTercile    = ntile(earliestYear,3),
         profitTercile = ntile(roa_lagged,3),
         sizeTercile   = ntile(assetsLagged,3),
         
  # this worked very well when it was netIncome/(assetsLast + 0.001), or same for
  # vars other than netIncome
         lnRev  = log(totalRevenue + 1),
         lnCost = log(costGoodsSold + 1),
  
         revNormd      = (totalRevenue)/(assetsLast),
         costNormd     = (costGoodsSold)/(assetsLast),
         netIncNormd   = (netIncome)/(assetsLast),
         opIncAfNormd  = (opInc_afDep)/(assetsLast),
         opIncBefNormd = (opInc_befDep)/(assetsLast),
  
         netIncChange  = (netIncome - netIncomeLast)/(1+netIncomeLast),
         opIncBefChange = (opInc_befDep - opInc_befDepLast)/(1+opInc_befDepLast),
         opIncAfChange  = (opInc_afDep - opInc_afDepLast)/(1+opInc_afDepLast),
         revChange      = (totalRevenue - totalRevenueLast)/(1+totalRevenueLast),
         costChange     = (costGoodsSold - costGoodsSoldLast)/(1+costGoodsSoldLast),
  
         costNormd         = Winsorize(costNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         revNormd          = Winsorize(revNormd, probs = c(0.01, 0.99),   na.rm = TRUE),
         netIncNormd       = Winsorize(netIncNormd, probs = c(0.025, 0.99),na.rm = TRUE),
         opIncAfNormd      = Winsorize(opIncAfNormd, probs = c(0.025, 0.99), na.rm = TRUE),
         opIncBefNormd     = Winsorize(opIncBefNormd, probs = c(0.025, 0.99), na.rm = TRUE)) %>%
  
  mutate(lnCostNormd          = log(costNormd + 1),
         lnRevNormd           = log(revNormd  + 1),
         lnStockClose         = log(priceClose + 1),
         lnNetIncNormd        = log(netIncNormd + 1),
         lnOpIncAfNormd       = log(opIncAfNormd + 1),
         lnOpIncBefNormd      = log(opIncBefNormd + 1),
         
         # lnCostNormd         = Winsorize(lnCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         # lnRevNormd          = Winsorize(lnRevNormd, probs = c(0.01, 0.99),   na.rm = TRUE),
         # lnNetIncNormd       = Winsorize(lnNetIncNormd, probs = c(0.01, 0.99),na.rm = TRUE),
         # lnOpIncNormd        = Winsorize(lnOpIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         # lnStockClose        = Winsorize(lnStockClose, probs = c(0.01, 0.99), na.rm = TRUE),
         
         netIncChange        = Winsorize(netIncChange, probs = c(0.01, 0.99),  na.rm = TRUE),
         opIncBefChange      = Winsorize(opIncBefChange, probs = c(0.01, 0.99),   na.rm = TRUE),
         opIncAfChange       = Winsorize(opIncAfChange, probs = c(0.01, 0.99),na.rm = TRUE),
         revChange           = Winsorize(revChange, probs = c(0.01, 0.99), na.rm = TRUE),
         costChange          = Winsorize(costChange, probs = c(0.01, 0.99), na.rm = TRUE),
  
         yearQtr = paste0(year,"_",qtr), firmQtr = paste0(gvkey,'_',qtr), 
         ageQtr  = paste0(ageTercile,"_",yearQtr),
         sizeQtr  = paste0(sizeTercile,"_",yearQtr), 
         profitQtr  = paste0(profitTercile,"_",yearQtr), 
         indQtr  = paste0(indGroup,yearQtr)
         ) %>%
  
  # for direct effects
    mutate(extremeHeatQuarterly   = temp_zipQuarter95   + lag1_temp_zipQuarter95,
      extremePrecipQuarterly = precip_zipQuarter95      + lag1_precip_zipQuarter95,
      
      extremeHeatQuarterly_max   = empMx_temp_zipQuarter_95   + empMx_lag1_temp_zipQuarter_95,
      extremePrecipQuarterly_max = empMx_precip_zipQuarter_95 + empMx_lag1_precip_zipQuarter_95,
      
      extremeHeatQuarterly_wtd   = empWt_temp_zipQuarter95        + empWt_lag1_temp_zipQuarter95,
      extremePrecipQuarterly_wtd = empWt_precip_zipQuarter95      + empWt_lag1_precip_zipQuarter95,
      
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
      # heat95National   = temp_annual_95   + lag1_temp_annual_95,
      
      precip99National = precip_annual_99 + lag1_precip_annual_99,
      heat99National   = temp_annual_99   + lag1_temp_annual_99,
      
      extremeHeatDays_wtd =  empWt_temp_zipQuarter_95    + empWt_lag1_temp_zipQuarter_95,
      extremePrecipDays_wtd = empWt_precip_zipQuarter_95 + empWt_lag1_precip_zipQuarter_95,
      
      extremeHeatDays_max =  empMx_temp_zipQuarter_95    + empMx_lag1_temp_zipQuarter_95,
      extremePrecipDays_max = empMx_precip_zipQuarter_95 + empMx_lag1_precip_zipQuarter_95,
      
      tempTercile   = ntile(quarterly_avg_temp,3), 
      precipTercile = ntile(quarterly_avg_precip,3),
      
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
         precipDecile_byQtr = ntile(quarterly_avg_precip,10))

goodsData <- goodsData[complete.cases(goodsData$empMx_temp_zipQuarter_95) & 
                         complete.cases(goodsData$lnOpIncBefNormd) &
                         complete.cases(goodsData$lnOpIncAfNormd) & 
                         complete.cases(goodsData$lnNetIncNormd) &
                         complete.cases(goodsData$lnRevNormd) &
                         complete.cases(goodsData$lnCostNormd),]  
                         # 
                         # complete.cases(goodsData$opIncAfChange) & 
                         # complete.cases(goodsData$opIncBefChange) &
                         # complete.cases(goodsData$revChange) &
                         # complete.cases(goodsData$costChange)
                         # complete.cases(goodsData$opIncAfNormd) & 
                         # complete.cases(goodsData$opIncBefNormd)]

write.csv(goodsData,"data/companyData/goodsData.csv") 
sum(goodsData$opIncChange == '')
# revNormd    = (totalRevenue)/(assetsLast),
# costNormd   = (costGoodsSold)/(assetsLast),
# netIncNormd = (netIncome)/(assetsLast),
# opIncNormd  = (opInc_afDep)/(assetsLast),
