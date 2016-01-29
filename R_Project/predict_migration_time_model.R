library(lubridate);

library(effects);
cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex")
memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc")
BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';

header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime","BW","TotalL3Miss",
		"TotalINST","AvgL3Miss","AvgINST","MAR","AvgPageDirty","AvgUserSpaceUtil","AvgMemoryUsed","AvgROCL3Miss",
		"AvgROCPageDirty","TotalPageDirty");
vm_header_dataframe = c("Benchmark","Number","StartDateTime","EndDateTime","TotalTime","BW",
		"AvgPageDirty","AvgUserSpaceUtil","AvgMemoryUsed",
		"AvgROCPageDirty","TotalPageDirty");


temp1 = read.csv(paste(BASE,"/Dataset/sourcemachine_cpu_intensive_data_frame_final.csv", sep="" ),sep = ",");
cpu_data_set = temp1[which(temp1$BW != 100),];
cpu_data_set = subset(cpu_data_set,!(Benchmark == "zeusmp" & BW == 70)) ;
temp2 = read.csv(paste(BASE,"/Dataset/sourcemachine_memory_intensive_data_frame_final.csv", sep=""), sep = ",");
memory_data_set = temp2[which(temp2$BW != 100),];
memory_data_set = subset(memory_data_set,!(Benchmark == "GemsFDTD" & BW == 70)) ;
memory_data_set = subset(memory_data_set,!(Benchmark == "milc" & BW == 70));

temp5=read.csv(paste(BASE,"/Dataset/combined_cpu_intensive_data_frame_final.csv", sep="" ),sep = ",");
combined_cpu_data_set = temp5[which(temp5$BW != 100),];
combined_cpu_data_set= subset(combined_cpu_data_set,!(Benchmark == "zeusmp" & BW == 70)) ;
temp6=read.csv(paste(BASE,"/Dataset/combined_memory_intensive_data_frame_final.csv", sep=""), sep = ",");
combined_memory_data_set=temp6[which(temp6$BW != 100),];
combined_memory_data_set = subset(combined_memory_data_set,!(Benchmark == "GemsFDTD" & BW == 70)) ;
combined_memory_data_set = subset(combined_memory_data_set,!(Benchmark == "milc" & BW == 70));


test_cpu_data_set = temp1[which(temp1$BW == 100),];
test_memory_data_set = temp2[which(temp2$BW == 100),];
test_combined_cpu_data_set = temp5[which(temp5$BW == 100),];
test_combined_memory_data_set = temp6[which(temp6$BW == 100),];
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

pred1 = predict(cpu_fit,test_cpu_data_set);
pred2 = predict(memory_fit,test_memory_data_set);
pred5 = predict(combined_cpu_fit,test_combined_cpu_data_set);
pred6 = predict(combined_memory_fit,test_combined_memory_data_set);



#Add the numbering for the dataframe.
sqrd_error1 = data.frame(Benchmark=test_cpu_data_set$Benchmark,TotalTime=test_cpu_data_set$TotalTime,Number = test_cpu_data_set$Number,Predicted = pred1, Error = test_cpu_data_set$TotalTime - pred1,SquaredError =(test_cpu_data_set$TotalTime - pred1)^2);
sqrd_error2 = data.frame(Benchmark=test_memory_data_set$Benchmark,TotalTime=test_memory_data_set$TotalTime,Number = test_memory_data_set$Number,Predicted = pred2, Error = test_memory_data_set$TotalTime - pred2,SquaredError =(test_memory_data_set$TotalTime - pred2)^2);
sqrd_error3 = data.frame(Benchmark=test_combined_cpu_data_set$Benchmark,TotalTime=test_combined_cpu_data_set$TotalTime,Number = test_combined_cpu_data_set$Number,Predicted = pred5, Error = test_combined_cpu_data_set$TotalTime - pred5,SquaredError =(test_combined_cpu_data_set$TotalTime - pred5)^2);
sqrd_error4 = data.frame(Benchmark=test_combined_memory_data_set$Benchmark,TotalTime=test_combined_memory_data_set$TotalTime,Number = test_combined_memory_data_set$Number,Predicted = pred6, Error = test_combined_memory_data_set$TotalTime - pred6,SquaredError =(test_combined_memory_data_set$TotalTime - pred6)^2)

stderror1 = sqrt(sum((test_cpu_data_set$TotalTime - pred1)^2)/50);
stderror2 = sqrt(sum((test_memory_data_set$TotalTime - pred2)^2)/50);
stderror3 = sqrt(sum((test_combined_cpu_data_set$TotalTime - pred5)^2)/50);
stderror4 = sqrt(sum((test_combined_memory_data_set$TotalTime - pred6)^2)/50);
