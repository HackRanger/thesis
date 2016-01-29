library(lubridate);

library(effects);
cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex");
memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc");
BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';

header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime",
		"BW","TotalL3Miss","TotalINST","MAR",
		"CpuUtil","MemoryBandwidthUsed","AvgROCL3Miss","AvgROCPageDirty",
		"TotalPageDirty","PageDirtyPerSecondPerMigration");
vm_header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime",
		"BW",
		"CpuUtil","MemoryBandwidthUsed","AvgROCPageDirty",
		"TotalPageDirty","PageDirtyPerSecondPerMigration");

cpu_data_set = read.csv(paste(BASE,"/Dataset/sourcemachine_cpu_intensive_data_frame_final.csv", sep="" ),sep = ",");
cpu_data_set = subset(cpu_data_set,!(Benchmark == "zeusmp" & BW == 70)) ;

memory_data_set = read.csv(paste(BASE,"/Dataset/sourcemachine_memory_intensive_data_frame_final.csv", sep=""), sep = ",");
memory_data_set = subset(memory_set,!(Benchmark == "GemsFDTD" & BW == 70)) ;
memory_data_set = subset(memory_set,!(Benchmark == "milc" & BW == 70));

vm_cpu_data_set = read.csv(paste(BASE,"/Dataset/sourcemachine_cpu_intensive_data_frame_final.csv", sep="" ),sep = ",");
vm_memory_data_set = read.csv(paste(BASE,"/Dataset/sourcemachine_memory_intensive_data_frame_final.csv", sep=""), sep = ",");

combined_cpu_data_set = read.csv(paste(BASE,"/Dataset/combined_cpu_intensive_data_frame_final.csv", sep="" ),sep = ",");
combined_cpu_data_set= subset(combined_cpu_data_set,!(Benchmark == "zeusmp" & BW == 70)) ;

combined_memory_data_set = read.csv(paste(BASE,"/Dataset/combined_memory_intensive_data_frame_final.csv", sep=""), sep = ",");
combined_memory_data_set = subset(combined_memory_data_set,!(Benchmark == "GemsFDTD" & BW == 70)) ;
combined_memory_data_set = subset(combined_memory_data_set,!(Benchmark == "milc" & BW == 70));

#Model for CPU Intensive dataset for source
cpu_fit =  lm(TotalTime ~ TotalL3Miss + TotalINST +  CpuUtil + MemoryBandwidthUsed +  TotalPageDirty + MAR  +TotalPageDirty:MemoryBandwidthUsed 
		+  MAR:MemoryBandwidthUsed ,data=cpu_data_set);
summary(cpu_fit);

#Model for Memory Intensive dataset for source
memory_fit = lm(TotalTime ~ TotalL3Miss + TotalINST + CpuUtil + MemoryBandwidthUsed 
		+ TotalPageDirty + MAR:MemoryBandwidthUsed + TotalPageDirty:MemoryBandwidthUsed ,data=memory_data_set);
summary(memory_fit);

#Model for Combined CPU Intensive dataset
combined_cpu_fit =  lm(TotalTime ~ CpuUtil + MemoryBandwidthUsed + TotalL3Miss + TotalINST +
		 TotalPageDirty + VM_TotalPageDirty + MemoryBandwidthUsed:TotalPageDirty,data=combined_cpu_data_set);
summary(combined_cpu_fit);

#Model for Combined Memory Intensive dataset 
combined_memory_fit = lm(TotalTime ~ CpuUtil + MemoryBandwidthUsed + TotalL3Miss + TotalINST +  MAR:MemoryBandwidthUsed + TotalPageDirty + VM_TotalPageDirty,data=combined_memory_data_set);
summary(combined_memory_fit);

png(paste(BASE,"/source_model_cpu_intensive_benchmark.png", sep=""), units="in", width=11, height=8.5, res=300);
opar <- par(no.readonly=TRUE);
par(mfrow=c(2,2));
plot(cpu_fit,main="CPU Intensive Benchmark Model for Source Machine",cex.main=0.5);

dev.off();
par(opar);

png(paste(BASE,"/source_model_memory_intensive_benchmkark.png", sep=""), units="in", width=11, height=8.5, res=300);
opar <- par(no.readonly=TRUE);
par(mfrow=c(2,2));
plot(memory_fit,main="CPU Intensive Benchmark Model for Source Machine",cex.main=0.5);
dev.off();
par(opar);


png(paste(BASE,"/combined_cpu_intensive_benchmark.png", sep=""), units="in", width=11, height=8.5, res=300);
opar <- par(no.readonly=TRUE);
par(mfrow=c(2,2));

plot(combined_cpu_fit,main="CPU Intensive benchmark model for Combined",cex.main=0.5);

dev.off();
par(opar);


png(paste(BASE,"/combined_model_memory_intensive_benchmkark.png", sep=""), units="in", width=11, height=8.5, res=300);
opar <- par(no.readonly=TRUE);
par(mfrow=c(2,2));

plot(combined_memory_fit,main="CPU Intensive benchmark model for Combined");
dev.off();
par(opar);

