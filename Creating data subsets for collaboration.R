# Creating a subset of the data to share will collaborators

library(stringr)
library(googledrive) # googledrive app will need to be configured!!!
library(purrr)
# Note # Here we just have one stations photos to save time and space #

# First download the test images stored on GoogleDrive and put them in the images folder (the example is RICH10)
###
drive_auth()
1
dir.create("Example raw data/Images/RICH10")
## The folder location
folder_url <- "https://drive.google.com/drive/folders/1TZmPcNjWFe8p4kZ3hr04T-Gqb5z4PIIs"
## let googledrive know this is a file ID or URL, as opposed to file name
folder <- drive_get(as_id(folder_url))
## identify the jpg files in that folder and download them to the created folder
jpg_files <- drive_ls(folder, type = "jpg")
for(i in 1:nrow(jpg_files))
{
   drive_download(as_id(jpg_files$id[i]), path=paste0("Example raw data/Images/RICH10/", jpg_files$name[i]), overwrite=T)
   print(i)
}
###

# What are the files you need to complete this code?

# 1. The deployment data and station covariates
# 2. The sub-setted detection data
# 3. The raw image files (if required)

# Name your project
project.name <- "Wolves Test Export"
# Create a list of species you want to extract
species.names <- c("Canis lupus")    # If you want more species, add them within the brackets separated by commas c("Canis lupus", "Canis latrans")

# Create a folder to store the files and images
dir.create(project.name)

# Inside this folder create a sub-directory to share the raw images
dir.create(paste0(project.name,"/Images"))

# Update to current file names and import full dataset - THESE MAY NEED UPDATING
all.dat <- read.csv("Example raw data/Master data//Detection_Data_June_2020_EXAMPLE.csv", header=T)
file.copy("Example raw data//Master data//Deployment_Data_Feb_2020_EXAMPLE.csv", paste0(project.name,"/"), overwrite = T)
file.copy("Example raw data//Master data//Station_Covariates_Feb_2020_EXAMPLE.csv", paste0(project.name,"/"),  overwrite = T)

# Use logic to subset the data you do want
sub.dat <- all.dat[all.dat$Species %in% species.names,]

# Write the file containing the subsetted data
write.csv(sub.dat, paste0(project.name,"/Richardson_2015_2019_", species.names, "_Data.csv"), row.names=F)

# Copy over the raw images relating to canis latrans

# Create a list of all the canis latrans files
images.needed <- as.character(sub.dat$Image.ID)

# As we have so many files, it is easier to break down by station
# NOTE HERE WE HAVE JUST ONE FOLDER AS AN EXAMPLE

dirs <- list.files(path="Example raw data/Images/", full.names = T)
i <- 1
# Loop through the stations
for(i in 1:length(dirs))
{
  # Make a list of all the files in the folder
  # With the full path
   tmp <- list.files(path=dirs[i], recursive=T)
   
  #If you have extra file structures (e.g. photos are categorized based on camera check dates), subset the string so that the extra characters due to extra file structure are removed. 
  #the line below omits everything before (and including) the last dash. what you are left is your "image namae.jpg"
  tmp2<-gsub('^(?:[^/]*/)*\\s*(.*)', '\\1', tmp)
  
  #or if you have a file structure with constant number of characters you can just subset based on the number of characters you want to omit.
  #the line below omits characters 1-11, sand starts the string from charcter 12 (That is because in our file structure photos were filed under cam visit dates with the format YYYY_MM_DD; That is 10 charcters + 1 charcter for the '/' following that)
  #tmp2<-substring(tmp, 12)
  
  # Some of our legacy files have raw files with brackets in, whereas in the data they have been removed.
  # The way to do this is to remove any brackets from both the data (just in case) and the raw file names
  
  # The following removes brackets from the strings
  tmp3 <- str_remove_all(tmp2, "[()]")
  images.needed2 <- str_remove_all(images.needed, "[()]")
  
  # Subset the files to just those which you are interested in.
  tmp <- tmp[tmp3 %in% images.needed2]
  # Make a copy of the required files in the collaboration  folder
  file.copy(paste0(dirs[i],"/",tmp),  paste0(project.name, "/Images/" ))
  # Counter
  print(paste(round((i/length(dirs)*100), 2), "%"))
}

# Check that the folder has your images in it!


