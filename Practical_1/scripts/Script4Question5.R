#5 boxplot - plot
data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);
library(package = "lattice");

ips=c("101", "102", "102", "108", "107", "110")

i <- 1
while(i < length(ips)) {
	mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", paste("boxplot_", ips[i], "_", ips[i+1], ".png", sep=""))
	png(file=mypath, 1500, 900)
	par(mfrow=c(1,2))

	sourceAddr = paste("192.168.2.", ips[i], sep = "")
	destAddr = paste("192.168.2.", ips[i+1], sep = "")
	Xdata <- timestamp[which(ip==sourceAddr & neighbor==destAddr)]
	Ydata <- lq[which(ip==sourceAddr & neighbor==destAddr)]

	boxplot(Ydata, main=paste("Boxplot of ", ips[i], "-", ips[i+1], sep=""))
	plot(Ydata~Xdata, xlab="Time Stamp(seconds)", ylab="Link Quality", main=paste("Plot of ", ips[i], "-", ips[i+1], sep=""))

	dev.off()

	i = i + 2
}
