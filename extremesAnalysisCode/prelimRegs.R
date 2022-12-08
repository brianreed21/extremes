library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies); library(sjPlot); library(margins)
library(broom); library(fixest)


setwd("~/Documents/supplyChain")

goodsData <- read.csv("data/companyData/goodsData_withIndDefs.csv") 

print(colnames(goodsData)) 


##############################################
# overall
regressors = c('lnOpIncNormd') # ,'lnRevNormd')
weathers   = c('excessHeat', 'excessHeatEmp','excessHeatMax', 'excessHeat90Plus','extremeHeatQuarterly',
               'excessRain', 'excessRainEmp','excessRainMax', 'excessRainNational', 'extremePrecipQuarterly')


results = data.frame()
index = 1
industry = 'indGroup'

start = Sys.time()
for (regressor in regressors){
  for (weather in weathers){
    print(weather)
    
    formula = as.formula(paste0(regressor, '~', weather, ' + factor(', industry, ') + factor(gvkey) + factor(indSeason) + factor(yearQtr) ', ' | 0 | 0 | gvkey'))
    firstTake = felm( formula, data = goodsData %>% filter(qtr = quarter))
    
    
    results[index,'weather']   = weather
    results[index,'regressor'] = regressor
    
    results[index,'coeffs']    = coef(firstTake)[weather]
    results[index,'pvals']     = tidy(firstTake) %>% filter(term == weather) %>% pull(p.value) 

    results[index,'industryDef'] = industry
    results[index,'industry'] = "all"
    
    
    results[index, 'n'] = dim(goodsData)[1]
    print(results)
    
    index = index + 1 

    print(Sys.time())
    print(Sys.time() - start)
    
    write.csv(results,"extremes/results/resultsAll.csv")
  }
}

#############################
# by quarter
results = data.frame()
index = 1
industry = 'indGroup'

regressors = c('lnOpIncNormd') # ,'lnRevNormd')
weathers   = c('excessHeat', 'excessRain', 'excessHeat90Plus', 'extremeHeatQuarterly','extremePrecipQuarterly')

start = Sys.time()
for (weather in weathers){
  for (quarter in c(1,2,3,4)){
    print(quarter)
    
    for (regressor in regressors){
      print(weather)
      
      formula = as.formula(paste0(regressor, '~', weather, ' + factor(', industry, ') + factor(gvkey) + factor(indGroup) + factor(year)', ' | 0 | 0 | gvkey'))
      firstTake = felm( formula, data = goodsData %>% filter(qtr == quarter))
      
      
      results[index,'weather']   = weather
      results[index,'regressor'] = regressor
      
      results[index,'coeffs']    = coef(firstTake)[weather]
      results[index,'pvals']     = tidy(firstTake) %>% filter(term == weather) %>% pull(p.value) 
      
      results[index,'industryDef'] = industry
      results[index,'industry'] = "all"
      results[index,'quarter']     = quarter
      
      
      results[index, 'n'] = dim(goodsData %>% filter(qtr == quarter))[1]
      print(results)
      
      index = index + 1 
      
      print(Sys.time())
      print(Sys.time() - start)
      
      write.csv(results,"extremes/results/resultsByQuarter.csv")
    }
  }
}

################################################################################################################
# by industry
results = data.frame()
index = 1
# industry = 'indGroup'

regressors = c('lnOpIncNormd') # ,'lnRevNormd')
weathers   = c('excessHeat', 'excessHeatEmp','excessHeatMax', 'excessHeat90Plus','extremeHeatQuarterly',
               'excessRain', 'excessRainEmp','excessRainMax', 'excessRainNational', 'extremePrecipQuarterly')
industryTypes = c('sic2Desc', 'gsectorDesc', 'ggroupDesc', 'gindDesc', 'gsubindDesc') # c('indGroup',

