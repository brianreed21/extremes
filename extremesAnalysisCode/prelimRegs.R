library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)

########################################################################################################################


setwd("~/Documents/supplyChain")
cstatData               <- read.csv("data/companyData/cstatWithWeather.csv") %>% select(-X) 
allCompaniesWithWeather <- read.csv("data/companyData/allCompaniesWithWeather.csv") %>% select(-X) 

suppliersWithWeather <- read.csv("data/companyData/suppliersWithWeather.csv") %>% select(-X) 
customersWithWeather <- read.csv("data/companyData/customersWithWeather.csv") %>% select(-X) 


largestSuppliers <- read.csv("data/companyData/largestSuppliersWithWeather.csv") %>% select(-X)  
# data <- read.csv("data/companyData/wtdAvgSuppliers.csv") %>% select(-X)  

largestSuppliers = unique(largestSuppliers$gvkey)

suppliersWithWeather = suppliersWithWeather %>% filter(gvkey %in% largestSuppliers)

igData                  <- read.csv("data/companyData/igWithWeather.csv") %>% select(-X) 
data <- igData 
# suppliersWithWeather

# dim(cstatData)
head(data)



########################################################################################################################
# clean the data and remove any financial firms

dim(data)
# data = data[complete.cases(data$employeesAtLocation) & data$employeesAtLocation > 0.5,]
# dim(data)

data = data[complete.cases(data$revenueChange) & complete.cases(data$costChange) & complete.cases(data$assets) & # complete.cases(data$incomeChange) &
              complete.cases(data$profitTercile) & complete.cases(data$ageTercile) & complete.cases(data$sizeTercile) &
              (data$revenueChange < 1e12) & (data$costChange < 1e12) & (data$incomeChange < 1e12),] # & complete.cases(data$incomeChange)

dim(data)

