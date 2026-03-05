library(googledrive)
library(readr)
library(dplyr)
library(lubridate)

drive_auth()

drive_folder<-drive_get(as_id("1zQIy9SZ8IE3wgsL73Q-y74SMaq5rLx3N"))

drive_files <- drive_ls(drive_folder)

setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/Data/WQ_with_Q2")
WQ_Q_files = list.files()
clean_names <- as.list(sub("_merge.csv", "", WQ_Q_files))

for(i in 1:length(clean_names)){
  file_row <- drive_files %>%
    filter(name == paste0(clean_names[i],".csv"))
  
  if(nrow(file_row)==0){message("No matching file for following", clean_names[i])
    next
  }
  
  #Download temporarily
  
  tmp <- tempfile(fileext = ".csv")
  drive_download(as_id(file_row$id),
                 path = tmp,
                 overwrite = TRUE)
  
  # Read only required columns
  drive_df <- read_csv(tmp)
  timeformat = colnames(drive_df)[1]
  
  if(timeformat=="DateTime"){
  drive_df <- read_csv(tmp,
                       col_select = c("DateTime","Tair", "Rainf"))
  } else {
    drive_df <- read_csv(tmp,
                         col_select = c("time","Tair", "Rainf"))
  drive_df$DateTime = drive_df$time
  }
  
  # Join to local dataframe
  setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/Data/WQ_with_Q2")
  existing_merged <- read.csv(paste0(clean_names[i],"_merge.csv"))
  #existing_merged$DateTime = as.POSIXct(existing_merged$DateTime, format = "%Y-%m-%d %H:%M:%S")
  # existing_mergedv2 = existing_merged
  existing_merged$DateTime = dt <- parse_date_time(existing_merged$DateTime, orders = c("ymd HMS", "ymd", "dmy HMS", "dmy"))
    
  merge_w_climate <- left_join(existing_merged,drive_df,by="DateTime")
  setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/Data/WQ_with_Q_with_P")
  write.csv(merge_w_climate,paste0(clean_names[i],"_wclim.csv"))
}
