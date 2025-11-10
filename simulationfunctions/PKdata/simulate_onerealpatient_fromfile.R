simulate_onerealpatient<-function(parsin = parsin, modelfolder, funfolder, patientID, replaced=c(),
									Exp_datafile, returnfull=FALSE ,MCMC=FALSE, sigma=NA) {

	modeldir<-paste0("../models/",modelfolder,"/")  #all locations one level up
	fundir<-paste0("../simulationfunctions/",funfolder,"/")
	 
	#load the model (remember unload it in the end!)
	modelname<-"delaymymod"
	isWindows<-Sys.info()[["sysname"]]=="Windows"
	extension<-ifelse(isWindows, ".dll", ".so")
	dyn.load(paste0(modeldir,modelname,extension))
	source(paste0(modeldir,"delaystates.R"))
	source(paste0(modeldir,"delaypars.R"))
	source(paste0(modeldir,modelname,".R"))
	#add names to EXTRA model output
	#only if there are yout in the c file AND you want to name them
	#probably not relevant for BHM of popPK
	#source(paste0(modeldir,"addnames.R"))

	# Update parameters
	parameterIndex<-match(names(pars), names(parsin), nomatch=0)
	pars[parameterIndex!=0]<- parsin[parameterIndex]
 
 
 	# update states if needed
 	Variables <- read.csv('../models/PKmodel/initial.csv')	
	tmp = Variables[c('X',patientID)]
	states["CI"] <- as.numeric(tmp[which(tmp['X']=="CI"),patientID]) 
	states["TP"] <- as.numeric(tmp[which(tmp['X']=="TP"),patientID])   
	states["IL6"] <- as.numeric(tmp[which(tmp['X']=="IL6"),patientID]) 
	states["Mi"] <- as.numeric(tmp[which(tmp['X']=="Mi"),patientID]) 	
	if (is.na(tmp[which(tmp['X']=="TN"),patientID])){
		 pars['TN_switch'] <- FALSE
		 states["TN"] <- 0
	} else {
		    pars['TN_switch'] <- TRUE
            states["TN"] <- as.numeric(tmp[which(tmp['X']=="TN"),patientID]) 
    } 
	
	Delta_time <- 1
	#load data
	clinicaldata<-read.csv(Exp_datafile,sep="\t")
	clinicaldata$Days<-round(clinicaldata$Days*Delta_time)    #devided one day to 0.01 parts
	clinicaldata$days<-round(clinicaldata$days*Delta_time)    #devided one day to 0.01 parts
	
	clinicaldata_CART <- clinicaldata[c("Days","CART") ]
	clinicaldata_IL6 <-  clinicaldata[c("days","IL6") ]
	clinicaldata_IL6 <- clinicaldata_IL6[!is.na(clinicaldata_IL6)[,'days'],]
	names(clinicaldata_IL6) <- c("Days","IL6")
 
	if (nrow(clinicaldata_IL6)==0) {
        clinicaldata_IL6 <- tibble(Days = 0, IL6 = 0)
    	states["IL6"] <- 0.0 # if no IL6 data, set initial IL6 to 0
		states["Mi"]  <- 0.0 # if no IL6 data, set initial IL6 to 0
    }
    
    
    
	#load error calculation functions
	pars['sigmaI']   = pars['deltaI'] * min(clinicaldata_IL6[,"IL6"]) 

 	last_day <- max(max(clinicaldata_CART$Days), max(clinicaldata_IL6$Days)) + 20.0
	#start simulation
	out<-fundede(states=states,fulltimes=seq(0.0,Delta_time*last_day),truepar=pars)
#	out <- ode(y = states, times = seq(0.0,Delta_time*last_day), func = carT_ode, parms = pars, method = "rk4")
	

	y_CART <- clinicaldata_CART$CART
	idxPeaktime1<-out[,"time"]%in%clinicaldata_CART$Days
	P_CART <- out[idxPeaktime1,c("CT")]  

	
	y_IL6 <- clinicaldata_IL6$IL6
	idxPeaktime2<-out[,"time"]%in%clinicaldata_IL6$Days
	P_IL6 <- out[idxPeaktime2,c("IL6")]  
 
	
	
	if(MCMC){
		return(sum(dnorm(yO,mean = yP,sd = sigma,log = TRUE)))
	}

	fval1<- sqrt(sum((y_CART - P_CART)^2/y_CART^2))
	fval2<- sqrt(sum((y_IL6 - P_IL6)^2/y_IL6^2))
	

	#unload the model
	dyn.unload(paste0(modeldir,modelname,extension))
	rm(pars); rm(states)

	#return
    fval <- fval1  + fval2

	if(returnfull){
		clinicaldata_IL6$Days <- clinicaldata_IL6$Days / Delta_time
        clinicaldata_CART$Days <- clinicaldata_CART$Days / Delta_time
        out[,'time'] <- as.numeric(out[,'time'] / Delta_time)
		return(list(fval, clinicaldata_CART,clinicaldata_IL6,out))
	}else{
		return(fval)
	}

}