goodsData = data %>% mutate(revenueChange = Winsorize(revenueChange, probs = c(0.01, 0.99), na.rm = TRUE),
                             # incomeChange  = Winsorize(incomeChange, probs = c(0.01, 0.99)),
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
                filter(!(famafrench %in% c('44','45','47','48'))) %>% unique()

goodsData = goodsData[complete.cases(goodsData$lnCost) & (goodsData$lnCostNormd < 1e12),] 

dim(goodsData)


# add a couple of these: gvkey_calQtr, ageTercile_Qtr, profTercile_Qtr, sizeTercile_Qtr

# 'firmQtr', 
goodsData_withDummies = dummy_cols(goodsData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(goodsData_withDummies,"extremes/goodsData_igData.csv")


agData = goodsData %>% filter(famafrench == 2)
agData_withDummies = dummy_cols(agData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(agData_withDummies,"extremes/agData_igData.csv")

cnstrctnData             = goodsData %>% filter((famafrench == 17) | (famafrench == 18))
cnstrctnData_withDummies = dummy_cols(cnstrctnData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(cnstrctnData_withDummies,"extremes/cnstrctnData_igData.csv")

utilitiesData             = goodsData %>% filter((famafrench == 31))
utilitiesData_withDummies = dummy_cols(utilitiesData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
write.csv(utilitiesData_withDummies,"extremes/utilitiesData_igData.csv")


dim(agData)



# let's do all the regression results by famafrench level
for (ind in seq(1,43)){
  print(ind)
  
  tempData = goodsData %>% filter(famafrench == ind)
  
  tempData_withDummies = dummy_cols(tempData, select_columns =  c('gvkey', 'indQtr','ageQtr','sizeQtr','profitQtr'), remove_first_dummy = TRUE)
  
  # filename = paste0('data/companyData/igData_ind', ind,'.csv')
  # write.csv(tempData_withDummies,filename)
  
  print(dim(tempData))
}

ind = 0
filename = paste0('extremes/igData_ind', ind,'.csv')

############################################################################

X = goodsData %>% select(starts_with(c('precip','temp','gvkey_', 'indQtr_'))) %>% as.matrix()


c("assets","costGoodsSold","totalInv","netIncome","totalRevenue","assetsLast",                             
"netIncomeLast","totalRevenueLast","costGoodsSoldLast","totalInvLast","incomeChange","revenueChange",
"costChange","inventoryChange")


y = goodsData %>% pull(revenueChange) %>% as.matrix()



(solve(t(X) %*% X) %*% X)%*% y

coef(.lm.fit(cbind(1,X), y))

#######################################################################################################################

ptm <- proc.time()
summary(lm(revenueChange ~ precip5Days_annualquant_1x5Yrs + factor(gvkey) + factor(indQtr), 
           data = goodsData))
proc.time() - ptm

model_robust_stata <- coeftest(model, 
                                vcov = vcovHC,
                                type = "HC1", 
                               cluster = 'gvkey')

model_robust_stata


plm(revenueChange ~ precip_zipquant_1.0 + temp_zipquant_1.0 +
      factor(hotTier) + factor(wetTier) + variedHot + variedWet +
      factor(roaTier) + factor(ageTier) + factor(profitTier) + 
      factor(famafrench) + factor(yearQtr), data = goodsData, inde)



summary(lm(revenueChange ~ precip_zipquant_1.0 + temp_zipquant_1.0 +
                factor(hotTier) + factor(wetTier) + variedHot + variedWet +
                factor(roaTier) + factor(ageTier) + factor(profitTier) + 
                factor(famafrench) + factor(yearQtr), data = goodsData ))

summary(lm(revenueChange ~ precip_monthlyquant_1.0 + temp_monthlyquant_1.0 + 
             factor(hotTier) + factor(wetTier) + variedHot + variedWet +
             factor(roaTier) + factor(ageTier) + factor(profitTier) + 
             factor(famafrench)  + factor(yearQtr), data = goodsData )) #  + factor(gvkey)

summary(lm(revenueChange ~ precip_annualquant_1.0 + temp_annualquant_1.0 + 
             factor(hotTier) + factor(wetTier) + 
             factor(roaTier) + factor(ageTier) + factor(profitTier) + 
             factor(famafrench)  + factor(yearQtr), data = goodsData ))


industries = unique(goodsData %>% pull(famafrench))

for (ind in industries){
  print(ind)
  print('*************************')
  print(summary(lm(revenueChange ~ temp_annualquant_1.0 + precip_annualquant_1.0 + 
               # factor(hotTier) + factor(wetTier) + variedHot + variedWet +
               # factor(roaTier) + factor(ageTier) + factor(profitTier) + 
               factor(yearQtr) + factor(gvkey) + factor(zipcode), 
             data = goodsData[goodsData$famafrench == ind,] ))) 
  
}
  
  

  
  


summary(lm(costChange ~ precip_monthlyquant_1.0 + temp_monthlyquant_1.0 + factor(hotTier) + factor(wetTier) +
             factor(roaTier) + factor(ageTier) + factor(profitTier) + 
             factor(famafrench) + factor(yearQtr) + factor(gvkey), data = data ))




summary(lm(costChange ~ temp_annualquant_1.0 + precip_annualquant_1.0 + factor(hotTier) + factor(wetTier) +
             factor(roaTier) + factor(ageTier) + factor(profitTier) + 
             factor(famafrench) + factor(yearQtr), data = data ))

+ factor(gvkey)


grep("*_quant_*", capture.output(revChange), value = TRUE)




########################################################################################################################
# all variables: 
# tmax_quant_0.05 + tmax_quant_0.1 + tmax_quant_0.15 + tmax_quant_0.2 + tmax_quant_0.25 + tmax_quant_0.30 + 
#   tmax_quant_0.35 + tmax_quant_0.4 + tmax_quant_0.45 + tmax_quant_0.5 + tmax_quant_0.55 + tmax_quant_0.60 + 
#   tmax_quant_0.65 + tmax_quant_0.70 + tmax_quant_0.75 + tmax_quant_0.8 + tmax_quant_0.85 + tmax_quant_0.9 + 
#   tmax_quant_0.95 + tmax_quant_1.0 + precip_quant_0.65 + precip_quant_0.70 + precip_quant_0.75 + 
#   precip_quant_0.8 + precip_quant_0.85 + precip_quant_0.9 + precip_quant_0.95 + precip_quant_1.0


revChange <- summary(lm(revenueChange   ~ precip_quant_1.0  +  tmax_quant_1.0 + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0  + factor(zipcode) + factor(yearQtr) + factor(naics2), data = data))
grep("*_quant_*", capture.output(revChange), value = TRUE)

# incomeChange <- summary(lm(incomeChange    ~ precip_quant_1.0  +  tmax_quant_1.0  + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0 + factor(yearQtr)*factor(naics2), data = data))
# grep("*_quant_*", capture.output(incomeChange), value = TRUE)

costChange <- summary(lm(costChange      ~ precip_quant_1.0  +  tmax_quant_1.0  + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0 + factor(yearQtr)*factor(naics2), data = data))
grep("*_quant_*", capture.output(costChange), value = TRUE)

inventoryChange <- summary(lm(inventoryChange ~ precip_quant_1.0  +  tmax_quant_1.0  + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0 + factor(yearQtr)*factor(naics2), data = data))
grep("*_quant_*", capture.output(inventoryChange), value = TRUE)

########################################################################################################################
# look at baseline profit changes as well



########################################################################################################################
# regress on industry subgroups


# list the industries first
data %>% pull(naics2) %>% unique() %>% sort()


# regress by industries
for (ind in data %>% pull(naics2) %>% unique() %>% sort()){
  
  if (ind != '61'){
    print("******************")
    print(ind)
    coeffPrecip <- summary(lm(costChange ~ precipQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 1]
    pvalPrecip  <- summary(lm(costChange ~ precipQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 4]
    print(paste0("precip: ", coeffPrecip," | p: ", pvalPrecip))
    
    
    coeffTmax <- summary(lm(costChange ~ tmaxQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 1]
    pvalTmax  <- summary(lm(costChange ~ tmaxQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 4]
    print(paste0("tmax: ", coeffTmax," | p: ", pvalTmax))
  }
  
}
  
############################################################################################################################
,
naics2 = substr(naics,1,2), zip2 = substr(zipcode,1,2),
hotTier = ntile(quarterly_avg_temp,3), wetTier = ntile(quarterly_avg_precip,3),
variedWet = ntile(quarterly_variance_precip,3), variedHot = ntile(quarterly_variance_temp,3),
roaTier = ntile(roa, 3), ageTier = ntile(earliestYear, 3), profitTier = ntile(netIncome,3),
extremeTempsZip  = temp_zipquant_0.95 + temp_zipquant_1.0,
extremePrecipZip = precip_zipquant_0.95 + precip_zipquant_1.0
