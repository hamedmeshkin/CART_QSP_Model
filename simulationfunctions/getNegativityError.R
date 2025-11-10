getNegativityError<-function(list_of_out, namesyout){
	shorter_namesyout<-namesyout[namesyout != "Chemoreflex drive (l/min)"]
	negativeerror<-sapply(list_of_out, function(x) sum(pmin(x[,shorter_namesyout],0)^2))
	negativeerror<-sum(negativeerror)
	negativeerror
	
}