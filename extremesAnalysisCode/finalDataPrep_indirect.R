library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)


########################################################################################################################
# load the data first

setwd("~/Documents/supplyChain")

# load: changes data, largest supplier data, and all supplier data

# largestSuppliers <- read.csv("data/companyData/largestSuppliersWithWeather_more500K.csv") %>% select(-X)

allSuppliers     <- read.csv("data/companyData/allIndirect.csv")  %>% select(-X)  



########################################################################################################################
# clean the data, first pass 
data <- allSuppliers 
dim(data)


data = data[complete.cases(data$assetsLast) & complete.cases(data$profitTercile) & complete.cases(data$ageTercile) & complete.cases(data$sizeTercile),] %>% 
  filter(indGroup %in% c('agForFish','construction','manu','mining','transportUtilities','wholesale','retail')) %>% 
  mutate(totalRevenue = case_when(totalRevenue < 0 ~ 0, totalRevenue > 0 ~ totalRevenue)) 
dim(data)


########################################################################################################################
# run this to get data across all firms

goodsData = data  %>% rename(gvkey = customer_gvkey) %>% mutate(
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
    mutate(worstSupplier_excessHeat90PlusEmp   = worst_supplier_empWt_days90Plus + worst_supplier_empWt_lag1_days90Plus - 9,
           largestSupplier_excessHeat90PlusEmp = largest_supplier_empWt_days90Plus + largest_supplier_empWt_lag1_days90Plus - 9,
           wtdSupplier_excessHeat90PlusEmp     = wtd_supplier_empWt_days90Plus   + wtd_supplier_empWt_lag1_days90Plus - 9,
           
           worstSupplier_excessRain90PlusEmp   = worst_supplier_empWt_precip_zipQuarter_95   + worst_supplier_empWt_precip_zipQuarter_95 - 9,
           largestSupplier_excessRain90PlusEmp = largest_supplier_empWt_precip_zipQuarter_95 + largest_supplier_empWt_precip_zipQuarter_95 - 9,
           wtdSupplier_excessRain90PlusEmp     = wtd_supplier_empWt_precip_zipQuarter_95     + wtd_supplier_empWt_precip_zipQuarter_95 - 9) %>% 
  select(-contains("_supplier")) %>% drop_na(lnOpIncNormd, lnRevNormd, lnCostNormd, lnStockClose)
write.csv(goodsData,"data/companyData/customer_goodsData.csv")
