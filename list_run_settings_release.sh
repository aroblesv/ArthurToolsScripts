#Parameters
CURRENT=`pwd`
LIST_FILE=$1
#LIST_FILE=$CURRENT/$1

#Local Variables

echo -e "\rcheck status"
while read node
        do
          [[ "${node:0:1}" == "#" ]] && continue
          NODE_ID=`grep $node $LIST_FILE | cut -d "," -f 1`
        $CURRENT/run_settings_release.sh $NODE_ID &
        done < $LIST_FILE

