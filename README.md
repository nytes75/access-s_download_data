# ACCESS-S NetCDF Data Download Script

This Bash script is designed for downloading ACCESS-S (Australian Community Climate and Earth System Simulator - Seasonal) netCDF data files from a specified base URL. The script allows you to customize which types of data (weekly, monthly, or seasonal) and which variables (anom, median, terciles) you want to download. It also checks if the URLs are responsive before initiating downloads.

## About 

The script gets the netCDF data files for *rain*. The following variables are downloaded:
- Anomaly (anom)
- Median (median)
- Terciles (terciles)

You can choose to download these variables for different time intervals, including:

- Weekly data
- Monthly data
- Seasonal data

The script checks the responsiveness of the provided URLs before initiating downloads and handles them accordingly.

## ⚡️ Quick start

1. Clone or download the script to your local machine.

2. Make sure you have wget installed. If it's not already installed, you can typically install it using package managers like apt or yum.

3. Open a terminal and navigate to the directory where the script is located.

4. Modify the script settings:

  - Set the download_weekly, download_monthly, and download_seasonal variables to true or false based on your data download preferences.
  - Adjust the base_url variable if your data source URL is different.
  - Specify the main folder where you want the data to be stored in the main_folder variable.
  - Save your changes and run the script using the following command:

```bash
bash access-s_data.sh
```

5. The script will start downloading the specified data files based on your settings. It will create subfolders for weekly, monthly, and seasonal data within the main folder.

6. The script will check if the URLs are responsive before initiating downloads. If a URL is unresponsive, it will be reported in the terminal.

7. The script includes a random sleep period between downloads to prevent overwhelming the server.

8. Once the script completes, you'll find the downloaded data in the specified main folder, organized by data type and variable.

You can now use the downloaded netCDF data for your analysis and research.

Enjoy using this script to download ACCESS-S netCDF data efficiently!
