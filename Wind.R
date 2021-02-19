library(data.table)
library(tidyr)
library(dplyr)
library(openair)
options(stringsAsFactors=F)

#Load the wind data file 
windfile<-read.table("~/GitHub/Atmo/Sonicdata.txt",skip=2,fill=TRUE,sep="")

#Use separate function from dplyr to split column 3 into additional columns. 
#Some NA values are introduced on some rows
windfile2<-separate(windfile,
                    col = "V3",
                    into = c("Q","u","v","w", "unit","X","status"),
                    sep = ",")

#Name all rows in your data frame 
names(windfile2)<-c("Date","Time","NodeAddress","u","v","w","units(m/s)","SpeedOfSound","SonicTemp")

#Use complete.cases function to check the whole data frame for missing values.
#TRUE indicates a complete row; 
#FALSE indicates a row with at least one incomplete column
complete.cases(windfile2) 

#This line shows the sum of all rows that are complete. This is useful since this
#data has many rows. Compare the sum of complete rows to the original data frame
sum(complete.cases(windfile2))

#Create new data set without missing values i.e. all rows are complete
windfile2_complete <- windfile2[complete.cases(windfile2), ] 

#Convert U,V,and W axis columns from character to numeric 
windfile2_complete[,4:6] <- sapply(windfile2_complete[,4:6],as.numeric)

#Combine Date and Time fields into one DATETIME field. Convert DATETIME field to
# as.POSIXct datetime format 
windfile2_complete$DATETIME <-paste(windfile2_complete$Date,windfile2_complete$Time)
windfile2_complete$DATETIME<-as.POSIXct(windfile2_complete$DATETIME,format="%Y-%m-%d %H:%M:%S")

#Create two functions to calculate the wind direction and wind speed from u,v 
# axis. Sonic anemometer gives wind speed outputs as +ve or -ve speeds along the
# U axis, V axis and W(vertical) axis 

windDir <-function(u,v){
  (270-atan2(u,v)*180/pi)%%360 #%% means modulo 
}

#WDIR= (270-atan2(V,U)*180/pi)%360

windSpd <-function(u,v){
  sqrt(u^2+v^2)
}

#Compute wind direction and wind speed using the functions just created
#The openair package needs to have wind direction stored as "wd" and wind speed
#stored as "ws" to pick those columns and plot the wind rose
windfile2_complete$wd <-windDir(windfile2_complete$u,windfile2_complete$v)
windfile2_complete$ws <-windSpd(windfile2_complete$u,windfile2_complete$v)

#Plot wind rose 
png("windplot.png", width = 480,height = 480, units = "px",pointsize = 12)
windplot=windRose(windfile2_complete,ws="ws",wd="wd",breaks=c(0,2,4,6,8),paddle = FALSE,main="Wind rose")
dev.off()

#Save windrose plot
ggsave("windplot.pdf",width = 297,height = 210,units = c("mm"),dpi=300)



