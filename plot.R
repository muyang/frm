p<-ggplot(df_2, aes(x=car2)) + 
  geom_histogram(color="black", fill="white")

p=p+ geom_vline(aes(xintercept=mean(car2)),
            color="blue", linetype="dashed", size=1) 
ggplot(df, aes(x=bus))+
 geom_histogram(aes(y=..density..), colour="black", fill="white")+
 geom_density(alpha=.2, fill="#FF6666") 

p<-ggplot(df, aes(x=bus2)) + 
  geom_histogram(color="black", fill="white")

p=p+ geom_vline(aes(xintercept=mean(bus2)),
            color="blue", linetype="dashed", size=1) 


##############scatter plot, df2 baseline stat

ggplot(df,aes(x=tick,y=car))+geom_point(shape=1) +geom_smooth()

ggplot(df2, aes(x, y = value, color = variable)) + geom_point(aes(x=tick, y = car, col = "car"))+ geom_point(shape=1,size=0.1) + geom_smooth()+
    geom_point(aes(x=tick, y = car2, col = "car2"))+ geom_point(shape=1,size=0.1)+ geom_smooth()+
    geom_point(aes(x=tick, y = bus, col = "bus"))+ geom_point(shape=1,size=0.1)+ geom_smooth()+
    geom_point(aes(x=tick, y = bus2, col = "bus2"))+ geom_point(shape=1,size=0.1)+ geom_smooth()
####################
library(reshape)
df2=read.table("f:/nlogo/inundated_info.txt","\t",header=T)
df.melted <- melt(df2, id = "tick")
ggplot(data = df.melted, aes(x = tick, y = value, color = variable)) + 
  geom_point(shape=1,size=0.1)+xlab("time: min")+ylab("Number")+stat_smooth()




##########################################
df_engineer=read.table("f:/nlogo/engineer.txt")
x <- df_engineer$drainage
y <- df_engineer$paved
z <- df_engineer$car
# Compute the linear regression (z = ax + by + d)
fit <- lm(z ~ x + y)
# predict values on regular xy grid
grid.lines = 26
x.pred <- seq(min(x), max(x), length.out = grid.lines)
y.pred <- seq(min(y), max(y), length.out = grid.lines)
xy <- expand.grid( x = x.pred, y = y.pred)
z.pred <- matrix(predict(fit, newdata = xy), 
                 nrow = grid.lines, ncol = grid.lines)
# fitted points for droplines to surface
fitpoints <- predict(fit)
# scatter plot with regression plane
scatter3D(x, y, z, pch = 18, cex = 2, bty = "g",
    theta = 20, phi = 20, ticktype = "detailed",
    xlab = "drainage capability", ylab = "paved", zlab = "car",  
    surf = list(x = x.pred, y = y.pred, z = z.pred,  
    facets = NA, fit = fitpoints), main = "Affected car")
############################################
benefit
############################################

df_B_engineer=read.table("f:/nlogo/B_engineer.txt",header=T)
x <- df_B_engineer$drainage
y <- df_B_engineer$paved

z <- df_B_engineer$car
# Compute the linear regression (z = ax + by + d)
fit <- lm(z ~ x + y)
# predict values on regular xy grid
grid.lines = 26
x.pred <- seq(min(x), max(x), length.out = grid.lines)
y.pred <- seq(min(y), max(y), length.out = grid.lines)
xy <- expand.grid( x = x.pred, y = y.pred)
z.pred <- matrix(predict(fit, newdata = xy), 
                 nrow = grid.lines, ncol = grid.lines)
# fitted points for droplines to surface
fitpoints <- predict(fit)
# scatter plot with regression plane
scatter3D(x, y, z, pch = 18, cex = 2, bty = "g",
    theta = 20, phi = 20, ticktype = "detailed",
    xlab = "drainage capability: mm/h", ylab = "runoff coefficient", zlab = "bs:%",  
    surf = list(x = x.pred, y = y.pred, z = z.pred,  
    facets = NA, fit = fitpoints), main = "Affected car")





#############################
library("plot3D")
df_w=read.table("f:/nlogo/bs_warning3.txt",header=T)

x <- df_w$recieve
y <- df_w$warning
z <- df_w$car2
# Compute the linear regression (z = ax + by + d)
fit <- lm(z ~ x + y)
# predict values on regular xy grid
grid.lines = 26
x.pred <- seq(min(x), max(x), length.out = grid.lines)
y.pred <- seq(min(y), max(y), length.out = grid.lines)
xy <- expand.grid( x = x.pred, y = y.pred)
z.pred <- matrix(predict(fit, newdata = xy), 
                 nrow = grid.lines, ncol = grid.lines)
# fitted points for droplines to surface
fitpoints <- predict(fit)
# scatter plot with regression plane
scatter3D(x, y, z, pch = 18, cex = 2, bty = "g",
    theta = 20, phi = 20, ticktype = "detailed",
    xlab = "recieve probability", ylab = "warning time", zlab = "bs",  
    surf = list(x = x.pred, y = y.pred, z = z.pred,  
    facets = NA, fit = fitpoints), main = "Indirectly affected car")



