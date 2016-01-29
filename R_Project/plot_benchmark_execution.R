BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';
benchmarks = c( "zeusmp", "gromacs", "namd", "sphinx3", "soplex" , "mcf", "GemsFDTD", "omnetpp", "astar", "milc")
header = c("Benchmark","StartDateTime","EndDateTime","TotalTime");

#Execution time with out migration
benchmarks1 = c( "gromacs", "namd", "sphinx3", "soplex" , "mcf", "GemsFDTD", "omnetpp", "astar", "milc")
exec_time_without_migtation = read.csv(paste(BASE, "/Dataset/without_migration/", "zeusmp" ,".csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in benchmarks1)
{
	temp1 = read.csv(paste(BASE, "/Dataset/without_migration/", bench ,".csv", sep=""),  sep=",",col.names=header,header = F);
	exec_time_without_migtation= rbind(exec_time_without_migtation,temp1); 
}

png(paste(BASE,"/benchmark_execution_time_wihtout_migration.png", sep=""),unit="in",width=11,height=8.5,res=200);
opar <- par(no.readonly=TRUE);
brpt1 = barplot(exec_time_without_migtation$TotalTime,names.arg=exec_time_without_migtation$Benchmark, beside=T,xlab="Benchmark", ylab="Execution Time in Seconds",main="Total Execution Time for Benchmark without migrating",ylim=c(0,5000));

text(y= exec_time_without_migtation$TotalTime + 100 , x= brpt1, labels=as.character(round(exec_time_without_migtation$TotalTime,2)), ypd=TRUE)
	dev.off();
	par(opar);
# Execution time with migration
	bandwidth <- seq(70,100,10);
for(bw in bandwidth)
{
	exec_time_with_migration = c();
	exec_time_with_migration = read.csv(paste(BASE, "/Dataset/Time/", "zeusmp",bw ,".csv", sep=""),  sep=",",col.names=header,header = F);
	png(paste(BASE,"/benchmark_execution_time_with_migration",bw,".png", sep=""),units="in", width=11, height=8.5,res=200);
	opar <- par(no.readonly=TRUE);
	for(bench in benchmarks1)
	{
		temp2 = read.csv(paste(BASE, "/Dataset/Time/", bench , bw,  ".csv", sep=""),  sep=",",col.names=header,header = F);
		exec_time_with_migration  = rbind(exec_time_with_migration,temp2);	
		brpt = barplot(exec_time_with_migration$TotalTime,names.arg=exec_time_with_migration$Benchmark, beside=T,xlab="Benchmark", ylab="Execution Time in Seconds",main=paste("Total Execution Time for Benchmark with migrating , with network bandwidth of ",bw," MBps",sep=""),ylim=c(0,5000));
		text(y= exec_time_with_migration$TotalTime + 100 , x= brpt, labels=as.character(round(exec_time_with_migration$TotalTime,2)), ypd=TRUE)
	}

	dev.off();
	par(opar);
}

