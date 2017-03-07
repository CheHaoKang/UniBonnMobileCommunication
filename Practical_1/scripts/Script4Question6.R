#6 Histogram
data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);
library(package = "lattice");

data_102_108 <- lq[which(ip=="192.168.2.102" & neighbor=="192.168.2.108")]
data_103_108 <- lq[which(ip=="192.168.2.103" & neighbor=="192.168.2.108")]

mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", "Histogram.png")
png(file=mypath, 1500, 900)
par(mfrow=c(1,2))
hist(data_102_108, main="Histogram of 102-108", xlab="Link Quality")
hist(data_103_108, main="Histogram of 103-108", xlab="Link Quality")
dev.off()
