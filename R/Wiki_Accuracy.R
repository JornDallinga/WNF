
# read excel file
df <- read.xlsx("FC_test.xlsx", sheet = 1, startRow = 1, colNames = TRUE)

xy <- df[,c(2,3)]

spdf <- SpatialPointsDataFrame(coords = xy, data = df,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

## assign raster file
ras <- raster('data/cerrado_af_2010_forest_WGS.tif')

# reproject <- projectRaster(from = ras , crs = CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'), method = 'ngb', progress = 'text')


# cropping the points that fall within the raster object
t <- crop(x = spdf, y = ras)






# extract values
test <- extract(x = ras, y = t, method = 'simple', df = T, factors = T)

# add column with data
t$WWF <- test$cerrado_af_2010_forest_WGS
head(t)

# remove NA's
t <- t[complete.cases(t$WWF),]

# subset by date
subsettest <- subset(t, substr(t$Google.image.date, 0, 4) == c('2008', '2010', '2011', '2012'))
#subsettest <- t
# subset by confidence level
subt <- subset(subsettest, subsettest$HI.Confidence <= 30)

# set forest cover threshold
threshold <- 30
mydata <- subt

# criteria for accuracy assessment

mydata$Reference[(subt$LC1 == 1 & subt$LC1_Perc >= threshold) | (subt$LC2 == 1 & subt$LC2_Perc >= threshold) | (subt$LC3 == 1 & subt$LC3_Perc >= threshold) ] <- 1
mydata$Reference[is.na(mydata$Reference)] <- 0









## accuracy assessment

tabletest <- table(mydata$WWF,mydata$Reference)
outcome_points <- confusionMatrix(tabletest)
outcome_points

# report proportional table
tablet <- prop.table(tabletest)

#-------------------------------------------------start of polygon--------------------------------------------------------#

# convert projection system to meters
newData <- spTransform(mydata, CRS("+init=epsg:3857"))

# buffer points
bufferedPoints <- gBuffer(newData,width=500, byid=TRUE, capStyle = 'SQUARE')

# write OGR
#writeOGR(obj=bufferedPoints, dsn="data/output", layer="buffers", driver="ESRI Shapefile")

# reproject to WGS
newData1 <- spTransform(bufferedPoints, CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))



# copy dataset
mypol <- mydata

rs <- as.data.frame(mydata)

# clear of NA's in both coloms
mypol <- mypol[!with(mypol,is.na(forest)& is.na(non_forest)),]


# set threshold for accuracy assessment
mypol$WWF[(mypol$forest >= (threshold/100))] <- 1
mypol$WWF[(mypol$forest < (threshold/100)) | is.na(mypol$forest)] <- 0

# Calculate accuracy for polygons
tabletest <- table(mypol$Ref,mypol$WWF)
outcome_poly <- confusionMatrix(tabletest)
outcome_poly
