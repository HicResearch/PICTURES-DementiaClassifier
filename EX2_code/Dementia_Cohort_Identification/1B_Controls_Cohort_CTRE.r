###################################
# 1B_Controls_Cohort_CTRE.r
#
# Purpose:
# Construct non-dementia control cohort
#
# Inputs:
# - Dementia cohort (to exclude)
# - Clinical datasets
#
#
# Outputs:
# - Final_Non_Dementia_cohort.csv
#
# Author: PS Reel (psreel@dundee.ac.uk)
###################################

library(DBI)
library(dplyr)
library(stringr)
library('odbc')

# Load All Dementia patients
All_dementia <- read.csv('/home/ubuntu/Desktop/Working_Scripts/Final_Dementia_cohort.csv')
length(unique(All_dementia$PROCHI))
dementia_PROCHI <- All_dementia$PROCHI

# Load Metadata
eDRIS_metadata <- read.csv(X, stringsAsFactors = FALSE)

#remove dementia patients from Metadata 
non_dementia <- eDRIS_metadata %>% anti_join(All_dementia,by="PROCHI") 
non_dementia_PROCHI <- length(unique(non_dementia$PROCHI))
modality_pattern <- c('T1','t1')
non_dementia_T1 <- non_dementia %>% mutate(StudyDate=as.Date(str_split(StudyDate, " ",simplify = TRUE)[,1], format = "%d/%m/%Y")) %>% 
  filter(str_detect(SeriesDescription, paste(modality_pattern,collapse = "|"))) #%>%
  #select(PROCHI)
non_dementia_T1_PROCHI <- unique(non_dementia_T1$PROCHI)

con <-  dbConnect(odbc(), database = "X", server = "X",
                  driver = "/opt/microsoft/msodbcsql18/lib64/libmsodbcsql-18.3.so.1.1",
                  TrustServerCertificate = "Yes", Uid = "X")

# Find alive and dead non-dementia patients 
GRO <- dbGetQuery(con, '
                  select "PROCHI", "DtDeath"
                  from "Deaths_NRS" ')
#non_dementia_alive <- non_dementia_T1 %>% anti_join(GRO,by="PROCHI") 
#non_dementia_alive_PROCHI <- unique(non_dementia_alive$PROCHI)

non_dementia_dead <- data.frame(PROCHI = unique(non_dementia_T1$PROCHI)) %>% inner_join(GRO,by="PROCHI") 


# For all non-dementia patients (dead & alive)
#Find the most recent event and followup for these non-dementia patients in 2 databases (SMR01 & SMR04)

# SMR01
SMR01 <- dbGetQuery(con, '
  select "PROCHI", "ADMISSION_DATE", "DISCHARGE_DATE", "MAIN_CONDITION","OTHER_CONDITION_1", "OTHER_CONDITION_2","OTHER_CONDITION_3", "OTHER_CONDITION_4", "OTHER_CONDITION_5"
  from "SMR01_Admissions" 
  ')
SMR01_data <- SMR01 %>% filter_at(.vars = vars(PROCHI), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(non_dementia_T1_PROCHI,collapse = "|"), ")" ))))
SMR01_data_out <- SMR01_data %>% group_by(PROCHI) %>%
  summarise(Latest_Event_Date = max(as.Date(ADMISSION_DATE)),no_events = n(), Most_Freq_ICD_Main = names(which.max(table(MAIN_CONDITION))),
            Most_Freq_ICD_percent = round(100*((sum(MAIN_CONDITION %in% Most_Freq_ICD_Main))/no_events),1))
View(summary(as.factor(SMR01_data_out$Most_Freq_ICD_Main)))
colnames(SMR01_data_out)[-1] <- paste("SMR01", colnames(SMR01_data_out[-1]), sep="_")


# SMR04
SMR04 <- dbGetQuery(con, '
  select "PROCHI", "ADMISSION_DATE", "MAIN_CONDITION","OTHER_CONDITION_1", "OTHER_CONDITION_2",   "OTHER_CONDITION_3", "OTHER_CONDITION_4", "OTHER_CONDITION_5"
  from "SMR04_Psychiatric" 
  ')
SMR04_data <- SMR04 %>% filter_at(.vars = vars(PROCHI), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(non_dementia_T1_PROCHI,collapse = "|"), ")" ))))
SMR04_data$MAIN_CONDITION[which(is.na(SMR04_data$MAIN_CONDITION))]='None'
SMR04_data_out <- SMR04_data %>% group_by(PROCHI) %>%
  summarise(Latest_Event_Date = max(as.Date(ADMISSION_DATE)),no_events = n(), Most_Freq_ICD_Main = names(which.max(table(MAIN_CONDITION))),
            Most_Freq_ICD_percent = round(100*((sum(MAIN_CONDITION %in% Most_Freq_ICD_Main))/no_events),1))
View(summary(as.factor(SMR04_data_out$Most_Freq_ICD_Main)))
colnames(SMR04_data_out)[-1] <- paste("SMR04", colnames(SMR04_data_out[-1]), sep="_")

# NO Need of prescription
# #prescription records
# # find non-dementia prochis in pesctipion database
# prescribed_non_dementia_alive <- dbGetQuery(con, paste0("
#   SELECT PROCHI, quantity, res_seqno, corrected_PRESCRIBED_DATE
#   FROM Prescribing
#   WHERE PROCHI IN (", paste0("'",paste( non_dementia_alive_PROCHI, sep = "_",collapse="','"),"'") , ")") )
# 
# pres_data_out <- prescribed_non_dementia_alive %>% na.omit() %>% filter(corrected_PRESCRIBED_DATE < "2021-01-01") %>%
#   group_by(PROCHI) %>% arrange(desc(corrected_PRESCRIBED_DATE)) %>% 
#   mutate(no_pres_data = max(row_number()), Latest_corrected_PRESCRIBED_DATE=as.Date(corrected_PRESCRIBED_DATE)) %>% 
#   filter(row_number() == 1) %>% select(PROCHI, Latest_corrected_PRESCRIBED_DATE, no_pres_data) %>% ungroup()
# 
# colnames(pres_data_out)[-1] <- paste("Pres", colnames(prescribed_data_out[-1]), sep="_")

non_dementia_cases_all <- merge(SMR01_data_out, SMR04_data_out, by="PROCHI", all=TRUE)
non_dementia_cases <- merge(non_dementia_cases_all, non_dementia_dead, by="PROCHI", all=TRUE)
#convert DtDeath from POSIXct to Date format
non_dementia_cases$DtDeath <- as.Date(non_dementia_cases$DtDeath)
#non_dementia_cases <- merge(non_dementia_cases, pres_data_out, by="PROCHI", all=TRUE)

#Obtain the latest date of followup (LDF) across 2 datasets
non_dementia_cases <- non_dementia_cases %>% rowwise() %>% mutate(LDF = max(SMR01_Latest_Event_Date, SMR04_Latest_Event_Date,DtDeath, na.rm = TRUE))

#setwd('X')
write.csv(non_dementia_cases,'All_Non_Dementia_patients.csv', row.names = FALSE)

