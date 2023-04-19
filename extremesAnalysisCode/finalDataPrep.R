library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);
library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);
library(lmtest);library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)


########################################################################################################################
# load the data first
setwd("~/Documents/supplyChain")

# load: changes data, largest supplier data, and all supplier data
igData           <- read.csv("data/companyData/igWithWeather.csv") #  %>% select(-X, -opInc_befDep) # before depreciation, things seem a bit more scarce

allSuppliers     <- read.csv("data/companyData/allIndirectWeather.csv")  %>% select(-X)  

# dirIndir         <- read.csv("data/companyData/allDirIndir.csv") %>% select(-X)
dirIndir         <- read.csv("data/companyData/allDirIndir_with500k.csv") %>% select(-X)
estabAvgs         = read.csv("data/companyData/estabWtdWeather_0320.csv") %>% select(-X)
dirIndir <- merge(estabAvgs,dirIndir)




########################################################################################################################
# clean the data, first pass 
data <- dirIndir # igData 
dim(data)


# merge in the gics and the sic2
gicsMap = read.csv("data/companyData/gicsMap_complete.csv") %>% select(-X)

sicsMap = read.csv("data/companyData/sic_2_digit_codes.csv") %>% rename(sic2 = Code.Value, sic2Desc = Description)
head(sicsMap)

dim(data)

data = data %>% merge(gicsMap) %>% merge(sicsMap)

dim(data)

data = data[complete.cases(data$assetsLast) & complete.cases(data$profitTercile) & complete.cases(data$ageTercile) & complete.cases(data$sizeTercile),] %>% 
  filter(indGroup %in% c('agForFish','construction','manu','mining','transportUtilities','wholesale','retail')) %>%
  filter(!(gsectorDesc == 'Financials')) %>%
  mutate(totalRevenue = case_when(totalRevenue < 0 ~ 0, totalRevenue > 0 ~ totalRevenue),
         costGoodsSold = case_when(costGoodsSold < 0 ~ 0, costGoodsSold > 0 ~ costGoodsSold),
         ) 

table(data$sic2Desc)


########################################################################################################################
# run this to get data across all firms
goodsData = data  %>%  mutate(
         ageTercile    = ntile(earliestYear,3),
         profitTercile = ntile(roa_lagged,3),
         sizeTercile   = ntile(assetsLagged,3),
         
         ###########################################################
         # do this the old fashioned way: winsorize, etc
         revNormd    = (totalRevenue + 0.001)/(assetsLast + 0.001),
         costNormd   = (costGoodsSold + 0.001)/(assetsLast + 0.001),
         netIncNormd = (netIncome + 0.001)/(assetsLast + 0.001),
         opIncNormd  = (opInc_afDep + 0.001)/(assetsLast + 0.001),
  
         lnRev  = log(totalRevenue + 0.001),
         lnCost = log(costGoodsSold + 0.001),
         
         lnCostNormd          = log(costNormd),
         lnRevNormd           = log(revNormd),
         lnStockClose         = log(priceClose + 1),
         
          # lnNetIncNormd        = case_when((netIncNormd <= 0) ~ -1,
          #                                 (netIncNormd  > 0) ~ log(netIncome/assetsLast + 1)),
          # lnOpIncNormd         = case_when((opIncNormd <= 0) ~ -1,
          #                                 ((opIncNormd + 0.001)/(assetsLast + 0.001) > 0) ~ log(opInc_afDep/assetsLast + 1)),
         
  
         costNormd         = Winsorize(costNormd, probs = c(0.01, 0.99),  na.rm = TRUE),
         revNormd          = Winsorize(revNormd, probs = c(0.01, 0.99),   na.rm = TRUE),
         netIncNormd       = Winsorize(netIncNormd, probs = c(0.01, 0.99),na.rm = TRUE),
         opIncNormd        = Winsorize(opIncNormd, probs = c(0.01, 0.99), na.rm = TRUE),
        
        
         ##############################################################
         # now do this the other way 
         revNormd_take2     = (totalRevenue/assetsLast) ,
         costNormd_take2    = (costGoodsSold/assetsLast) ,
         netIncNormd_take2  = (netIncome/assetsLast) ,
         opIncNormdAf_take2 = (opInc_afDep/assetsLast) ,
         opIncNormdBef_take2 = (opInc_befDep/assetsLast) ,
         
         
         lnCostNormd_take2       = log(Winsorize(costNormd_take2 + 1, probs     = c(0.01, 0.99),  na.rm = TRUE)),
         lnRevNormd_take2        = log(Winsorize(revNormd_take2 + 1, probs      = c(0.01, 0.99),   na.rm = TRUE)),
         lnNetIncNormd_take2     = log(Winsorize(netIncNormd_take2 + 1, probs   = c(0.025, 0.99),na.rm = TRUE)),
         lnOpIncNormdAf_take2    = log(Winsorize(opIncNormdAf_take2 + 1, probs  = c(0.025, 0.99), na.rm = TRUE)),
         lnOpIncNormdBef_take2   = log(Winsorize(opIncNormdBef_take2 + 1, probs = c(0.025, 0.99), na.rm = TRUE)),
         
         
         yearQtr = paste0(year,"_",qtr), firmQtr = paste0(gvkey,'_',qtr), 
         ageQtr  = paste0(ageTercile,"_",yearQtr),
         sizeQtr  = paste0(sizeTercile,"_",yearQtr), 
         profitQtr  = paste0(profitTercile,"_",yearQtr), 
         indQtr  = paste0(indGroup,yearQtr)
         )
  
