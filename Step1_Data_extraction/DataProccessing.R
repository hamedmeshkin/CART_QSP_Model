library(dplyr)
library(tidyr)

Patients_lable = c( "L1", "L2","L3","L4", "L6","L7", "P01","P02","P03",	 "P05",	 "P09", "P10","P12", "M03","M09","M21",  "M57","M68","G01","P22","M04",	"M19","M26","M44", "G02")
#
# Load input data
for (patient in Patients_lable) {
	
	# Load CAR-T data
	file_path_CAR <- paste0("../data/", patient, "-QSP.csv")
	if (file.exists(file_path_CAR)) {	
		all_CAR <- read.csv(file_path_CAR)
	} else {
		all_CAR <- read.csv(paste0("../data/", patient, "-QSP-NEG.csv"))
    }
	CAR_Date <- all_CAR[c("EVENT","TIME","DV.CART")]
	CAR_Date <- CAR_Date[CAR_Date$EVENT=="DV",][c("TIME","DV.CART")]
	CAR_Date <- CAR_Date[!is.na(CAR_Date$DV.CART),]
 
 	# Load IL-6 data
	file_path_IL6 <- paste0("../data/", patient, "-QSP-IL.csv")
	if (!file.exists(file_path_IL6)) {	
		IL6_Date <- data_frame(TIME = NA,  DV.IL6 = NA)
	} else {
		all_IL6 <- read.csv(file_path_IL6)
		IL6_Date <- all_IL6[c("EVENT","TIME","DV.IL6")]
		IL6_Date <- IL6_Date[IL6_Date$EVENT=="DV",][c("TIME","DV.IL6")]
		IL6_Date <- IL6_Date[!is.na(IL6_Date$DV.IL6),]
	}
  
	out <- full_join(
		  CAR_Date %>% mutate(.row = row_number()),
		  IL6_Date %>% mutate(.row = row_number()),
		  by = ".row"
	) %>% select(-.row)
	
	Letters <- strsplit(patient, "")[[1]]
	num <- as.integer(gsub("\\D", "", patient))  # extract all digits
	letter <- gsub("\\d", "", patient)  		 # extract all letters
	patientID_num <- paste0(letter, sprintf("%02d", num))

	names(out) <- c("Days", "CART", "days", "IL6")
	write.table(out, file = file.path("./extracted_data", paste0("Individual_Data_",patientID_num,"_CART_IL6.csv")),
			sep = "\t",
            row.names = FALSE,
            col.names = TRUE,
            quote = FALSE)
}


 # End of the script