start = Sys.time()
for (industryType in industryTypes){
  print('*********************************************')
  print(industryType)
  
  for (weather in weathers){
    for (ind in unique(goodsData[,industryType])){
      
      for (regressor in regressors){
        print(weather)
        
        tryCatch({
          formula = as.formula(paste0(regressor, '~', weather, ' + factor(gvkey) + factor(qtr) + factor(yearQtr)', ' | 0 | 0 | gvkey'))
          firstTake = felm( formula, data = goodsData %>% filter(!!as.name(industryType) == ind))
  
          results[index,'weather']   = weather
          results[index,'regressor'] = regressor
          
          results[index,'coeffs']    = coef(firstTake)[weather]
          results[index,'pvals']     = tidy(firstTake) %>% filter(term == weather) %>% pull(p.value) 
          
          results[index,'industryDef'] = industryType
          results[index,'industry']    = ind
          results[index,'quarter']     = "all"
          
          
          results[index, 'n'] = dim(goodsData %>% filter(!!as.name(industryType) == ind))[1]
          print(results)
          
          index = index + 1 
          
          print(Sys.time())
          print(Sys.time() - start)
          
          write.csv(results,"extremes/results/resultsByIndustry_noControls.csv")
        }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
      }
    }
  }
}


#########################################################################################################
# by industry-quarter
results = data.frame()
index = 1
# industry = 'indGroup'

regressors = c('lnOpIncNormd') # ,'lnRevNormd')
weathers   = c('excessHeat', 'excessHeatEmp','excessHeatMax', 'excessHeat90Plus','extremeHeatQuarterly',
               'excessRain', 'excessRainEmp','excessRainMax', 'excessRainNational', 'extremePrecipQuarterly')
industryTypes = c('sic2Desc', 'gsectorDesc', 'ggroupDesc', 'gindDesc', 'gsubindDesc') # c('indGroup',

start = Sys.time()
for (quarter in c(1,2,3,4)){
  

  for (industryType in industryTypes){
    print('*********************************************')
    print(industryType)
    
    for (weather in weathers){
      for (ind in unique(goodsData[,industryType])){
        
        for (regressor in regressors){
          print(weather)
          
          tryCatch({
            formula = as.formula(paste0(regressor, '~', weather, ' + factor(gvkey) + factor(yearQtr)', ' | 0 | 0 | gvkey'))
            firstTake = felm( formula, data = goodsData %>% filter(!!as.name(industryType) == ind & qtr == quarter))
            
            results[index,'weather']   = weather
            results[index,'regressor'] = regressor
            
            results[index,'coeffs']    = coef(firstTake)[weather]
            results[index,'pvals']     = tidy(firstTake) %>% filter(term == weather) %>% pull(p.value) 
            
            results[index,'industryDef'] = industryType
            results[index,'industry']    = ind
            results[index,'quarter']     = quarter
            
            
            results[index, 'n'] = dim(goodsData %>% filter(!!as.name(industryType) == ind & qtr == quarter))[1]
            print(results)
            
            index = index + 1 
            
            print(Sys.time())
            print(Sys.time() - start)
            
            write.csv(results,"extremes/results/resultsByIndustry_noControls.csv")
          }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
        }
      }
    }
  }
}

# by background climate





##############################################################33
# mfx is here
# loop over regressors and weather vars

results = data.frame()
index = 1

regressors = c('lnOpIncNormd') 

industryTypes = c('indGroup', 'sic2Desc', 'gsubindDesc')

weathers   = c('excessRain', 'excessRainEmp', 'extremePrecipQuarterly','excessHeat', 'excessHeatEmp','extremeHeatQuarterly')
# ,'excessHeatMax', 'excessHeat90Plus',
#               'excessRain', 'excessRainEmp','excessRainMax', 'excessRainNational', 'extremePrecipQuarterly')

start = Sys.time()
print(start)

for (industry in industryTypes){
  for (regressor in regressors){
    for (weather in weathers){
      
      
      # goodsData['indQtr'] = paste0(goodsData[industry], goodsData['qtr'])
      
      formula = as.formula(paste0(regressor, '~', weather, '*factor(', industry, ') + factor(gvkey) + factor(qtr)*factor(', industry, ') + factor(yearQtr)', ' | 0 | 0 | gvkey'))
      firstTake = felm( formula, data = goodsData)
      
      print(head(summary(firstTake)$coef))
      print(Sys.time())
      print(Sys.time() - start)
      
      
      results[index,'weather']   = weather
      results[index,'regressor'] = regressor
      
      ind = sort(unique(goodsData[,industry]))[1]
      results[index,'industryDefn'] = industry
      results[index,'industry'] = ind
      results[index,'mfx']      = coef(firstTake)[weather]
      tempVariance  = vcov(firstTake)[weather,weather]
      
      n = table(goodsData[industry])[ind]
      results[index,'s.e.'] = sqrt(tempVariance) #/sqrt(n)
      
      z = results[index,'mfx']/results[index,'s.e.']
      p = 2*pnorm(z)
      results[index,'pval'] = p
      
      index = index + 1
      for (ind in sort(unique(goodsData[,industry]))[2:length(unique(goodsData[,industry]))]){
        
        results[index,'industryDefn'] = industry
        results[index,'industry'] = ind
        
        results[index,'mfx']      = coef(firstTake)[weather] + coef(firstTake)[paste0(weather,':factor(',industry,')',ind)]
        
        tempVariance  = vcov(firstTake)[weather,weather] + 2*vcov(firstTake)[weather,paste0(weather,':factor(',industry,')',ind)] + vcov(firstTake)[paste0('factor(',industry,')',ind),paste0('factor(',industry,')',ind)]
        n = table(goodsData['indGroup'])[ind]
        results[index,'s.e.'] = sqrt(tempVariance) / sqrt(n)
        z = 2*results[index,'mfx']/results[index,'s.e.']
        p = pnorm(z)
        
        results[index,'pval'] = p
        
        results[index,'weather']   = weather
        results[index,'regressor'] = regressor
        
        index = index + 1
      }
      print(results)
      print(Sys.time())
      print(Sys.time() - start)
    }  
  }
}
results

write.csv(results,"/results/results2.csv")

########
regressors = c('lnOpIncNormd') 
industryTypes = c('indGroup', 'sic2Desc', 'gsubindDesc')
weathers   = c('excessRain', 'excessRainEmp', 'extremePrecipQuarterly','excessHeat', 'excessHeatEmp','extremeHeatQuarterly')

regressor         = regressors[1]
weather           = weathers[1]
industry          = industryTypes[1]

formula = as.formula(paste0(regressor, '~', weather, '*factor(', industry, ') + factor(gvkey) + factor(qtr)*factor(', industry, ') + factor(yearQtr)', ' | 0 | 0 | gvkey'))
firstTake = felm( formula, data = goodsData %>% filter(year == 2014))

# https://stats.stackexchange.com/questions/474768/comparing-clustering-of-standard-errors-between-felm-and-feols-functions
library(marginaleffects)
formula = as.formula(paste0(regressor, '~', weather, '*factor(', industry, ') + factor(gvkey) + factor(qtr)*factor(', industry, ') + factor(yearQtr)'))
firstTake = feols(formula, data = goodsData %>% filter(year == 2014), cluster = ~ gvkey)
marginaleffects(firstTake, by = industry, variables = weather)