# for direct effects
goodsData =  goodsData %>% mutate(extremeHeatQuarterly  = temp_zipQuarter95   + lag1_temp_zipQuarter95,
      extremePrecipQuarterly     = precip_zipQuarter95      + lag1_precip_zipQuarter95,
      
      extremeHeatQuarterly_max   = empMx_temp_zipQuarter95   + empMx_lag1_temp_zipQuarter95,
      extremePrecipQuarterly_max = empMx_precip_zipQuarter95 + empMx_lag1_precip_zipQuarter95,
      
      extremeHeatQuarterly_wtd   = empWt_temp_zipQuarter95   + empWt_lag1_temp_zipQuarter95,
      extremePrecipQuarterly_wtd = empWt_precip_zipQuarter95      + empWt_lag1_precip_zipQuarter95,
      
      heatAnomalyQuarterly   = temp_zipQuarter50     + lag1_temp_zipQuarter50,
      precipAnomalyQuarterly = precip_zipQuarter50   + lag1_precip_zipQuarter50,
      
      heatAnomalyQuarterly_wtd   = empWt_temp_zipQuarter50     + empWt_lag1_temp_zipQuarter50,
      precipAnomalyQuarterly_wtd = empWt_precip_zipQuarter50   + empWt_lag1_precip_zipQuarter50,
      
      extremeHeatDaily   = temp_zipQuarter_95   + lag1_temp_zipQuarter_95,
      extremePrecipDaily = precip_zipQuarter_95 + lag1_precip_zipQuarter_95,
      
      heatAnomalyDaily   = temp_zipQuarter_50     + lag1_temp_zipQuarter_50,
      precipAnomalyDaily = precip_zipQuarter_50   + lag1_precip_zipQuarter_50,
      
      heatAnomalyDaily_wtd   = empWt_temp_zipQuarter_50     + empWt_lag1_temp_zipQuarter_50,
      precipAnomalyDaily_wtd = empWt_precip_zipQuarter_50   + empWt_lag1_precip_zipQuarter_50,
      
      heatDays90Plus    = days90Plus + lag1_days90Plus,
      streak90Plus  = streak90Plus   + lag1_streak90Plus,
      
      heatDays90Plus_wtd    = empWt_days90Plus     + empWt_lag1_days90Plus,
      heatDays90Plus_max    = empMx_days90Plus     + empMx_lag1_days90Plus,
      
      precip95National     = precip_annual_95 + lag1_precip_annual_95,
      precip95National_wtd = empWt_precip_annual_95 + empWt_lag1_precip_annual_95,
      precip95National_max = empMx_precip_annual_95 + empMx_lag1_precip_annual_95,

      precip99National = precip_annual_99 + lag1_precip_annual_99,
      precip99National_wtd = empWt_precip_annual_99 + empWt_lag1_precip_annual_99,
      
      heat95National       = temp_annual_95   + lag1_temp_annual_95,
      heat95National_wtd   = empWt_temp_annual_95   + empWt_lag1_temp_annual_95,
      
      heat99National       = temp_annual_99   + lag1_temp_annual_99,
      heat99National_wtd   = empWt_temp_annual_99   + empWt_lag1_temp_annual_99,
      
      extremeHeatDays_wtd   =  empWt_temp_zipQuarter_95    + empWt_lag1_temp_zipQuarter_95,
      extremeHeatDays_wtd99 =  empWt_temp_zipQuarter_99    + empWt_lag1_temp_zipQuarter_99,
      
      extremePrecipDays_wtd   = empWt_precip_zipQuarter_95 + empWt_lag1_precip_zipQuarter_95,
      extremePrecipDays_wtd99 = empWt_precip_zipQuarter_99 + empWt_lag1_precip_zipQuarter_99,
      
      extremeHeatDays_max =  empMx_temp_zipQuarter_95    + empMx_lag1_temp_zipQuarter_95,
      extremePrecipDays_max = empMx_precip_zipQuarter_95 + empMx_lag1_precip_zipQuarter_95,
      
      precipAnomaly_natl_wtd = empWt_precip_annual_50   + empWt_lag1_precip_annual_50,
      
      tempTercile   = ntile(quarterly_avg_temp,3), 
      precipTercile = ntile(quarterly_avg_precip,3),
      
      tempHalfWtd   = ntile(weightedTempQtr,2),
      precipHalfWtd = ntile(weightedPrecipQtr,2),
      
      tempTercileWtd   = ntile(weightedTempQtr,3),
      precipTercileWtd = ntile(weightedPrecipQtr,3),
      
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
      
      
      indSeason = paste0(indGroup,qtr)) #  %>%

  
