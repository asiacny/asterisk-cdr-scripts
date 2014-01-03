#!/bin/sh
#
# Annual summary of call destination by count and duration.
#
# Example output: https://gist.github.com/technmsg/8247872
#

CDR="asterisk-cdr-csv.csv"
TOP=5
TOPX='head -'${TOP}
SORT='sort -t( -nr -k2'

DST_WEBEX="(6504793208|8776684493)"

# Pick a year or bunch of years.
if [ -z $@ ] ; then
  YEARS="2011 2012 2013 2014"
else
  YEARS=$@
fi

for YEAR in ${YEARS} ; do

  echo "== ${YEAR} =="

  echo
  # Total
  awk -F, \
  '/'${YEAR}'-/ { sum+=$14; count+=1 } END { sum/=60; printf "Total Calls: %d (%d mins)\n", count, sum }' \
  ${CDR}

  # WebEx conference calls
  awk -F, \
  '/'${DST_WEBEX}'.*'${YEAR}'-/ { sum+=$14; count+=1 } END { sum/=60; printf "WebEx Calls: %d (%d mins)\n", count, sum }' \
  ${CDR}
 
  echo
  echo "Top ${TOP} Destinations (count)"
  grep ${YEAR}- ${CDR} | cut -d, -f3 | sort -n | uniq -c | sort -rn | ${TOPX}
  #awk -F, '/'${YEAR}'-/{count[$3]++}END{for(j in count) print j,"("count[j]" calls)"}' ${CDR} | ${SORT} | ${TOPX}

  echo
  echo "Top ${TOP} Destinations (minutes)"
  awk -F, '/'${YEAR}'-/{count[$3]+=$14}END{for(j in count) printf "%4d %s\n", count[j]/60, j }' ${CDR} | ${SORT} | ${TOPX}

  echo

done

# EOF
