cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex")
memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc")

BASE='/Users/subramanya/Workspace/LiveMigration/R_Project';

for(bench in cpu_intensive)
{
	cpu = read.csv(paste(BASE, "/Dataset/70MB/Wuotan/", "intel_",bench,"70" ,".csv", sep=""),  sep=";",header = T,fill=T,skip=1);
	# plot(ecdf(intel$L3MISS),col="red",main=bench);
	# ts.plot(intel$L3MISS,col="red",main=paste("Time series ",bench,sep=""),xlab="Time",ylab="L3 cache line misses in millions");
}
for(bench in memory_intensive)
{
	memory = read.csv(paste(BASE, "/Dataset/70MB/Wuotan/", "intel_",bench,"70" ,".csv", sep=""),  sep=";",header = T,fill=T,skip=1);
	# plot(ecdf(intel$L3MISS),col="red",main=bench);
	# ts.plot(intel$L3MISS,col="red",main=paste("Time series ",bench,sep=""),xlab="Time",ylab="L3 cache line misses in millions");
}


header = c("Number","Benchmark","BW","StartDateTime","EndDateTime","TotalTime","BW");

cpu_intensive1 = c("gromacs", "namd", "sphinx3", "soplex")
memory_intensive1 = c("GemsFDTD", "omnetpp", "astar", "milc")

cpu_migration_time = read.csv(paste(BASE, "/Dataset/70MB/Time/", "zeusmp","70" ,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in cpu_intensive1)
{
	temp1 = read.csv(paste(BASE, "/Dataset/70MB/Time/", bench ,"70_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	cpu_migration_time = rbind(cpu_migration_time,temp1); 
	# plot(ecdf(intel$L3MISS),col="red",main=bench);
	# ts.plot(intel$L3MISS,col="red",main=paste("Time series ",bench,sep=""),xlab="Time",ylab="L3 cache line misses in millions");
}

memory_migration_time = read.csv(paste(BASE, "/Dataset/70MB/Time/", "mcf","70" ,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in memory_intensive1)
{
	temp2 = read.csv(paste(BASE, "/Dataset/70MB/Time/", bench ,"70_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	memory_migration_time = rbind(memory_migration_time,temp1); 
	# plot(ecdf(intel$L3MISS),col="red",main=bench);
	# ts.plot(intel$L3MISS,col="red",main=paste("Time series ",bench,sep=""),xlab="Time",ylab="L3 cache line misses in millions");
}