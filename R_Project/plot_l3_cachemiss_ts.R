library(lubridate);
library(TTR);
cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex");
memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc");
header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime",
		"BW","TotalL3Miss","TotalINST","MAR",
		"CpuUtil","MemoryBandwidthUsed","AvgROCL3Miss","AvgROCPageDirty",
		"TotalPageDirty","PageDirtyPerSecondPerMigration");

BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';
bandwidth <- seq(70,100,10);
migration_count = seq(1, 10, 1);
cpu_migration_time_all = c();
memory_migration_time_all = c();

##### Bandwidth #####
data_frame_final = c();
data_frame_final_mem = c();
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
	}

	cpu_migration_time_all = rbind(cpu_migration_time_all,cpu_migration_time); 

	memory_migration_time = read.csv(paste(BASE, "/Dataset/Time/", "mcf",bw ,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	for(bench in memory_intensive1)
	{
		temp2 = read.csv(paste(BASE, "/Dataset/Time/", bench ,bw,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
		memory_migration_time = rbind(memory_migration_time,temp2); 
	}
	memory_migration_time_all = rbind(memory_migration_time_all,memory_migration_time); 

########################### Source Machine ###########################
### CPU Intensive Benchmark ###
	migration_time_bw = cpu_migration_time_all[which(cpu_migration_time_all$BW == bw),];
	for(bench in cpu_intensive)
	{	
		cpu_counters = read.csv(paste(BASE, "/Dataset/Wuotan/", "intel_",bench,bw,".csv", sep=""),  sep=";",header = T,fill=T,skip=1);
		migration_time_bench = migration_time_bw[which(migration_time_bw$Benchmark == bench),];
		migration_time_bench$StartDateTime <- strptime(migration_time_bench$StartDateTime,"%a %b %d %H:%M:%S %Y");
		migration_time_bench$EndDateTime <- strptime(migration_time_bench$EndDateTime,"%a %b %d %H:%M:%S %Y");
		migration_time_bench$EndDateTime <- migration_time_bench$EndDateTime - 30;
		migration_time_bench$TotalTime <- migration_time_bench$TotalTime - 30;
		migration_interval <- new_interval(migration_time_bench$StartDateTime,migration_time_bench$EndDateTime);

		cpu_counters = within(cpu_counters, {timestamp=strptime(paste(Date," " ,Time), "%Y-%m-%d %H:%M:%OS")});
		df1 = cpu_counters[cpu_counters$timestamp %within% migration_interval,];
		png(paste(BASE,"/l3_",bench,"_", bw,".png", sep=""),unit="in",width=11,height=8.5,res=200);
		opar <- par(no.readonly=TRUE);
		ts.plot(df1$L3MISS,col="red",main=paste("Time series ",bench," at bandwidth of ",bw, " Mbps",sep=""),xlab="Time",ylab="L3 cache line misses in millions",ylim=c(0,17));
		dev.off();
		par(opar);
	}

### Memory Intensive Benchmark ###
	migration_time_bw_mem = memory_migration_time_all[which(memory_migration_time_all$BW == bw),]
		for(bench in memory_intensive)
		{	
			cpu_counters_mem = read.csv(paste(BASE, "/Dataset/Wuotan/", "intel_",bench,bw,".csv", sep=""),  sep=";",header = T,fill=T,skip=1);
			migration_time_bench_mem = migration_time_bw_mem[which(migration_time_bw_mem$Benchmark == bench),];
			migration_time_bench_mem$StartDateTime <- strptime(migration_time_bench_mem$StartDateTime,"%a %b %d %H:%M:%S %Y");
			migration_time_bench_mem$EndDateTime <- strptime(migration_time_bench_mem$EndDateTime,"%a %b %d %H:%M:%S %Y");
			migration_interval_mem <- new_interval(migration_time_bench_mem$StartDateTime,migration_time_bench_mem$EndDateTime);

			cpu_counters_mem = within(cpu_counters_mem, {timestamp=strptime(paste(Date," " ,Time), "%Y-%m-%d %H:%M:%OS")});
			df1_mem = cpu_counters_mem[cpu_counters_mem$timestamp %within% migration_interval_mem,];
			png(paste(BASE,"/l3_",bench,"_", bw,".png", sep=""),unit="in",width=11,height=8.5,res=200);
			opar <- par(no.readonly=TRUE);

			ts.plot(df1_mem$L3MISS,col="red",main=paste("Time series ",bench," at bandwidth of ",bw, " Mbps",sep=""),xlab="Time",ylab="L3 cache line misses in millions",ylim=c(0,17));
			dev.off();
			par(opar);

		}
}