goodsData =  goodsData %>% group_by(qtr) %>%
  
  mutate(tempTercile_byQtr   = ntile(quarterly_avg_temp,3), 
         precipTercile_byQtr = ntile(quarterly_avg_precip,3),
         
         tempQuintile_byQtr   = ntile(quarterly_avg_temp,5), 
         precipQuintile_byQtr = ntile(quarterly_avg_precip,5),
         
         tempDecile_byQtr   = ntile(quarterly_avg_temp,10), 
         precipDecile_byQtr = ntile(quarterly_avg_precip,10)) #  %>%
  
  
# next for indirect effects
goodsData =  goodsData %>%  mutate(worstSupplier_excessHeat90PlusEmp   = worst_supplier_empWt_days90Plus   + worst_supplier_empWt_lag1_days90Plus - 9,
         largestSupplier_excessHeat90PlusEmp = largest_supplier_empWt_days90Plus + largest_supplier_empWt_lag1_days90Plus - 9,
         wtdSupplier_excessHeat90PlusEmp     = wtd_supplier_empWt_days90Plus     + wtd_supplier_empWt_lag1_days90Plus - 9,
         
         worstSupplier_excessRainEmp   = worst_supplier_empWt_precip_zipQuarter_95   + worst_supplier_empWt_precip_zipQuarter_95 - 9,
         largestSupplier_excessRainEmp = largest_supplier_empWt_precip_zipQuarter_95 + largest_supplier_empWt_precip_zipQuarter_95 - 9,
         wtdSupplier_excessRainEmp     = wtd_supplier_empWt_precip_zipQuarter_95     + wtd_supplier_empWt_precip_zipQuarter_95 - 9,
         
         worstSupplier_excessHeat90Plus   = worst_supplier_days90Plus   + worst_supplier_lag1_days90Plus - 9,
         largestSupplier_excessHeat90Plus = largest_supplier_days90Plus + largest_supplier_lag1_days90Plus - 9,
         wtdSupplier_excessHeat90Plus     = wtd_supplier_days90Plus     + wtd_supplier_lag1_days90Plus - 9,
         
         worstSupplier_excessRain   = worst_supplier_precip_zipQuarter_95   + worst_supplier_precip_zipQuarter_95 - 9,
         largestSupplier_excessRain = largest_supplier_precip_zipQuarter_95 + largest_supplier_precip_zipQuarter_95 - 9,
         wtdSupplier_excessRain     = wtd_supplier_precip_zipQuarter_95     + wtd_supplier_precip_zipQuarter_95 - 9) #  %>%
  
