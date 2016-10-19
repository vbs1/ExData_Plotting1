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

#function to plot first plot
plot1 <- function(power, toFile) {
  if(toFile == TRUE) {
    png(filename = "plot1.png")
  }
  hist(power, main = "Global Active Power", col="red", 
       xlab = "Global Active Power (Kilowatts)")
  if(toFile == TRUE) {
    dev.off()
  }
}

#check if data is loaded for plots
test <- exists("myData")
if(test==FALSE) myData <- loadData()

#use with to make calling each function simpler and re-using the data
with(myData, {
  plot1(Global_active_power, toFile = TRUE)
})