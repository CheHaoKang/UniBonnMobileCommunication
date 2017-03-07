# 2-1 network topology
###Draw igraph in separate plots###
library(igraph) # Load the igraph package

data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);

numberConverter <- function(x) {
	if(x==10) {
        return ("10")
	}
    else {
        return (paste('0', toString(x), sep = ""))
    }
}

timeBase=700
for(percent in 1:10) {
	time = percent*timeBase
	timeStamp_percent<- subset(data, (data$timestamp<=time))

	mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", "Practical_1", "percentEvolution", paste(percent*timeBase, ".png", sep=""))
	png(file=mypath, 1500, 900)

	node<-c()
	link<-list()
	for(i in 1:10) {
		sourceAddr = paste("192.168.2.1", numberConverter(i), sep = "")
		if(sourceAddr!="192.168.2.104")
		    node<-c(node, sourceAddr)

		for(j in (i+1):10) {
			if(i==j)
				next

			destAddr = paste("192.168.2.1", numberConverter(j), sep = "")
			lqFirstDirection<- timeStamp_percent$lq[which(timeStamp_percent$ip==sourceAddr & timeStamp_percent$neighbor==destAddr)]
			lqSecondDirection<- timeStamp_percent$lq[which(timeStamp_percent$ip==destAddr & timeStamp_percent$neighbor==sourceAddr)]
			lqBidirection<-c(lqFirstDirection, lqSecondDirection)

			if(length(lqBidirection)==0).
				next

			link$node1<-c(link$node1, sourceAddr)
			link$node2<-c(link$node2, destAddr)
			link$mean<-c(link$mean, mean(lqBidirection))
			if(mean(lqBidirection) <= 0.33)
				link$level<-c(link$level, 1)
			else if(mean(lqBidirection) > 0.66)
				link$level<-c(link$level, 3)
			else
				link$level<-c(link$level, 2)
		}
	}

	nodeDataFrame<-data.frame(node)
    # node
	# 1 192.168.2.101
	# 2 192.168.2.102
	# 3 192.168.2.103
	# 4 192.168.2.105
	# 5 192.168.2.106
	# 6 192.168.2.107
	# 7 192.168.2.108
	# 8 192.168.2.109
	# 9 192.168.2.110
	linkDataFrame<-data.frame(link)
    # node1         node2       mean level
	# 1  192.168.2.101 192.168.2.102 0.11889749     1
	# 2  192.168.2.101 192.168.2.103 0.62787968     2
	# 3  192.168.2.101 192.168.2.105 0.02158713     1

	net <- graph_from_data_frame(d=linkDataFrame, vertices=nodeDataFrame, directed=F)
	colors <- c("black", "orange2", "limegreen")
	V(net)$color <- "orchid1"
	E(net)$width <- E(net)$mean*12
	E(net)$color <- colors[E(net)$level]
	plot(net, edge.arrow.size=.4, vertex.label.cex=1.2, edge.curved=.1, layout = layout.circle, main=paste("Time period: 0~", timeBase*percent, " seconds(", percent*10, "%)", sep = ""))
	legend(x=0.9, y=-0.5, c("High Link Quality", "Medium Link Quality", "Low Link Quality"), pch="-",
		col=rev(colors), pt.cex=2, cex=1.0, bty="n", ncol=1, xpd = TRUE)
	dev.off()
}


#2-2 link quality separated by percents
library(package = "lattice");
library(quantreg)
data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header=T)
attach(data)
mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", "percentageLinkQuality.png")
png(file=mypath, 1500, 900)
xyplot(lq~timestamp|ip+neighbor, data=data, xlim=c(0, 7000), ylim = c(0, 1), type="b", 
		xlab="Time Stamp(seconds)", ylab="Link Quality", 
		scales=list(x=list(at=seq(0, 7000, 1400)), y=list(at=seq(0, 1, 0.2))),
		panel = function(x,y, ...) {
			panel.xyplot(x, y, ...)

			start = 700
			for(i in 1:10) {
				panel.abline(v=i*start)
			}
		})
dev.off()
