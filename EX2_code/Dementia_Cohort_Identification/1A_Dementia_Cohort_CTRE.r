###################################
# 1A_Dementia_Cohort_CTRE.r
#
# Purpose:
# Construct dementia cohort from clinical datasets
#
# Inputs:
# - GoFusion database (SMR01, SMR04, GRO, Prescribing)
#
# Outputs:
# - All_Dementia_patients.csv
# - Final_Dementia_cohort.csv
#
# Author: PS Reel (psreel@dundee.ac.uk)
###################################

# -------------------------------
# Function: Extract dementia cases from SMR datasets
# -------------------------------
run_SMR_query <- function(SMR_data){
  # Code for Alzheimer's disease (AD)
  AZ_codes <- c('^3310','F00','G30')
  
  AZ_data <- SMR_data %>% filter_at(.vars = vars(MAIN_CONDITION:OTHER_CONDITION_5), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(AZ_codes,collapse = "|"), ")" ))))
  #first admission only
  AZ_data_FA <- AZ_data %>% group_by(PROCHI) %>% dplyr::mutate(AZ_FAD=as.Date(ADMISSION_DATE),AZ_type = 1,AZ_ad_no = n()) %>% arrange(AZ_FAD) %>%
    filter(row_number() == 1) %>% select(PROCHI,AZ_FAD, AZ_type,AZ_ad_no)
  
  # Code for Vascular Dementia (VD)
  VD_codes <- c('^2904','F01')
  VD_data <- SMR_data %>% filter_at(.vars = vars(MAIN_CONDITION:OTHER_CONDITION_5), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(VD_codes,collapse = "|"), ")" ))))
  VD_data_FA <- VD_data %>% group_by(PROCHI) %>% dplyr::mutate(VD_FAD=as.Date(ADMISSION_DATE),VD_type = 1,VD_ad_no =n()) %>% arrange(VD_FAD) %>%
    filter(row_number() == 1) %>% select(PROCHI,VD_FAD, VD_type,VD_ad_no)
  # Code for Unspecified Dementia (UD)
  UD_codes <- c("^2900","^2901","^2902","^2903","^2942","^3312","F03","G311")
  UD_data <- SMR_data %>% filter_at(.vars = vars(MAIN_CONDITION:OTHER_CONDITION_5), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(UD_codes,collapse = "|"), ")" ))))
  UD_data_FA <- UD_data %>% group_by(PROCHI) %>% dplyr::mutate(UD_FAD=as.Date(ADMISSION_DATE),UD_type = 1,UD_ad_no = max(row_number())) %>% arrange(UD_FAD) %>%
    filter(row_number() == 1) %>% select(PROCHI,UD_FAD, UD_type,UD_ad_no)
  
  # Code for other dementia (OD)
  OD_codes <- c("^2912","^2982","^2941","^3311","^3312","^33119","^33111","^33182","^29282","F02","A810","F051","G310","G318","^0461","^797","F1027","F1097","G3110","G3109","G3183")
  OD_data <- SMR_data %>% filter_at(.vars = vars(MAIN_CONDITION:OTHER_CONDITION_5), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(OD_codes,collapse = "|"), ")" ))))
  OD_data_FA <- OD_data %>% group_by(PROCHI) %>% dplyr::mutate(OD_FAD=as.Date(ADMISSION_DATE),OD_type = 1,OD_ad_no = max(row_number())) %>% arrange(OD_FAD) %>%
    filter(row_number() == 1) %>% select(PROCHI,OD_FAD, OD_type,OD_ad_no)
  
  # Merge the data
  SMR_data_out <- merge(AZ_data_FA, VD_data_FA, by="PROCHI", all=TRUE)
  SMR_data_out <- merge(SMR_data_out, UD_data_FA, by="PROCHI", all=TRUE)
  SMR_data_out <- merge(SMR_data_out, OD_data_FA, by="PROCHI", all=TRUE)
}

