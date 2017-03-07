# Generate the diagrams of Packet Loss and Round-trip Min/Avg/Max over time

data <- read.table("E:/Dropbox/PROGRAMS/Workspce_Python/p_MobileCommunication/Practical_2/test/pingMeasurementTable.txt", header = TRUE);
attach(data);
library(package = "lattice");

mypath <- file.path("E:","Dropbox","PROGRAMS", "Workspce_Python", "p_MobileCommunication", "Practical_2", "test", "pingMeasurementAVG.png")
png(file=mypath, 800, 600)

par(mar = c(5,5,2,5))

plot(data$timestamp, data$packetloss, xlab="", ylab="", type = "o", col ="blue", axes = FALSE) #, y=list(at=seq(0, 1, 0.2))))
xticks <- seq(1466541400, 1466550000, 100)
axis(1, at = xticks)
yticks <- seq(0, 40, 2)
axis(2, at = yticks, labels = yticks, col.axis="blue", las=2)
mtext(side = 2, line = 3, 'Packet Loss (%)', col="blue")
# x <- c(0:250000)
# axis(2, at=x, labels=x, col.axis="red", las=2)

par(new = T)
plot(timestamp, avg, ylab="", type = "o", lty=4, col ="green4", axes = FALSE)
mtext(side = 4, line = 3, 'round-trip avg (ms)', col="green4")#, adj=0) # adj = 0 means left or bottom alignment
yticks <- seq(0, 100, 5)
axis(side = 4, at = yticks, labels = yticks, col.axis="green4", las=2)

dev.off()


mypath <- file.path("E:","Dropbox","PROGRAMS", "Workspce_Python", "p_MobileCommunication", "Practical_2", "test", "pingMeasurementMIN.png")
png(file=mypath, 800, 600)

par(mar = c(5,5,2,5))

plot(data$timestamp, data$packetloss, xlab="", ylab="", type = "o", col ="blue", axes = FALSE) #, y=list(at=seq(0, 1, 0.2))))
xticks <- seq(1466541400, 1466550000, 100)
axis(1, at = xticks)
yticks <- seq(0, 40, 2)
axis(2, at = yticks, labels = yticks, col.axis="blue", las=2)
mtext(side = 2, line = 3, 'Packet Loss (%)', col="blue")
# x <- c(0:250000)
# axis(2, at=x, labels=x, col.axis="red", las=2)

par(new = T)
plot(timestamp, min, ylab="", type = "o", lty=4, col ="green4", axes = FALSE)
mtext(side = 4, line = 3, 'round-trip min (ms)', col="green4")#, adj=0) # adj = 0 means left or bottom alignment
yticks <- seq(0, 100, 5)
axis(side = 4, at = yticks, labels = yticks, col.axis="green4", las=2)

dev.off()


mypath <- file.path("E:","Dropbox","PROGRAMS", "Workspce_Python", "p_MobileCommunication", "Practical_2", "test", "pingMeasurementMAX.png")
png(file=mypath, 800, 600)

par(mar = c(5,5,2,5))

plot(data$timestamp, data$packetloss, xlab="", ylab="", type = "o", col ="blue", axes = FALSE) #, y=list(at=seq(0, 1, 0.2))))
xticks <- seq(1466541400, 1466550000, 100)
axis(1, at = xticks)
yticks <- seq(0, 40, 2)
axis(2, at = yticks, labels = yticks, col.axis="blue", las=2)
mtext(side = 2, line = 3, 'Packet Loss (%)', col="blue")
# x <- c(0:250000)
# axis(2, at=x, labels=x, col.axis="red", las=2)

par(new = T)
plot(timestamp, max, ylab="", type = "o", lty=4, col ="green4", axes = FALSE)
mtext(side = 4, line = 3, 'round-trip max (ms)', col="green4")#, adj=0) # adj = 0 means left or bottom alignment
yticks <- seq(0, 1100, 100)
axis(side = 4, at = yticks, labels = yticks, col.axis="green4", las=2)

dev.off()
