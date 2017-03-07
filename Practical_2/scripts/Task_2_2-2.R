# Generate the diagram of Throughput and Transferred bytes over time

data <- read.table("E:/Dropbox/PROGRAMS/Workspce_Python/p_MobileCommunication/Practical_2/test/httpMeasurementTable.txt", header = TRUE);
attach(data);
library(package = "lattice");

mypath <- file.path("E:","Dropbox","PROGRAMS", "Workspce_Python", "p_MobileCommunication", "Practical_2", "test", "httpMeasurement.png")
png(file=mypath, 800, 600)

par(mar = c(5,5,2,5))

plot(data$timestamp, data$throughput, xlab="", ylab="", type = "o", col ="blue", axes = FALSE) #, y=list(at=seq(0, 1, 0.2))))
# xticks <- seq(1466413696, 1466600000, 5000)
xticks <- seq(1466541416, 1466560000, 100)
axis(1, at = xticks)
yticks <- seq(0, 10000, 500)
axis(2, at = yticks, labels = yticks, col.axis="blue", las=2)
mtext(side = 2, line = 4, 'throughput (bytes/seconds)', col="blue")
# x <- c(0:250000)
# axis(2, at=x, labels=x, col.axis="red", las=2)

par(new = T)
plot(timestamp, bytes, ylab="", type = "p", lty=4, col ="green4", axes = FALSE)
#plot(timestamp, bytesDropped, ylab="", type = "p", lty=4, col ="green4", axes = FALSE)
mtext(side = 4, line = 3.5, 'bytes', col="green4")
#yticks <- seq(0, 44550000, 5000000)
yticks <- seq(0, 45550000, 5000000)
axis(side = 4, at = yticks, labels = yticks, col.axis="green4", las=2)

dev.off()
