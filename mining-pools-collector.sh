#!/bin/bash

# Sources in plain text, one per line
PLAIN1="https://raw.githubusercontent.com/andoniaf/mining-pools-list/master/mining-pools.lst"
PLAIN2="https://raw.githubusercontent.com/andoniaf/mining-pools-list/master/mining-pools_IP.lst"

# Sources in CSV format
CSV1="https://raw.githubusercontent.com/antoinet/cryptoioc/master/pools.csv"


# Downloading sources
wget $PLAIN1 -O /tmp/plain1.txt
wget $PLAIN2 -O /tmp/plain2.txt

wget $CSV1 -O /tmp/csv1.txt

# Concatenating sources to files according to type
cat /tmp/plain1.txt /tmp/plain2.txt > /tmp/plain.txt
cat /tmp/csv1.txt > /tmp/csv.txt

OUTPUT_FILE="pools.txt"

POOLS=()

# Processing pools from plain text format
while IFS='' read -r line || [[ -n "$line" ]]; do
   if [[ ! " ${POOLS[@]} " =~ " ${line} " ]]; then
      POOLS+=(${line})
   fi
done  < "/tmp/plain.txt"
rm /tmp/plain*

# Processing pools from csv format
while IFS='' read -r line || [[ -n "$line" ]]; do
   IFS=',' read -r -a array <<< "$line"
   if [[ ! " ${POOLS[@]} " =~ " ${array[0]} " ]]; then
      POOLS+=(${array[0]})
   fi

done < "/tmp/csv.txt"
rm /tmp/csv*

# Printing unique pools to file
echo -n "" > $OUTPUT_FILE

for line in ${POOLS[@]}; do
   echo ${line} >> $OUTPUT_FILE
done

echo "Unique pools count:"
wc -l $OUTPUT_FILE



