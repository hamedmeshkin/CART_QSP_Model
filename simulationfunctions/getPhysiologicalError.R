getPhysiologicalError<-function(out, pars){
	Perror<-0
	sratio<-out[1,"Brain CO2 partial pressure (mm Hg)"]/pars["P_B_co2_0"]
	Perror<- Perror + min(0, sratio-0.8)^2+max(0, sratio - 1.2)^2
	
	f_pc<-pars["K_fpc"]*log(out[1,"Arterial CO2 partial pressure (mm Hg)"]/pars["Bp"])*
			(pars["f_pc_max"]+pars["f_pc_min"]*exp((out[1,"Arterial O2 partial pressure (mm Hg)"] - 
									pars["P_a_o2_c"])/pars["K_pc"]))/(1+exp((out[1,"Arterial O2 partial pressure (mm Hg)"]-
									pars["P_a_o2_c"])/pars["K_pc"]))
	sratio<- f_pc/pars["f_pc_0"]
	
	Perror<- Perror + min(0, sratio-0.8)^2+max(0, sratio - 1.2)^2
	
	sratio<- out[1,"Brain O2 partial pressure (mm Hg)"]/pars["P_B_o2_0"]
	Perror<- Perror + min(0, sratio-0.8)^2+max(0, sratio - 1.2)^2
	
	sratio<-out[1,"Brain O2 partial pressure (mm Hg)"]/pars["P_B_o2_0"]
	Perror<- Perror + min(0, sratio-0.8)^2+max(0, sratio - 1.2)^2
	
	sratio<- out[1,"Arterial CO2 partial pressure (mm Hg)"]/pars["Cco2"]
	Perror<- Perror + min(0, sratio-0.8)^2+max(0, sratio - 1.2)^2
	
	sratio<- out[1,"Arterial O2 partial pressure (mm Hg)"]/pars["P_a_o2_0"]
	Perror<- Perror + min(0, sratio-0.8)^2+max(0, sratio - 1.2)^2
	return(Perror)
}