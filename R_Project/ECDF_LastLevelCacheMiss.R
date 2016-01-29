BASE='/Users/subramanya/Workspace/LiveMigration/R_Project';
benchmarks = c( "gromacs", "namd", "sphinx3","GemsFDTD", "omnetpp", "astar", "milc","soplex" , "mcf","zeusmp")
	library(lubridate);
header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime",
	"BW","TotalL3Miss","TotalINST","AvgL3Miss","AvgINST","MAR");

cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex")
memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc")

opar <- par(no.readonly=TRUE);
par(mfrow=c(5,2))
par(mar=c(1,1,1,1))
pdf("mygraph_intel.pdf")
cl <- rainbow(11);
ch <- seq(1:10);
bandwidth <- seq(70,100,10);
migration_count = seq(1, 10, 1);
cpu_migration_time_all = c();
memory_migration_time_all = c();
##### Bandwidth #####
data_frame_final = c();
for(bw in bandwidth)
{

# Migration Time
header = c("Number","Benchmark","BW","StartDateTime","EndDateTime","TotalTime","BW");
cpu_intensive1 = c("gromacs", "namd", "sphinx3", "soplex")
memory_intensive1 = c("GemsFDTD", "omnetpp", "astar", "milc")

cpu_migration_time = read.csv(paste(BASE, "/Dataset/Time/", "zeusmp",bw ,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in cpu_intensive1)
{
	temp1 = read.csv(paste(BASE, "/Dataset/Time/", bench ,bw,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	cpu_migration_time = rbind(cpu_migration_time,temp1); 
# plot(ecdf(intel$L3MISS),col="red",main=bench);
# ts.plot(intel$L3MISS,col="red",main=paste("Time series ",bench,sep=""),xlab="Time",ylab="L3 cache line misses in millions");
}

cpu_migration_time_all = rbind(cpu_migration_time_all,cpu_migration_time); 

memory_migration_time = read.csv(paste(BASE, "/Dataset/Time/", "mcf",bw ,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
for(bench in memory_intensive1)
{
	temp2 = read.csv(paste(BASE, "/Dataset/Time/", bench ,bw,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	memory_migration_time = rbind(memory_migration_time,temp2); 
# plot(ecdf(intel$L3MISS),col="red",main=bench);
# ts.plot(intel$L3MISS,col="red",main=paste("Time series ",bench,sep=""),xlab="Time",ylab="L3 cache line misses in millions");
}
memory_migration_time_all = rbind(memory_migration_time_all,memory_migration_time); 

intel_cache_miss_all = c();

### CPU Intensive Benchmark ###
cpu_pagedirty = c ();
cpu_dstat = c ();
data_frame_bench = c();

migration_time_bw = cpu_migration_time_all[which(cpu_migration_time_all$BW == bw),]
for(count in migration_count)
{
	migration_time_count = migration_time_bw[which(migration_time_bw$Number == count),]
	for(bench in cpu_intensive)
	{	
		cpu_counters = read.csv(paste(BASE, "/Dataset/Wuotan/", "intel_",bench,bw,".csv", sep=""),  sep=";",header = T,fill=T,skip=1);
		migration_time_bench = migration_time_count[which(migration_time_count$Benchmark == bench),];
		migration_time_bench$StartDateTime <- strptime(migration_time_bench$StartDateTime,"%a %b %d %H:%M:%S %Y");
		migration_time_bench$EndDateTime <- strptime(migration_time_bench$EndDateTime,"%a %b %d %H:%M:%S %Y");
		migration_interval <- new_interval(migration_time_bench$StartDateTime,migration_time_bench$EndDateTime);

		cpu_counters = within(cpu_counters, {timestamp=strptime(paste(Date," " ,Time), "%Y-%m-%d %H:%M:%OS")});
		df1 = cpu_counters[cpu_counters$timestamp %within% migration_interval,];

		data_frame = data.frame(migration_time_bench[,c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime","BW")],mean(df1$L3MISS*1000000),mean(df1$INST),sum(df1$L3MISS*1000000),sum(df1$INST),sum(df1$L3MISS)*1000000/sum(df1$INST));
		data_frame_bench = rbind.data.frame(data_frame_bench,data_frame);
	}
}

data_frame_final = rbind.data.frame(data_frame_bench,data_frame_final);
cpu_intensive_data_frame_final = data_frame_final[order(data_frame_final$Benchmark),]

}
colnames(cpu_intensive_data_frame_final) <- header_dataframe;
write.csv(cpu_intensive_data_frame_final,file = paste(BASE, "/Dataset/cpu_lastlevelcachemiss.csv", sep=""),row.names=FALSE);

dev.off();
#legend("topright", inset=.05, title="Migration", legend=levels(migration_time$Benchmark),lty=c(1, 2), pch=ch, col=cl);
par(opar);
