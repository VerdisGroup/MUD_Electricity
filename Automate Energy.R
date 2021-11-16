library(readxl)
library(lubridate)
library(tidyverse)
library(dbplyr)
library(plyr)
library(purrr)
library(tibble)
library(janitor)
library(plotly)

options(scipen = 999)

#Get data
Sheets <- excel_sheets("~/Documents/Verdis Data/MUD/Automate Energy Data/MUD Energy Data 2020-2021.xlsx")
str(All_Sheets)
service_points <- read_excel("~/Documents/Verdis Data/MUD/Automate Energy Data/MUD Energy Data 2020-2021.xlsx", skip = 2)
print(Sheets)

#Read All sheets
Raw_MUD<- "~/Documents/Verdis Data/MUD/Automate Energy Data/MUD Energy Data 2020-2021.xlsx"
All_Sheets <- lapply(Sheets, function(x) read_excel(path = Raw_MUD, sheet = x))
str(All_Sheets)

#Meter ID
Point <- as.list(service_points$Address, na = TRUE)
Meter_ID <- as.list(service_points$Point, na = TRUE)

#Convert data into similar format to tracking sheet

#list modification
### Find KWH
pluck(All_Sheets, 3,"...9")
??purrr::map


kWh <- map(All_Sheets[3:39], "...9", print)
Date <- map(All_Sheets[3:39], "BILL CYCLE", print)

##Stack horizontal data into vertical columns and Clean names
kWh <- kWh %>% data.frame() %>% stack()
colnames(kWh) <- c("kWh", "Rubish")

Date <- Date %>% data.frame() %>% stack()
colnames(Date) <- c("Date", "Trash")


Electricity <- data.frame(kWh) 

#Clean date cereal numbers
Electricity$Date <- Date$Date
Electricity$Date <- Electricity$Date %>%
  as.numeric() %>% convert_to_date( character_fun=lubridate::ymd, truncated=1, tz="UTC")

#Repeating meter and point lists 
Electricity$Address <- as.character(rep(Meter_ID[-38], each = 56))
Electricity$Points <- as.character(rep(Point[-38], each = 56))

Electricity$kWh <- as.numeric(Electricity$kWh)


Electricity <- Electricity[ ,-c(2)]
Electricity <- na.omit(Electricity)

plot <- ggplot(Electricity, mapping =  aes(x = Date, y = kWh, text= paste('Address:', Address, 
                                                                          '<br>Point_ID:',Points), 
                                           fill = Points)) +
  geom_point()

ggplotly(plot)

write_csv(Electricity, "~/Documents/MUD/MUD_2021_electricity_updates")

git remote add origin ttps://github.com/VerdisGroup/VGMUD.git





