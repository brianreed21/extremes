library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)

########################################################################################################################
# load the data first

setwd("~/Documents/supplyChain")



# load: changes data, largest supplier data, and all supplier data
igData           <- read.csv("data/companyData/igWithWeather.csv") %>% select(-X, -opInc_befDep) # before depreciation, things seem a bit more scarce

# largestSuppliers <- read.csv("data/companyData/largestSuppliersWithWeather.csv") %>% select(-X)  
# allSuppliers     <- read.csv("data/companyData/allSuppliersWithWeather.csv")  %>% select(-X)  


# choose to focus on one of them


########################################################################################################################
# clean the data, first pass 
data <- igData 
dim(data)


unique(data$indGroup)

# complete.cases(data$revenueChange) & complete.cases(data$costChange)  & complete.cases(data$opInc_afDep) & complete.cases(data$netIncome) &
data = data[complete.cases(data$revenueChange) & complete.cases(data$costChange) & complete.cases(data$assetsLast) & 
              complete.cases(data$profitTercile) & complete.cases(data$ageTercile) & complete.cases(data$sizeTercile),] %>% 
  filter(indGroup %in% c('agForFish','construction','manu','mining','transportUtilities','wholesale','retail')) %>% 
  mutate(totalRevenue = case_when(totalRevenue < 0 ~ 0,
                                  totalRevenue > 0 ~ totalRevenue), # 26 cases with negative revenues
    
        wetDaysCat = case_when(precip_zipQuarterquant_0.95  <= 5   ~ "cat1", 
                               (precip_zipQuarterquant_0.95  > 5)  & (precip_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                               (precip_zipQuarterquant_0.95  > 10) & (precip_zipQuarterquant_0.95 <= 15)    ~ "cat3",
                               (precip_zipQuarterquant_0.95  > 15)                                          ~ "cat4"),
         
         lag1_wetDaysCat = case_when(lag1_precip_zipQuarterquant_0.95  <= 5   ~ "cat1", 
                                (lag1_precip_zipQuarterquant_0.95  > 5)  & (lag1_precip_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                                (lag1_precip_zipQuarterquant_0.95  > 10) & (lag1_precip_zipQuarterquant_0.95 <= 15)    ~ "cat3",
                                (lag1_precip_zipQuarterquant_0.95  > 15)                                          ~ "cat4"),
         lag2_wetDaysCat  = case_when(lag2_precip_zipQuarterquant_0.95  <= 5   ~ "cat1", 
                                     (lag2_precip_zipQuarterquant_0.95  > 5)  & (lag2_precip_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                                     (lag2_precip_zipQuarterquant_0.95  > 10) & (lag2_precip_zipQuarterquant_0.95 <= 15)    ~ "cat3",
                                     (lag2_precip_zipQuarterquant_0.95  > 15)                                          ~ "cat4"),
         lag3_wetDaysCat  = case_when(lag3_precip_zipQuarterquant_0.95  <= 5   ~ "cat1", 
                                     (lag3_precip_zipQuarterquant_0.95  > 5)  & (lag3_precip_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                                     (lag3_precip_zipQuarterquant_0.95  > 10) & (lag3_precip_zipQuarterquant_0.95 <= 15)    ~ "cat3",
                                     (lag3_precip_zipQuarterquant_0.95  > 15)                                          ~ "cat4"),
         
         hotDaysCat = case_when(temp_zipQuarterquant_0.95    <= 5   ~ "cat1", 
                                (temp_zipQuarterquant_0.95   > 5)  & (temp_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                                (temp_zipQuarterquant_0.95   > 10) & (temp_zipQuarterquant_0.95 <= 15)   ~ "cat3",
                                (temp_zipQuarterquant_0.95   > 15)  ~ "cat4"),
         
         lag1_hotDaysCat = case_when(lag1_temp_zipQuarterquant_0.95    <= 5   ~ "cat1", 
                                (lag1_temp_zipQuarterquant_0.95   > 5)  & (lag1_temp_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                                (lag1_temp_zipQuarterquant_0.95   > 10) & (lag1_temp_zipQuarterquant_0.95 <= 15)   ~ "cat3",
                                (lag1_temp_zipQuarterquant_0.95   > 15)  ~ "cat4"),
         
         lag2_hotDaysCat = case_when(lag2_temp_zipQuarterquant_0.95    <= 5   ~ "cat1", 
                                (lag2_temp_zipQuarterquant_0.95   > 5)  & (lag2_temp_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                                (lag2_temp_zipQuarterquant_0.95   > 10) & (lag2_temp_zipQuarterquant_0.95 <= 15)   ~ "cat3",
                                (lag2_temp_zipQuarterquant_0.95   > 15)  ~ "cat4"),
         
         lag3_hotDaysCat = case_when(lag3_temp_zipQuarterquant_0.95    <= 5   ~ "cat1", 
                                (lag3_temp_zipQuarterquant_0.95   > 5)  & (lag3_temp_zipQuarterquant_0.95 <= 10)    ~ "cat2",
                                (lag3_temp_zipQuarterquant_0.95   > 10) & (lag3_temp_zipQuarterquant_0.95 <= 15)   ~ "cat3",
                                (lag3_temp_zipQuarterquant_0.95   > 15)  ~ "cat4")
         )


table(data$wetDaysCat)
table(data$hotDaysCat)

dim(data)

########################################################################################################################
# run this to get data across all firms

goodsData = data  %>%  mutate(ageTercile    = ntile(earliestYear,3),
         profitTercile = ntile(roa_lagged,3),
         sizeTercile   = ntile(assetsLagged,3),
         tempTercile   = ntile(quarterly_avg_temp,3), 
         precipTercile = ntile(quarterly_avg_precip,3),
         firmConcTercile = ntile(locationFracOfEmployees,3))  %>% 
  # this worked very well when it was netIncome/(assetsLast + 0.001), or same for
  # vars other than netIncome
  mutate(lnCostNormd          = log((costGoodsSold + 0.001)/(assetsLast + 0.001) + 1),
         lnRevNormd           = log((totalRevenue )/(assetsLast + 0.001)), 
         # anything with + 1 gives us .09 .22 .018 .018
         
         # totalRevenue + 0.001 gives us .09, .22, .018 .019 pvals
         # lnNetIncNormd        = log(netIncome/assetsLast + 1),
         # lnOpIncNormd         = log(opInc_afDep/(assetsLast + 0.001)  + 1),
         lnStockClose         = log(priceClose + 1),
         
         lnNetIncNormd       = case_when(((netIncome + 0.001)/(assetsLast + 0.001) <= 0) ~ -10,
                                         ((netIncome + 0.001)/(assetsLast + 0.001)  > 0) ~ log(netIncome/assetsLast + 1)),
         lnOpIncNormd        = case_when(((opInc_afDep + 0.001)/(assetsLast + 0.001) <= 0) ~ -10,
                                         ((opInc_afDep + 0.001)/(assetsLast + 0.001) > 0) ~ log(opInc_afDep/assetsLast + 1)),
         
         lnCostNormd         = Winsorize(lnCostNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         lnRevNormd          = Winsorize(lnRevNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         lnNetIncNormd       = Winsorize(lnNetIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         lnOpIncNormd        = Winsorize(lnOpIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
         lnStockClose        = Winsorize(lnStockClose, probs = c(0.01, 0.99), na.rm = TRUE),
         
                  
         # totalRevenue  = Winsorize(totalRevenue, probs = c(0.01, 0.99), na.rm = TRUE),
         # costGoodsSold = Winsorize(costGoodsSold, probs = c(0.01, 0.99), na.rm = TRUE),
         
         yearQtr = paste0(year,"_",qtr),
         firmQtr = paste0(gvkey,'_',qtr), 
         ageQtr  = paste0(ageTercile,"_",yearQtr),
         sizeQtr  = paste0(sizeTercile,"_",yearQtr),
         profitQtr  = paste0(profitTercile,"_",yearQtr),
         indQtr  = paste0(indGroup,yearQtr),
         extremeHeat   = temp_zipQuarterquant_0.95   + lag1_temp_zipQuarterquant_0.95,
         extremePrecip = precip_zipQuarterquant_0.95 + lag1_precip_zipQuarterquant_0.95)


hist(goodsData$opInc_befDep/goodsData$assetsLast)


# goodsData %>% filter(firmConcTercile != 1) %>% pull(locationFracOfEmployees) %>% min()
goodsData %>% pull(temp_zipQuarter95_99) %>% max()
# goodsData = goodsData[complete.cases(goodsData$lnCost) & (goodsData$lnCostNormd < 1e12),] 

sum(goodsData$temp_zipQuarter95_99 == goodsData$lag1_temp_zipQuarter95_99)

write.csv(goodsData,"data/companyData/goodsData_igData.csv")


colnames(goodsData)


##################################################################
# run regressions across a few of the industries in particular
# add a couple of these: gvkey_calQtr, ageTercile_Qtr, profTercile_Qtr, sizeTercile_Qtr

# 'firmQtr', 
goodsData_withDummies = dummy_cols(goodsData, select_columns =  c('precipBin', 'heatBin'), remove_first_dummy = TRUE) # dummy_cols(goodsData, select_columns =  c('gvkey', 'precipBin', 'heatBin', 'indQtr','ageTercile', 'sizeTercile', 'profitTercile'), remove_first_dummy = TRUE)
write.csv(goodsData,"data/companyData/goodsData_igData.csv")


##################################################################
# let's do all the regression results by famafrench level - by industry

# for (ind in seq(1,43)){
for (ind in unique(data$indGroup)){
  print(ind)

  tempData = data %>% filter(indGroup == ind) 
  if (dim(tempData)[1] > 0){
    tempData = tempData %>% mutate(revenueChange = Winsorize(revenueChange, probs = c(0.01, 0.99), na.rm = TRUE),
                                   costChange    = Winsorize(costChange, probs = c(0.01, 0.99), na.rm = TRUE),
                                   totalRevenue  = Winsorize(totalRevenue, probs = c(0.01, 0.99), na.rm = TRUE),
                                   costGoodsSold = Winsorize(costGoodsSold, probs = c(0.01, 0.99), na.rm = TRUE),
                                   lnCost = log(costGoodsSold + 0.0001),
                                   lnRev  = log(totalRevenue + 0.0001),
                                   lnCostNormd = log((costGoodsSold + 0.0001)/assets),
                                   lnRevNormd  = log((totalRevenue + 0.0001)/assets),
                                   yearQtr = paste0(year,"_",qtr),
                                   indQtr  = paste0(sic2,yearQtr),
                                   firmQtr = paste0(gvkey,'_',qtr)) %>% 
      mutate(ageTercile    = ntile(earliestYear,3),
             profitTercile = ntile(roa_lagged,3),
             sizeTercile   = ntile(assetsLagged,3)) %>% 
      mutate(ageQtr  = paste0(ageTercile,"_",yearQtr),
             sizeQtr  = paste0(sizeTercile,"_",yearQtr),
             profitQtr  = paste0(profitTercile,"_",yearQtr))
    
    tempData = tempData[complete.cases(tempData$lnCost) & (tempData$lnCostNormd < 1e12),] 
    
    # dim(goodsData)
    
    tempData_withDummies = dummy_cols(tempData, select_columns =  c('gvkey', 'ageTercile', 'sizeTercile', 'profitTercile', 'ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
    
    filename = paste0('data/companyData/igData_ind', ind,'.csv')
    write.csv(tempData_withDummies,filename)
    
    print(dim(tempData_withDummies))
    
  }
  
  
  else{
    filename = paste0('data/companyData/igData_ind', ind,'.csv')
    write.csv(tempData,filename)
    
    print(dim(tempData))
  }
}

##################################################################
# let's do all the regression results by famafrench level - by supplier industry
for (ind in seq(1,43)){
  print(ind)
  
  tempData = data %>% filter(supplier_famafrench == ind) 
  if (dim(tempData)[1] > 0){
    tempData = tempData %>% mutate(revenueChange = Winsorize(revenueChange, probs = c(0.01, 0.99), na.rm = TRUE),
                                   # incomeChange  = Winsorize(incomeChange, probs = c(0.01, 0.99)),
                                   costChange    = Winsorize(costChange, probs = c(0.01, 0.99), na.rm = TRUE),
                                   totalRevenue  = Winsorize(totalRevenue, probs = c(0.01, 0.99), na.rm = TRUE),
                                   costGoodsSold = Winsorize(costGoodsSold, probs = c(0.01, 0.99), na.rm = TRUE),
                                   lnCost = log(costGoodsSold + 0.0001),
                                   lnRev  = log(totalRevenue + 0.0001),
                                   lnCostNormd = log((costGoodsSold + 0.0001)/assets),
                                   lnRevNormd  = log((totalRevenue + 0.0001)/assets),
                                   yearQtr = paste0(year,"_",qtr),
                                   indQtr  = paste0(famafrench,yearQtr),
                                   firmQtr = paste0(gvkey,'_',qtr)) %>% 
      mutate(ageTercile    = ntile(earliestYear,3),
             profitTercile = ntile(roa_lagged,3),
             sizeTercile   = ntile(assetsLagged,3)) %>% 
      mutate(ageQtr  = paste0(ageTercile,"_",yearQtr),
             sizeQtr  = paste0(sizeTercile,"_",yearQtr),
             profitQtr  = paste0(profitTercile,"_",yearQtr)) %>%
      filter(!(famafrench %in% c('44','45','47','48'))) %>% unique()
    
    tempData = tempData[complete.cases(tempData$lnCost) & (tempData$lnCostNormd < 1e12),] 
    
    # dim(goodsData)
    
    tempData_withDummies = dummy_cols(tempData, select_columns =  c('gvkey', 'ageTercile', 'sizeTercile', 'profitTercile', 'ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
    
    filename = paste0('data/companyData/supplier_igData_ind', ind,'.csv')
    write.csv(tempData_withDummies,filename)
    
    print(dim(tempData_withDummies))
    
  }
  
  
  else{
    filename = paste0('data/companyData/supplier_igData_ind', ind,'.csv')
    write.csv(tempData,filename)
    
    print(dim(tempData))
  }
}

