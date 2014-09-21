---
title: "README.md"
author: "Richard Ebling"
date: "09/21/2014"
output: html_document
---
This explains how run_analysis.R works. 

## Before running R code, some pre-processing was done in Linux, using bash shell commands: 
* created directory to contain data for analysis:
`$ mkdir ~/DS-R/gcd`
* changed working directory to the new data directory:
`$ cd ~/DS-R/gcd`
* used 'wget' utility to obtain data file (url copied from Course Project docs)
`$ wget https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip`
## Everything else is R code/comments.
To load libraries needed:
`library("dplyr", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")`
`library("tidyr", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")`
Then set working directory to location of data, and unzip data file
`setwd("~/DS-R/gcd/")`
`unzip("getdata-projectfiles-UCI HAR Dataset.zip")`

### General Plan:
0. read data, write key describing contents
1. identify columns of interest (labels with 'mean' or 'std', from 'features')
*Note: variable names ending in -mean(), -meanFreq, and -std() appear to match
 the specification. Variable names containing "Mean" represented angles, NOT
 means (cf line 49 of features_info.txt, and inspection of var names). **Many
 thanks to John Goffart** for [pointing that out in the Forum** (see https://class.coursera.org/getdata-007/forum/thread?thread_id=49)*

2. combine 3 pairs of 'train' and 'test' data into 3 longer+narrower datasets
with meaningful names (while excluding unwanted columns)
3. combine those 3 "longer" datasets into one "wider" dataset for analysis
4. analyze for avg of each variable by activity & subject

## Reading files into data_frame_tbl to enable dplyr conveniences
`sj_train <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/train/subject_train.txt", quote="\"", stringsAsFactors=FALSE))`
`sj_test <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/test/subject_test.txt", quote="\"", stringsAsFactors=FALSE))`
`y_test <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/test/y_test.txt", quote="\"", stringsAsFactors=FALSE))`
`X_test <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/test/X_test.txt", quote="\"", stringsAsFactors=FALSE))`
`X_train <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/train/X_train.txt", quote="\"", stringsAsFactors=FALSE))`
`y_train <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/train/y_train.txt", quote="\"", stringsAsFactors=FALSE))`
`activity_labels <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/activity_labels.txt", quote="\"", stringsAsFactors=FALSE))`
`features <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/features.txt", quote="\"", stringsAsFactors=FALSE))`

## After viewing data sets, examining them with dim(dataframe), etc: create a reference description of data frames (all text/data files are ordered):
X_test.txt contains 2947 observations of 561 variables ("features")
X_train.txt containes 7352 observations of 561 variables ("features")
objects sj_test and sj_train contain subject id-numbers for 2947 & 7352 observations #   (dim = 2947 x1   and 7352 x 1 respectively)
y_test and y_train contain 'activity' codes for 2947 & 7352 observations
  (dim = 2947  x1   and 7352 x 1 respectively)
Concluded because 'activity' codes (6-level factor) based on min=1, max=6, mean=~3.5)
activity_labels.txt contains the 6 labels with numeric codes for each
features.txt contains list of 561 variable names (equals # vars in X_t*)

## 1. identify column labels from 'features' list, containing "mean" or "std"
`mean_std_cols <- grep("mean|std", features[[2]])`
*deliberately avoided using [Mm]ean*

Instructions said to extract only measurements on the mean & SD for each measurement, and to merge the training and the test sets to create one data set".
Rather than doing those separately, the tasks were combined by using the results of the grep command above:

### combine Mean+SD columns of X_test and X_train, into "maindf"
`maindf <- rbind(X_test[,mean_std_cols], X_train[mean_std_cols])`

### apply var names to corresponding columns in maindf, *after* removing '-' and '()' so names will be legal column names:
`fixednams <- gsub("\\(\\)", "", gsub("-","_", features[mean_std_cols,2]), perl=TRUE)
names(maindf) <- fixednams`

### combine datasets 'sj_test' & 'sj_train' into "ID" (being careful to use the same sequence as X_test and X_train, so data will be aligned properly)
`ID <- rbind(sj_test, sj_train)`

### combine datasets 'y_test' & 'y_train' into "Activity" (same sequence as X_t*)
`Activity <- rbind(y_test, y_train)`

### add column names to ID and Activity: 
`names(ID) <- "ID"`
`names(Activity) <- "Activity"`

### combine ID, Activity, maindf (in that order) to create the working df
`ti_D <- cbind(ID, Activity, maindf)`

### assign labels for factors (Activities):
`ti_D$Activity <- factor(ti_D$Activity, levels = c(1,2,3,4,5,6), labels = c("Walking", "Walking_up_stairs", "Walking_down_stairs", "Sitting", "Standing", "Laying"))`
### make sure result of data operations is a data frame tbl:
`TidyDF <- tbl_df(ti_D)`

### Because project instructions are ambiguous, there are 3 main options for generating tidy data in step#5; must group dataframe as needed, and generate summary stats, showing one of: 
1. mean of each variable ("feature"), by activity AND subject
2. mean of each variable, by SUBJECT
3. mean of each variable, by ACTIVITY

Since #1 seems to be best supported in getdata-007 Discussion Forum, by advisors as well as students, and is the most comprehensive, that was the option selected for this project. 

## organize dataframe into subsets: 
`grouptdf <- group_by(TidyDF, Activity, ID)`

## apply 'mean' to each column within each subset, by using 'summarise_each'
`Means_of_Means_ByActivityBySubject<- summarise_each(grouptdf, funs(mean))`
## modify namelist to reflect the type of data in the new dataframe:
`newnamesAll <- c("Activity", "ID", gsub("^", "MEAN_OF_", names(TidyDF[3:81])))`

## instructions say that the script should "output" the final data frame. So to be sure, it gets printed and saved for uploading. 
`print(Means_of_Means_ByActivityBySubject)`

## Saving output as a .txt file, per specification: 
`write.table(Means_of_Means_ByActivityBySubject, file="Means_of_Means_ByActivityBySubject.txt", sep=" ", row.names = FALSE, )`

### The following code sections are not "live" in run_analysis.R, but are included for lagniappe, to demonstrate means to accomplish options #2 and #3, above (output columns would need renaming).

### Shoe means of all variables for each Activity (would need to relabel them)
`groupAct <- group_by(TidyDF, Activity)`
`summarise_each(groupAct, funs(mean))[,c(1,3:81)]`

Showing means of all vars for each SUBJECT (vars need relabeling)
`groupSubj <- group_by(TidyDF, ID)`
`summarise_each(groupSubj, funs(mean))[,c(1:2,4:81)]`

End of file.