goodsData =  goodsData %>%   mutate(worstSupplier500k_excessHeat90PlusEmp   = worst_supplier500k_empWt_days90Plus   + worst_supplier500k_empWt_lag1_days90Plus - 9,
         largestSupplier500k_excessHeat90PlusEmp = largest_supplier500k_empWt_days90Plus + largest_supplier500k_empWt_lag1_days90Plus - 9,
         wtdSupplier500k_excessHeat90PlusEmp     = wtd_supplier500k_empWt_days90Plus     + wtd_supplier500k_empWt_lag1_days90Plus - 9,
         
         worstSupplier500k_excessRainEmp   = worst_supplier500k_empWt_precip_zipQuarter_95   + worst_supplier500k_empWt_precip_zipQuarter_95 - 9,
         largestSupplier500k_excessRainEmp = largest_supplier500k_empWt_precip_zipQuarter_95 + largest_supplier500k_empWt_precip_zipQuarter_95 - 9,
         wtdSupplier500k_excessRainEmp     = wtd_supplier500k_empWt_precip_zipQuarter_95     + wtd_supplier500k_empWt_precip_zipQuarter_95 - 9,
         
         worstSupplier500k_excessHeat90Plus   = worst_supplier500k_days90Plus   + worst_supplier500k_lag1_days90Plus - 9,
         largestSupplier500k_excessHeat90Plus = largest_supplier500k_days90Plus + largest_supplier500k_lag1_days90Plus - 9,
         wtdSupplier500k_excessHeat90Plus     = wtd_supplier500k_days90Plus     + wtd_supplier500k_lag1_days90Plus - 9,
         
         worstSupplier500k_excessRain   = worst_supplier500k_precip_zipQuarter_95   + worst_supplier500k_precip_zipQuarter_95 - 9,
         largestSupplier500k_excessRain = largest_supplier500k_precip_zipQuarter_95 + largest_supplier500k_precip_zipQuarter_95 - 9,
         wtdSupplier500k_excessRain     = wtd_supplier500k_precip_zipQuarter_95     + wtd_supplier500k_precip_zipQuarter_95 - 9) # %>%
  
goodsData =  goodsData %>%   mutate_at(c('worstSupplier_excessHeat90PlusEmp', 'largestSupplier_excessHeat90PlusEmp', 'wtdSupplier_excessHeat90PlusEmp',
               'worstSupplier_excessRainEmp', 'largestSupplier_excessRainEmp', 'wtdSupplier_excessRainEmp',
               'worstSupplier500k_excessHeat90PlusEmp', 'largestSupplier500k_excessHeat90PlusEmp', 'wtdSupplier500k_excessHeat90PlusEmp',
               'worstSupplier500k_excessRainEmp', 'largestSupplier500k_excessRainEmp', 'wtdSupplier500k_excessRainEmp',
               'worstSupplier_excessRain','worstSupplier_excessHeat90Plus'), ~replace_na(.,-500))

goodsData <- goodsData[complete.cases(goodsData$empMx_temp_zipQuarter_95) & 
                         
                         complete.cases(goodsData$revNormd) &
                         complete.cases(goodsData$costNormd) &
                         complete.cases(goodsData$opIncNormd) & 
                         
                         
                         complete.cases(goodsData$revNormd_take2) &
                         complete.cases(goodsData$costNormd_take2) &
                         complete.cases(goodsData$lnOpIncNormdAf_take2) &
                         
                         complete.cases(goodsData$lnRev) &
                         complete.cases(goodsData$lnCost) &
                         complete.cases(goodsData$lnStockClose) &
                         
                         complete.cases(goodsData$gvkey), ]

dim(goodsData)


freqWeights = goodsData %>%
  count(indGroup, sizeTercile) %>%
  mutate(freq = round(n / sum(n), 4)) %>% select(-n) %>% merge(
    (goodsData %>% filter(isSupplier == "True") %>%
       count(indGroup, sizeTercile) %>%
       mutate(freq = round(n / sum(n), 4)) %>% 
       select(-n) %>% rename(freqSuppliers = freq))) %>% 
  mutate(pweights = freq/freqSuppliers) %>% select(-c(freq,freqSuppliers))

