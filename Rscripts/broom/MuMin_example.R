## MuMIn package examples
## code and sample data from https://sites.google.com/site/rforfishandwildlifegrads/home/mumin_usage_examples
## Feb 21 2016


# download the file directly from the website
dater<-read.csv("https://sites.google.com/site/rforfishandwildlifegrads/home/mumin_usage_examples/Example%20data.csv?attredirects=0&d=1")
# or read in downloaded  datafile
#dater<-read.csv("Example data.csv")

# what's in the data
head(dater)

# the data includes 3 response variables count, density and presence
# and 5 explanitory variables: elev (elevation), slope (gradient),
# area, distance (to nearest population), and pct.cover (% cover)

# make sure all numeric values and no missing
summary(dater)

# load the MUMIn package
library(MuMIn)

# this changes the global options for how to handle 
# missing data. It indicates that a function will not work
# if data are missing. This is required if you use the "dredge"
# function below
options(na.action = "na.fail")

#First, fit 4 candidate models to explain  variation in density 
# using ordinary linear regression
mod1<-lm(density~distance+elev, data = dater)
mod2<-lm(density~slope+pct.cover, data = dater)
mod3<-lm(density~slope+distance, data = dater)
mod4<-lm(density~slope+distance+elev, data = dater)

# use the mod.sel function to conduct model selection
# and put output into object out.put
out.put<-model.sel(mod1,mod2,mod3,mod4)
# what's it look like, hmm AIC with small sample bias adjustment AICc
# delta AICc, and the model weights
out.put

# we can create a confidence set of models using the 
# subset command E.G.,
# select models with delta AICc less than 5
# IMPORTANT: Weights have been renormalized!!
subset(out.put, delta <5)

# select models using Royall's 1/8 rule for strength of evidence
# IMPORTANT: Weights have been renormalized!!
subset(out.put, 1/8 < weight/max(out.put$weight))

# select models 95% cumulative weight criteria
# IMPORTANT: Weights have been renormalized!!
subset(out.put, cumsum(out.put$weight) <= 0.95)

# to write the model selection to a table requires
# that you coerce the object out.put into a data frame
# elements 6-10 in out.put have what we want
sel.table<-as.data.frame(out.put)[6:10]
sel.table
# a little clean-up, lets round things a bit
sel.table[,2:3]<- round(sel.table[,2:3],2)
sel.table[,4:5]<- round(sel.table[,4:5],3)
# thats better
sel.table
# how about a little renaming columns to fit proper conventions
# df should be K
names(sel.table)[1] = "K"
## lets be sure to put the model names in a column
sel.table$Model<-rownames(sel.table)
# replace Model name with formulas little tricky so be careful
for(i in 1:nrow(sel.table)) sel.table$Model[i]<- as.character(formula(paste(sel.table$Model[i])))[3]
# let's see what is in there
sel.table
#little reordering of columns
sel.table<-sel.table[,c(6,1,2,3,4,5)]
sel.table

# write to a file, here a comma seperated values format
# make sure your working directory is properly specified
write.csv(sel.table,"My model selection table.csv", row.names = F)
?write.csv

# The default model selection is AICc, but we can specify a
# variety of model selection criteria BIC
mod.sel(mod1,mod2,mod3,mod4, rank = BIC)
#consistent AIC with Fishers information matrix
mod.sel(mod1,mod2,mod3,mod4, rank = CAICF)

# There also are functions for calculating model selection criteria 
# Mallows Cp (ad hoc model selection criteria, not recommended)
Cp(mod4)
#AIC
AIC(mod1,mod2)
# CAICF
CAICF(mod1, mod2)

# Importance weights for individual predictor variables
# can be calculated using the importance function
importance(out.put)

# plenty of evidence for distance and elev (weights close to one), 
# but much less for pct.cover. The latter is in only 1 model so 
# interpret weights with caution

#' MuMIn also calculates model averaged parameter estimates
#' using the model.avg function. Here you have several options
#' most importantly is "revised.var" ALWAYS USE IT.

# Model average using all candidate models
MA.ests<-model.avg(out.put, revised.var = TRUE)
MA.ests

# Here are the beta hat bar MA estimates, standard erors, you want 
# the Adjusted SE and upper and lower CL
MA.ests$avg.model

#Here are the beta tilda bar MA estimates
MA.ests$coef.shrinkage

# you can also obtain importance weights for individual params
MA.ests$importance

#create model averaged estimates for parameters in confidence set of  
# models only using subset command
MA.ests<-model.avg(out.put, subset= delta < 5, revised.var = TRUE)
MA.ests$avg.model

# lets clean up a bit and write to a file
MA.est.table<-round(MA.ests$avg.model[,c(1,3:5)],6)
MA.est.table

## write to a CSV file
write.csv(MA.est.table, "My model averaged estimates.csv")

#extract parameters and weights from confidence model set
# using get.models function
pred.parms<-get.models(out.put, subset= delta < 5)

# predict values using each model, here were just using the
# the example dataset, you could use a new dataset
model.preds = sapply(pred.parms, predict, newdata = dater)
model.preds

# weight the prediction from each model by its AIC weight
# the Weights function extracts the weights
# we also are using matrix multiplication %*%
mod.ave.preds<-model.preds %*% Weights(out.put)
mod.ave.preds

