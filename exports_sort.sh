#!/bin/bash

directory="./exports"  # Replace with the actual directory path
padding_length=4  # Replace with the desired padding length
count=1

# Change to the target directory
cd "$directory" || exit

# Iterate over the files in the directory sorted by creation time
for file in $(ls -t -r); do
  if [ -f "$file" ]; then  # Check if it's a regular file
    extension="${file##*.}"
    padded_count=$(printf "%0${padding_length}d" "$count")
    new_name="beat_em_high__$padded_count.$extension"
	 if [[ "$file" != "$new_name" ]]; then
    	mv "$file" "$new_name"
    	echo "Renamed $file to $new_name"
	 fi
    ((count++))
  fi
done
