library(dplyr)
library(reshape2)

#setting a directory in the local system 
dir<- setwd("D:/Coursera/Getting & cleaning data/1_project")
dir_2<-paste(dir, "/", "data.zip", sep = "")

# Weblink of the data 
url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Downloading raw data in the directory 
download.file(url = url, destfile = dir_2)

#Creating new folder to unzip the raw data file 
if (!file.exists("./data_unzip")){
  dir.create("./data_unzip")
}

#Unzip the data 
unzip("./data.zip", exdir = "data_unzip")

#Now reading the data from the train set
train_x<- read.table(file = "./data_unzip/UCI HAR Dataset/train/X_train.txt", sep = "")
train_y<- read.table(file = "./data_unzip/UCI HAR Dataset/train/y_train.txt", sep = "")
train_subject<-train_x<- read.table(file = "./data_unzip/UCI HAR Dataset/train/subject_train.txt", sep = "")

#Reading the test data 
test_x<- read.table(file = "./data_unzip/UCI HAR Dataset/test/X_test.txt", sep = "")
test_y<- read.table(file = "./data_unzip/UCI HAR Dataset/test/y_test.txt", sep = "")
test_subject<- read.table(file = "./data_unzip/UCI HAR Dataset/test/subject_test.txt", sep = "")

#Reading activity labels
activity_labels<- read.table("./data_unzip/UCI HAR Dataset/activity_labels.txt", sep = "")

#Reading features
features<- read.table("./data_unzip/UCI HAR Dataset/features.txt", sep = "")

#Renaming the columns 

#For x, naming from the dataframe of features
names(train_x)<- features[,2] 
names(test_x)<- features[,2]
#now combining as a single set for x
x<- rbind(train_x, test_x)

#For y
names(train_y)<-"Activity_no" 
names(test_y) <- "Activity_no" 
#combining both test and train for y
y<- rbind(train_y, test_y)

#for subject
names(train_subject)<- "Subject_no"
names(test_subject)<- "Subject_no"  
#combining as well
subject<- rbind(train_subject, test_subject) 

#Combinig all the train and test data data into a single dataset
df<- cbind(y, subject, x)
  
#Name of the variables of df
columns_df<- colnames(df)

#Extracting columns with "mean" 
select_mean<-grep("mean", columns_df)
df_mean<- df[, select_mean]

#Extracting column with "std"
select_std<-grep("std", columns_df)
df_std<- df[, select_std]

#Combining both the columns for mean and std 
df_meanandstd<- cbind(y, subject, df_mean, df_std)

#renaming the columns of activity_labels
activity_labels_2<- rename(activity_labels, Activity_no=1, Activity=2 )

#Now, merging the data frames 
df_mean.std_activity<- merge(activity_labels_2, df_meanandstd,
                             by= "Activity_no")


#Now, making a second tidy data according to the combination of activity and subject
#Meltin the values according to subject and activity
df_sub_act<- melt(df_mean.std_activity, id = c("Subject_no", "Activity"))
#creating the 2nd tidy data 
df_tidy <- dcast(n, Subject_no + Activity ~ variable, mean)

#Finally sorting the 2nd tidy data according to the subject no. and activity no.
df_tidy_sorted<- arrange(df_tidy, Subject_no, Activity_no )

#Saving the data as text file in the local system
write.table(df_tidy_sorted, "./geting_and_cleaning_data.txt",
            row.names = FALSE, quote = FALSE)








