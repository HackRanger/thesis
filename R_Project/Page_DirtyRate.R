library("TTR")
BASE='/Users/subramanya/Workspace/LiveMigration/R_Project';
benchmarks = c( "gromacs", "namd", "sphinx3","GemsFDTD", "omnetpp", "astar", "milc","soplex" , "mcf","zeusmp")
header = c("Date","Time","PageDirty");
opar <- par(no.readonly=TRUE);
par(mfrow=c(5,2))
par(mar=c(1,1,1,1))
pdf("mygraph_page_dirty.pdf")
cl <- rainbow(11);
ch <- seq(1:10);
i=1;
for(bench in benchmarks)
{
	pagedirty = read.csv(paste(BASE, "/Dataset/70MB/Wuotan/", "checkmem_",bench,"70" ,".csv", sep=""),  sep=",",header = F,fill=T,col.names=header);
	plot(ts(pagedirty$PageDirty/4),main=paste("Page Dirty Rate for ",bench,sep=""),col=cl[i],xlab="Time in seconds",ylab="Number of Pages Dirtied(Page Size = 4KB)",ylim=c(0,100));
	#abline(mean(ROC(pagedirty$PageDirty)), lwd=1.5, lty=2, col="gray")
	plot(ROC(pagedirty$PageDirty/4));
	i=i+1;
}
par(opar);
dev.off();
