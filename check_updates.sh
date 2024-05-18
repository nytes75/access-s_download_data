#!/usr/bin/env bash
#                                                    ___  
#===github:@nytes75=================================| _ |
#     _    ____ ____ _____ ____ ____       ____     | _ |
#    / \  / ___/ ___| ____/ ___/ ___|     / ___|    |___|
#   / _ \| |  | |   |  _| \___ \___ \ ____\___ \ 
#  / ___ \ |__| |___| |___ ___) |__) |_____|__) |
# /_/   \_\____\____|_____|____/____/     |____/            
#  _   _ ____  ____    _  _____ _____ ____  
# | | | |  _ \|  _ \  / \|_   _| ____/ ___| 
# | | | | |_) | | | |/ _ \ | | |  _| \___ \ 
# | |_| |  __/| |_| / ___ \| | | |___ ___) |
#  \___/|_|   |____/_/   \_\_| |_____|____/ 

# Checking new updates added to the ACCESS-S cloud files

# local[1]: change this dir 
export DL_DIR=./index/              # Folder to store [index].html file

# request[2]: These will be passed in as Args
download_access=true                # Default: true
download_access_rain_terciles=true  # Default: true
download_access_mjo=true            # Default: true

# local[2]: Testing 
testing_mode=false                  # Default: false 

if [ "$testing_mode" = true ]; then
  echo "Testing Phase local[2]"
else
  # request[1]: URL 
  # The URL and Args will come from Download Scripts
  url_wkf="http://access-s.clide.cloud/files/project/PNG_crews/ACCESS_S-outlooks/PNG_crews/weekly/forecast/"
sat_webpage_content="$(curl -s "$url_wkf")"

fi

check_storage_folder()
{
    # Check if folder exists
  if [ ! -d "$folder" ]; then
    echo "Folder '$folder' not found. Creating..."
    mkdir -p "$folder"  # Create folder if it doesn't exist
  else
      echo "Folder '$folder' already exists."
  fi

    # Check if file exists
  if [ ! -f "$folder/$file" ]; then
      echo "File '$file' not found in '$folder'. Creating..."
      touch "$folder/$file"  # Create file if it doesn't exist
  else
      echo "File '$file' already exists in '$folder'."
  fi
}

filter_html() {
  # Commenting Line Below For reference
  filter_dates=($(echo "$1" | grep -Po "$date_pattern")) 
  echo ${filter_dates[@]}
}

function validate_url()
{
	if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
		echo "Connection: Successful";
    echo $1
    format_and_display $1	
  else
		echo "Connection: Failed";
  fi 
}

get_names() {
    local input_array=("$1") 
    # Define a regular expression pattern to match additional information within other <td> tags
    other_info_pattern="<td><a (.*?)>(.*?)</a></td>"
    # saved_webpage1_content <- 
    IFS=$'\n' read -r -d '' -a array <<< "$(echo "$input_array" | sed -E 's/[[:space:]]*~[[:space:]]*│[[:space:]]*//g' | grep -Po '<a[^>]*>\K(.*?)(?=<\/a>)')"

    # Initialize an empty array to store filtered items
    filtered_array=()
    # Loop through the original array and filter items
    for item in "${array[@]}"; do
      # Use a case statement to check file extensions
      case "$item" in
        *.png|*.gif|*.jpg)
            # If the file has a valid extension, add it to the filtered array
            filtered_array+=("$item")
            ;;
        *)
            # Ignore items with other extensions
            ;;
      esac
    done
    echo "${filtered_array[@]}"
 }

# Stricly for the dates
format_dates_and_store() {
    local input_array=("$@")  # Store the passed array in a local variable
    local output_array=()     # Initialize an empty array for storing formatted values
    local i=0

    while [ $i -lt ${#input_array[@]} ]; do
        local date="${input_array[$i]}"
        local time="${input_array[$i+1]}"
        local formatted="${date} ${time}"
        output_array+=("$formatted")
        ((i+=2))
    done

    # Return
    echo "${output_array[@]}"
}

format_and_display() {
    modified=0
    constant=0 
    # Check file and directory

    #==================[ ONE ]===========================
    #Follow Where these 3 variables going to be next: [1]
    
    filter_html_saved=($(filter_html "$1"))
    filter_html_url=($(filter_html "$2"))
    formatted_saved=($(format_dates_and_store "${filter_html_saved[@]}"))
    formatted_url=($(format_dates_and_store "${filter_html_url[@]}")) 
    label_url=($(get_names "$2"))

    # Check if both arrays have the same length
    if [ ${#formatted_saved[@]} -ne ${#formatted_url[@]} ]; then
        echo "Arrays have different lengths, cannot display side by side."
        return
    fi
    #echo "${formatted_url[@]}"
    #echo "${formatted_dates[@]}"

    # formatted_dates and formatted_url have an array length of 6 while labels have only 3
    for ((i = 0; i < ${#formatted_saved[@]}; i++)); do
        local label="${label_url[$i/2]}"  # Due to arrays formatted_url & formatted_dates having 2X the size
        local date1="${formatted_saved[$i]}"
        local time1="${formatted_saved[$i+1]}"
        local date2="${formatted_url[$i]}"
        local time2="${formatted_url[$i+1]}"
    
        if [ "$date1 $time1" != "$date2 $time2" ]; then
            modified=$((modified+1))
            echo "$date1 $time1 | $date2 $time2 |: Modified :| $label"
        else 
            constant=$((constant+1))
            echo "$date1 $time1 | $date2 $time2 || Constant || $label"
        fi
        #echo "$date1 $time1 | $date2 $time2"
        ((i++)) 
    done

    if [ $modified = 0 ]; then
        echo "Files have yet to be modified online:"
    elif [ $modified/$constant = 1 ]; then
        echo "All flies have been Modified"
        sleep 0.3
        echo "Do you wish to continue with update [Y/n]"
    else
        echo "we have $modified modified and $constant constant"
        sleep 1
        echo
        while true; do
          read -p "Do you wish to continue with the Update [Y/n]: " choice
          case "$choice" in
            [Yy])
              echo "Continuing..."
              sleep 0.8
              echo "Updating Product"
              echo "----------------"
              echo $2 > "$3" 
              sleep 1
              echo "-Files Updated-"

              # Add your code here to continue
              break
              ;;
            [Nn])
              echo "Exiting..."
              # Add your code here to handle the exit or anything else you want to do
              break
              ;;
            *)
              echo "Invalid key. Please press Y if you wish to continue with the update or n to exit."
              ;;
          esac
        done    
    fi
}
validate_url ${url_wkf} 
