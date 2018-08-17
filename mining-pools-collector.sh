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

OUTPUT_FILE_NAMES="pools-name.txt"
OUTPUT_FILE_IPS="pools-IP.txt"

POOLS_NAMES=()
POOLS_IPS=()

# Processing pools from plain text format
while IFS='' read -r line || [[ -n "$line" ]]; do
   if [[ "$line" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
      if [[ ! " ${POOLS_IPS[*]} " =~ " ${line} " ]]; then
         POOLS_IPS+=("${line}")
      fi 
   else
      if [[ ! " ${POOLS_NAMES[*]} " =~ " ${line} " ]]; then
         POOLS_NAMES+=("${line}")
      fi

   fi

done  < "/tmp/plain.txt"
rm /tmp/plain*

# Processing pools from csv format
while IFS='' read -r line || [[ -n "$line" ]]; do
   IFS=',' read -r -a array <<< "$line"
   
   if [[ "${array[0]}" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
      if [[ ! " ${POOLS_IPS[*]} " =~ " ${array[0]} " ]]; then
         POOLS_IPS+=("${array[0]}")
      fi 
   else
      if [[ ! " ${POOLS_NAMES[*]} " =~ " ${array[0]} " ]]; then
         POOLS_NAMES+=("${array[0]}")
      fi

   fi

done < "/tmp/csv.txt"
rm /tmp/csv*

# Printing unique pools to file
echo -n "" > $OUTPUT_FILE_NAMES
echo -n "" > $OUTPUT_FILE_IPS

for line in "${POOLS_NAMES[@]}"; do
   echo "${line}" >> $OUTPUT_FILE_NAMES
done

for line in "${POOLS_IPS[@]}"; do
   echo "${line}" >> $OUTPUT_FILE_IPS
done

echo "Unique pools name count:"
wc -l $OUTPUT_FILE_NAMES

echo "Unique pools IPs count:"
wc -l $OUTPUT_FILE_IPS