run_GRO_query <- function(GRO_data){
  # Code for Alzheimer's disease (AD)
  AZ_codes <- c('^3310','F00','G30')
  #AD_data1 <- smr01 %>% filter(str_detect(MAIN_CONDITION, paste(AD_codes,collapse = "|")))
  AZ_data <- GRO_data %>% filter_at(.vars = vars(icdcucd:icdrcd6), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(AZ_codes,collapse = "|"), ")" ))))
  AZ_data_GRO <- AZ_data %>% group_by(PROCHI) %>% dplyr::mutate(AZ_type = 1,DtDeath=as.Date(DtDeath)) %>% select(PROCHI,DtDeath, AZ_type)
  
  # Code for Vascular Dementia (VD)
  VD_codes <- c('^2904','F01')
  VD_data <- GRO_data %>% filter_at(.vars = vars(icdcucd:icdrcd6), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(VD_codes,collapse = "|"), ")" ))))
  VD_data_GRO <- VD_data %>% group_by(PROCHI) %>% dplyr::mutate(VD_type = 1,DtDeath=as.Date(DtDeath)) %>% select(PROCHI,DtDeath, VD_type)
  # Code for Unspecified Dementia (UD)
  UD_codes <- c("^2900","^2901","^2902","^2903","^2942","^3312","F03","G311")
  UD_data <- GRO_data %>% filter_at(.vars = vars(icdcucd:icdrcd6), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(UD_codes,collapse = "|"), ")" ))))
  UD_data_GRO <- UD_data %>% group_by(PROCHI) %>% dplyr::mutate(UD_type = 1,DtDeath=as.Date(DtDeath)) %>% select(PROCHI,DtDeath, UD_type)
  
  # Code for other dementia (OD)
  OD_codes <- c("^2912","^2982","^2941","^3311","^3312","^33119","^33111","^33182","^29282","F02","A810","F051","G310","G318","^0461","^797","F1027","F1097","G3110","G3109","G3183")
  OD_data <- GRO_data %>% filter_at(.vars = vars(icdcucd:icdrcd6), .vars_predicate = any_vars(str_detect(. , paste0("^(",paste(OD_codes,collapse = "|"), ")" ))))
  OD_data_GRO <- OD_data %>% group_by(PROCHI) %>% dplyr::mutate(OD_type = 1,DtDeath=as.Date(DtDeath)) %>% select(PROCHI,DtDeath, OD_type)
  
  # Merge the data
  GRO_data_out <- merge(AZ_data_GRO, VD_data_GRO, by=c("PROCHI","DtDeath"), all=TRUE)
  GRO_data_out <- merge(GRO_data_out, UD_data_GRO, by=c("PROCHI","DtDeath"), all=TRUE)
  GRO_data_out <- merge(GRO_data_out, OD_data_GRO, by=c("PROCHI","DtDeath"), all=TRUE)
}

