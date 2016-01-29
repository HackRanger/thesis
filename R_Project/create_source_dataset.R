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

########################### Source Machine ###########################


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
					migration_time_bench$EndDateTime <- migration_time_bench$EndDateTime - 30;
					migration_time_bench$TotalTime <- migration_time_bench$TotalTime - 30;
					migration_interval <- new_interval(migration_time_bench$StartDateTime,migration_time_bench$EndDateTime);

					cpu_counters = within(cpu_counters, {timestamp=strptime(paste(Date," " ,Time), "%Y-%m-%d %H:%M:%OS")});
					df1 = cpu_counters[cpu_counters$timestamp %within% migration_interval,];
					temp1 = read.table(paste(BASE, "/Dataset/Wuotan/", "checkmem_",bench,bw ,".csv", sep=""));
					cpu_pagedirty = temp1[,c("V1","V2","V4")];
					cpu_pagedirty = within(cpu_pagedirty, {timestamp=strptime(paste(V1," " ,V2), "%Y-%m-%d %H:%M:%OS")});
					df2 = cpu_pagedirty[cpu_pagedirty$timestamp %within% migration_interval,];
					first = df2[1,c("V4")]/4;
					for (i in 2:length(df2[,c("V4")])-1) {
						temp_a = df2[i,c("V4")]/4;
						temp_b = df2[i+1,c("V4")]/4;
						t = temp_b - temp_a;
						if(!is.null(t) && t >= 0 )
						{
							first = first + temp_b - temp_a;
						}
					}

					temp2 = read.csv(paste(BASE, "/Dataset/Wuotan/dstat_", bench ,bw,".csv", sep=""),header=T,sep=",",skip=6);
					cpu_dstat = within(temp2, {timestamp=strptime(paste("2015-",time), "%Y-%d-%m %H:%M:%S")});
					df3 = cpu_dstat[cpu_dstat$timestamp %within% migration_interval,];

					data_frame = data.frame(migration_time_bench[,c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime",
								"BW")],sum(df1$L3MISS*1000000,na.rm=TRUE),sum(df1$INST,na.rm=TRUE)
							,sum(df1$L3MISS,na.rm=TRUE)*1000000/sum(df1$INST,na.rm=TRUE)
							,mean(df3$usr.4,na.rm=TRUE),mean(df3$used/bw,na.rm=TRUE),mean(ROC(df1$L3MISS),na.rm=T),
							mean(ROC(df2[-1,c("V4")]/4),na.rm=T),first,first/migration_time_bench$TotalTime);

					data_frame_bench = rbind.data.frame(data_frame_bench,data_frame);
				}
		}

	data_frame_final = rbind.data.frame(data_frame_bench,data_frame_final);
	cpu_intensive_data_frame_final = data_frame_final[order(data_frame_final$Benchmark),]

### Memory Intensive Benchmark ###
		memory_pagedirty = c() ; 
	memory_dstat = c();
	migration_time_bw_mem = memory_migration_time_all[which(memory_migration_time_all$BW == bw),]
		data_frame_bench_mem = c();

	for(count in migration_count)
	{
		migration_time_count_mem = migration_time_bw_mem[which(migration_time_bw_mem$Number == count),]
			for(bench in memory_intensive)
			{	
				cpu_counters_mem = read.csv(paste(BASE, "/Dataset/Wuotan/", "intel_",bench,bw,".csv", sep=""),  sep=";",header = T,fill=T,skip=1);
				migration_time_bench_mem = migration_time_count_mem[which(migration_time_count_mem$Benchmark == bench),];
				migration_time_bench_mem$StartDateTime <- strptime(migration_time_bench_mem$StartDateTime,"%a %b %d %H:%M:%S %Y");
				migration_time_bench_mem$EndDateTime <- strptime(migration_time_bench_mem$EndDateTime,"%a %b %d %H:%M:%S %Y");
				migration_interval_mem <- new_interval(migration_time_bench_mem$StartDateTime,migration_time_bench_mem$EndDateTime);

				cpu_counters_mem = within(cpu_counters_mem, {timestamp=strptime(paste(Date," " ,Time), "%Y-%m-%d %H:%M:%OS")});
				df1_mem = cpu_counters_mem[cpu_counters_mem$timestamp %within% migration_interval_mem,];

				temp1_mem = read.table(paste(BASE, "/Dataset/Wuotan/", "checkmem_",bench,bw ,".csv", sep=""));
				pagedirty_mem = temp1_mem[,c("V1","V2","V4")];
				pagedirty_mem = within(pagedirty_mem, {timestamp=strptime(paste(V1," " ,V2), "%Y-%m-%d %H:%M:%OS")});
				df2_mem = pagedirty_mem[pagedirty_mem$timestamp %within% migration_interval_mem,];

				first_mem = df2_mem[1,c("V4")]/4;
				for (i in 2:length(df2_mem[,c("V4")])-1) {
					tempa = df2_mem[i,c("V4")]/4;
					tempb = df2_mem[i+1,c("V4")]/4;
					t_mem = tempb - tempa;
					if(!is.null(t_mem) && t_mem >= 0 )
					{
						first_mem = first_mem + tempb - tempa;
					}
				}

				temp2_mem = read.csv(paste(BASE, "/Dataset/Wuotan/dstat_", bench ,bw,".csv", sep=""),header=T,sep=",",skip=6);
				dstat_mem = within(temp2_mem, {timestamp=strptime(paste("2015-",time), "%Y-%d-%m %H:%M:%S")});
				df3_mem = dstat_mem[dstat_mem$timestamp %within% migration_interval_mem,];

				data_frame_mem = data.frame(migration_time_bench_mem[,c("Benchmark","Number","StartDateTime","EndDateTime",
							"TotalTime","BW")],sum(df1_mem$L3MISS*1000000,na.rm=TRUE),sum(df1_mem$INST,na.rm=TRUE),
						sum(df1_mem$L3MISS,na.rm=TRUE)*1000000/sum(df1_mem$INST,na.rm=TRUE),
						mean(df3_mem$usr.4,na.rm=TRUE),mean(df3_mem$used/bw,na.rm=TRUE),
						mean(ROC(df1_mem$L3MISS),na.rm=T),mean(ROC(df2_mem[-1,c("V4")]/4),na.rm=T),first_mem,first_mem/migration_time_bench$TotalTime);

				data_frame_bench_mem = rbind.data.frame(data_frame_bench_mem,data_frame_mem);
			}
	}
	data_frame_final_mem = rbind.data.frame(data_frame_bench_mem,data_frame_final_mem);
	memory_intensive_data_frame_final = data_frame_final_mem[order(data_frame_final_mem$Benchmark),]


}
colnames(memory_intensive_data_frame_final) <- header_dataframe;
colnames(cpu_intensive_data_frame_final) <- header_dataframe;
write.csv(cpu_intensive_data_frame_final,file = paste(BASE, "/Dataset/sourcemachine_cpu_intensive_data_frame_final.csv", sep=""),row.names=FALSE);
write.csv(memory_intensive_data_frame_final,file = paste(BASE, "/Dataset/sourcemachine_memory_intensive_data_frame_final.csv", sep=""),row.names=FALSE);


