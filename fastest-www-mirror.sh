#~/bin/sh

STATS=/tmp/.fastest-www-mirror.$$
echo > $STATS

function cleanup {
  rm -rf $STATS
  exit
}

trap cleanup 2 3 9 15

hosts=$(curl -s https://www.openbsd.org/ftp.html | \
  grep '"https://.*/pub/OpenBSD/"' | \
  sed 's/.*\/\/\(.*\)\/pub\/OpenBSD\/.*/\1/' | \
  grep -v ^$)

for host in $hosts; do
  time=$(ping -w2 -c1 $host 2> /dev/null | grep -o 'time=.*' | sed 's/time=\(.*\)/\1/')
  if [ "$time" != "" ]; then
    echo $host $time >> $STATS
    echo $host $time
  fi
done

MIRROR=$(cat $STATS | grep -v "^$" | sort -k2 -n | head -1)
echo "\n"
echo "********************************************"
echo " fastest mirror: $MIRROR"
echo "********************************************"

