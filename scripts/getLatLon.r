library(zipcode)
library(choroplethr)
data(zipcode)
hospital.data.lat.lon <- hospital.data %>% 
  mutate(zip = paste(Provider.Zip.Code)) %>% 
  left_join(zipcode, by="zip")
source("getcounty.r")
counties <- hospital.data.lat.lon[, 17:16] %>% 
  filter(!is.na(latitude), !is.na(longitude)) %>% 
  latlong2county()
hospital.data.county <- hospital.data.lat.lon %>%
  filter(!is.na(latitude), !is.na(longitude))
data(county.fips)
hospital.data.county$county <- counties
hospital.data.counties <- hospital.data.county %>%
  select(Provider.City, county, Average.Covered.Charges, Average.Total.Payments) %>%  
  group_by(county) %>% 
  summarize(County.Covered.Charges = mean(as.numeric(gsub("\\$", "", Average.Covered.Charges)) / as.numeric(gsub("\\$", "", Average.Total.Payments)), na.rm = TRUE)) %>% 
  mutate(polyname = county) %>% 
  left_join(county.fips, by="polyname") %>% 
  mutate(value = County.Covered.Charges, region = fips) %>% 
  select(value, region)