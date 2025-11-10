

#--- load libraries
library(cmaes)
library(parallel)
library(optparse)
library(deSolve)                #since all error calulation scripts will use the same deSolve package, do it here
library(ggplot2)
library(dplyr)
library(tidyr)

#--- specify command line arguments
parser<-OptionParser()
parser<-add_option(parser, c("-a", "--patient"), default="M09",type="character", help="patient ID")
parser<-add_option(parser, c("-s", "--seed"), default=100, type="integer", help="Random seed [default 100]")
parser<-add_option(parser, c("-c", "--cores"), default=1, type="integer", help="Number of cores to use during fitting [default 1]")
parser<-add_option(parser, c("-f", "--forking"), default=FALSE, action="store_true", help="Flag to turn on forking for parallelization (not supported in Windows)")
parser<-add_option(parser, c("-l", "--lambda"), default=512,type="integer", help="Population size to use for CMA-ES [default 4+floor(3*log(N))]")
parser<-add_option(parser, c("-m", "--maxiter"), default=512,type="integer", help="Maximum number of generations for CMA-ES [default 100*N^2]")
parser<-add_option(parser, c("-t", "--tol"), default=0.001,type="double", help="Stopping tolerance for CMA-ES [default 0.5e-12]")
args<-parse_args(parser)


patientID=args$patient
output_folder = "/results_CAR"
#prepare output folders----------------
#outdir1=sprintf("output/fitting_results/a_itr%s_lam%s_agepars",args$maxiter,args$lambda)
outdir1=sprintf("output/fitting_results/%s",patientID)
dir.create(paste0(outdir1,"/figs"),recursive = TRUE)
dir.create(paste0(outdir1,output_folder),recursive = TRUE)

#simulation functions. note that the folders are one level up
source("../simulationfunctions/fundede.R")
source("../simulationfunctions/fundedewithEvent.R")
source("../simulationfunctions/PKdata/simulate_onerealpatient_fromfile.R")
source("../simulationfunctions/deWrapper.R")                 #one level up


#initial guesses
pp <- read.delim("nnn.txt",header = TRUE, sep = '\t') #../nnn.txt is the file used by Step0; nnn.txt is a file
Pre_fitted <- read.csv('../models/PKmodel/initial.csv')	
Pre_fitted <- Pre_fitted[c('X',patientID)]
Pre_fitted <- Pre_fitted[!is.na(Pre_fitted)[,patientID],]
Pre_fitted <- Pre_fitted[!Pre_fitted[,patientID]==0,]
for (i in 1:nrow(pp)){
	if (pp$Parameter[i] %in% Pre_fitted$X){
		pp$Initial[i] <- as.numeric(Pre_fitted[which(Pre_fitted$X==pp$Parameter[i]),patientID])
		pp$Low[i] <- as.numeric(Pre_fitted[which(Pre_fitted$X==pp$Parameter[i]),patientID])/ 2
		pp$High[i] <- as.numeric(Pre_fitted[which(Pre_fitted$X==pp$Parameter[i]),patientID]) * 2
	}
}
			
		
		
                          #with larger ranges to be used by Step1.
pinit <- pp$Initial
pnames<-pp$Parameter
high_bounds<-pp$High
low_bounds<-pp$Low

#--- parameter encoding to 0-10 range
pmax<-10
encode_pars<-function(pars) pmax*log10(pars/low_bounds)/log10(high_bounds/low_bounds)
decode_pars<-function(ind) low_bounds*(high_bounds/low_bounds)^(ind/pmax)
seednum<-args$seed
cores<-args$cores
usefork<-args$forking
POP_SIZE<-args$lambda
MAX_GENERATION<-args$maxiter
STOPTOL<-args$tol

# cmaes hyperparameters
ctl_list<-list(vectorized=TRUE)
if(!is.null(POP_SIZE)){
	print(sprintf("Using population size: %g",POP_SIZE))
	ctl_list[["lambda"]]<-POP_SIZE
}
if(!is.null(MAX_GENERATION)){
	print(sprintf("Using number of generations: %g",MAX_GENERATION))
	ctl_list[["maxit"]]<-MAX_GENERATION
}
if(!is.null(STOPTOL)){
	print(sprintf("Using stopping tolerance: %g",STOPTOL))
	ctl_list[["stop.tolx"]]<-STOPTOL
}

