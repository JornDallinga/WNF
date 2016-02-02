coordstest <- data.frame(c(-0.481505, 111.451592))
coordsystem <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

Spat <- SpatialPoints(data.frame(coordstest[1,1],coordstest[2,1]), proj4string = coordsystem)

# create spatial points
t = cbind(111.451592, -0.481505)

df1 = data.frame(t)
points = SpatialPoints(df1)
proj4string(points) = CRS("+proj=longlat +datum=WGS84")


## testing example function

xc = round(runif(10,-1,1)+27.2, 2) 
yc = round(runif(10,-1,1)+-82.5,2) 
xy = cbind(xc, yc) 
tc = Sys.time() + 3600 * (1:1) 
df = data.frame(z1 = round(5 + rnorm(10), 2), z2 = 20:29)

xy.sp = SpatialPoints(xy) 
proj4string(xy.sp) = CRS("+proj=longlat +datum=WGS84")

# add time stamp
library(spacetime)
ST = STIDF(points, tc, df1)

# plot kml file
library(plotKML) 
plotKML(ST)

