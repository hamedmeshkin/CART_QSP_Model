fundedewithEvent<-function(states, fulltimes,truepar,eventdata, namesyout=NULL){
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	try({out <- dede(states, fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=length(namesyout), rtol=1e-10, atol=1e-10, method="adams",n_history = 100000,events=list(data=eventdata))});
	if(!is.null(namesyout)){
		colnames(out)[(length(states)+2):(length(states)+length(namesyout)+1)]=namesyout
	}
	out
}