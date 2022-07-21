library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)

########################################################################################################################
# load the data first

setwd("~/Documents/supplyChain")



# load: changes data, largest supplier data, and all supplier data
igData           <- read.csv("data/companyData/igWithWeather.csv") %>% select(-X) 
largestSuppliers <- read.csv("data/companyData/largestSuppliersWithWeather.csv") %>% select(-X)  
allSuppliers     <- read.csv("data/companyData/allSuppliersWithWeather.csv")  %>% select(-X)  


# choose to focus on one of them
data <- allSuppliers 
dim(data)


########################################################################################################################
# clean the data, first pass 
data = data[complete.cases(data$revenueChange) & complete.cases(data$costChange) & complete.cases(data$assets) & 
              complete.cases(data$profitTercile) & complete.cases(data$ageTercile) & complete.cases(data$sizeTercile),] 

dim(data)

########################################################################################################################
# run this to get data across all firms
goodsData = data %>% mutate(revenueChange = Winsorize(revenueChange, probs = c(0.01, 0.99), na.rm = TRUE),
                       costChange    = Winsorize(costChange, probs = c(0.01, 0.99), na.rm = TRUE),
                       totalRevenue  = Winsorize(totalRevenue, probs = c(0.01, 0.99), na.rm = TRUE),
                       costGoodsSold = Winsorize(costGoodsSold, probs = c(0.01, 0.99), na.rm = TRUE),
                       lnCost = log(costGoodsSold + 0.0001),
                       lnRev  = log(totalRevenue + 0.0001),
                       lnCostNormd = log((costGoodsSold + 0.0001)/assets),
                       lnRevNormd  = log((totalRevenue + 0.0001)/assets),
                       yearQtr = paste0(year,"_",qtr),
                       firmQtr = paste0(gvkey,'_',qtr), 
                       ageQtr  = paste0(ageTercile,"_",yearQtr),
                       sizeQtr  = paste0(sizeTercile,"_",yearQtr),
                       profitQtr  = paste0(profitTercile,"_",yearQtr),
                       indQtr  = paste0(famafrench,yearQtr)) %>% 
                filter(!(famafrench %in% c('7','11','32','33','34','43','44','45','47','48'))) %>% 
                filter(!(supplier_famafrench %in% c('7','11','32','33','34','43','44','45','47','48'))) %>% unique()


# we've added a few more of the services categories


goodsData = goodsData[complete.cases(goodsData$lnCost) & (goodsData$lnCostNormd < 1e12),] 

dim(goodsData)




##################################################################
# run regressions across a few of the industries in particular
# add a couple of these: gvkey_calQtr, ageTercile_Qtr, profTercile_Qtr, sizeTercile_Qtr

# 'firmQtr', 
goodsData_withDummies = dummy_cols(goodsData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(goodsData_withDummies,"data/companyData/goodsData_supplierData.csv")




agData = goodsData %>% filter((supplier_famafrench == 1) | (supplier_famafrench == 2))
agData_withDummies = dummy_cols(agData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(agData_withDummies,"extremes/supplier_agData_igData.csv")

cnstrctnData             = goodsData %>% filter((supplier_famafrench == 17) | (supplier_famafrench == 18))
cnstrctnData_withDummies = dummy_cols(cnstrctnData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(cnstrctnData_withDummies,"extremes/supplier_cnstrctnData_igData.csv")

utilitiesData             = goodsData %>% filter((supplier_famafrench == 31))
utilitiesData_withDummies = dummy_cols(utilitiesData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(utilitiesData_withDummies,"extremes/supplier_utilitiesData_igData.csv")


dim(agData)

##################################################################
# let's do all the regression results by famafrench level
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

