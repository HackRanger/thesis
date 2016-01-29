BASE='/Users/subramanya/Workspace/LiveMigration/R_Project';
benchmarks = c( "gromacs", "namd", "sphinx3","GemsFDTD", "omnetpp", "astar", "milc","soplex" , "mcf")
header = c("Number","Benchmark","BW","StartDateTime","EndDateTime","TotalTime","BW");

#Migration time for 70MBps
migration_time = read.csv(paste(BASE, "/Dataset/70MB/Time/", "zeusmp","70" ,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in benchmarks)
{
	temp1 = read.csv(paste(BASE, "/Dataset/70MB/Time/", bench ,"70_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	migration_time = rbind(migration_time,temp1); 
}
opar <- par(no.readonly=TRUE);
par(mfrow=c(5,2))
par(mar=c(1,1,1,1))
pdf("MigrationTime70.pdf")
cl <- rainbow(11);
ch <- seq(1:10);
ich = 1;
plot(migration_time$TotalTime[migration_time$Benchmark=="zeusmp"],type="b",ylim=c(0,1500),main="Migration time at 70MB/s",xlab="Migration", ylab="Time to Migration in Seconds",pch=ich, lty=1 ,col=cl[1]);
text(1,max(migration_time$TotalTime[migration_time$Benchmark=="zeusmp"]),"zeusmp",cex=0.6, pos=4, col="red")
i=2;
for(bench in benchmarks)
{
	i=i+1;
	ich=ich+1;
	plot(migration_time$Number[migration_time$Benchmark==bench],migration_time$TotalTime[migration_time$Benchmark==bench],type="b",pch=ich, lty=1,col=cl[i],main="Migration time at 70MB/s",xlab="Migration", ylab="Time to Migration in Seconds")
	text(1,max(migration_time$TotalTime[migration_time$Benchmark==bench]),bench,cex=0.6, pos=4, col="red")
}
dev.off();
#legend("topright", inset=.05, title="Migration", legend=levels(migration_time$Benchmark),lty=c(1, 2), pch=ch, col=cl);
par(opar);
