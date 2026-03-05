#######Create_One_WQ_Database_each_site#########

require(dplyr)
require(lubridate)

###Creating lists of available sites for parameters and Q###
#Create list of all Q data
setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/09_streamflow_discharge/09_streamflow_discharge")
Q_sites = list.files()


setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM")
all_WQ_avail = read.csv("metadata_parameters_identified.csv",sep=",")
all_sites_list = all_WQ_avail$STREAM_ID
n.all_sites = length(all_sites_list)
# n.all_sites <- n.all_sites[ !n.all_sites %in% c("STREAM-gauge-4431", "STREAM-gauge-4432") ]

setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/02_waterquality_timeseries/02_waterquality_timeseries")
files_in_folder = list.files()

for(i in 1:n.all_sites){
  site = all_sites_list[i]
  setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/02_waterquality_timeseries/02_waterquality_timeseries")
  file_name=paste0(site,".csv")
  if(!file_name %in% files_in_folder){
    next
  }
  
  WQ_site_og = read.csv(file_name,sep=",")
  WQ_site = WQ_site_og
  WQ_site$DateTime = as.POSIXct(WQ_site_og$DateTime, format = "%Y-%m-%d %H:%M")

  if (file_name %in% Q_sites) {
    setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/09_streamflow_discharge/09_streamflow_discharge")
    Q_site_og = read.csv(file_name,sep=",")
    Q_site = Q_site_og
    Q_site$DateTime = as.POSIXct(Q_site_og$DateTime, format = "%Y-%m-%d %H:%M")
    merged_data_WQ_Q <- merge(WQ_site, Q_site, by = "DateTime",all.x=TRUE)
    setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/Data/WQ_with_Q")
    write.csv(merged_data_WQ_Q,paste0(site,"_merge",".csv"))
  }  else {
    merged_data_WQ_Q = WQ_site
    merged_data_WQ_Q$Q_m3s<-NA
    merged_data_WQ_Q$Flag_Q_m3s<-"NoQ"

    merged_data_WQ_Q$DateTime = as.POSIXct(merged_data_WQ_Q$DateTime,format = "%Y-%m-%d %H:%M:%S")
    setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM/Data/WQ_with_Q")
    write.csv(merged_data_WQ_Q,paste0(site,"_merge",".csv"))
  }
  
}


#################
#Create list of all WQ data (SC, Turb, NO3, temp)
setwd("C:/Users/lanna/Dropbox/Research/Projects/STREAM")
all_WQ_avail = read.csv("metadata_parameters_identified.csv",sep=",")
SpC_sites = all_WQ_avail %>% filter(is_SpC==TRUE)
SpC_sites = SpC_sites %>% select(STREAM_ID)
Q_SpC = inner_join(Q_sites,SpC_sites,by="STREAM_ID")

Turb_sites = all_WQ_avail %>% filter(is_Turb_FNU==TRUE)
Turb_sites = Turb_sites[["STREAM_ID"]]
Turb_sites = inner_join(Q_sites,Turb_sites)

NO3_sites = all_WQ_avail %>% filter(is_NO3_mgNL==TRUE)
NO3_sites = NO3_sites[["STREAM_ID"]]
NO3_sites = inner_join(Q_sites,NO3_sites)
