#########################################################################
##### GOA Dynamics Working Group                                    #####
##### Benthic Nearshore Group - Data Assembly script                #####
##### Created by Rachael Blake on Sept. 21, 2015                    #####
#########################################################################

## load packages (order matters)
library(httr)
library(plyr)
library(dplyr)
library(XML)
library(curl)
library(rvest)
library(tidyr)
library(stringr)


## Steps for adding data columns:
## 1) run each data cleaning script to generate data frames
## 2) create empty data frame
## 3) merge all data frames with CoPrct dataframe:   
##        CoPrct=merge(CoPrct,newData,all.x=T)  


# Source and run each data cleaning script
sourceDir <- function(path, trace=TRUE) {
    for (nm in list.files(path, pattern = "[.][RrSsQq]$")) {
       if(trace) cat(nm,":")
       source(file.path(path, nm))
       if(trace) cat("\n")
    }
}

sourceDir("Benthic_Nearshore_Drivers/Data_Cleaning_Scripts_DMX_Benthic_Nearshore")


# Create empty data frame with Year, Region, Site, and Quadrat columns
BenNearSites <- data.frame('Site_Name'=c("Aialik Bay","Amalik Bay","Bettles Bay","Cedar Bay",
                                         "Chinitna Bay","Chisik Island","Disk Island",
                                         "Esther Passage","Galena Bay","Harris Bay","Herring Bay",
                                         "Herring Bay-Bear Cove","Herring Bay-Southwest",
                                         "Hogan Bay","Iktua Bay","Johnson Bay","Johnson Creek",
                                         "Kaflia Bay","Kinak Bay","Kukak Bay","McCarty Fjord",
                                         "Ninagiak Island","Northwest Bay","Nuka Bay","Nuka Passage",
                                         "Observation Island","Olsen Bay","Perry Island",
                                         "Polly Creek","Port Fidalgo","Simpson Bay","Takli Island",
                                         "Tukendni Bay","Unakwik Inlet","Whale Bay")
                           )

BenNear <- BenNearSites %>% 
           mutate(Region = ifelse((Site_Name %in% c("Galena Bay","Observation Island",
                                                    "Olsen Bay","Port Fidalgo",
                                                    "Simpson Bay")),'EPWS',
                           ifelse((Site_Name %in% c("Amalik Bay","Kaflia Bay","Kinak Bay",
                                                    "Kukak Bay","Ninagiak Island",
                                                    "Takli Island")),'KATM',
                           ifelse((Site_Name %in% c("Aialik Bay","Harris Bay","McCarty Fjord",
                                                    "Nuka Bay","Nuka Passage")),'KEFJ',
                           ifelse((Site_Name %in% c("Chinitna Bay","Chisik Island","Johnson Creek",
                                                    "Polly Creek","Tukendni Bay")),'LACL',
                           ifelse((Site_Name %in% c("Bettles Bay","Cedar Bay","Esther Passage",
                                                    "Perry Island","Unakwik Inlet")),'NPWS',       
                           ifelse((Site_Name %in% c("Disk Island","Herring Bay",
                                                    "Herring Bay-Bear Cove","Herring Bay-Southwest",
                                                    "Hogan Bay","Iktua Bay","Johnson Bay",
                                                    "Northwest Bay","Whale Bay")),'WPWS',""))))))
    
                  ) %>%
           select(Region,Site_Name) %>%
           arrange(Region)

BenNear <- BenNear[rep(seq_len(nrow(BenNear)), each=6),]   # repeats data frame the number of years
BenNear$Year=rep(c(2010:2015))   # adds the year column with the years filled in
                      
BenNear <- BenNear[rep(seq_len(nrow(BenNear)), each=12),]   # repeats data frame the number of quadrats
BenNear$Quadrat=rep(c(1:12))   # adds the quadrat column with the quad # filled in
                         

# Merge in data columns generated by data cleaning scripts into one large data frame
BenNear <- merge(BenNear,ENSO_annual,all.x=T)    # ENSO annual
BenNear <- merge(BenNear,pdo_annual,all.x=T)     # PDO annual
BenNear <- merge(BenNear,npgo_annual,all.x=T)    # NPGO annual
BenNear <- merge(BenNear,upanom,all.x=T)         # Upwelling anomalies annual
BenNear <- merge(BenNear,Phy,all.x=T)            # Phytoplankton - Seward Line, spring
BenNear <- merge(BenNear,SatChl_df,all.x=T)      # Chla - Satellite annual
BenNear <- merge(BenNear,SST,all.x=T)            # SST - Seward Line
BenNear <- merge(BenNear,Wlk_GOA,all.x=T)        # Whelks (Nucella sp.)
BenNear <- merge(BenNear,SS_GOA,all.x=T)         # Sea Stars



BenNear <- arrange(BenNear, Region,Site_Name,Year,Quadrat)


# Optional: Write data frame to a CSV
#write.csv(BenNear, file = "BenNear.csv", row.names=FALSE)



##############################################################################################









