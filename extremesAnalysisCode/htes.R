library(dplyr)       # Data manipulation (0.8.0.1)
library(fBasics)     # Summary statistics (3042.89)
library(corrplot)    # Correlations (0.84)
library(psych)       # Correlation p-values (1.8.12)
library(grf)         # Generalized random forests (0.10.2)
library(rpart)       # Classification and regression trees, or CART (4.1-13)
library(rpart.plot)  # Plotting trees (3.0.6)
library(treeClust)   # Predicting leaf position for causal trees (1.1-7)
library(car)         # linear hypothesis testing for causal tree (3.0-2)
library(remotes)    # Install packages from github (2.0.1)
library(readr)       # Reading csv files (1.3.1)
library(tidyr)       # Database operations (0.8.3)
library(tibble)      # Modern alternative to data frames (2.1.1)
library(knitr)       # RMarkdown (1.21)
library(kableExtra)  # Prettier RMarkdown (1.0.1)
library(ggplot2)     # general plotting tool (3.1.0)
library(haven)       # read stata files (2.0.0)
library(aod)         # hypothesis testing (1.3.1)
library(evtree)      # evolutionary learning of globally optimal trees (1.0-7)
library(estimatr)    # simple interface for OLS estimation w/ robust std errors ()

# For causal trees (Athey and Imbens, 2016)  version 0.0
remotes::install_github('susanathey/causalTree') # Uncomment this to install the causalTree package
library(causalTree)
remotes::install_github('grf-labs/sufrep') # Uncomment this to install the sufrep package
library(sufrep)

########################
setwd("~/Documents/supplyChain")
# generally follow this: https://gsbdbi.github.io/ml_tutorial/hte_tutorial/hte_tutorial.html#part_ii:_policy_evaluation_and_learning
goodsData <- read.csv("data/companyData/goodsData_withIndDefs.csv") goodsData %>% filter(year == 2015)

print(colnames(goodsData)) 
