#!/bin/bash

testing_mode=true   #disable : [false] when ready

# Function to check if a URL is responsive
check_url() {
    url_to_check=$1
    if wget -q --spider "$url_to_check"; then
        return 0 # URL is responsive
    else
        return 1 # URL is not responsive
    fi
}

# Set flags for different types of downloads
download_weekly=false     # Default false
download_monthly=true     # Default true
download_seasonal=false   # Default false

# Base URL
base_url="http://access-s.clide.cloud/files/global/"

# Main folder
main_folder="ACCESS-S/data"

# Variables to download ||anom||median||terciles||
variables="anom median terciles"


function clean_archive {
	#	#Remove maps older than 1 months (based on file creation)
  #Smoother Approach
	find ${main_folder}/$1/ -name '*.nc' -delete 2>/dev/null
  # Brute Force Delete folder
  #rm -rf ${main_folder}/
  echo "$main_folder/$1/"
	echo "Cleaned $1 folder"
  sleep 0.6
}

# Download The NetCDF Data
for var in $variables; do
    if [ "$download_weekly" = true ]; then
        dir="weekly"
        clean_archive "$dir"
        # Construct the file pattern for weekly
        #find ${main_folder} -name '*.nc' -mtime +40 -type f -delete 2>/dev/null
        #echo "Cleaned $dir folder.."
      
        file_pattern="rain.forecast.$var.weekly.nc"
        full_url="${base_url}${dir}/data/${file_pattern}"
        
        # Check if the URL is responsive
        if check_url "$full_url"; then
            # Sub-DIRECTORY 
            mkdir -p "$main_folder/$dir"  # <--- $dir; lets change to run date or [date Modified]
            # Download
            wget -P "$main_folder/$dir" -nc -nd --no-check-certificate "$full_url"
            sleep $((RANDOM % 3 + 1)) # <--- create a human like approach in downloading
        else
            echo "URL is not responsive: $full_url"
        fi
    fi

    if [ "$download_monthly" = true ]; then
        dir="monthly"
        # Construct the file pattern for monthly
        file_pattern="rain.forecast.$var.monthly.nc"
        full_url="${base_url}${dir}/data/${file_pattern}"
        
        # Check if the URL is responsive
        if check_url "$full_url"; then
            # Create a subfolder for monthly data
            mkdir -p "$main_folder/$dir"
            
            # Download the file to the subfolder
            wget -P "$main_folder/$dir" -nc -nd --no-check-certificate "$full_url"
            sleep $((RANDOM % 3 + 1))
        else
            echo "URL is not responsive: $full_url"
        fi
    fi

    if [ "$download_seasonal" = true ]; then
        dir="seasonal"
        # Construct the file pattern for seasonal
        file_pattern="rain.forecast.$var.seasonal.nc"
        full_url="${base_url}${dir}/data/${file_pattern}"
        
        # Check if the URL is responsive
        if check_url "$full_url"; then
            # Create a subfolder for seasonal data
            mkdir -p "$main_folder/$dir"
            
            # Download the file to the subfolder
            wget -P "$main_folder/$dir" -nc -nd --no-check-certificate "$full_url"
            sleep $((RANDOM % 3 + 1))
        else
            echo "URL is not responsive: $full_url"
        fi
    fi
done
