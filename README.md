# Wind 
## Calculate and plot wind speed and direction from u,v in wind data 
 
The data used here is from Sonic anemometer measurements made over a few hours in one day. read.table() "is to convert character variables (which are not converted to logical, numeric or complex) to factors" hence the need to set the stringsAsFactors to false. 
1. Load the data 
 ````
library(data.table)
library(tidyr)
library(dplyr)
library(openair)
options(stringsAsFactors=F)

#Load the wind data file 
windfile<-read.table("~/GitHub/Atmo/3D-monitoring_2019-09-13.txt",skip=2,fill=TRUE,sep="")

#Use separate function from dplyr to split column 3 into additional columns. 
#Some NA values are introduced on some rows
windfile2<-separate(windfile,
                    col = "V3",
                    into = c("Q","u","v","w", "unit","X","status"),
                    sep = ",")

#Name all rows in your data frame 
names(windfile2)<-c("Date","Time","NodeAddress","u","v","w","units(m/s)","SpeedOfSound","SonicTemp")
````
2. Convert data formats
After this I removed some NA values that were introduced when importing the data. All the data was in character format so the next step is to change it to numeric before doing the calculation. The ```sapply() function makes it possible to do this over all the columns that need it 

````
#Convert U,V,and W axis columns from character to numeric 
windfile2_complete[,4:6] <- sapply(windfile2_complete[,4:6],as.numeric)
````

3. Create functions to calculate wind speed and direction

The wind components are eastward and northward wind vectors that are represented by the variables “U” and “V” respectively.The U wind component is parallel to the x-axis (i.e. longitude). A positive U wind comes from the west, and a negative U wind comes from the east. The V wind component is parallel to the y- axis (i.e. latitude). A positive V wind comes from the south, and a negative V wind comes from the north.
