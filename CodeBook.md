---
title: "CodeBook.md"
author: "Richard Ebling"
date: "09/21/2014"
output: html_document
---
When you click the **Knit** button a document will be generated that includes both 

This data was obtained from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip , using wget under Linux, then unZIPped into an appropriate directory, with no other transformations.

The original source description is available at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones . 

Transformation: Through the script run_analysis.R,  the "train" and "test" files were merged back into a combined file, which should be the same as the original data before it was separated into training and test subsets.  Subject ID's and Activity descriptions were also re-merged into the file, keeping all merged segments in the same order of observations. Apart from ID and Activity, only columns with "mean" or "std" in the variable names were retained. 

 Data comes from 30 subjects in all, each of whom performed 6 different Activities during the monitoring period; 79 variables were reviewed (note: some reviewers may have omitted the 13 'meanFreq' columns, for 66 variables)
 
Data was grouped by ID and Activity, and means were calculated for each ID-Activity pair, for all variables, yielding a dataframe which was then saved as filename "Means_of_Means_ByActivityBySubject.txt", containing 180 observations of 81 variables; columns were renamed to reflect that means and standard deviations (in the original dataset) were transformed to Means OF those means, and standard deviations. The units of measurement for the values were not given in the original dataset, but were generally in terms of linear acceleration or angular acceleration (gravitational component was subtracted out of the original data set). 

 Note: in the output file, "Means_of_Means_ByActivityBySubject.txt", names of variables were altered to replace '-' with '_',  and to remove '()' characters and blanks, for technical reasons. This does not appear to have changed the meaning of the variable names. 

Description of the three variable types whose means were calculated for this 
report: 
meanFreq(): Weighted average of the frequency components to obtain a mean frequency
mean(): Mean value
std(): Standard deviation

*Many thanks to the original researchers who have made their data openly available for use:*
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012.