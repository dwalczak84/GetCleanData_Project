# Load packages
library("data.table")
library("reshape2")

# Dowdnload and extract the data:
download.file(paste0('https://d396qusza40orc.cloudfront.net/', 'getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'), method='curl', destfile='getdata-projectfiles-UCI HAR Dataset.zip') 
unzip('getdata-projectfiles-UCI HAR Dataset.zip')

# Reading activity labels and features and subjects, only 2nd columns 
# of the files
ActvLbls <- read.table('UCI HAR Dataset/activity_labels.txt')[, 2]
Feats <- read.table('UCI HAR Dataset/features.txt')[, 2]

# Extract the measurements for mean and std from features.txt:
ExtrFeats <- grepl("mean|std", Feats)

# Reading subject_test, X_test and y_test:
Stst <- read.table('UCI HAR Dataset/test/subject_test.txt') 
Xtst <- read.table('UCI HAR Dataset/test/X_test.txt') 
Ytst <- read.table('UCI HAR Dataset/test/y_test.txt') 
names(Xtst) <- Feats
Xtst <- Xtst[, ExtrFeats]
Ytst[, 2] <- ActvLbls[Ytst[, 1]]
names(Ytst) <- c("ActivityID", "ActivityLabel")
names(Stst) <- "Subject"

# Combine test data
DataTst <- cbind(as.data.table(Stst), Ytst, Xtst)

# Reading subject_train, X_train and y_train:
Strn <- read.table('UCI HAR Dataset/train/subject_train.txt') 
Xtrn <- read.table('UCI HAR Dataset/train/X_train.txt') 
Ytrn <- read.table('UCI HAR Dataset/train/y_train.txt') 
names(Xtrn) <- Feats
Xtrn <- Xtrn[, ExtrFeats]
Ytrn[, 2] <- ActvLbls[Ytrn[, 1]]
names(Ytrn) <- c("ActivityID", "ActivityLabel")
names(Strn) <- "Subject"

# Combine train data
DataTrn <- cbind(as.data.table(Strn), Ytrn, Xtrn)

# Combine test and train data sets together
Data <- rbind(DataTst, DataTrn)
IdLbls <- c("Subject", "ActivityID", "ActivityLabel")
DataLbls <- setdiff(colnames(Data), IdLbls)
MeltData <- melt(Data, id = IdLbls, measure.vars = DataLbls)

# Apply mean function to dataset with usage of dcast function
DataTidy <- dcast(MeltData, Subject + ActivityLabel ~ variable, mean)

# Write tidy data to .txt file
write.table(DataTidy, file = "/DataTidy.txt", row.name = FALSE)


