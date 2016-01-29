library(lubridate)
BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';
benchmarks = c( "gromacs", "namd", "sphinx3","GemsFDTD", "mcf", "omnetpp","zeusmp", "astar", "milc","soplex")
header = c("Number","Benchmark","BW","StartDateTime","EndDateTime","TotalTime","BW");
power_bench=c("gromacs70_2015-04-03_11-24-32.csv",  "namd70_2015-04-03_11-49-56.csv",     "sphinx370_2015-04-03_12-10-55.csv",
"GemsFDTD70_2015-04-03_01-35-11.csv", "mcf70_2015-04-03_01-02-24.csv",      "omnetpp70_2015-04-03_02-15-33.csv",  "zeusmp70_2015-04-03_10-51-34.csv",
"astar70_2015-04-03_03-15-25.csv",    "milc70_2015-04-03_03-57-41.csv",     "soplex70_2015-04-03_12-31-51.csv");
#Migration time for 70MBps
i=1;
opar <- par(no.readonly=TRUE);
pdf("power70.pdf")
cl <- rainbow(11);
ch <- seq(1:10);
combined_power = c();
for(bench in benchmarks)
{

	temp1 = read.csv(paste(BASE, "/Dataset/70MB/Time/", bench ,"70_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	power = read.csv(paste(BASE, "/Dataset/70MB/Sampler1/", power_bench[i] ,sep=""),  sep=",",header = T);
	combined_power =  c(combined_power,power);
}
plot(ecdf(combined_power$power),col=cl,main="Power for each benchmark");
legend("topright", inset=.05, title="Benchmark", legend=benchmarks, col=cl);
for(bench in benchmarks)
{

	temp1 = read.csv(paste(BASE, "/Dataset/70MB/Time/", bench ,"70_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	power = read.csv(paste(BASE, "/Dataset/70MB/Sampler1/", power_bench[i] ,sep=""),  sep=",",header = T);
	ts.plot(power$power,main=bench,col=cl[i]);
	plot(ecdf(power$power),main=bench,col=cl[i]);
	i=i+1;
	for(j in seq(1,10))
	{
		mig = temp1[j,];
		mig$StartDateTime <- strptime(mig$StartDateTime,"%a %b  %d %H:%M:%S %Y");
		mig$EndDateTime <- strptime(mig$EndDateTime,"%a %b  %d %H:%M:%S %Y");
		power$timestamp <- strptime(power$timestamp,"%Y-%m-%d %H:%M:%S");
		int <- new_interval(mig$StartDateTime,mig$EndDateTime)
		power_set = power[power$timestamp %within% int,]
		ts.plot(power_set$power,main=paste(bench," migration count " , j , sep=""),col=cl[i]);
	}
}

par(opar);
dev.off();
