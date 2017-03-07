#1-1 all
data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);
library(package = "lattice");

mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", paste("all.png", sep = ""))
png(file=mypath, 1500, 900)
xyplot(lq ~ timestamp | ip + neighbor, xlab="Time Stamp(seconds)", ylab="Link Quality", data=sample)
detach(data);
dev.off()

#1-2 Mean
data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);
library(package = "lattice");

mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", paste("mean.png", sep = ""))
png(file=mypath, 1500, 900)
xyplot(lq ~ timestamp | ip + neighbor, xlab="Time Stamp(seconds)", ylab="Link Quality", data=sample, panel =
function(x,y, ...) {
	panel.xyplot(x, y, ...)
	panelMean<-mean(y)
	panel.abline(h=panelMean, col=3)
	partPanelMean<-substr(panelMean,0,6)
	panel.text(3750,1.0, col=3, labels=paste("Mean:", partPanelMean))
})
detach(data);
dev.off()

#1-3 Median
data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);
library(package = "lattice");

mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", paste("median.png", sep = ""))
png(file=mypath, 1500, 900)
xyplot(lq ~ timestamp | ip + neighbor, xlab="Rearranged Time Stamp(seconds)", ylab="Link Quality", data=sample, panel =
function(x,y, ...) {
	y<-y[order(y)]
	panel.xyplot(x, y, ...)
	panelMedian<-median(y)
	panel.abline(h=panelMedian, col=6)
	partPanelMedian<-substr(panelMedian,0,6)
	panel.text(3750,1.0, col=6, labels=paste("Median:", partPanelMedian))
})
detach(data);
dev.off()

#1-4 Quantile
data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);
library(package = "lattice");
library(quantreg)

mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", paste("quantile.png", sep = ""))
png(file=mypath, 1500, 900)
xyplot(lq ~ timestamp | ip + neighbor, xlab="Rearranged Time Stamp(seconds)", ylab="Link Quality", data=sample, panel =
function(x,y, ...) {
	panel.xyplot(x, y, ...)
	q25<-rq(y~x, .25) 
	q50<-rq(y~x, .50) 
	q75<-rq(y~x, .75) 
	panel.abline(q25, col="orange3")
	panel.abline(q50, col="mediumorchid4")
	panel.abline(q75, col="darkred")

	panelQuantile <- quantile(y)
	panel.text(3750, 1.0, col="darkred", labels=paste("75% quantile:", panelQuantile[4]))
	panel.text(3750, 0.8, col="mediumorchid4", labels=paste("50% quantile:", panelQuantile[3]))
	panel.text(3750, 0.6, col="orange3", labels=paste("25% quantile:", panelQuantile[2]))	
})
detach(data);
dev.off()
