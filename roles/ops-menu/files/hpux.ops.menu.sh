#!/sbin/sh

export TERM=vt100

function CPU
{
echo "Top 10 CPU processes - View 1"
echo ""
echo "Searching......"
echo ""
#/usr/bin/top -n 1|head -17
/usr/bin/top -d 1 -n 10 -f /tmp/ops.top.out
cat /tmp/ops.top.out
#ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10

#ps aux --sort=-pcpu | head -10
#ps -eo %cpu,time,user,pid,cmd --sort=-%cpu|cut -c 1-80|head -12
echo ""
echo "Top 10 CPU processes - View 2"
echo ""
echo " %CPU     TIME RUSER      PID COMMAND"
#ps -eo %cpu,time,user,pid,cmd --sort=-%cpu|cut -c 1-80|head -12 > /tmp/ops.data.out
UNIX95= ps -e -o pcpu,time,ruser,pid,args |sort -n -r|cut -c 1-80 |head -10 > /tmp/ops.data.out
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
rm -f /tmp/ops.top.out

}

function MEM
{
echo "Top memory usage processes"
echo ""
#ps aux --sort=-vsz,-rss | head -10
#ps -eo vsz,user,pid,cmd --sort=-vsz|cut -c 1-80|head -12
#ps -eo vsz,user,pid,cmd --sort=-vsz|cut -c 1-80|head -12 > /tmp/ops.data.out
#ps -eo %mem,user,pid,cmd |grep -v USER|sort -nr|cut -c 1-80|head -12 > /tmp/ops.data.out
UNIX95= ps -e -o vsz,ruser,pid,args |sort -n -r |cut -c 1-80|head -12 > /tmp/ops.data.out
#echo "%MEM USER       PID CMD"
echo "virtual memory in kilobytes"
echo "VSZ RUSER      PID COMMAND"
cat /tmp/ops.data.out
echo "------------------"
echo ""
echo "USER INFO:"
echo ""
cat /tmp/ops.data.out|awk '{print $2}'|grep -v USER|sort -n |uniq|while read name
 do
grep ^$name /etc/passwd|cut -d: -f1,5
 done
echo ""
echo "------------------"
echo ""
echo ""
UNIX95= ps -e -o sz,ruser,pid,args |sort -n -r |cut -c 1-80|head -12 > /tmp/ops.data.out
echo "size in physical pages of the core image of the process"
echo "SZ RUSER      PID COMMAND"
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
#free
/usr/sbin/swapinfo
}

function LRG
{
cat /dev/null > /tmp/fs.look.out
/usr/sbin/mount |grep -v NFS |awk '{print $1}' |while read name
do
bdf $name |grep % |grep -v "Mounted on"|awk '{print $(NF-1), $NF}'
done

echo ""
echo "ENTER File system: "
read FS
echo ""
echo "Searching......"
echo ""

sudo /usr/bin/find $FS -xdev -type f -mtime -1   |while read name
do
sudo /usr/bin/du -sk $name  >> /tmp/fs.look.out
done
clear
#echo "HOSTNAME: `hostname`"
#echo ""
#echo "File system: $FS "
#echo "File System Owner: `ls -al $FS |head -2 |grep -v total |awk '{print $3}'`"
#echo "Top 10 largest files changed in last day."


#echo ""
#echo "USER GROUP SIZE MM-DD-YY/TIME FILENAME"
#echo ""
cat /tmp/fs.look.out |sort -nr |head -10|awk '{print $2}'|while read name
do
sudo /bin/ls -l $name |awk '{print $3" "$4" "$5" "$6" "$7" "$8" "$9}'   >> /tmp/ops.data.out
done

clear
echo ""
echo "HOSTNAME: `hostname`"
echo ""
echo "File system: $FS "
echo "File System Owner: `ls -al $FS |head -2 |grep -v total |awk '{print $3}'`"
echo ""
echo "Top 10 largest files changed in last day."
echo ""
echo "USER GROUP SIZE MM-DD-YY/TIME FILENAME"
echo ""
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
ps -ef|grep snmp |grep -v grep
echo ""
}

function SNMPSTART
{
sudo /sbin/init.d/SnmpMaster stop
sudo /sbin/init.d/SnmpMaster start
echo ""
}

function SYSINFO
{

/usr/contrib/bin/machinfo

echo ""
echo ""
echo "NETWORK:"
/usr/bin/netstat -in
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
echo "7 - System UPTIME"
echo "0 - EXIT"
echo "---------------------------------"
echo ""
echo "Enter choice:"
read CHOICE

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
read GO

done

echo "DONE"
