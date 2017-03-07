# Generate topology diagrams

library(igraph) 
fileList=dir("E:/Dropbox/PROGRAMS/Workspce_Python/p_MobileCommunication/Practical_2/test", pattern = "linkCostTable_", full.names = FALSE, ignore.case = TRUE)
fileFullList=dir("E:/Dropbox/PROGRAMS/Workspce_Python/p_MobileCommunication/Practical_2/test", pattern = "linkCostTable_", full.names = TRUE, ignore.case = TRUE)
fileBestList=dir("E:/Dropbox/PROGRAMS/Workspce_Python/p_MobileCommunication/Practical_2/test", pattern = "linkBestRoute_", full.names = TRUE, ignore.case = TRUE)
for (j in 1:length(fileFullList)){
	print (fileFullList[j])
	#data <- read.table("E:/Dropbox/PROGRAMS/Workspce_Python/p_MobileCommunication/Practical_2/test/linkCostTable_1.txt", header = TRUE);
	data <- read.table(fileFullList[j], header = TRUE);
	attach(data);
	data <- data[order(data$From, data$To),]

	node<-c("10.0.0.1", "10.0.0.2", "10.0.0.3", "10.0.0.4", "10.0.0.5", "10.0.0.6")
	#node<-c("10.0.0.6", "10.0.0.5", "10.0.0.4", "10.0.0.3", "10.0.0.2", "10.0.0.1")
	nodeDataFrame<-data.frame(node)

	link<-list()
	link$From<-data$From
	link$To<-data$To
	link$LinkQuality<-data$LinkQuality
	link$NeighborLinkQuality<-data$NeighborLinkQuality
	link$tcEdgeCost<-data$tcEdgeCost

	for(i in 1:length(link$LinkQuality)) {
		if((link$LinkQuality[i]*link$NeighborLinkQuality[i]) < 0.33) {
			link$level<-c(link$level, 1)
		}
		else if((link$LinkQuality[i]*link$NeighborLinkQuality[i]) > 0.66) {
			link$level<-c(link$level, 3)
		} else {
			link$level<-c(link$level, 2)
		}
	}

	linkDataFrame<-data.frame(link)

	data <- data[order(data$From, data$To),]

	print(nodeDataFrame)
	print(linkDataFrame)

	# ## The plotting function
	# eqarrowPlot <- function(graph, layout, edge.lty=rep(1, ecount(graph)),
	#                         edge.arrow.size=rep(1, ecount(graph)),
	#                         vertex.shape="circle",
	#                         edge.curved=autocurve.edges(graph), ...) {
	#   plot(graph, edge.lty=0, edge.arrow.size=0, layout=layout,
	#        vertex.shape="none")
	#   for (e in seq_len(ecount(graph))) {
	#     graph2 <- delete.edges(graph, E(graph)[(1:ecount(graph))[-e]])
	#     plot(graph2, edge.lty=edge.lty[e], edge.arrow.size=edge.arrow.size[e],
	#          edge.curved=edge.curved[e], layout=layout, vertex.shape="none",
	#          vertex.label=NA, add=TRUE, ...)
	#   }
	#   plot(graph, edge.lty=0, edge.arrow.size=0, layout=layout,
	#        vertex.shape=vertex.shape, add=TRUE, ...)
	#   invisible(NULL)
	# }

	print (fileList[j])
	mypath <- file.path("E:","Dropbox","PROGRAMS", "Workspce_Python", "p_MobileCommunication", "Practical_2", "test", "linkCostPics", paste(strsplit(fileList[j], ".", fixed = TRUE)[[1]][1], ".png", sep = ""))
	png(file=mypath, 1600, 800)
	par(mfrow=c(1, 2))

	# layout <- layout.norm(layout, -1, 1, -1, 1)
	net <- graph_from_data_frame(d=linkDataFrame, vertices=nodeDataFrame, directed=TRUE)
	colors <- c("black", "orange2", "limegreen")
	V(net)$color <- "orchid1"
	E(net)
	V(net)
	E(net)$color <- colors[E(net)$level]
	E(net)$width <- E(net)$LinkQuality*E(net)$NeighborLinkQuality*6
	l <- layout.reingold.tilford(net)
	l[1,1] <- -1
	l[1,2] <- -0.8

	l[2,1] <- -0.8
	l[2,2] <- -0.6

	l[3,1] <- -0.4
	l[3,2] <- -0.85

	l[4,1] <- -0.1
	l[4,2] <- -0.85

	l[5,1] <-  0.2
	l[5,2] <- -0.6

	l[6,1] <-  0.6
	l[6,2] <- -0.8
	# l <- layout.norm(l, -10, 10, -10, 10)
	plot(net, edge.arrow.size=2., vertex.label.cex=1.2, edge.curved=.7, layout=l, main=paste("Timestamp: ", data$Timestamp[1], sep = ""))
	legend(x=0.3, y=-1.15, c("High LQ*NLQ (> 0.66)", "Medium LQ*NLQ (< 0.66 & >= 0.33)", "Low LQ*NLQ (< 0.33)"), pch="-",
			col=rev(colors), pt.cex=2, cex=1.0, bty="n", ncol=1, xpd = TRUE)

	# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	data2 <- read.table(fileBestList[j], header = TRUE);
	attach(data2);

	link2<-list()
	link2$From<-data2$From
	link2$To<-data2$To

	link2DataFrame<-data.frame(link2)

	net <- graph_from_data_frame(d=link2DataFrame, vertices=nodeDataFrame, directed=TRUE)
	V(net)$color <- "orchid1"
	E(net)
	V(net)
	E(net)$color <- "blue"
	E(net)$width <- 10
	l <- layout.reingold.tilford(net)
	l[1,1] <- -1
	l[1,2] <- -0.8

	l[2,1] <- -0.8
	l[2,2] <- -0.6

	l[3,1] <- -0.4
	l[3,2] <- -0.85

	l[4,1] <- -0.1
	l[4,2] <- -0.85

	l[5,1] <-  0.2
	l[5,2] <- -0.6

	l[6,1] <-  0.6
	l[6,2] <- -0.8
	# l <- layout.norm(l, -10, 10, -10, 10)
	plot(net, edge.arrow.size=2.8, vertex.label.cex=1.2, edge.curved=1., layout=l, main=paste("Timestamp: ", data$Timestamp[1], "   Cost: ", data2$Cost[1], sep = ""))
	legend(x=0.7, y=-1.15, c("The best route"), pch="-",
			col="blue", pt.cex=2, cex=1.0, bty="n", ncol=1, xpd = TRUE)
	# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

	dev.off()

	#detach(data)
	#Sys.sleep(1)
}