# more interesting application of model averaging for plotting
# create a dataset where everything but elevation is set at its mean value
elev=c(min(dater$elev):max(dater$elev))
plotdata<-as.data.frame(lapply(lapply(dater[5:8],mean),rep,length(c(min(dater$elev):max(dater$elev)))))
plotdata<-cbind(elev,plotdata)
# now predict density for the plot data with each model
model.preds = sapply(pred.parms, predict, newdata = plotdata)
# weight the prediction from each model by its AIC weight
# and sum (matrix multiplication)
mod.ave4plot<-model.preds %*% Weights(out.put)

# plot the model averaged predicted densities vs elevation
plot(mod.ave4plot~ elev, type = 'l', xlab="Elevation (m)", ylab="Model averaged predicted density")

## FOR EXPLORATORY PURPOSES ONLY!!! NEVER EVER DO THIS FOR A REAL
## STUDY

# fit model with all parameters
all.parms<-lm(density~slope+distance+elev+ pct.cover, data = dater)

# the dredge function fits all combinations
# on the variables in the all.parms model fit above
results<-dredge(all.parms)
results
# grab best suppported models
subset(results, delta <5)

#grab best model
subset(results, delta == 0)

# calculate variable importance weights
importance(results)

# use another model selection criteria
results<-dredge(all.parms, rank = BIC)
results

# only allow a maximum of 3 and minimum of 1 parameters in each model
results<-dredge(all.parms,m.max =3, m.min = 1)
results

# fit all models but do not include models with both slope and elevation
results<-dredge(all.parms, subset= !(slope && elev))
results

# include elevation in all models
results<-dredge(all.parms,fixed =c("elev"))
results

# objectes created with dredge can also be used to 
# create model averged parameters
MA.ests<-model.avg(results, subset= delta < 2, revised.var = TRUE)
MA.ests$avg.model



# fit global poisson regression model 
global.mod<-glm(count~area+distance+elev+ slope, data = dater, family = poisson)
summary(global.mod)

# calculate c-hat to evaluate model assumptions, > 1 mean overdispersion
chat<-sum(residuals(glob.mod,"pearson")^2)/glob.mod$df.residual
chat

# fit global quasipoisson regression model 
global.mod<-glm(count~area+distance+elev+ slope, data = dater, family = quasipoisson)
summary(global.mod)

modl2<-glm(count~area+slope, data = dater, family = quasipoisson)
modl3<-glm(count~area+distance, data = dater, family = quasipoisson)
modl4<-glm(count~area+elev, data = dater, family = quasipoisson)

# try model selection with quasi AICc be sure to supply the 
# chat of the global model
quasi.MS<-model.sel(global.mod,modl2,modl3,modl4, rank = QAICc, rank.args = alist(chat = chat))
## lets see what we got
as.data.frame(quasi.MS)

# This is needed to get the likelihood and calculate QAICc
x.quasipoisson <- function(...) {
  res <- quasipoisson(...)
  res$aic <- poisson(...)$aic
  res
}

# update the models so you can get the log likelihood
global.mod<-update(global.mod,family = "x.quasipoisson")
modl2<-update(modl2,family = "x.quasipoisson")
modl3<-update(modl3,family = "x.quasipoisson")
modl4<-update(modl4,family = "x.quasipoisson")

# now conduct model selection
quasi.MS<-model.sel(global.mod,modl2,modl3,modl4, rank = QAICc, rank.args = alist(chat = chat))
as.data.frame(quasi.MS)

## get the best model
subset(quasi.MS, delta == 0)

# yes, dredge works but only on updated model
dredge(global.mod, rank = "QAICc", chat = chat)

require(lme4)

## read data directly from website
trout<-read.csv("http://sites.google.com/site/rforfishandwildlifegrads/home/week-8/Westslope.csv?attredirects=0&d=1")
## or read downloaded file
# trout<-read.csv("Westslope.csv")

#lets see what is in the file
head(trout)

# the data contains presence and absence data from streams in 
#watersheds within Interior Columbia River Basin. The file contains 
#the following data:
#PRESENCE- species presence (1) or absence(0)
#WSHD - Watershed ID
#SOIL_PROD - percent of watershed with productive soils
#GRADIENT- gradient (%) of the stream
#WIDTH- Mean width of the stream in meters


## fit logistic regression with random effect output to H.logit
model1 <-glmer(PRESENCE ~ SOIL_PROD + GRADIENT + WIDTH + (1|WSHD),data = trout, family = binomial)
summary(model1)
# fit remaining candidate models
model2 <-glmer(PRESENCE ~ GRADIENT + WIDTH + (1|WSHD),data = trout, family = binomial)
model3 <-glmer(PRESENCE ~ SOIL_PROD + (1|WSHD),data = trout, family = binomial)
model4 <-glmer(PRESENCE ~ SOIL_PROD + WIDTH + (1 + SOIL_PROD|WSHD),data = trout, family = binomial)
model5 <-glmer(PRESENCE ~ SOIL_PROD + WIDTH + (1 |WSHD),data = trout, family = binomial)


# conduct model selection using BIC
my.models<-model.sel(model1,model2,model3,model4,model5,rank=BIC)
my.models
# calculate importance weights
importance(my.models)

## yes dredge works here too, yikes!
dredge(model1, rank = BIC)





