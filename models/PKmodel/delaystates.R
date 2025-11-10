states <- c(
  CI = NA_real_,  # injected CAR-T (cells or cells/L)   
  CE = 0.0,       # expanders                          
  CP = 0.0,       # persisters                         
  TP = NA_real_,  # antigen-positive tumor cells        
  TN = NA_real_,  # antigen-negative tumor cells (0 if not used)
  Mi = NA_real_,  # naive monocytes/macrophages         
  Ma = 0.0,       # activated macrophages              
  IL6 = 1.0   		# IL-6 concentration             
)