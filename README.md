Assignment: Getting and Cleaning Data Course Project
---------------------------------------------------------------

##Project Purpose

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

Here are the data for the project:

<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. The target R script called run_analysis.R does the following:
- Merges the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement.
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names.
- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


The repository contains following files:

- *run_analysis.R* : The R code that perfroms required functionality

- *Tidy.txt* : The clean data extracted from different data sets *run_analysis.R*

- *CodeBook.md* : the CodeBook reference to the variables in *Tidy.txt*

- *README.md* : Purpose of the document and how the R code *run_analysis.R* works


## Code Details

###Download the file and extract it if the directory doesn't exist

The R code checks if a directory `UCI HAR Dataset` exists at the preferred location. If the directory doesn't exist get the Zip file available at <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> using `download.file` and extarct using `unzip`. Don't forget to specify `method="curl" while using `download.file`

```{r}
filePath <- "../UCI HAR Dataset"
if(!file.exists(filePath)) {
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, "../getdata_projectfiles_UCI HAR Dataset.zip")
        unzip(zipfile="../getdata_projectfiles_UCI HAR Dataset.zip",exdir="../")
}
```

###Libraries Used

The libraries used in this operation are `data.table` and `dplyr`.

```{r}
library(data.table)
library(dplyr)
```

##Step 1
##1. Merges the training and the test sets to create one data set.

### Each directory consists of files for subject(subject_*.txt), activity(y_*.txt) and features(X_*.txt)

###Read trainng data
```{r}
tabSubjectTraining <- read.table(file.path(filePath,"train", "subject_train.txt"), header = FALSE)
tabActivityTraining <- read.table(file.path(filePath,"train", "y_train.txt"), header = FALSE)
tabFeaturesTraining <- read.table(file.path(filePath,"train", "X_train.txt"), header = FALSE)
```

###Read test data
```{r}
tabSubjectTest <- read.table(file.path(filePath,"test", "subject_test.txt"), header = FALSE)
tabActivityTest <- read.table(file.path(filePath,"test", "y_test.txt"), header = FALSE)
tabFeaturesTest <- read.table(file.path(filePath,"test", "X_test.txt"), header = FALSE)
```

###First let's merge the rows of both data sets
```{r}
tabSubject <- rbind(tabSubjectTraining, tabSubjectTest)
tabActivity <- rbind(tabActivityTraining, tabActivityTest)
tabFeatures <- rbind(tabFeaturesTraining, tabFeaturesTest)
```

###We will assign column names to previous data as the data doesn't containt any headers. Features are available in features.txt

###Get the data from the input files
```{r}
tabFeatureNames <- read.table(file.path(filePath,"features.txt"), header = FALSE)
tabActivityLabels <- read.table(file.path(filePath, "activity_labels.txt"), header = FALSE)
```

###Assign column names to the row merged data sets
###Features names are in the second column of tabFeatureNames
```{r}
colnames(tabFeatures) <- t(tabFeatureNames[2])
```

###Assign hard coded valeues "Subject" and "Activity" as column names for `tabSubject` and `tabActivity`
```{r}
colnames(tabSubject) <- "Subject"
colnames(tabActivity) <- "Activity"
```

###Finally column merge all three data tables into `tabStep1MergedData`
```{r}
tabStep1MergedData <- cbind(tabSubject, tabActivity, tabFeatures)
```

##Step 2
##2. Extracts only the measurements on the mean and standard deviation for each measurement. 

###Use grep to find columns with name containing mean and standard deviation(std). Even though we know the column numbers of column names `Subject` and `Activity` we have used similar grep function for those. These may be parameterized in future
```{r}
colNamesWithMeanandStd <- grep("mean\\(\\)|std\\(\\)", names(tabStep1MergedData), ignore.case=TRUE)
colNameSubject <- grep("Subject", names(tabStep1MergedData), ignore.case=FALSE)
colNameActivity <- grep("Activity", names(tabStep1MergedData), ignore.case=FALSE)
```

###Get the columns to be filtered
```{r}
vecReqColumns <- c(colNameSubject, colNameActivity, colNamesWithMeanandStd)
```

###Check dimensions in data table after Step 1 `tabStep1MergedData`
```{r}
dim(tabStep1MergedData)
```

###Extract required data into data table `tabStep2ExtractedData`
```{r}
tabStep2ExtractedData <- tabStep1MergedData[,vecReqColumns]
```

###Now check the Dimensions in data table after Step 2 `tabStep2ExtractedData`
```{r}
dim(tabStep2ExtractedData)
```

##Step 3
##3. Uses descriptive activity names to name the activities in the data set

###The `Activity` field in `tabStep2ExtractedData` is of type numeric. Let's change it ot character type to assign descriptive values. The labels are already read into `tabActivityLabels`
```{r}
tabStep2ExtractedData$Activity <- as.character(tabStep2ExtractedData$Activity)
for (i in 1:6){
  tabStep2ExtractedData$Activity[tabStep2ExtractedData$Activity == i] <- as.character(tabActivityLabels[i,2])
 }
```

###Set the activity variable in the data as a factor once the activity names are updated
```{r}
tabStep2ExtractedData$Activity <- as.factor(tabStep2ExtractedData$Activity)
```

##Step 4
##4. Appropriately labels the data set with descriptive variable names.

###The following acronyms needs to be replaced:
- Leading t or f is based on time or frequency measurements. Replace `^t` with Time and `^f` with Frequency
- Body = related to body movement. Replace `BodyBody` with Body
- Gravity = acceleration of gravity
- Acc = accelerometer measurement. Replace `Acc` with Accelerometer
- Gyro = gyroscopic measurements. Replace `Gyro` with Gyroscope
- Jerk = sudden movement acceleration
- Mag = magnitude of movement. Replace `Mag` with Magnitude
- mean and SD are calculated for each subject for each activity for each mean and SD measurements. The units given are g’s for the accelerometer and rad/sec for the gyro and g/sec and rad/sec/sec for the corresponding jerks. Replace `-mean()` with MEAN and `-std()` with SD

###Let's see the names before replacing using `gsub`
```{r}
names(tabStep2ExtractedData)
```

###Replace the column name using gsub
```{r}
names(tabStep2ExtractedData)<-gsub("^t", "Time", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("^f", "Frequency", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("Acc", "Accelerometer", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("Gyro", "Gyroscope", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("BodyBody", "Body", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("Mag", "Magnitude", names(tabStep2ExtractedData))
names(tabStep2ExtractedData)<-gsub("-mean()", "MEAN", names(tabStep2ExtractedData), ignore.case = TRUE)
names(tabStep2ExtractedData)<-gsub("-std()", "SD", names(tabStep2ExtractedData), ignore.case = TRUE)
```

###Let's see the names after replacing using `gsub`
```{r}
names(tabStep2ExtractedData)
```

##Step 5
##5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Let's set the subject variable in the data as a factor
```{r}
tabStep2ExtractedData$Subject <- as.factor(tabStep2ExtractedData$Subject)
tabStep5ExtractedData <- data.table(tabStep2ExtractedData)
```

###Create tidyData as a set with average for each activity and subject
```{r}
tidyData <- aggregate(. ~Subject + Activity, tabStep5ExtractedData, mean)
```

###Order tidayData according to subject and activity
```{r}
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
```

###Write tidyData into a text file
```{r}
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
```
