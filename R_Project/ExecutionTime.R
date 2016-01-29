BASE='/Users/subramanya/Workspace/LiveMigration/R_Project';
benchmarks = c( "gromacs", "namd", "sphinx3", "soplex" , "mcf", "GemsFDTD", "omnetpp", "astar", "milc")
header = c("Benchmark","StartDateTime","EndDateTime","TotalTime");

#Execution time with out migration
exec_time = read.csv(paste(BASE, "/Dataset/without_migration/", "zeusmp" ,".csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in benchmarks)
{
	temp1 = read.csv(paste(BASE, "/Dataset/without_migration/", bench ,".csv", sep=""),  sep=",",col.names=header,header = F);
	exec_time= rbind(exec_time,temp1); 
}

# Execution time with migration at 70MB/s
exec_time70 = read.csv(paste(BASE, "/Dataset/70MB/Time/", "zeusmp", "70",  ".csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in benchmarks)
{
	cat(paste("Read ",BASE, "/Dataset/70MB/Time/", bench, "70",  ".csv \n",sep = ""));
	temp2 = read.csv(paste(BASE, "/Dataset/70MB/Time/", bench , "70",  ".csv", sep=""),  sep=",",col.names=header,header = F);
	exec_time70 = rbind(exec_time70,temp2);	
}
#exec_time70 = rbind(exec_time70,exec_time);
write.csv(exec_time70, file = paste(BASE, "/Dataset/70MB/Time/", "Exec_Time", ".csv", sep=""));
opar <- par(no.readonly=TRUE);
par(mfrow=c(2,2))
# ph Specifies the symbol to use when plotting points
pdf("execution_time.pdf")
# lty Specifies the line type, lwd Specifies the line width
#par(lty=2, pch=17,font.lab=3, cex.lab=0.5, font.main=4, cex.main=0.7);
barplot(exec_time$TotalTime,names.arg=exec_time$Benchmark, beside=T,xlab="Benchmark", ylab="Execution Time in Seconds",main="Total Execution Time for Benchmark without migrating",ylim=c(0,5000));
barplot(exec_time70$TotalTime,names.arg=exec_time70$Benchmark,beside=T, xlab="Benchmark", ylab="Execution Time in Seconds",main="Total Execution Time for Benchmark While Migration at 70Mb/s bandwidth",ylim=c(0, 5000));
dev.off();
par(opar);
