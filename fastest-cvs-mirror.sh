#~/bin/sh

STATS=/tmp/.fastest-cvs-mirror.$$

echo > $STATS

function cleanup {
  rm -rf $STATS
  exit
}

trap cleanup 2 3 9 15

HOSTS=$(curl -s https://ftp.openbsd.org/anoncvs.html | \
  grep 'CVSROOT=anoncvs@.*:/cvs' | \
  sed 's/.*\@\(.*\)\:.*/\1/')

for host in $HOSTS; do
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