# freqWeights2 = goodsData %>%
#   count(indGroup) %>%
#   mutate(freq = round(n / sum(n), 4)) %>% select(-n) %>% merge(
#     (goodsData %>% filter(isSupplier == "True") %>%
#        count(indGroup) %>%
#        mutate(freq = round(n / sum(n), 4)) %>% 
#        select(-n) %>% rename(freqSuppliers = freq))) %>% 
#   mutate(pweights2 = freq/freqSuppliers) %>% select(-c(freq,freqSuppliers))

goodsData = goodsData %>% merge(freqWeights, how = 'left') %>% select(-contains('_supplier_'), 
                                                                      -contains('_supplier500k_')) %>% filter(!(gsectorDesc %in% c('Communication Services',
                                                                                                                                   'Real Estate')))



write.csv(goodsData,"data/companyData/goodsData_withLags_large.csv")

dim(goodsData)


goodsData = goodsData %>% merge(freqWeights, how = 'left') %>% select(-contains('lag'),
                                                                      -contains('empWt_'),
                                                                      -contains('empMx_'),
                                                                      # -contains('50'),
                                                                      -contains('_95'),
                                                                      -contains('95_'),
                                                                      # -contains('99'),
                                                                      -contains('_supplier_'), 
                                                                      -contains('_supplier500k_')) %>% filter(!(gsectorDesc %in% c('Communication Services',
                                                                                                                              'Real Estate')))


dim(goodsData)

write.csv(goodsData,"data/companyData/goodsData_0328.csv")



nonServices = goodsData %>% filter(!(ggroupDesc %in% c('Commercial  & Professional Services',
                                                       "Diversified Financials", "Banks", "Insurance")))
write.csv(nonServices,"data/companyData/goodsData_0320_nonservices.csv")

write.csv(goodsData[goodsData$isSupplier == 'True',],"data/companyData/supplierGoodsData.csv")


#################
subset = goodsData %>%
  select(opIncNormd, opInc_afDep, earliestYear, assetsLast, quarterly_avg_temp, quarterly_avg_precip) %>% mutate(opIncNormd = opIncNormd*100)
names(subset) <- gsub(x = names(subset), pattern = "_", replacement = ".")  
subset = subset %>% mutate(quarterly.avg.temp = quarterly.avg.temp*9/5 + 32) 
df.sum <- subset %>%  summarise_each(funs(Min. = min, 
                      Q05 = quantile(., 0.05),
                      Q33 = quantile(., 0.33), 
                      Median = median, 
                      Q66 = quantile(., 0.66),
                      Q95 = quantile(., 0.95),
                      Max. = max,
                      Mean = mean, 
                      'Std Dev.' = sd))

# the result is a wide data frame
dim(df.sum)

# reshape it using tidyr functions
rowOrder = c('opInc.afDep', "assetsLast","opIncNormd",  "earliestYear",'quarterly.avg.precip','quarterly.avg.temp')

df.stats.tidy <- df.sum %>% gather(stat, val) %>%
  separate(stat, into = c("var", "stat"), sep = "_") %>%
  spread(stat, val) %>% format(digits=2,scientific = FALSE) %>% # select(var, min, q33, median, q66, max, mean, sd) %>%
  slice(match(rowOrder,var)) %>% mutate(var = c('Operating Income (mn. $)', 'Assets (mn. $)','Operating Income over Assets', 'First Year Public',
                                                'Quarterly Avg. Rainfall (mm)', 'Quarterly Avg. Temperature (C)')) %>% 
  rename(' ' = var) %>% select(" ", 'Q05', "Q33", "Median", "Q66",'Q95', 'Mean',"Std Dev.")
write.csv(df.stats.tidy,"data/companyData/summaryStats.csv")


indCounts = goodsData %>% count(gsectorDesc) %>% mutate(n = n/dim(goodsData)[1]*100) %>% format(digits=2,scientific = FALSE) %>% t()
rownames(indCounts) = c('Industry','% Companies')
indCounts[1,] <- c('Cons. Discret.', 'Cons. Staples', 'Energy', 'HealthCare', 'Industrials', 'I.T.','Materials','Utilities')
indCounts <- noquote(indCounts)
write.csv(indCounts,"data/companyData/indCounts.csv")

