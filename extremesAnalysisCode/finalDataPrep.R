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
  mutate(totalRevenue = case_when(totalRevenue < 0 ~ 0, totalRevenue > 0 ~ totalRevenue)) 
dim(data)


########################################################################################################################
# run this to get data across all firms
goodsData = data  %>%  mutate(ageTercile    = ntile(earliestYear,3),
         profitTercile = ntile(roa_lagged,3),
         sizeTercile   = ntile(assetsLagged,3),
         
  # this worked very well when it was netIncome/(assetsLast + 0.001), or same for
  # vars other than netIncome
         revNormd    = (totalRevenue + 0.001)/(assetsLast + 0.001),
         costNormd   = (costGoodsSold + 0.001)/(assetsLast + 0.001),
         netIncNormd = (netIncome + 0.001)/(assetsLast + 0.001),
         opIncNormd  = (opInc_afDep + 0.001)/(assetsLast + 0.001),
  
  
  
         lnCostNormd          = log(costNormd),
         lnRevNormd           = log(revNormd),
         lnStockClose         = log(priceClose + 1),
         
         lnNetIncNormd        = case_when((netIncNormd <= 0) ~ -1,
                                         (netIncNormd  > 0) ~ log(netIncome/assetsLast + 1)),
         lnOpIncNormd         = case_when((opIncNormd <= 0) ~ -1,
                                         ((opIncNormd + 0.001)/(assetsLast + 0.001) > 0) ~ log(opInc_afDep/assetsLast + 1)),
         
  
         costNormd         = Winsorize(costNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         revNormd          = Winsorize(revNormd, probs = c(0.01, 0.99),   na.rm = TRUE),
         netIncNormd       = Winsorize(netIncNormd, probs = c(0.01, 0.99),na.rm = TRUE),
         opIncNormd        = Winsorize(opIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
  
  
         lnCostNormd         = Winsorize(lnCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         lnRevNormd          = Winsorize(lnRevNormd, probs = c(0.01, 0.99),   na.rm = TRUE),
         lnNetIncNormd       = Winsorize(lnNetIncNormd, probs = c(0.01, 0.99),na.rm = TRUE),
         lnOpIncNormd        = Winsorize(lnOpIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         lnStockClose        = Winsorize(lnStockClose, probs = c(0.01, 0.99), na.rm = TRUE),
         
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
                         complete.cases(goodsData$lnOpIncNormd) &
                         complete.cases(goodsData$lnRevNormd) &
                         complete.cases(goodsData$lnCostNormd),]

write.csv(goodsData,"data/companyData/goodsData.csv")
