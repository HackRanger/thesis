#!/usr/bin/python
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
import paramiko, base64
import time
import libvirt
import libvirt
import sys
import threading
from multiprocessing import Process, Value, Array

vm_host = '141.76.42.35'
vm_user = 'ubuntu'
vm_pass = 'ubuntu'

source_host = '141.76.40.64'
source_user = 'root'
source_pass = 'wuotan'

dest_host = '141.76.41.139'
dest_user = 'root'
dest_pass = 'gandalf'


s1_host = "141.76.41.125";
s1_user = "lab";
s1_pass = "wireless";

s2_host = "141.76.41.126"; 
s2_user = "lab";
s2_pass = "wireless";

bw=100

def start_vm_migration(source,destination,network_bw,benchmark,sourcepass,destpass):
    try:
        domain = source.lookupByName("ubuntutest")
    except:
        print 'Failed to find the main domain'
        sys.exit(1)
    try:
        domain.migrate(destination, libvirt.VIR_MIGRATE_LIVE, "ubuntutest", None, network_bw)
        domain = None
    except Exception,e:
        print e
        #stop_source_measurements()
        #stop_destination_measurements()
        #stop_vm_measurements()
        #stop_power_measurements()
        #sys.exit(1) 

def ntp_update():
    print "Starting NTP update for  " + vm_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(vm_host, username=vm_user, password=vm_pass)
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo su  -l -c 'ntpdate ntp.ubuntu.com'")
    ssh.close()

    print "Starting NTP update for  " + source_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(source_host, username=source_user, password=source_pass)
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("ntpdate 0.fedora.pool.ntp.org 1.fedora.pool.ntp.org")
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("echo 1 > /sys/devices/system/cpu/cpu0/online")
    ssh.close()

    print "Starting NTP update for  " + dest_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(dest_host, username=dest_user, password=dest_pass)
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("ntpdate 0.fedora.pool.ntp.org 1.fedora.pool.ntp.org")
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("echo 1 > /sys/devices/system/cpu/cpu0/online")
    ssh.close()

def start_vm_measurements(benchmark_name):
    print "Starting SSH connection to " + vm_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(vm_host, username=vm_user, password=vm_pass)
    print "Starting Measurements at " + vm_host
    dstat = "nohup dstat -tcmdnsy --proc-count --top-cpu --top-cputime --top-mem -C 0,1,2,3,total -N em1  --output dstat_" + benchmark_name + str(bw) + ".csv > /dev/null 2>&1 &"
    checkmem = "checkmem.py -t 100 -o /home/ubuntu/checkmem_" + benchmark_name + str(bw) + ".csv > /dev/null 2>&1 &"
    #Start CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(dstat)
    time.sleep(10)
    #Start Last Level Cache Miss
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(checkmem)

def stop_vm_measurements():
    print "Starting SSH connection to " + vm_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(vm_host, username=vm_user, password=vm_pass)
    print "Stoping Measurements at " + vm_host
    #Stop CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo su  -l -c 'killall /usr/bin/python'")
    #Stop Last Level Cache Miss
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("sudo su  -l -c 'killall intelpcm'")


def start_power_measurements(benchmark_name):
    print "Starting SSH connection to " + s1_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(s1_host, username=s1_user, password=s1_pass)
    print "Starting Measurements at " + s1_host
    command = "WT230 -u subbu -p" + benchmark_name + str(bw) + " >/dev/null &"
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(command)
    ssh.close()
    print "Starting SSH connection to " + s2_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(s2_host, username=s2_user, password=s2_pass)
    print "Starting Measurements at " + s2_host
    command = "WT230 -u subbu -p" + benchmark_name + str(bw) + " >/dev/null &"
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(command)
    ssh.close()


def stop_power_measurements():
    print "Starting SSH connection to " + s1_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(s1_host, username=s1_user, password=s1_pass)
    print "Stoping Measurements at " + s1_host
    #Stop CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall WT230")
    ssh.close()
    print "Starting SSH connection to " + s2_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(s2_host, username=s2_user, password=s2_pass)
    print "Stoping Measurements at " + s2_host
    #Stop CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall WT230")
    ssh.close()


def start_source_measurements(benchmark_name):
    print "Starting SSH connection to " + source_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(source_host, username=source_user, password=source_pass)
    print "Starting Measurements at " + source_host
    dstat = "cd /home/Subbu;nohup dstat -tcmdnsy --proc-count --top-cpu --top-cputime --top-mem -C 0,1,2,3,total -N em1  --output dstat_" + benchmark_name + str(bw) + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    intelpcm = "cd /home/Subbu;intelpcm -r -csv=intel_" + benchmark_name + str(bw) + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    checkmem = "cd /home/Subbu;checkmem.py -t 100 -o checkmem_" + benchmark_name + str(bw) + ".csv > /dev/null 2>&1 &"
    time.sleep(10)

    #Start CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(dstat)
    for line in ssh_stdout:
        print '... ' + line.strip('\n')
    #Start Memory Dirty rate
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(intelpcm)
    for line in ssh_stdout:
        print '... ' + line.strip('\n')

    #Start Last Level Cache Miss
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(checkmem)
    for line in ssh_stdout:
        print '... ' + line.strip('\n')

    ssh.close()

def stop_source_measurements():
    print "Starting SSH connection to " + source_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(source_host, username=source_user, password=source_pass)
    print "Stoping Measurements at " + source_host
    #Stop CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall python")
    #Stop Last Level Cache Miss
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall intelpcm")
    ssh.close()



