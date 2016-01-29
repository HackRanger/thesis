#create_source_vm_dataset

library(lubridate);

library(effects);
cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex")
memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc")
BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';

header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime","BW","TotalL3Miss",
"TotalINST","AvgL3Miss","AvgINST","MAR","AvgPageDirty","AvgUserSpaceUtil","AvgMemoryUsed","AvgROCL3Miss",
"AvgROCPageDirty","TotalPageDirty");
vm_header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime",
		"BW",
		"CpuUtil","MemoryBandwidthUsed","AvgROCPageDirty",
		"TotalPageDirty","PageDirtyPerSecondPerMigration");

combined_header = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime","BW","TotalL3Miss",
"TotalINST","AvgL3Miss","AvgINST","MAR","AvgPageDirty","AvgUserSpaceUtil","AvgMemoryUsed","AvgROCL3Miss",
"AvgROCPageDirty","TotalPageDirty", "VM_TotalPageDirty", "VM_AvgROCPageDirty")


cpu_data_set = read.csv(paste(BASE,"/Dataset/sourcemachine_cpu_intensive_data_frame_final.csv", sep="" ),sep = ",");
memory_data_set = read.csv(paste(BASE,"/Dataset/sourcemachine_memory_intensive_data_frame_final.csv", sep=""), sep = ",");

vm_cpu_data_set = read.csv(paste(BASE,"/Dataset/vm_cpu_intensive_data_frame_final.csv", sep="" ),sep = ",");
vm_memory_data_set = read.csv(paste(BASE,"/Dataset/vm_memory_intensive_data_frame_final.csv", sep=""), sep = ",");


cpu_data_set$VM_TotalPageDirty = vm_cpu_data_set[match(cpu_data_set$Benchmark, vm_cpu_data_set $Benchmark)
		 && match(cpu_data_set$Number, vm_cpu_data_set$Number) 
		 && match(cpu_data_set$BW, vm_cpu_data_set$BW),c("TotalPageDirty")]

memory_data_set$VM_TotalPageDirty = vm_memory_data_set[match(memory_data_set$Benchmark, vm_memory_data_set$Benchmark)
		 && match(memory_data_set$Number, vm_memory_data_set$Number) 
		 && match(memory_data_set$BW, vm_memory_data_set$BW),c("TotalPageDirty")]

write.csv(cpu_data_set,file = paste(BASE, "/Dataset/combined_cpu_intensive_data_frame_final.csv", sep=""),row.names=FALSE);
write.csv(memory_data_set,file = paste(BASE, "/Dataset/combined_memory_intensive_data_frame_final.csv", sep=""),row.names=FALSE);
