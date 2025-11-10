# File:         deWrapper.R
# Author:       Kelly Chang
#               Zhihua Li
# Date:         Sep 2017
# Version:      1.0
# 
# Description:  Helper R function which evaluates an objective function for the
#               specified subpopulation.
#

deWrapper<-function(chrpernode,pop,objfun){
    # returns function to evaluate errors of subpopulation
    function(idx){
        # get indices of individuals to evaluate
        max_idx<-min(dim(pop)[2],chrpernode*idx) # allows the last worker to have fewer
        indidx <- (chrpernode*(idx-1)+1):max_idx

        # get parameters
        inds<-pop[,indidx,drop=FALSE]

        # error calculation
        inderror<-matrix(0, nrow=length(indidx), ncol=2)
        inderror[,1]<-indidx
        for(p in 1:length(indidx)){
            ind<-inds[,p] # parameters for current individual
			ind<-unlist(ind)
            try({err_tot<-objfun(ind)}) # get objective function value for individual
			if(!exists("err_tot")||inherits(err_tot,"try-error")||any(is.na(as.numeric(err_tot)))|| any(is.nan(as.numeric(err_tot))))
				err_tot<-1e50
            inderror[p,2]<-as.numeric(err_tot)
        }
        inderror
    }
}
