#4 Correlation Coefficient http://goo.gl/wbCF0s
# ‧Exactly –1. A perfect downhill (negative) linear relationship
# ‧–0.70. A strong downhill (negative) linear relationship
# ‧–0.50. A moderate downhill (negative) relationship
# ‧–0.30. A weak downhill (negative) linear relationship
# ‧0. No linear relationship
# ‧+0.30. A weak uphill (positive) linear relationship
# ‧+0.50. A moderate uphill (positive) relationship
# ‧+0.70. A strong uphill (positive) linear relationship
# ‧Exactly +1. A perfect uphill (positive) linear relationship

numberConverter <- function(x) {
	if(x==10) {
        return ("10")
	}
    else {
        return (paste('0', toString(x), sep = ""))
    }
}

data <- read.table("E:/Dropbox/University_Bonn/Summer_Semester_2016/Mobile\ Communication/Practical/Assignment_01/lq.dat", header = TRUE);
attach(data);
library(package = "lattice");

for(i in 1:10) {
	sourceAddr = paste("192.168.2.1", numberConverter(i), sep = "")

	for(j in 1:10) {
		if(i==j)
			next

		destAddr = paste("192.168.2.1", numberConverter(j), sep = "")
		column1 <- lq[which(ip==sourceAddr & neighbor==destAddr)]
		column2 <- lq[which(ip==destAddr & neighbor==sourceAddr)]

		if(length(column1)==0 | length(column2)==0)
			next

		if(length(column1) > length(column2))
			finalLength = length(column2)
		else
			finalLength = length(column1)

		mypath <- file.path("E:","Dropbox","PROGRAMS", "R", "R_MoCo", "pairs", paste("192.168.2.1", numberConverter(i), "_", "192.168.2.1", numberConverter(j),".png", sep = ""))
		png(file=mypath, 1500, 900)

		pairData <- data.frame(IP1=column1[1:finalLength], IP2=column2[1:finalLength])
		corCoeff = cor(pairData)
		pairs(pairData, main=paste("The correlation coefficient between 192.168.2.1", numberConverter(i), " and ", "192.168.2.1", numberConverter(j), " is ", corCoeff[2], sep = ""))
		dev.off()
	}
}
