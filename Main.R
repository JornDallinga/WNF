# Installing packages
if (!require(raster)) install.packages('raster')
if (!require(sp)) install.packages('sp')
if (!require(rgdal)) install.packages('rgdal')
if (!require(RCurl)) install.packages('RCurl')
if (!require(ff)) install.packages('ff')
if (!require(gfcanalysis)) install.packages('gfcanalysis')
if (!require(caret)) install.packages('caret', dependencies = T)

# Loading packages
library(raster)
library(sp)
library(rgdal)
library(RCurl)
library(bitops)
library(gfcanalysis)
library(caret)
library(e1071)


# Load source scripts
source("R/Download_FTP.R")
source("R/Hansen.R")
source("R/WWF.R")
source("R/Extent.R")
source("R/Confusion_matrix.R")

# Create folders
dir.create(file.path('data'), showWarnings = FALSE)
dir.create(file.path('data/Hansen'), showWarnings = FALSE)
dir.create(file.path('data/extract_hansen'), showWarnings = FALSE)


# Set function parameters
data <- 'Forest Cover'
year <- 2005
mydir <- 'data'
threshold <- 30
country <- NULL # or 
country <- 'MYS' # http://en.wikipedia.org/wiki/ISO_3166-1
region <- 'Johor' # Select state/province of country. Use NULL if you wish to use the whole country as extent

# Run functions

## Download WWF data
x <- Download_WWF(data = 'Forest Cover', year = year, mydir = 'data')

## Create extent from selected country
output <- Extent_func(year = year, mydir = mydir, country = country, region = region)

## Forest Cover WWF
WWF_FC <- WWF(x = x, output = output)

## Download and prepare Hansen Forest Cover data
hansen_FC <- Hansen(threshold = threshold, year = year, output = output)

## Confusion matrix for accuracy assessment
Confusion_Matrix(WNF = WWF_FC, Hansen = hansen_FC[1])


#----------------------------------------end of script---------------------------------------#