usesocket<-FALSE
if(cores>1){
	if(usefork){
		lapplyfun<-function(X, FUN) mclapply(X, FUN, mc.cores=cores, mc.preschedule=FALSE)
	}else{
		cl<-makeCluster(cores)
		invisible(clusterEvalQ(cl,library(deSolve)))
		clusterExport(cl,c("patientID"))

		lapplyfun<-function(X, FUN) clusterApply(cl, X, FUN)
		usesocket<-TRUE
	}
}else{
	lapplyfun<-lapply
}


objfun<-function(ind){

	parsin=decode_pars(ind)
	names(parsin)=names(ind)
	parnames = names(parsin)
	replaced_pars <- c(parnames,"weight") # makes weight get updated per individual patient's weight
	Exp_datafile<-paste0("../Step0_Data_extraction/extracted_data/Individual_Data_",patientID,"_CART_IL6",".csv")
	error1<- simulate_onerealpatient(
									parsin = parsin,
									modelfolder = "PKmodel",
									funfolder = "PKdata",
									patientID = patientID, # options are patientID or "averagedata"
									replaced = replaced_pars,
									Exp_datafile = Exp_datafile,
									returnfull = FALSE)

	totalerror<-error1
#	print(totalerror)
	return(totalerror)

}

genfile<-paste0(outdir1,output_folder,"/CMAESgeneration")
errfile<-paste0(outdir1,output_folder,"/CMAESerror")
if(file.exists(genfile)) file.remove(genfile);
if(file.exists(errfile)) file.remove(errfile);
#save.image()
objfun_vec<-function(pop){
	#print(pop)
	print("-----------")
	nchr<-ncol(pop)
	chrpernode<-ceiling(nchr/cores)
	nnodes<-min(cores,nchr)
	#save(pop, nchr, chrpernode, nnodes, file="pop.RData")
	errorlist<-lapplyfun(1:nnodes, deWrapper(chrpernode,pop,objfun))
	errormat<-do.call(rbind, errorlist)
	#save(pop, errormat, file="pop.RData")
	#errormat[,2]<-as.numeric(errormat[,2]) #which.min will do this automatically I think
	imin<-which.min(errormat[,2])
	write.table(data.frame(t(decode_pars(pop[,imin]))), genfile, sep=" ", row.names=F, col.names=F, append=T)
	write(errormat[imin,2], errfile, ncolumns=1, sep=" ", append=T)
	errormat[,2]
}

#Spikin ----------------------------------------------------------
use_spike="no"
if (use_spike=="yes") {  #start from a previously set of estimated parameters
	dir1 <- sprintf("output/fitting_results/%s/",patientID)
	spikein_path=paste0(dir1,output_folder,"/")
	ttt<-read.table(paste0(spikein_path,"scaled_pars",".txt"),header=F,as.is=T)
	pinit=(ttt[,2]) #for ploting just remode decode
	names(pinit)=ttt[,1]
}

#--- run CMA-ES

pinit <- encode_pars(pinit)
names(pinit) <- pnames

res<-cma_es(pinit,objfun_vec,lower=0,upper=pmax,control=ctl_list)
str(res)

#--- save best results
fitpars<-signif(decode_pars(res$par), digits=4)
names(fitpars)<-pnames
parnames <- names(fitpars)
write.table(fitpars, file=paste0(sprintf("%s%s/pars.txt",outdir1,output_folder)), row.names=T, col.names=F, quote=F)
pars_scaled=signif((res$par), digits=4)
names(pars_scaled)<-pnames
write.table(pars_scaled, file=paste0(sprintf("%s%s/scaled_pars.txt",outdir1,output_folder)), row.names=T, col.names=F, quote=F)



#--- plot convergence
#fitting done; why not plot it?
estimatedpars<-read.table(paste0(outdir1,output_folder,"/pars",".txt"),header=F,as.is=T)
objfun<-function(parsin){

	#no need to do decode
	parsvec<-parsin[,2]
	names(parsvec)=parsin[,1]
 	parnames <- names(parsvec)
	replaced_pars <- c(parnames,"weight") # makes weight get updated per individual patient's weight
	Exp_datafile<-paste0("../Step0_Data_extraction/extracted_data/Individual_Data_",patientID,"_CART_IL6",".csv")
	error1<- simulate_onerealpatient(
									parsin = parsvec,
									modelfolder = "PKmodel",
									funfolder = "PKdata",
									patientID = patientID, # options are patientID or "averagedata"
									replaced = replaced_pars,
									Exp_datafile = Exp_datafile,
									returnfull = TRUE)
	return(error1)

}


forplotting<-objfun(estimatedpars)
source('Plotting.R')