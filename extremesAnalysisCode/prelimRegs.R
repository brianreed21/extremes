library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)


########################################################################################################################
# load the data first

setwd("~/Documents/supplyChain")

# load: changes data, largest supplier data, and all supplier data
igData           <- read.csv("data/companyData/hqsOnly/igWithWeather.csv") #  %>% select(-X, -opInc_befDep) # before depreciation, things seem a bit more scarce
# igData = igData[igData$locationFracOfEmployees > 0.25,]
# hist(igData$locationFracOfEmployees, breaks = 50, xlim = c(0,1.0))
dim(igData)





allSuppliers     <- read.csv("data/companyData/hqsOnly/allSupplierData.csv")  %>% select(-X)  
customerData_largestSupplier <- read.csv("data/companyData/hqsOnly/largestSuppliersWithWeather_more500K.csv") %>% select(-X)

fractions = read.csv('data/companyData/fractionEmployees_byEstablishment.csv') %>% rename(year = archive_version_year,
                                                                                          gvkey = parent_number) %>% select(-c(latitude, longitude))



########################################################################################################################
# clean the data, first pass 
data <- igData 

data = merge(data,fractions, how = 'left')

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
         revNormd   = (totalRevenue + 0.001)/(assetsLast + 0.001),
         costNormd  = (costGoodsSold + 0.001)/(assetsLast + 0.001),
         opIncNormd = (opInc_afDep + 0.001)/(assetsLast + 0.001),
         lnCostNormd          = log(costNormd),
         lnRevNormd           = log(revNormd),
         lnStockClose         = log(priceClose + 1),
         
         lnNetIncNormd        = case_when(((netIncome + 0.001)/(assetsLast + 0.001) <= 0) ~ -1,
                                         ((netIncome + 0.001)/(assetsLast + 0.001)  > 0) ~ log(netIncome/assetsLast + 1)),
         lnOpIncNormd         = case_when(((opInc_afDep + 0.001)/(assetsLast + 0.001) <= 0) ~ -1,
                                         ((opInc_afDep + 0.001)/(assetsLast + 0.001) > 0) ~ log(opInc_afDep/assetsLast + 1)),
         
         lnCostNormd         = Winsorize(lnCostNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         lnRevNormd          = Winsorize(lnRevNormd, probs = c(0.01, 0.99),   na.rm = TRUE),
         lnNetIncNormd       = Winsorize(lnNetIncNormd, probs = c(0.01, 0.99),na.rm = TRUE),
         lnOpIncNormd        = Winsorize(lnOpIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         lnStockClose        = Winsorize(lnStockClose, probs = c(0.01, 0.99), na.rm = TRUE),
  
         opIncNormd          = Winsorize(opIncNormd, probs = c(0.025, 0.99),   na.rm = TRUE),
         revNormd            = Winsorize(revNormd, probs = c(0.01, 0.99),   na.rm = TRUE),
         costNormd           = Winsorize(costNormd, probs = c(0.01, 0.99),  na.rm = TRUE),

         lnOpIncNormd_take2         = log(opIncNormd + 1),
         lnCostNormd_take2          = log(costNormd + 1),
         lnRevNormd_take2           = log(revNormd  + 1),
  
  
         yearQtr = paste0(year,"_",qtr), # firmQtr = paste0(gvkey,'_',qtr), 
         ageQtr  = paste0(ageTercile,"_",yearQtr),
         sizeQtr  = paste0(sizeTercile,"_",yearQtr), 
         profitQtr  = paste0(profitTercile,"_",yearQtr), 
         indQtr  = paste0(indGroup,yearQtr)
         ) %>%
  
  
  # for direct effects
     mutate(extremeHeat   = temp_zipQuarter_95   + lag1_temp_zipQuarter_95,
       heat90Plus    = days90Plus + lag1_days90Plus,
       streak90Plus  = streak90Plus + lag1_streak90Plus,
       extremePrecipQuarter = precip_zipQuarter95    + lag1_precip_zipQuarter95,
       extremePrecipAnywhere_days = precip_annual_95 + lag1_precip_annual_95,
       extremePrecip = precip_zipQuarter_95 + lag1_precip_zipQuarter_95,
       tempTercile   = ntile(quarterly_avg_temp,3), 
       precipTercile = ntile(quarterly_avg_precip,3),
       days_extremeIs90Plus = (days90Plus <= temp_zipQuarter_95)*days90Plus,
       lag1_days_extremeIs90Plus = (lag1_days90Plus <= lag1_temp_zipQuarter_95)*lag1_days90Plus) %>%
  rowwise() %>% mutate(days90_Extreme = min(temp_zipQuarter_95, days90Plus),
                       lag1_days90_Extreme = min(lag1_temp_zipQuarter_95, lag1_days90Plus),
                       
                       days90_orExtreme = days90_Extreme + lag1_days90_Extreme,
                       days90_ifExtreme = days_extremeIs90Plus + lag1_days_extremeIs90Plus)

  # firmConcTercile = ntile(locationFracOfEmployees,2)
  # for indirect effects
  #   mutate(supplier_extremeHeat   = supplier_temp_zipQuarter_95   + supplier_lag1_temp_zipQuarter_95,
  #           supplier_heat90Plus    = supplier_days90Plus + supplier_lag1_days90Plus,
  #           supplier_streak90Plus  = supplier_streak90Plus + supplier_lag1_streak90Plus,
  #           supplier_extremePrecip = supplier_precip_zipQuarter_95 + supplier_lag1_precip_zipQuarter_95,
  #           supplierTempTercile    = ntile(supplier_quarterly_avg_temp,3),
  #           supplierPrecipTercile  = ntile(supplier_quarterly_avg_precip,3)) %>%
  # rename(gvkey = customer_gvkey)

sum(is.na(goodsData$lnOpIncNormd_take2))
goodsData = goodsData[complete.cases(goodsData$revNormd) & 
                        complete.cases(goodsData$costNormd) &
                        complete.cases(goodsData$opIncNormd), ]

# write.csv(goodsData,"data/companyData/hqsOnly/goodsData_dirEffects.csv")
write.csv(goodsData,"data/companyData/hqsOnly/goodsData_allSupplierData_dirEffects.csv")
# write.csv(goodsData,"data/companyData/hqsOnly/goodsData_allCustomerData_indirEffects.csv")

dim(goodsData)

for (col in colnames(goodsData)){
  print(col)
}

##################################################################
# run regressions across a few of the industries in particular
# add a couple of these: gvkey_calQtr, ageTercile_Qtr, profTercile_Qtr, sizeTercile_Qtr

# 'firmQtr', 
# 
# write.csv(goodsData,"data/companyData/goodsData_igData.csv")

