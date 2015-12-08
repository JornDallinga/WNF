# Installing packages
if (!require(raster)) install.packages('raster')
if (!require(RCurl)) install.packages('RCurl')

# Loading packages
library(raster)
library(RCurl)

Download_WWF(data = 'Forest Cover', year = 2000, mydir = 'data')
Download_WWF(data = 'MODIS Mosaic.overviews', year = 'MODIS2005.Overviews', mydir = 'data/MODIS_MOSAIC')
