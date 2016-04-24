#Download the file if doesn't exist

filePath <- "../UCI HAR Dataset" 
if(!file.exists(filePath)) {
	fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(fileUrl, "../getdata_projectfiles_UCI HAR Dataset.zip",method="curl")
	unzip(zipfile="../getdata_projectfiles_UCI HAR Dataset.zip",exdir="../")
}


#Loadng the libraries
library(data.table)
library(dplyr)


#Step 1
#1. Merges the training and the test sets to create one data set.

# Each directory consists of files for subject(subject_*.txt), activity(y_*.txt) and features(X_*.txt)

#Read trainng data
#tabSubjectTraining <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
#tabActivityTraining <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
#tabFeaturesTraining <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
tabSubjectTraining <- read.table(file.path(filePath,"train", "subject_train.txt"), header = FALSE)
tabActivityTraining <- read.table(file.path(filePath,"train", "y_train.txt"), header = FALSE)
tabFeaturesTraining <- read.table(file.path(filePath,"train", "X_train.txt"), header = FALSE)

#Read test data
#tabSubjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
#tabActivityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
#tabFeaturesTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
tabSubjectTest <- read.table(file.path(filePath,"test", "subject_test.txt"), header = FALSE)
tabActivityTest <- read.table(file.path(filePath,"test", "y_test.txt"), header = FALSE)
tabFeaturesTest <- read.table(file.path(filePath,"test", "X_test.txt"), header = FALSE)

#First let's merge the rows of both data sets
tabSubject <- rbind(tabSubjectTraining, tabSubjectTest)
tabActivity <- rbind(tabActivityTraining, tabActivityTest)
tabFeatures <- rbind(tabFeaturesTraining, tabFeaturesTest)

#We will assign column names to previous data. Features are available in features.txt

#Get the data from the input files
#tabFeatureNames <- read.table("UCI HAR Dataset/features.txt", header= FALSE)
#tabActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
tabFeatureNames <- read.table(file.path(filePath,"features.txt"), header = FALSE)
tabActivityLabels <- read.table(file.path(filePath, "activity_labels.txt"), header = FALSE)

#Assign column names to the row merged data sets
#Features names are in the second column of tabFeatureNames
colnames(tabFeatures) <- t(tabFeatureNames[2])
#Assign vales to Subject and Activity
colnames(tabSubject) <- "Subject"
colnames(tabActivity) <- "Activity"

#Finally column merge all three data tables
tabStep1MergedData <- cbind(tabSubject, tabActivity, tabFeatures)

#Step 2
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 

#Use grep to find columns with name containing mean and standard deviation(std)
colNamesWithMeanandStd <- grep("mean\\(\\)|std\\(\\)", names(tabStep1MergedData), ignore.case=TRUE)
#colNamesWithMeanandStd <- grep(".*mean.*|.*std\\(\\)", names(tabStep1MergedData), ignore.case=TRUE)
colNameSubject <- grep("Subject", names(tabStep1MergedData), ignore.case=FALSE)
colNameActivity <- grep("Activity", names(tabStep1MergedData), ignore.case=FALSE)

#Get the columns to be filtered
vecReqColumns <- c(colNameSubject, colNameActivity, colNamesWithMeanandStd)

#Dimensions in tabStep1MergedData
dim(tabStep1MergedData)

#Extrct required data set
tabStep2ExtractedData <- tabStep1MergedData[,vecReqColumns]

#Dimensions in tabStep2ExtractedData
dim(tabStep2ExtractedData)

#Step 3
#3. Uses descriptive activity names to name the activities in the data set

tabStep2ExtractedData$Activity <- as.character(tabStep2ExtractedData$Activity)
for (i in 1:6){
  tabStep2ExtractedData$Activity[tabStep2ExtractedData$Activity == i] <- as.character(tabActivityLabels[i,2])
 }
#Set the activity variable in the data as a factor
tabStep2ExtractedData$Activity <- as.factor(tabStep2ExtractedData$Activity)

#Step 4
#4. Appropriately labels the data set with descriptive variable names.

# a. leading t or f is based on time or frequency measurements
# b. Body = related to body movement.
# c. Gravity = acceleration of gravity
# d. Acc = accelerometer measurement
# e. Gyro = gyroscopic measurements
# f. Jerk = sudden movement acceleration
# g. Mag = magnitude of movement
# h. mean and SD are calculated for each subject for each activity for each mean and SD measurements. The units given are g’s for the accelerometer and rad/sec for the gyro and g/sec and rad/sec/sec for the corresponding jerks.

#Debug names
names(tabStep2ExtractedData)

names(tabStep2ExtractedData)<-gsub("^t", "Time", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("^f", "Frequency", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("Acc", "Accelerometer", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("Gyro", "Gyroscope", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("BodyBody", "Body", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("Mag", "Magnitude", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("-mean()", "MEAN", names(tabStep2ExtractedData), ignore.case = TRUE)
names(tabStep2ExtractedData)<-gsub("-std()", "SD", names(tabStep2ExtractedData), ignore.case = TRUE)

#Debug names
names(tabStep2ExtractedData)

#Step 5
#5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Set the subject variable in the data as a factor

tabStep2ExtractedData$Subject <- as.factor(tabStep2ExtractedData$Subject)
tabStep5ExtractedData <- data.table(tabStep2ExtractedData)

#Create tidyData as a set with average for each activity and subject
tidyData <- aggregate(. ~Subject + Activity, tabStep5ExtractedData, mean)

#Order tidayData according to subject and activity
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]

#Write tidyData into a text file
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
