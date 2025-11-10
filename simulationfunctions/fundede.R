fundede<-function(states, fulltimes,truepar,namesyout=NULL){
	namesyout <- c("CT","T_pop")
	out=list()
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	try({out <- dede(states, fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=length(namesyout),n_history = 100000, rtol=1e-14, atol=1e-14, method="impAdams")});
	if(!is.null(namesyout)){
		colnames(out)[(length(states)+2):(length(states)+length(namesyout)+1)]=namesyout
	}

	out
}