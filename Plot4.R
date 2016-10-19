#install.packages("sqldf")
#library(sqldf)
#library(utils)

loadData <- function() {
  #get working directory
  wk <- getwd()
  
  #set zip file to download
  url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
  
  #set destination file name
  destFile <- "household_power_consumption.zip"
  
  #download zip file
  utils::download.file(url, destFile, quiet = TRUE, mode="wb")
  
  #unzip content to working directory
  utils::unzip(destFile)
  
  #set full path of filename
  fileName <- paste(wk, "household_power_consumption.txt", sep="/")
  
  #query to read only data we need from file
  sqlQuery <- "select Date, Time, Global_active_power, Global_reactive_power, 
  Voltage, Global_intensity, Sub_metering_1, Sub_metering_2, 
  Sub_metering_3 from file where Date = '1/2/2007' or Date = '2/2/2007'"
  
  #read the data from text file using query, and set colClass type to speed up process
  data <- sqldf::read.csv.sql(file = fileName, sql = sqlQuery, header = TRUE, sep = ";", 
                              colClasses = c("character","character","numeric","numeric","numeric",
                                             "numeric","numeric","numeric","numeric") )
  
  #take the date and time and cast them as date time re-insert into date field
  data$Date <- strptime(paste(data$Date, data$Time, sep = " "), "%d/%m/%Y %T")
  
  #remove time column that is not longer needed
  data$Time <- NULL
  
  #delete the zip file and the txt file
  unlink(fileName)
  unlink(destFile)
  
  #return the data to the caller
  return(data)
}

#function to plot fourth plot
plot4 <- function(time, activepower, voltage, metering1, metering2, 
                  metering3, reactivepower, toFile) {
  if(toFile == TRUE) {
    png(filename = "plot4.png", width = 2400, height = 2400, res = 300)
  }
  
  par(mfrow=c(2,2))
  
  plot(time,activepower, type="l", xlab="", ylab="Global Active Power")
  
  plot(time,voltage, type="l", xlab="datetime", ylab="Voltage")
  
  plot(time,metering1, type="l", xlab="", ylab="Energy sub metering")
  
  lines(time,metering2,col="red")
  
  lines(time,metering3,col="blue")
  
  legend("topright", col=c("black","red","blue"), c("Sub_metering_1  ",
                                                    "Sub_metering_2  ", "Sub_metering_3  "),lty=c(1,1), bty="n", cex=.5)
  
  plot(time,reactivepower, type="l", xlab="datetime", ylab="Global_reactive_power")
  
  if(toFile == TRUE) {
    dev.off()
  }
}

#check if data is loaded for plots
test <- exists("myData")
if(test==FALSE) myData <- loadData()

#use with to make calling each function simpler and re-using the data
with(myData, {
  plot4(Date,Global_active_power,Voltage,Sub_metering_1,Sub_metering_2,
        Sub_metering_3,Global_reactive_power, toFile = TRUE)
})