#!/bin/bash

clear
#check sudo access
sudo date

function CPU
{
echo "Top 10 CPU processes - View 1"
echo ""
echo ""
/usr/bin/top -n 1|head -17
echo ""
echo ""
#ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10

#ps aux --sort=-pcpu | head -10
#ps -eo %cpu,time,user,pid,cmd --sort=-%cpu|cut -c 1-80|head -12
echo "Top 10 CPU processes - View 2"
echo ""
ps -eo %cpu,time,user,pid,cmd --sort=-%cpu|cut -c 1-80|head -12 > /tmp/ops.data.out
cat /tmp/ops.data.out

echo "------------------"
echo ""
echo "USER INFO:"
echo ""
cat /tmp/ops.data.out|awk '{print $3}'|grep -v USER|sort -n |uniq|while read name
 do 
grep ^$name /etc/passwd|cut -d: -f1,5
 done 

rm -f /tmp/ops.data.out

}

function MEM
{
echo "Top memory usage processes"
echo ""
#ps aux --sort=-vsz,-rss | head -10
#ps -eo vsz,user,pid,cmd --sort=-vsz|cut -c 1-80|head -12
#ps -eo vsz,user,pid,cmd --sort=-vsz|cut -c 1-80|head -12 > /tmp/ops.data.out
ps -eo %mem,user,pid,cmd |grep -v USER|sort -nr|cut -c 1-80|head -12 > /tmp/ops.data.out
echo "%MEM USER       PID CMD"
cat /tmp/ops.data.out

echo "------------------"
echo ""
echo "USER INFO:"
echo ""
cat /tmp/ops.data.out|awk '{print $2}'|grep -v USER|sort -n |uniq|while read name
 do
grep ^$name /etc/passwd|cut -d: -f1,5
 done

rm -f /tmp/ops.data.out

echo ""
echo "------------------"
echo ""
echo "Server memory usage."
free
}

function LRG
{
cat /dev/null > /tmp/fs.look.out
df -Ph|grep -v :|awk '{print $5" "$6}'|grep -vE 'boot|dev\/shm'
echo ""
echo "ENTER File system: "
read -e FS
echo ""
echo "Searching......"
echo ""

sudo /usr/bin/find $FS -xdev -type f -mtime -1 |while read name
do
sudo /usr/bin/du -sk $name >> /tmp/fs.look.out
done
clear
echo "HOSTNAME: `hostname`"
echo ""
echo "File system: $FS "
echo "File System Owner: `stat -c "%U" $FS`"
echo "Top 10 largest files changed in last day."


echo ""
echo "USER GROUP SIZE MM-DD-YY/TIME FILENAME"
echo ""
cat /tmp/fs.look.out |sort -nr |head -10|awk '{print $2}'|while read name
do
sudo /bin/ls -l $name |awk '{print $3" "$4" "$5" "$6" "$7" "$8" "$9}' >> /tmp/ops.data.out
done
cat /tmp/ops.data.out

echo "------------------"
echo ""
echo "USER INFO:"
echo ""
cat /tmp/ops.data.out|awk '{print $1}'|grep -v USER|sort -n |uniq|while read name
 do
grep ^$name /etc/passwd|cut -d: -f1,5
 done

rm -f /tmp/ops.data.out

#cp /tmp/fs.look.out /tmp/jeff
rm -f /tmp/fs.look.out
}

function SNMPSTAT
{
sudo /usr/sbin/service snmpd status
echo ""
ps -ef|grep snmp|grep -v grep
}

function SNMPSTART
{
sudo /usr/sbin/service snmpd stop
sudo /usr/sbin/service snmpd start
echo ""
}

function SYSINFO
{
/usr/bin/lsb_release -i -r
echo ""
sudo dmidecode --type 1
cat /proc/meminfo | grep MemT
cat /proc/meminfo|grep -i swap
sudo dmidecode -t 4|grep -E '\''Intel|Core|Version'\''|grep -v Unknown|grep -v Manuf'
echo ""
echo "NETWORK:"
/sbin/ip a
}

function UPTIME
{
echo "Server UPTIME"
echo ""
/usr/bin/uptime
}

###################################
CHOICE="x"
until [ $CHOICE = 0 ]
do

clear
echo "1 - List TOP CPU processes"
echo "2 - List TOP Memory processes"
echo "3 - Find large files"
echo "4 - Check SNMP Status"
echo "5 - Restart SNMP"
echo "6 - System INFO"
echo "7 - System Uptime"
echo "0 - EXIT"
echo "---------------------------------"
echo ""
echo "Enter choice:"
read -e CHOICE

echo ""
clear
echo "HOSTNAME: `hostname`"
echo ""

[ $CHOICE = 0 ] && exit
[ $CHOICE = 1 ] && CPU
[ $CHOICE = 2 ] && MEM
[ $CHOICE = 3 ] && LRG
[ $CHOICE = 4 ] && SNMPSTAT
[ $CHOICE = 5 ] && SNMPSTART
[ $CHOICE = 6 ] && SYSINFO
[ $CHOICE = 7 ] && UPTIME

echo ""
echo "Enter Return to continue."
read -e GO

done

echo "DONE"