def start_destination_measurements(benchmark_name):
    print "Starting SSH connection to " + dest_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(dest_host, username=dest_user, password=dest_pass)
    print "Starting Measurements at " + dest_host
    dstat = "cd /home/Subbu;nohup dstat -tcmdnsy --proc-count --top-cpu --top-cputime --top-mem -C 0,1,2,3,total -N em1  --output dstat_" + benchmark_name + str(bw) + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    intelpcm = "cd /home/Subbu;intelpcm -r -csv=intel_" + benchmark_name + str(bw) + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    checkmem = "cd /home/Subbu;checkmem.py -t 100 -o checkmem_" + benchmark_name + str(bw) +  ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    #Start CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(dstat)
    for line in ssh_stdout:
        print '... ' + line.strip('\n')
    #Start Memory Dirty rate
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(intelpcm)
    for line in ssh_stdout:
        print '... ' + line.strip('\n')

    #Start Last Level Cache Miss
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(checkmem)
    for line in ssh_stdout:
        print '... ' + line.strip('\n')

    ssh.close()


def stop_destination_measurements():
    print "Starting SSH connection to " + dest_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(dest_host, username=dest_user, password=dest_pass)
    print "Stoping Measurements at " + dest_host
    #Stop CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall python")
    #Stop Last Level Cache Miss
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall intelpcm")
    ssh.close()

def start_benchmark(benchmark_name):
    print "starting the benchmark " + benchmark_name
    two_iterations = [ "astar" , "gromacs" , "mcf" , "milc", "namd", "omnetpp", "soplex" ]
    cmd = "cd /home/ubuntu/benchmarking/;source shrc;runspec -c linux64-amd64-gcc43.cfg  --iterations=1 --noreportable -T base " + benchmark_name  
    if benchmark_name in two_iterations:
        cmd = "cd /home/ubuntu/benchmarking/;source shrc;runspec -c linux64-amd64-gcc43.cfg  --iterations=2 --noreportable -T base " + benchmark_name
    print "Starting SSH connection to " + vm_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(vm_host, username=vm_user, password=vm_pass)
    print "Starting benchmark at " + vm_host
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(cmd)
    print ssh_stdout.readlines()
    ssh.close()

threads = []
def main():
    #sync time in all the servers
    ntp_update()
    cpu_intensive = [ "zeusmp", "gromacs", "namd", "sphinx3", "soplex" ]
    memory_intensive = [  "mcf", "GemsFDTD", "omnetpp", "astar", "milc" ]
    two_iterations = [ "astar" , "gromacs" , "mcf" , "milc", "namd", "omnetpp", "soplex" ]
    #stop_source_measurements()
    #stop_destination_measurements()
    #stop_vm_measurements()
    #stop_power_measurements()
    #sys.exit(0) 
    for benchmark in cpu_intensive:
        start_source_measurements(benchmark)
        start_destination_measurements(benchmark)
        start_vm_measurements(benchmark)
        start_power_measurements(benchmark)
        t = threading.Thread(target=start_benchmark, args=(benchmark,))
        threads.append(t)
        t.start()
        
        log = open( benchmark + str(bw) + ".csv" , "a+" )
        print "Run log will be recorded in: ", log.name
        log.write("\n")    
        log.write(benchmark)
        log.write(",")
        start = time.time()
        log.write(time.asctime(time.localtime(start)))
        log.write(",")
        migration_log = open( benchmark + str(bw) + "_migration.csv" , "a+" )
        print "Run log will be recorded in: ", migration_log.name
        #For loop for number of migrations.
        for x in range(1, 11):         
            migration_log.write("\n")
            migration_log.write(str(x))
            migration_log.write(",")
            migration_log.write(benchmark)
            migration_log.write(",")
            migration_log.write(str(bw))
            migration_log.write(",")
            migrationstart = time.time()
            migration_log.write(time.asctime(time.localtime(migrationstart)))
            migration_log.write(",")
            print "Startin Migration from Wuotan to Gandalf"
            sconn=libvirt.open("qemu+tcp://141.76.40.64:500/system")
            dconn=libvirt.open("qemu+tcp://141.76.41.139:500/system")
            if sconn == None:
                print 'Failed to open connection to the source hypervisor'
                sys.exit(1)
            if dconn == None:
                print 'Failed to open connection to the destination hypervisor'
                sys.exit(1)
            start_vm_migration(sconn, dconn,bw,benchmark,source_pass,dest_pass)
            sconn.close()
            dconn.close()
            time.sleep(30)
            migrationend = time.time()
            migration_log.write(time.asctime(time.localtime(migrationend)))
            migration_log.write(",")
            migration_log.write(str(float(migrationend-migrationstart)))
            migration_log.write(",")
            migration_log.write(str(bw))
            migration_log.write("\n")
            print "Starting Migration from Gandalf to Wuotan"
            sconn=libvirt.open("qemu+tcp://141.76.40.64:500/system")
            dconn=libvirt.open("qemu+tcp://141.76.41.139:500/system")
            if sconn == None:
                print 'Failed to open connection to the source hypervisor'
                sys.exit(1)
            if dconn == None:
                print 'Failed to open connection to the destination hypervisor'
                sys.exit(1)
            start_vm_migration(dconn, sconn,100,benchmark,dest_pass,source_pass)
            sconn.close()
            dconn.close()
            time.sleep(10)
           
        migration_log.close()
        print "waiting for benchmark to finish"
        while True:
            if not t.is_alive():
                break
            else:
                print "Waiting for thread" + benchmark + " to finish"
                time.sleep(10)

        stop_source_measurements()
        stop_destination_measurements()
        stop_vm_measurements()
        stop_power_measurements()
        end = time.time()
        log.write(time.asctime(time.localtime(end)))
        log.write(",")
        log.write(str(float(end-start)))
        log.write("\n")    
        log.close()
        time.sleep(60)
    
    print "Finished all test successfully!"

if __name__ == '__main__': 
    main()
