BASE='/Users/subramanya/Workspace/LiveMigration/R_Project';
cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex")
memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc")opar <- par(no.readonly=TRUE);
par(mfrow=c(5,2))
par(mar=c(1,1,1,1))
pdf("mygraph_dstat_70.pdf")
cl <- rainbow(11);
ch <- seq(1:10);
for(bench in benchmarks)
{
	temp1 = read.csv(paste(BASE, "/Dataset/Wuotan/dstat_", bench ,"70.csv", sep=""),header=T,sep=",",skip=6)
	ts1 = ts(temp1$idl.4);
	ts2 = ts(temp1$usr.4);
	ts3 = ts(temp1$sys.4);
	ts.plot(ts1,ts2,ts3,gpars = list(col = c("black", "red","green")),main=bench,lty=c(1,2))
	legend("topright", inset=.05, title="CPU Utlization", legend=c("idl","usr","sys"),lty=c(1, 2),col=c("black", "red","green"));
}
dev.off();
par(opar);
