require(ggplot2)
	BASE='/Users/subramanya/Workspace/LiveMigration/SVN/Subbu/R_Project';
	benchmarks = c( "gromacs", "namd", "sphinx3","GemsFDTD", "omnetpp", "astar", "milc","soplex" , "mcf")
	header = c("Number","Benchmark","BW","StartDateTime","EndDateTime","TotalTime","BW");

	bandwidth <- seq(70,100,10);
	all_migration_time = c();
	cpu_intensive = c("zeusmp", "gromacs", "namd", "sphinx3", "soplex");
	memory_intensive = c("mcf", "GemsFDTD", "omnetpp", "astar", "milc");
for(bw in bandwidth)
{
	migration_time = read.csv(paste(BASE, "/Dataset/Time/", "zeusmp",bw ,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
	for(bench in benchmarks)
	{
		temp1 = read.csv(paste(BASE, "/Dataset/Time/", bench ,bw,"_migration.csv", sep=""),  sep=",",col.names=header,header = F);
		migration_time = rbind(migration_time,temp1); 
	}
	all_migration_time=rbind(all_migration_time,migration_time);
}
temp1 = c();
for(bench in cpu_intensive)
{
	cpu_intensive_data = subset(all_migration_time,Benchmark == bench);
	temp1 = rbind(temp1,cpu_intensive_data);
}
temp1 = temp1[order(temp1$Benchmark),];
temp2 = c();
for(bench1 in memory_intensive)
{
	memory_intensive_data = subset(all_migration_time,Benchmark == memory_intensive);
	temp2 = rbind(temp2,memory_intensive_data);
}

temp2 = temp2[order(temp2$Benchmark),];
for(bw in bandwidth)
{
	png(paste(BASE,"/cpu_migration_time",bw,".png", sep=""),width = 500, height = 200, units = "mm", res = 300);
	opar <- par(no.readonly=TRUE);
	mytitle = paste("Migration Time using ",bw," Mbps bandwidth",sep="");
	p=ggplot(temp1[which(temp1$BW == bw),], aes(x=Number, y=TotalTime,colour = as.factor(Benchmark), group = as.factor(Benchmark))) + geom_point() +  geom_line() + scale_x_continuous(breaks=1:10) + scale_y_continuous(limits = c(0,1200)) + ggtitle(mytitle);
	print(p);
	dev.off();

}

for(bw in bandwidth)
{
	png(paste(BASE,"/memory_migration_time",bw,".png", sep=""),width = 500, height = 200, units = "mm", res = 300);
	opar <- par(no.readonly=TRUE);
	mytitle1 = paste("Migration Time using ",bw," Mbps bandwidth",sep="");
	p1=ggplot(temp2[which(temp2$BW == bw),], aes(x=Number, y=TotalTime,colour = as.factor(Benchmark), group = as.factor(Benchmark))) + geom_point() +  geom_line() + scale_x_continuous(breaks=1:10) + scale_y_continuous(limits = c(0,1200)) + ggtitle(mytitle1);
	print(p1);
	dev.off();
}
