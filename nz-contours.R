
library(maps)
quakes <- read.csv("quakes-mod.csv")
quakes$long <- ifelse(quakes$LONG < 0, 360 + quakes$LONG, quakes$LONG)
quakes <- quakes[quakes$LAT < 0 & quakes$long < 190, ]
library(MASS)
qd <- kde2d(quakes$long, quakes$LAT, n=100)
ql <- contourLines(qd$x, qd$y, qd$z, nlevels=10)
n <- length(ql)
outline <- map("nz", plot=FALSE)
xrange <- range(outline$x, na.rm=TRUE)
yrange <- range(outline$y, na.rm=TRUE)
xbox <- xrange + c(-2, 2)
ybox <- yrange + c(-2, 2)

hue <- 240

####################
## Use paths
par(mar=rep(0, 4))
# Plot the data
map("nz")
mapply(function(c, col) {
           polygon(c, col=col, border=adjustcolor(col, 1, .9, .9, .9))
       },
       ql, as.list(hcl(hue, 50, 20 + 60*n:1/(n+1)))) # grey(.7*n:1/(n+1) + .2)))
polypath(c(outline$x, NA, c(xbox, rev(xbox))),
         c(outline$y, NA, rep(ybox, each=2)),
         col="white", rule="evenodd")


####################
## Use clipping path 
par(mar=rep(0, 4))
# Plot the data
map("nz")
mapply(function(c, col) {
           polygon(c, col=col, border=adjustcolor(col, 1, .9, .9, .9))
       },
       ql, as.list(hcl(hue, 50, 20 + 60*n:1/(n+1)))) # grey(.7*n:1/(n+1) + .2)))
library(gridGraphics)
grid.echo()
outlinePath <- grid.grep("line", grep=TRUE, viewport=TRUE)
outlineGrob <- grid.get(outlinePath)
contourPaths <- grid.grep("polygon", grep=TRUE, global=TRUE)
downViewport(attr(outlinePath, "vpPath"))
clipvp <- editViewport(clip=polygonGrob(outlineGrob$x, outlineGrob$y))
upViewport(0)
for (i in contourPaths) {
    grid.edit(i, vp=clipvp, redraw=FALSE)
}
downViewport(attr(outlinePath, "vpPath"))
grid.draw(outlineGrob)
grid.refresh()

