library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies)


goodsData <- read.csv("data/companyData/goodsData_largestSupplierData_dirEffects.csv") %>% mutate(indQtr = paste0(indGroup,qtr))


############################################
# run regressions across a few of the industries in particular
# add a couple of these: gvkey_calQtr, ageTercile_Qtr, profTercile_Qtr, sizeTercile_Qtr 

# followed https://www.kellogg.northwestern.edu/faculty/petersen/htm/papers/se/se_programming.htm to 
# https://sites.google.com/site/waynelinchang/r-code
summary(felm(lnRevNormd ~ extremePrecip, data = goodsData))
rainResults = list()
rainResults[[1]] = summary(felm(lnOpIncNormd ~ extremePrecip + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
             data = goodsData))$coefficients

rainResults[[2]] = summary(felm(lnRevNormd ~ extremePrecip + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
                       data = goodsData))$coefficients

rainResults[[3]] = summary(felm(lnCostNormd ~ extremePrecip + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
                       data = goodsData))$coefficients

rainResults[[4]] = summary(felm(lnStockClose ~ extremePrecip + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
                       data = goodsData))$coefficients

for (i in 1:(length(rainResults) )){
  print(i)
  rainResults[[i]] = rainResults[[i]][rownames(rainResults[[i]]) == 'extremePrecip',]
}

allRainResults <- do.call(rbind.data.frame, rainResults)
colnames(allRainResults) <- c('coef','cluster s.e.','tvalue','pvalue')



tempResults = list()
tempResults[[1]] = summary(felm(lnOpIncNormd ~ extremeHeat + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
                                data = goodsData))$coefficients

tempResults[[2]] = summary(felm(lnRevNormd ~ extremeHeat + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
                                data = goodsData))$coefficients

tempResults[[3]] = summary(felm(lnCostNormd ~ extremeHeat + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
                                data = goodsData))$coefficients

tempResults[[4]] = summary(felm(lnStockClose ~ extremeHeat + factor(gvkey) + factor(indQtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)| 0 | 0 | gvkey, 
                                data = goodsData))$coefficients

for (i in 1:(length(tempResults) )){
  print(i)
  tempResults[[i]] = tempResults[[i]][rownames(tempResults[[i]]) == 'extremeHeat',]
}

allTempResults <- do.call(rbind.data.frame, tempResults)
colnames(allTempResults) <- c('coef','cluster s.e.','tvalue','pvalue')

