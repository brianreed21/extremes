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
  ageTercile    = ntile(earliestYear,3),
  profitTercile = ntile(roa_lagged,3),
  sizeTercile   = ntile(assetsLast,3),
  
  ###########################################################
  # do this the old fashioned way: winsorize, etc
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
  
  
  
  ##############################################################
  # now do this the other way 
  revNormd_take2     = (totalRevenue/assetsLast) + 1,
  costNormd_take2    = (costGoodsSold/assetsLast) + 1,
  netIncNormd_take2  = (netIncome/assetsLast) + 1,
  opIncNormdAf_take2 = (opInc_afDep/assetsLast) + 1,
  opIncNormdBef_take2 = (opInc_befDep/assetsLast) + 1,
  
  
  lnCostNormd_take2       = log(Winsorize(costNormd_take2, probs     = c(0.01, 0.99),  na.rm = TRUE)),
  lnRevNormd_take2        = log(Winsorize(revNormd_take2, probs      = c(0.01, 0.99),   na.rm = TRUE)),
  lnNetIncNormd_take2     = log(Winsorize(netIncNormd_take2, probs   = c(0.025, 0.99),na.rm = TRUE)),
  lnOpIncNormdAf_take2    = log(Winsorize(opIncNormdAf_take2, probs  = c(0.025, 0.99), na.rm = TRUE)),
  lnOpIncNormdBef_take2   = log(Winsorize(opIncNormdBef_take2, probs = c(0.025, 0.99), na.rm = TRUE)),
  
  
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
           wtdSupplier_excessRain90PlusEmp     = wtd_supplier_empWt_precip_zipQuarter_95     + wtd_supplier_empWt_precip_zipQuarter_95 - 9,
           
           
           ) %>% 
  select(-contains("_supplier")) %>% drop_na(lnOpIncNormd, lnRevNormd, lnCostNormd, lnStockClose, lnOpIncNormdBef_take2, lnOpIncNormdAf_take2) 
write.csv(goodsData,"data/companyData/customer_goodsData.csv")
