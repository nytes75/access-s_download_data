#!/usr/bin/env bash
#                                                     
#===github:@nytes75=================================
#     _    ____ ____ _____ ____ ____       ____    
#    / \  / ___/ ___| ____/ ___/ ___|     / ___|    
#   / _ \| |  | |   |  _| \___ \___ \ ____\___ \ 
#  / ___ \ |__| |___| |___ ___) |__) |_____|__) |
# /_/   \_\____\____|_____|____/____/     |____/            
#  _   _ ____  ____    _  _____ _____ ____  
# | | | |  _ \|  _ \  / \|_   _| ____/ ___| 
# | | | | |_) | | | |/ _ \ | | |  _| \___ \ 
# | |_| |  __/| |_| / ___ \| | | |___ ___) |
#  \___/|_|   |____/_/   \_\_| |_____|____/ 

# Checking new updates added to the ACCESS-S cloud files
# RIGHT NOW WE TESTING ON |CREWS-PNG| PRODUCTS

# local[1]: 
multiday=true
weekly=true 
fortnightly=true
monthly=true
seasonal=true 

sp_monthly=true



# storage[1]
export url_crews="http://access-s.clide.cloud/files/project/PNG_crews/ACCESS_S-outlooks/PNG_crews"
export url_semdp="http://access-s.clide.cloud/files/project/PNG_crews/SEMDP-products/"
export path_crews="./ACCESS-S/index/updated_pages/png_crews"
export path_semdp="./ACCESS-S/index/updated_pages/SEMDP-products"

# local[2]: Testing 
testing_mode=false

# A regular expression pattern to match the date and time within <td> tags
date_pattern="([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} )" # dateFormat "2023-10-04 10:30 "

filter_html() {
  # Commenting Line Below For Reference
  filter_dates=($(echo "$1" | grep -Po "$date_pattern")) 
  echo ${filter_dates[@]}
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
    # climate Products = [ 'saved', 'url', 'saved_name']
    
    #==================[ ONE ]===========================
    #Follow Where these 3 variables going to be next: [1]
    
    filter_html_saved=($(filter_html "$1"))
    # request[2]
    local html_url=$(curl -s "$2")
    filter_html_url=($(filter_html "${html_url}"))
    formatted_saved=($(format_dates_and_store "${filter_html_saved[@]}"))
    formatted_url=($(format_dates_and_store "${filter_html_url[@]}")) 
    label_url=($(get_names "${html_url}"))
    #echo "${filter_html_url}" 
    
    #echo "${formatted_saved[@]}"
    #echo "||"
    #echo "${formatted_url[@]}"

    # Check if both arrays have the same length
    if [ ${#formatted_saved[@]} -ne ${#formatted_url[@]} ]; then
        echo "Arrays have different lengths, cannot display side by side."
        return
    fi
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
      echo  
      echo "-> Files have yet to be modified online:"
    elif [ $modified/$constant = 1 ]; then
        echo "-> All flies have been Modified"
        sleep 0.3
        echo "> Do you wish to continue with update [Y/n]"
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
              sleep 0.8
              echo 
              # Saving/Updating the last saved webpage to lastest
              echo $html_url > "$3" 
              sleep 1
              echo "-|| Files Updated ||-"
              echo
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

#=========STARTING POINT==========
#+++++++++++++++++++++++++++++++++

if [ "$testing_mode" = true ]; then
  echo "Testing Phase local[2]"

else
  # +++========================+++
  # ------PNG CREWS PRODUCTS------
  # Still Tesing the Scripts

   for type in "weekly" "fortnightly" "monthly" "seasonal"; do
    var_name="$type"
    if [ "${!var_name}" = true ]; then
      url="${url_crews}/${type}/forecast/"
      saved_path="${path_crews}/${type}/png_crews_access_s-outlooks_png_crews_${type}_forecast.html"
      echo "Processing $type..."
      sleep 1

      # storage[2]
      crews_saved_content="$(cat -s $saved_path)"
       # array[1]
      # Climate Products = ['saved', 'url', 'url_name']
      crews_content=("$crews_saved_content" "$url" "$saved_path")
      
      # Check for internet Connections
      # request[1]
      if curl -s --head "$url" | grep "200 OK" > /dev/null; then
        echo "Connection: Successful"
        format_and_display "${crews_content[@]}"
      else
        echo "Connection: Failed"
       fi 
    fi
  done   
    
fi
