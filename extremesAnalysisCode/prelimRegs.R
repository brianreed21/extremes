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


# largestSuppliers <- read.csv("data/companyData/largestSuppliersWithWeather_more500K.csv") %>% select(-X)



allSuppliers     <- read.csv("data/companyData/allSupplierData.csv")  %>% select(-X)  



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
         
         lnNetIncNormd        = case_when(((netIncome + 0.001)/(assetsLast + 0.001) <= 0) ~ -1,
                                         ((netIncome + 0.001)/(assetsLast + 0.001)  > 0) ~ log(netIncome/assetsLast + 1)),
         lnOpIncNormd         = case_when(((opInc_afDep + 0.001)/(assetsLast + 0.001) <= 0) ~ -1,
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
      heat90Plus    = days90Plus + lag1_days90Plus,
      streak90Plus  = streak90Plus + lag1_streak90Plus,
      extremePrecip = precip_zipQuarter95 + lag1_precip_zipQuarter95,
      tempTercile   = ntile(quarterly_avg_temp,3), 
      precipTercile = ntile(quarterly_avg_precip,3),
      extremeHeat_wtd =  empWt_temp_zipQuarter_95   + empWt_lag1_temp_zipQuarter_95,
      extremePrecip_wtd = empWt_precip_zipQuarter_95 + empWt_lag1_precip_zipQuarter_95,
      extremeHeat_max =  empMx_temp_zipQuarter_95   + empMx_lag1_temp_zipQuarter_95,
      extremePrecip_max = empMx_precip_zipQuarter_95 + empMx_lag1_precip_zipQuarter_95)

  # firmConcTercile = ntile(locationFracOfEmployees,2)
  # for indirect effects
   # mutate(supplier_extremeHeat   = supplier_temp_zipQuarter_95   + supplier_lag1_temp_zipQuarter_95,
   #         supplier_heat90Plus    = supplier_days90Plus + supplier_lag1_days90Plus,
   #         supplier_streak90Plus  = supplier_streak90Plus + supplier_lag1_streak90Plus,
   #         supplier_extremePrecip = supplier_precip_zipQuarter_95 + supplier_lag1_precip_zipQuarter_95,
   #         supplierTempTercile    = ntile(supplier_quarterly_avg_temp,3),
   #         supplierPrecipTercile  = ntile(supplier_quarterly_avg_precip,3))

start = Sys.time()



Sys.time() - start



# write.csv(goodsData,"data/companyData/goodsData_largestSupplierData.csv")
write.csv(goodsData,"data/companyData/goodsData.csv")


dim(goodsData)


##################################################################
# run regressions across a few of the industries in particular
# add a couple of these: gvkey_calQtr, ageTercile_Qtr, profTercile_Qtr, sizeTercile_Qtr 

# followed https://www.kellogg.northwestern.edu/faculty/petersen/htm/papers/se/se_programming.htm to 
# https://sites.google.com/site/waynelinchang/r-code

start = Sys.time()
summary(felm(lnRevNormd ~ extremePrecip + factor(gvkey) + factor(indGroup) + factor(yearQtr), data = goodsData))
Sys.time() - start




summary(felm(lnRevNormd ~ extremePrecip + factor(gvkey) + factor(indGroup) + factor(yearQtr) | 0 | 0 | gvkey, data = goodsData))


# 'firmQtr', 
# 
# write.csv(goodsData,"data/companyData/goodsData_igData.csv")

