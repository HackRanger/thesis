#!/usr/bin/python
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
import paramiko, base64
import time
import libvirt
import libvirt
import sys
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


measurement_count = 1;

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
    dstat = "nohup dstat -tcmdnsy --proc-count --top-cpu --top-cputime --top-mem -C 0,1,2,3,total -N em1  --output dstat_" + benchmark_name + ".csv > /dev/null 2>&1 &"
    checkmem = "checkmem.py -t 100 -o /home/ubuntu/checkmem_" + benchmark_name + ".csv > /dev/null 2>&1 &"
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
    command = "WT230 -u subbu -p" + benchmark_name + " >/dev/null &"
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(command)
    ssh.close()
    print "Starting SSH connection to " + s2_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(s2_host, username=s2_user, password=s2_pass)
    print "Starting Measurements at " + s2_host
    command = "WT230 -u subbu -p" + benchmark_name + " >/dev/null &"
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
    dstat = "cd /home/Subbu;nohup dstat -tcmdnsy --proc-count --top-cpu --top-cputime --top-mem -C 0,1,2,3,total -N em1  --output dstat_" + benchmark_name + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    intelpcm = "cd /home/Subbu;intelpcm -r -csv=intel_" + benchmark_name + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    checkmem = "cd /home/Subbu;checkmem.py -t 100 -o checkmem_" + benchmark_name + ".csv > /dev/null 2>&1 &"
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

def start_dest_measurements(benchmark_name):
    print "Starting SSH connection to " + source_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(dest_host, username=dest_user, password=dest_pass)
    print "Starting Measurements at " + dest_host
    dstat = "cd /home/Subbu;nohup dstat -tcmdnsy --proc-count --top-cpu --top-cputime --top-mem -C 0,1,2,3,total -N em1  --output dstat_" + benchmark_name + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    intelpcm = "cd /home/Subbu;intelpcm -r -csv=intel_" + benchmark_name + ".csv > /dev/null 2>&1 &"
    time.sleep(10)
    checkmem = "cd /home/Subbu;checkmem.py -t 100 -o checkmem_" + benchmark_name + ".csv > /dev/null 2>&1 &"
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


def stop_dest_measurements():
    print "Starting SSH connection to " + dest_host
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(dest_host, username=dest_user, password=dest_pass)
    print "Stoping Measurements at " + source_host
    #Stop CPU Load Average
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall python")
    #Stop Last Level Cache Miss
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command("killall intelpcm")
    ssh.close()

def main():
    #sync time in all the servers
    ntp_update()
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy()) 
    cpu_intensive = [ "zeusmp", "gromacs", "namd", "sphinx3", "soplex" ]
    memory_intensive = [  "mcf", "GemsFDTD", "omnetpp", "astar", "milc" ]
    two_iterations = [ "astar" , "gromacs" , "mcf" , "milc", "namd", "omnetpp", "soplex" ]
    #stop_source_measurements()
    #stop_vm_measurements()
    #stop_power_measurements()
    #stop_dest_measurements()
    #sys.exit(0) 
    for benchmark in memory_intensive:
        start_source_measurements(benchmark)
        start_dest_measurements(benchmark)
        start_vm_measurements(benchmark)
        start_power_measurements(benchmark)
        log = open( benchmark + ".csv" , "a+" )
        print "Run log will be recorded in: ", log.name
        ssh.connect('141.76.42.35', username='ubuntu', password='ubuntu')
        channel = ssh.get_transport().open_session()
        log.write(benchmark)
        log.write(",")
        start = time.time()
        log.write(time.asctime(time.localtime(start)))
        log.write(",")
        cmd = "cd /home/ubuntu/benchmarking/;source shrc;runspec -c linux64-amd64-gcc43.cfg  --iterations=1 --noreportable -T base " + benchmark 
        if benchmark in two_iterations:
            cmd = "cd /home/ubuntu/benchmarking/;source shrc;runspec -c linux64-amd64-gcc43.cfg  --iterations=2 --noreportable -T base " + benchmark
        channel.exec_command(cmd)
        while not channel.exit_status_ready():
            time.sleep(10)
        stdout = channel.makefile("rb")
        output = stdout.readlines()
        print output
        stop_source_measurements()
        stop_dest_measurements()
        stop_vm_measurements()
        stop_power_measurements()
        end = time.time()
        log.write(time.asctime(time.localtime(end)))
        log.write(",")
        log.write(str(float(end-start)))
        log.write("\n")    
        ssh.close()
        log.close()
        time.sleep(60)
    print "Finished all tests!"

if __name__ == '__main__': 
    main()
