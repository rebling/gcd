# run_analysis.R   for getdata-007  R.Ebling
## for PREPROCESSING info  and detailed comments on this script,
## please see README.md

# load libraries needed for analysis:
library("dplyr", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("tidyr", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")

# set working directory to location of data, then unzip data file
setwd("~/DS-R/gcd/")
unzip("getdata-projectfiles-UCI HAR Dataset.zip")

# read files into data_frame_tbl to enable dplyr conveniences
sj_train <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/train/subject_train.txt", quote="\"", stringsAsFactors=FALSE))
sj_test <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/test/subject_test.txt", quote="\"", stringsAsFactors=FALSE))
y_test <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/test/y_test.txt", quote="\"", stringsAsFactors=FALSE))
X_test <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/test/X_test.txt", quote="\"", stringsAsFactors=FALSE))
X_train <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/train/X_train.txt", quote="\"", stringsAsFactors=FALSE))
y_train <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/train/y_train.txt", quote="\"", stringsAsFactors=FALSE))
activity_labels <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/activity_labels.txt", quote="\"", stringsAsFactors=FALSE))
features <- tbl_df(read.table("~/DS-R/gcd/UCI HAR Dataset/features.txt", quote="\"", stringsAsFactors=FALSE))


# identify column labels from 'features' list, containing "mean" or "std"
mean_std_cols <- grep("mean|std", features[[2]])
# ( deliberately excluded [Mm]ean )

# Extract measurements on the mean & SD for each measurement.
# Merge the training and the test sets to create one data set.
maindf <- rbind(X_test[,mean_std_cols], X_train[mean_std_cols])

# apply var names to corresponding columns in maindf AFTER removing '-' and
# '()' to create legal columnames
fixednams <- gsub("\\(\\)", "", gsub("-","_", features[mean_std_cols,2]), perl=TRUE)
names(maindf) <- fixednams

# combine pairs of test/train data into corresponding files, ID and Activity
ID <- rbind(sj_test, sj_train)
names(ID) <- "ID"
# assign appropriate names to both for following step
Activity <- rbind(y_test, y_train)
names(Activity) <- "Activity"

# generate combined file with all info
ti_D <- cbind(ID, Activity, maindf)

# convert Activity to levels with labels
ti_D$Activity <- factor(ti_D$Activity, levels = c(1,2,3,4,5,6), labels = c("Walking", "Walking_up_stairs", "Walking_down_stairs", "Sitting", "Standing", "Laying"))

#ensure table_df wrapper is applied ot new file
TidyDF <- tbl_df(ti_D)

# group data framce by activity & ID
grouptdf <- group_by(TidyDF, Activity, ID)

# calculate means for all variables within each group of rows:
Means_of_Means_ByActivityBySubject<- summarise_each(grouptdf, funs(mean))

# assign updated names to reflect contents
newnamesAll <- c("Activity", "ID", gsub("^", "MEAN_OF_", names(TidyDF[3:81])))

# save updated object to storage as txt file
write.table(Means_of_Means_ByActivityBySubject, file="Means_of_Means_ByActivityBySubject.txt", sep=" ", row.names = FALSE, )

# print ouput for review
print(Means_of_Means_ByActivityBySubject)


# BIG THANKS for the data, to: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier
# Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using # a Multiclass Hardware-Friendly Support Vector Machine. International Workshop
# of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
