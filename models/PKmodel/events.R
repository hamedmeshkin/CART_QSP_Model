dosingevents<<-function(naloxoneDosing){
#	print(naloxoneDosing)
	
	#opioid dose (irrlevant here)=======================================================
#	opioid_dose=0; 
#	opioid_time=0;
#	eventdata<-data.frame(var="PlasmaF",time=opioid_time,value=opioid_dose,method="add")
	#===================================================================================
	
	naloxone_time=0; #naloxone administration starts at time 0
	gap=150; #interdose delay of 150 seconds between consecutive naloxone doses
	eventdata<-c() #this should be commented out for cases with opioids
	if(naloxoneDosing == "3 mg"){ #for the case where 2 consecutive 4 mg naloxone doses are applied
		naloxone_dose=3e6; #all naloxone doses are 4e6 ng
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time),value=c(naloxone_dose),method="add"))
	}else if(naloxoneDosing == "4+4+4+4 mg"){ #for the case where 4 consecutive 4 mg naloxone doses are applied
		naloxone_dose=4e6; #all naloxone doses are 4e6 ng
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap, naloxone_time+gap+gap, naloxone_time+gap+gap+gap),value=c(rep(naloxone_dose,2),rep(1*naloxone_dose,2)),method="add"))
	}else if(naloxoneDosing == "8+8 mg"){ #for the case where 2 consecutive 8 mg naloxone doses are applied
		naloxone_dose=8e6; #all naloxone doses are 8e6 ng
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap),value=c(rep(1*naloxone_dose,2)),method="add")) #assuming 15% reduction in bioavailibility due to higher dose
	}
#	time11=seq(0,12*60*60)	
#	times=c(time11)
	times=seq(0,4*60*60,1) #simulation to be run for 12 hours	
	fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))
	output<-list(fulltimes, eventdata)
}
