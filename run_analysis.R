## Getting and cleaning data course project
## run_analysis.R is doing the following
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## check reshape2 package
if(!is.element("reshape2", installed.packages()[,1])){
  print("Installing packages")
  install.packages("reshape2")
}

library(reshape2)


## download and unzip the file if it does not already exist
file_name <- "dataset.zip"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if (!file.exists(file_name)){
  print("Downloading online data")
  download.file(fileURL, file_name)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file_name) 
}

## Read tables from the activity_labels and features files

activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities[,2] <- as.character(activities[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## Extract mean and standard deviation columns
meansd <- grep(".*mean.*|.*std.*", features[,2])
meansd.names <- features[meansd,2]
meansd.names = gsub('-mean', 'mean', meansd.names)
meansd.names = gsub('-std', 'standarddeviation', meansd.names)
meansd.names <- gsub('[-()]', '', meansd.names)


## Read the train and test datasets
trainset <- read.table("UCI HAR Dataset/train/X_train.txt")[meansd]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainset <- cbind(trainSubjects, trainActivities, trainset)

testset <- read.table("UCI HAR Dataset/test/X_test.txt")[meansd]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testset <- cbind(testSubjects, testActivities, testset)

## Merge train and test datasets
dataset1 <- rbind(trainset, testset)
colnames(dataset1) <- c("subject", "activity", meansd.names)

## Turn activities & subjects into factors
dataset1$activity <- factor(dataset1$activity, levels = activities[,1], labels = activities[,2])
dataset1$subject <- as.factor(dataset1$subject)

dataset1.melted <- melt(dataset1, id = c("subject", "activity"))
dataset1.mean <- dcast(dataset1.melted, subject + activity ~ variable, mean)

## Save TidyDataSet.txt
write.table(dataset1.mean, "TidyDataSet.txt", row.names = FALSE, quote = FALSE)