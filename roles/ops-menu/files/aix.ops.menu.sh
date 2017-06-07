#!/usr/bin/ksh
#
#check sudo access
sudo date
#

function CPU
{
echo "Top 10 CPU processes"
echo ""
#ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10

#ps aux --sort=-pcpu | head -10
#ps -eo %cpu,time,user,pid,cmd --sort=-%cpu|cut -c 1-80|head -12
#ps -eo %cpu,time,user,pid,cmd --sort=-%cpu|cut -c 1-80|head -12 > /tmp/ops.data.out
ps -eo pcpu,time,user,pid,args | sort -r -k1|cut -c 1-80 |head -12 > /tmp/ops.data.out
cat /tmp/ops.data.out

echo "------------------"
echo ""
echo "USER INFO:"
echo ""
cat /tmp/ops.data.out|awk '{print $3}'|grep -v USER|sort -n|grep -v "^$" |uniq|while read name
 do 
grep ^$name /etc/passwd|cut -d: -f1,5
 done 

rm -f /tmp/ops.data.out

}

function MEM
{
sudo svmon -P -O summary=basic,unit=MB,sortentity=pgsp|head -14|tail -10 > /tmp/ops.swap.temp

echo "TOP 10 Paging/swapping Processes"
echo "----------------------------------"
echo "   Pid Command          Inuse      Pin     Pgsp  Virtual  USER"

cat /tmp/ops.swap.temp|while read name
do
PIDMEM=`echo $name|awk '{print $1}'`
USERMEM=`ps -o user,pid -p $PIDMEM |grep -v USER|awk '{print $1}'`
echo "$name     $USERMEM"
echo $USERMEM >> /tmp/ops.user.temp
done

echo ""

sudo svmon -P -O summary=basic,unit=MB,sortentity=inuse|head -14|tail -10 > /tmp/ops.mem.temp

echo "TOP 10 real memory usage Processes"
echo "----------------------------------"
echo "   Pid Command          Inuse      Pin     Pgsp  Virtual  USER"

cat /tmp/ops.mem.temp|while read name
do
PIDMEM=`echo $name|awk '{print $1}'`
USERMEM=`ps -o user,pid -p $PIDMEM |grep -v USER|awk '{print $1}'`
echo "$name     $USERMEM"
echo $USERMEM >> /tmp/ops.user.temp
done

echo "------------------"
echo ""
echo "USER INFO:"
echo ""
cat /tmp/ops.user.temp|grep -v "^$" |sort -n |uniq|while read name
 do
grep ^$name /etc/passwd|cut -d: -f1,5
 done

rm -f /tmp/ops.data.out

echo ""
echo "------------------"
echo ""
echo "Server memory usage."
lsps -a

rm -f /tmp/ops.mem.temp
rm -f /tmp/ops.swap.temp
rm -f /tmp/ops.user.temp
}

function LRG
{
cat /dev/null > /tmp/fs.look.out
#df -Ph|grep -v :|awk '{print $5" "$6}'|grep -vE 'boot|dev\/shm'
df -k | grep -v :|awk '{print $4" "$7}'|grep -v "/proc"
echo ""
echo "ENTER File system: "
read FS
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
#echo "File System Owner: `stat -c "%U" $FS`"
echo "File System Owner: `ls -ld $FS |awk '{print $3}'`"
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
#sudo /sbin/service snmpd status
sudo /usr/bin/lssrc -s snmpd
echo ""
echo ""
ps -ef|grep snmp|grep -v grep
}

function SNMPSTART
{
#sudo /sbin/service snmpd stop
#sudo /sbin/service snmpd start
sudo /usr/bin/stopsrc -s snmpd
sudo /usr/bin/startsrc -s snmpd
echo ""
}

function SYSINFO
{

/usr/sbin/prtconf > /tmp/ops.sysinfo.out
head -n31 /tmp/ops.sysinfo.out
rm -f /tmp/ops.sysinfo.out

}

function UPTIME
{
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

