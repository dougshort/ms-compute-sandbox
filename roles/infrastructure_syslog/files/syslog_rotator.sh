#!/bin/bash

deldate=$(date --date="7 days ago" +%Y%m%d)
today=$(date +%Y%m%d)

while read logfile; do
  filename="${logfile##*/}"
  extension="${logfile##*.}"
  logdate=$(echo "${filename}" | cut -c1-10 | awk -F'-' '{ print $1$2$3 }')

  if [[ $logdate -eq $today ]]; then
    continue
  elif [[ $logdate -le $deldate ]]; then
    rm -rf ${logfile}
  else
    if [[ "$extension" = 'bz2' ]]; then
      continue
    else
      if [[ -f "$logfile.bz2" ]]; then
        rm -rf ${logfile}
      else
        /bin/nice -n 19 /usr/local/bin/bzip2 --compress --best --quiet $logfile
      fi
    fi
  fi
done < <(find /var/log/hosts -path /var/log/hosts/.snapshot -prune -o -type f \( -name "*.log" -o -name "*.log.bz2" \) -print)
