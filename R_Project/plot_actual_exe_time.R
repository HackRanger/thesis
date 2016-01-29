library(ggplot2);
bandwidth = seq(70,100,10);
BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';
rownnames = c("astar", "GemsFDTD", "gromacs", "mcf", "milc", "namd", "omnetpp", "soplex", "sphinx3", "zeusmp");
png(paste(BASE,"/benchmark_acutal_migrationtime.png", sep=""),unit="in",width=20,height=8.5,res=400);
opar <- par(no.readonly=TRUE);
par(mfrow=c(3,2));
header = c("Benchmark","EndDateTime","TotalTime");

exec_time_without_migtation = read.csv(paste(BASE, "/Dataset/Time/actual_exectime/", "without_mgration" ,".csv", sep=""),  sep=";",col.names=header,header = F);
exec_time_without_migtation = exec_time_without_migtation[order(exec_time_without_migtation$Benchmark),];
brpt=barplot(exec_time_without_migtation$TotalTime,names.arg=rownnames, beside=T,xlab="Benchmark", ylab="Execution Time in Seconds",main="Total Execution Time for Benchmark without migrating",ylim=c(0,5000));
text(y= exec_time_without_migtation$TotalTime + 500 , x= brpt, labels=as.character(round(exec_time_without_migtation$TotalTime,2)), ypd=TRUE);
for(bw in bandwidth)
{
	temp = read.csv(paste(BASE, "/Dataset/Time/actual_exectime/", bw ,".csv", sep=""),  sep=";",col.names=header,header = F);
	temp = temp[order(temp$Benchmark),];
	brpt1 = barplot(temp$TotalTime,names.arg=rownnames, beside=T,xlab="Benchmark", ylab="Execution Time in Seconds",main=paste("Total Execution Time for Benchmark with migrating , with network bandwidth of ",bw," MBps",sep=""),ylim=c(0,5000));
	text(y= temp$TotalTime + 500 , x= brpt1, labels=as.character(round(temp$TotalTime,2)), ypd=TRUE)
}

dev.off();
par(opar);

