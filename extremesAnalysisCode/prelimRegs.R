library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)


########################################################################################################################
# load the data first

setwd("~/Documents/supplyChain")

# load: changes data, largest supplier data, and all supplier data
igData           <- read.csv("data/companyData/igWithWeather.csv") #  %>% select(-X, -opInc_befDep) # before depreciation, things seem a bit more scarce
# igData = igData[igData$locationFracOfEmployees > 0.25,]
# hist(igData$locationFracOfEmployees, breaks = 50, xlim = c(0,1.0))
dim(igData)


largestSuppliers <- read.csv("data/companyData/largestSuppliersWithWeather_more500K.csv") %>% select(-X)  
# allSuppliers     <- read.csv("data/companyData/allSuppliersWithWeather.csv")  %>% select(-X)  
# allSupplierData.to_csv("../../data/companyData/allSupplierData.csv")

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
         revNormd = (totalRevenue + 0.001)/(assetsLast + 0.001),
         costNormd = (costGoodsSold + 0.001)/(assetsLast + 0.001),
         lnCostNormd          = log(costNormd),
         lnRevNormd           = log(revNormd),
         lnStockClose         = log(priceClose + 1),
         
         lnNetIncNormd        = case_when(((netIncome + 0.001)/(assetsLast + 0.001) <= 0) ~ -10,
                                         ((netIncome + 0.001)/(assetsLast + 0.001)  > 0) ~ log(netIncome/assetsLast + 1)),
         lnOpIncNormd         = case_when(((opInc_afDep + 0.001)/(assetsLast + 0.001) <= 0) ~ -10,
                                         ((opInc_afDep + 0.001)/(assetsLast + 0.001) > 0) ~ log(opInc_afDep/assetsLast + 1)),
         
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
   mutate(extremeHeat   = temp_zipQuarter95   + lag1_temp_zipQuarter95,
   extremePrecip = precip_zipQuarter95 + lag1_precip_zipQuarter95,
   tempTercile   = ntile(quarterly_avg_temp,2), 
     precipTercile = ntile(quarterly_avg_precip,2))
  # firmConcTercile = ntile(locationFracOfEmployees,2)
  # for indirect effects
  # mutate(supplier_extremeHeat   = supplier_temp_zipQuarterquant_0.95   + supplier_lag1_temp_zipQuarterquant_0.95,
  #        supplier_extremePrecip = supplier_precip_zipQuarterquant_0.95 + supplier_lag1_precip_zipQuarterquant_0.95,
  #        supplierTempTercile   = ntile(supplier_quarterly_avg_temp,3),
  #        supplierPrecipTercile = ntile(supplier_quarterly_avg_precip,3))

  
  
write.csv(goodsData,"data/companyData/goodsData_igData.csv")



for (col in colnames(goodsData)){
  print(col)
}

##################################################################
# run regressions across a few of the industries in particular
# add a couple of these: gvkey_calQtr, ageTercile_Qtr, profTercile_Qtr, sizeTercile_Qtr

# 'firmQtr', 
# goodsData_withDummies = dummy_cols(goodsData, select_columns =  c('precipBin', 'heatBin'), remove_first_dummy = TRUE) # dummy_cols(goodsData, select_columns =  c('gvkey', 'precipBin', 'heatBin', 'indQtr','ageTercile', 'sizeTercile', 'profitTercile'), remove_first_dummy = TRUE)
# write.csv(goodsData,"data/companyData/goodsData_igData.csv")