run_prescription_query <- function(con){
  # Pres_records for dementia BNF code '4.11'
  pres_data <- dbGetQuery(con, "
  SELECT res_seqno, Approved_Name, formatted_BNF_Code
  FROM Prescribing_Prescribing_Items
  WHERE formatted_BNF_Code = '4.11'"  )
  
  #for the unique res_seqno id find the prochis in prescribing database
  
  # Prescriptions (links to patients' PROCHI)
  prescribed <- dbGetQuery(con, paste0("
  SELECT PROCHI, quantity, res_seqno, corrected_PRESCRIBED_DATE
  FROM Prescribing
  WHERE res_seqno IN (", paste(pres_data$res_seqno , collapse=",") , ")") )
  
  # Merge the 2 dataframes by res_seqno 
  all_prescribing_dementia <- merge(pres_data, prescribed, by="res_seqno")
  all_prescribing_dementia <- all_prescribing_dementia %>% group_by(PROCHI) %>% arrange(corrected_PRESCRIBED_DATE) %>% 
    dplyr::mutate(no_pres_data = max(row_number()), corrected_PRESCRIBED_DATE=as.Date(corrected_PRESCRIBED_DATE)) %>% filter(row_number() == 1) %>% select(PROCHI, corrected_PRESCRIBED_DATE, no_pres_data)
}


# Connect with server HIc-SQL-02
#install.packages("dplyr")
#install.packages("odbc")
#install.packages("stringr")
library(DBI)
library(dplyr)
library(stringr)
library('odbc')
con <-  dbConnect(odbc(), database = "X", server = "X",
            driver = "/opt/microsoft/msodbcsql18/lib64/libmsodbcsql-18.3.so.2.1",
            TrustServerCertificate = "Yes", Uid = "X")

# SMR01
SMR01 <- dbGetQuery(con, '
  select "PROCHI", "ADMISSION_DATE", "DISCHARGE_DATE", "MAIN_CONDITION","OTHER_CONDITION_1", "OTHER_CONDITION_2","OTHER_CONDITION_3", "OTHER_CONDITION_4", "OTHER_CONDITION_5"
  from "SMR01_Admissions" 
  ')
SMR01_data_out <- run_SMR_query(SMR01)
colnames(SMR01_data_out)[-1] <- paste("SMR01", colnames(SMR01_data_out[-1]), sep="_")

# SMR04
SMR04 <- dbGetQuery(con, '
  select "PROCHI", "ADMISSION_DATE", "MAIN_CONDITION","OTHER_CONDITION_1", "OTHER_CONDITION_2",   "OTHER_CONDITION_3", "OTHER_CONDITION_4", "OTHER_CONDITION_5"
  from "SMR04_Psychiatric" 
  ')
SMR04_data_out <- run_SMR_query(SMR04)
colnames(SMR04_data_out)[-1] <- paste("SMR04", colnames(SMR04_data_out[-1]), sep="_")

# GRO
GRO <- dbGetQuery(con, '
                  select "PROCHI", "DtDeath", "icdcucd", "icdrcd0", "icdrcd1", "icdrcd2", "icdrcd3", "icdrcd4", "icdrcd5", "icdrcd6"
                  from "Deaths_NRS" ')
GRO_data_out <- run_GRO_query(GRO)
colnames(GRO_data_out)[-1] <- paste("GRO", colnames(GRO_data_out[-1]), sep="_")

pres_data_out <- run_prescription_query(con)
pres_data_out$AZ_type = 1
colnames(pres_data_out)[-1] <- paste("Pres", colnames(pres_data_out[-1]), sep="_")

#merge the four datasets
#GRO_data_out, SMR01_data_out, SMR04_data_out, pres_data_out

dementia_cases <- merge(SMR01_data_out, SMR04_data_out, by="PROCHI", all=TRUE)
dementia_cases <- merge(dementia_cases, pres_data_out, by="PROCHI", all=TRUE)
dementia_cases <- merge(dementia_cases, GRO_data_out, by="PROCHI", all=TRUE)

#Obtain the earliest date of dementia diagnosis (EDDD) and employ probabilistic model
dementia_cases <- dementia_cases %>% rowwise() %>% dplyr::mutate(EDDD = min(SMR01_AZ_FAD,SMR01_VD_FAD,SMR01_UD_FAD,SMR01_OD_FAD,
                                                                     SMR04_AZ_FAD,SMR04_VD_FAD,SMR04_UD_FAD,SMR04_OD_FAD,
                                                                     Pres_corrected_PRESCRIBED_DATE,GRO_DtDeath,na.rm = TRUE),
                                                          AZ_count= sum(SMR01_AZ_ad_no,SMR04_AZ_ad_no,GRO_AZ_type,Pres_AZ_type,na.rm = TRUE),
                                                          VD_count= sum(SMR01_VD_ad_no,SMR04_VD_ad_no,GRO_VD_type,na.rm = TRUE),
                                                          OD_count= sum(SMR01_OD_ad_no,SMR04_OD_ad_no,GRO_OD_type,na.rm = TRUE),
                                                          UD_count= sum(SMR01_UD_ad_no,SMR04_UD_ad_no,GRO_UD_type,na.rm = TRUE),
                                                          AZ_prob= sum(SMR01_AZ_ad_no,SMR04_AZ_ad_no,GRO_AZ_type,Pres_AZ_type,na.rm = TRUE)/sum(SMR01_AZ_ad_no,SMR04_AZ_ad_no,GRO_AZ_type,Pres_AZ_type,SMR01_VD_ad_no,SMR04_VD_ad_no,GRO_VD_type,SMR01_UD_ad_no,SMR04_UD_ad_no,GRO_UD_type,SMR01_OD_ad_no,SMR04_OD_ad_no,GRO_OD_type,na.rm = TRUE),
                                                          VD_prob= sum(SMR01_VD_ad_no,SMR04_VD_ad_no,GRO_VD_type,na.rm = TRUE)/sum(SMR01_AZ_ad_no,SMR04_AZ_ad_no,GRO_AZ_type,Pres_AZ_type,SMR01_VD_ad_no,SMR04_VD_ad_no,GRO_VD_type,SMR01_UD_ad_no,SMR04_UD_ad_no,GRO_UD_type,SMR01_OD_ad_no,SMR04_OD_ad_no,GRO_OD_type,na.rm = TRUE),
                                                          OD_prob= sum(SMR01_OD_ad_no,SMR04_OD_ad_no,GRO_OD_type,na.rm = TRUE)/sum(SMR01_AZ_ad_no,SMR04_AZ_ad_no,GRO_AZ_type,Pres_AZ_type,SMR01_VD_ad_no,SMR04_VD_ad_no,GRO_VD_type,SMR01_UD_ad_no,SMR04_UD_ad_no,GRO_UD_type,SMR01_OD_ad_no,SMR04_OD_ad_no,GRO_OD_type,na.rm = TRUE),
                                                          UD_prob= sum(SMR01_UD_ad_no,SMR04_UD_ad_no,GRO_UD_type,na.rm = TRUE)/sum(SMR01_AZ_ad_no,SMR04_AZ_ad_no,GRO_AZ_type,Pres_AZ_type,SMR01_VD_ad_no,SMR04_VD_ad_no,GRO_VD_type,SMR01_UD_ad_no,SMR04_UD_ad_no,GRO_UD_type,SMR01_OD_ad_no,SMR04_OD_ad_no,GRO_OD_type,na.rm = TRUE),
                                                          Final_Diagnosis = ifelse((max(AZ_prob,VD_prob,OD_prob,UD_prob)==AZ_prob),'AZ',
                                                                                   ifelse((max(AZ_prob,VD_prob,OD_prob,UD_prob)==VD_prob) & (VD_prob!=AZ_prob),'VD',
                                                                                   ifelse((max(AZ_prob,VD_prob,OD_prob,UD_prob)==OD_prob) & (OD_prob!=AZ_prob) & (OD_prob!=VD_prob) ,'OD',
                                                                                          ifelse((max(AZ_prob,VD_prob,OD_prob,UD_prob)==UD_prob) & (UD_prob!=AZ_prob) & (UD_prob!=VD_prob) & (UD_prob!=OD_prob) ,'UD')))))

summary(as.factor(dementia_cases$Final_Diagnosis))

write.csv(dementia_cases,'All_Dementia_patients.csv', row.names = FALSE)


