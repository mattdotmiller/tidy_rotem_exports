## Matthew Miller (C) 2019
##
## This program is  WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  It has been written for research/academic non-commercial use.


#if you do not have pacman installed run :install.packages("pacman")
library(pacman)
p_load(tidyverse, checkmate, stringr, lubridate, gdata, readxl, gmodels, naniar, openxlsx, ggpubr, janitor, skimr, REDCapR, hablar, mefa)



# STEP 1 ------------------------------------------------------------------


# load txt file, clean names, remove * ------------------------------------
path_to_file = file.path("input the path to your ROTEM sigma .txt file") # to enter the filepath correctly
# you dont need to enter the \ , just enter the folders like ("C:", "ROTEM" , "Backups" , "filename.txt")

rotem <- read_delim(path_to_file, "\t", escape_double = FALSE, trim_ws = TRUE)%>%
  clean_names()%>%
  select(-image_filename, -sex, -birth_date, -te_mogram_link, -starter, -stopper,-lot, -comment,  -saved_by,- channel,  -error_code, -flags, -serial_nr_cartridge, -profile)%>%
  mutate_all(funs(str_replace(., "[*]", "")))%>%
  convert(num(ct,a5,a10,a20,a30,cft,mcf,li30,li45,li60,ml))%>%
  # the text in brackets below lets you filter out names of test or calibration ROTEMS
  filter(patient_name != "training, training", patient_name != "ABC, DEF", patient_name != "demo, demo")%>%
  mutate(start_time = ymd_hms(start_time))%>%
  arrange(start_time)%>%
  #the next line creates an ID from the patient id and ROTEM start time - this is just used as a sample ID number
  mutate(uni_id = if_else(test_name == "fibtem c", (str_c(patient_id, hour(start_time), minute(start_time), sep = "-")), NA_character_, NA_character_))%>%
  mutate(uni_id = fill.na(uni_id))%>%
  mutate(rotem_start_time = if_else(test_name == "fibtem c", str_c(start_time), NA_character_, NA_character_))%>%
  mutate(rotem_run_time = if_else(test_name == "fibtem c", str_c(run_time), NA_character_, NA_character_))%>%
  mutate(rotem_start_time = fill.na(rotem_start_time))%>%
  mutate(rotem_run_time = fill.na(rotem_run_time))


# STEP 2 ------------------------------------------------------------------


#make it wide, this essentially creates the tidy data
wide_rotem <- rotem%>%
  group_by(uni_id)%>%
  pivot_wider(names_from = test_name, values_from = c(start_time, run_time, ct,a5,a10,a20,a30,cft,mcf,li30,li45,li60,ml))


# STEP 3 ------------------------------------------------------------------


#define as likely cardiac or not
# only run this if you want this as an extra column for later

rotem_final <- wide_rotem%>%
  mutate(possible_cardiac = if_else(is.na(`start_time_heptem c`), "no", "yes", "no"))%>%
  mutate(patient_name = "")%>%
  clean_names()


# STEP 4 ------------------------------------------------------------------


# upload to redcap --------------------------------------------------------



uri       <- "input your REDCAP URI"
api_key <- "input your RECAP project API key"



#create new record
redcap_write(ds=rotem_final, redcap_uri=uri, token=api_key)



# STEP 5 ------------------------------------------------------------------


# upload images -----------------------------------------------------------

image_upload <- rotem_final%>%
  select(uni_id, patient_id, rotem_start_time, start_time_fibtem_c, start_time_extem_c, start_time_intem_c,
         start_time_heptem_c, start_time_aptem_c)%>%
  mutate(patient_id = str_replace(patient_id, ".STG", "STG"))%>%#this is specific to my hospital, used to get rid of the '.' in the MRN. 
  mutate(patient_id = str_replace(patient_id, ".stg", "stg"))%>%
  mutate(file.year = str_sub(year(rotem_start_time), -2),
         file.month = str_pad(month(rotem_start_time), width = 2, side = ("left"), pad = "0"),
         file.day = str_pad(day(rotem_start_time), width = 2, side = ("left"), pad = "0")) %>%
  mutate(heptem.fn = str_c(patient_id, "_heptem c_", file.year, file.month, file.day,
                   str_pad(hour(start_time_heptem_c),width = 2, side = ("left"), pad = "0"),
                   str_pad(minute(start_time_heptem_c),width = 2, side = ("left"), pad = "0"),
                   str_pad(second(start_time_heptem_c),width = 2, side = ("left"), pad = "0"),
                   "000", ".jpg"),
         intem.fn = str_c(patient_id, "_intem c_", file.year, file.month, file.day,
                          str_pad(hour(start_time_intem_c),width = 2, side = ("left"), pad = "0"),
                                  str_pad(minute(start_time_intem_c),width = 2, side = ("left"), pad = "0"),
                                          str_pad(second(start_time_intem_c),width = 2, side = ("left"), pad = "0"),
                  "000",".jpg"),
         extem.fn = str_c(patient_id, "_extem c_", file.year, file.month, file.day,
                          str_pad(hour(start_time_extem_c),width = 2, side = ("left"), pad = "0"),
                          str_pad(minute(start_time_extem_c),width = 2, side = ("left"), pad = "0"),
                          str_pad(second(start_time_extem_c),width = 2, side = ("left"), pad = "0"),
                  "000",".jpg"),
         fibtem.fn = str_c(patient_id, "_fibtem c_", file.year, file.month, file.day,
                           str_pad(hour(start_time_fibtem_c),width = 2, side = ("left"), pad = "0"),
                           str_pad(minute(start_time_fibtem_c),width = 2, side = ("left"), pad = "0"),
                           str_pad(second(start_time_fibtem_c),width = 2, side = ("left"), pad = "0"),
                   "000",".jpg"),
         aptem.fn = str_c(patient_id, "_aptem c_", file.year, file.month, file.day,
                          str_pad(hour(start_time_aptem_c),width = 2, side = ("left"), pad = "0"),
                          str_pad(minute(start_time_aptem_c),width = 2, side = ("left"), pad = "0"),
                          str_pad(second(start_time_aptem_c),width = 2, side = ("left"), pad = "0"),
                  "000",".jpg")) %>%
  select(uni_id, heptem.fn, intem.fn, extem.fn, fibtem.fn, aptem.fn) %>%
  pivot_longer(-uni_id, names_to= "test", values_to = "filename") %>%
  na.omit()
  
fn <- image_upload$filename
rid <- image_upload$uni_id


rotemImageUpload <- function(x, y) {
  file.name <- x
  record.id <- y
  file_path <- file.path("path to the folder with the image files", file.name)
  field <- if_else(str_detect(file.name,"fibtem"), "fibtem_image",
                   if_else(str_detect(file.name,"aptem"), "aptem_image",
                           if_else(str_detect(file.name,"intem"), "intem_image",
                                   if_else(str_detect(file.name,"extem"), "extem_image",
                                           if_else(str_detect(file.name,"heptem"), "heptem_image", NA_character_ , NA_character_)))))
  
  images_in_folder <- list.files(file.path("path to the folder with the image files"))
  
  if  (any(grepl(file.name,images_in_folder)) == TRUE) {
  
  redcap_upload_file_oneshot(file_name = file_path, record = record.id, field = field,
    redcap_uri = uri, token = api_key)
  
    
  file.move.path <- file.path("path to the folder with the image files", file.name)
  file.rename(file_path, file.move.path)
  
}

}

map2(.x=fn, .y=rid, .f=rotemImageUpload) 
