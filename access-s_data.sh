#!/bin/bash

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
download_weekly=true     # Default false
download_monthly=true     # Default true
download_seasonal=true   # Default false

# Define the base URL
base_url="http://access-s.clide.cloud/files/global/"

# Main folder where data will be stored
main_folder="ACCESS-S/data"

# The variables to download
variables="anom median terciles"

# Loop through the variables
for var in $variables; do
    if [ "$download_weekly" = true ]; then
        dir="weekly"
        # Construct the file pattern for weekly
        file_pattern="rain.forecast.$var.weekly.nc"
        full_url="${base_url}${dir}/data/${file_pattern}"
        
        # Check if the URL is responsive
        if check_url "$full_url"; then
            # Create a subfolder for weekly data
            mkdir -p "$main_folder/$dir"
            
            # Download the file to the subfolder
            wget -P "$main_folder/$dir" -nc -nd --no-check-certificate "$full_url"
            sleep $((RANDOM % 3 + 1))
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
