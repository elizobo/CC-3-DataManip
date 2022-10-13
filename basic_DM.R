# Coding Cblub

# Part 1 Subset, extract and modify----
# Set your working directory to where the folder is saved on your computer
setwd("~/Desktop/Coding/CodingClub/CC-3-DataManip")

# Load the elongation data
elongation <- read.csv("EmpetrumElongation.csv", header = TRUE)   

# Check import and preview data
head(elongation)   # first few observations
str(elongation)    # types of variables

# Let's get some information out of this object!
elongation$Indiv   # prints out all the ID codes in the dataset
length(unique(elongation$Indiv))   # returns the number of distinct shrubs in the data

# Here's how we get the value in the second row and fifth column
elongation[2,5]

# Here's how we get all the info for row number 6
elongation[6, ]

# And of course you can mix it all together!
elongation[6, ]$Indiv   # returns the value in the column Indiv for the sixth observation
# (much easier calling columns by their names than figuring out where they are!)

# Dont subset with [row, column] as the observation there might change later on and its hard to find in big datasets
#Use LOGICAL OPERATIONS
# Let's access the values for Individual number 603
elongation[elongation$Indiv == 603, ]
    # "Take this dataframe (elongation), 
    # subset it ([ , ]) so as to keep the rows (writing the expression on the left-hand of the comma) 
    # for which the value in the column Indiv ($Indiv) is exactly (==) 603”.
# and if you wanted to access a character use elongation$Indiv == "six-hundred-and-three".


## OPERATORS FOR LOGICAL OPERATIONS ----

# Subsetting with one condition

elongation[elongation$Zone < 4, ]    # returns only the data for zones 2-3
elongation[elongation$Zone <= 4, ]   # returns only the data for zones 2-3-4


# This is completely equivalent to the last statement
elongation[!elongation$Zone >= 5, ]   # the ! means exclude
      #so like exclude values 5 and above

# Subsetting with two conditions
elongation[elongation$Zone == 2 | elongation$Zone == 7, ]    # returns only data for zones 2 and 7
  #at least one should be met
elongation[elongation$Zone == 2 & elongation$Indiv %in% c(300:400), ]    # returns data for shrubs in zone 2 whose ID numbers are between 300 and 400
  #both should be met
  # : colon means counting

# making sequences
seq(300, 400, 10) # going from 300 to 400 in steps of 10
rep(c(1,2), 3) # repeating 1 and 2 3 times
rep(seq(0, 30, 10), 4)# going from 0 to 30 with intervals of 10 4 times

## CHANGING VARIABLE NAMES AND VALUES IN A DATA FRAME----

# Let's create a working copy of our object
elong2 <- elongation

# Now suppose you want to change the name of a column: you can use the names() function
# Used on its own, it returns a vector of the names of the columns. Used on the left side of the assign arrow, it overwrites all or some of the names to value(s) of your choice.

names(elong2)                 # returns the names of the columns

names(elong2)[1] <- "zone"    # Changing Zone to zone: we call the 1st element of the names vector using brackets, and assign it a new value
names(elong2)[2] <- "ID"      # Changing Indiv to ID: we call the 2nd element and assign it the desired value

# Now suppose there's a mistake in the data, and the value 5.1 for individual 373 in year 2008 should really be 5.7

## - option 1: you can use row and column number
elong2[1,4] <- 5.7

## - option 2: you can use logical conditions for more control
elong2[elong2$ID == 373, ]$X2008 <- 5.7   # completely equivalent to option 1
  #in this dataframe, the id column of the dataframe defo equals 373, within the x2008 column, change it to this
  #means you dont need to know exactly where the data is


## CHANGING CLASS AND FACTOR LEVELS----

# Let's check the classes
str(elong2)

# The zone column shows as integer data (whole numbers), but it's really a grouping factor (the zones could have been called A, B, C, etc.) Let's turn it into a factor:

elong2$zone <- as.factor(elong2$zone)        # converting and overwriting original class
str(elong2)                                  # now zone is a factor with 6 levels
 

## CHANGING A FACTOR'S LEVELS

levels(elong2$zone)  # shows the different factor levels

levels(elong2$zone) <- c("A", "B", "C", "D", "E", "F")   # you can overwrite the original levels with new names

# You must make sure that you have a vector the same length as the number of factors, and pay attention to the order in which they appear!


#Part 2 Tidy data----

# tidy data is longform data - each row represents an observation and each column represents a variable.

install.packages("tidyr")  # install the package
library(tidyr)             # load the package


elongation_long <- gather(elongation, Year, Length,                           # in this order: data frame, key, value
                          c(X2007, X2008, X2009, X2010, X2011, X2012))        # we need to specify which columns to gather

# Here we want the lengths (value) to be gathered by year (key)

# Let's reverse! spread() is the inverse function, allowing you to go from long to wide format
elongation_wide <- spread(elongation_long, Year, Length)

#if you have a large dataset and think the order of columns wont change 
elongation_long2 <- gather(elongation, Year, Length, c(3:8)) #you can use numbers to gather

#interanual variation of growth can be quickly summoned now with neat dataframe
boxplot(Length ~ Year, data = elongation_long,
        xlab = "Year", ylab = "Elongation (cm)",
        main = "Annual growth of Empetrum hermaphroditum")

# Part 3 functions of dplyr----

#functions that take dataframe as the first argyment so dont need to keep refering to it with every subpart with $

install.packages("dplyr")  # install the package
library(dplyr)              # load the package

rename()
filter()and select()
mutate()
group_by()
summarise()
join()

## 1. RENAME VARIABLES----

elongation_long <- rename(elongation_long, zone = Zone, indiv = Indiv, year = Year, length = Length)     # changes the names of the columns (getting rid of capital letters) and overwriting our data frame

# As we saw earlier, the base R equivalent would have been
names(elongation_long) <- c("zone", "indiv", "year", "length")

## 2. FILTER ROWS AND SELECT() COLUMNS----
# FILTER OBSERVATIONS

# Let's keep observations from zones 2 and 3 only, and from years 2009 to 2011

elong_subset <- filter(elongation_long, zone %in% c(2, 3), year %in% c("X2009", "X2010", "X2011")) 
      # you can use multiple different conditions separated by commas

# For comparison, the base R equivalent would be (not assigned to an object here):
elongation_long[elongation_long$zone %in% c(2,3) & elongation_long$year %in% c("X2009", "X2010", "X2011"), ]

#  %in% as a logical operator because we are looking to match a list of exact (character) values, not a numeric range

new.object <- elongation_long # creates a duplicate of our object,
new.object <- "elongation_long" # creating an object consisting of one character value.



# SELECT COLUMNS

# Let's ditch the zone column just as an example

elong_no.zone <- dplyr::select(elongation_long, indiv, year, length)   # or alternatively
elong_no.zone <- dplyr::select(elongation_long, -zone) # the minus sign removes the column

# For comparison, the base R equivalent would be (not assigned to an object here):
elongation_long[ , -1]  # removes first column

# A nice hack! select() lets you rename and reorder columns on the fly
elong_no.zone <- dplyr::select(elongation_long, Year = year, Shrub.ID = indiv, Growth = length)

# Neat, uh?




## 3a. MUTATE DATASET, MAKE NEW COLUMNS----

# CREATE A NEW COLUMN (wide format)

elong_total <- mutate(elongation, total.growth = X2007 + X2008 + X2009 + X2010 + X2011 + X2012)


## 3b. GROUP BY FACTORS AND PERFORM OPERATIONS (long format)----

elong_grouped <- group_by(elongation_long, indiv)   # grouping our dataset by individual
  # no visible differences but creates an internal grouping
  #every subsequent function you run on it will use these groups, and not the whole dataset, as an input
  # useful for summary statistics of site, species etc.

## 3c. SUMMARISE DATA WITH SUMMARY STATISTICS----

#always create a new object for summarised data so the original full dataset doesnt go

summary1 <- summarise(elongation_long, total.growth = sum(length))
summary2 <- summarise(elong_grouped, total.growth = sum(length))
#summary 2 has the grouped internal dataframe so the output is for each group

summary3 <- summarise(elong_grouped, total.growth = sum(length),
                      mean.growth = mean(length),
                      sd.growth = sd(length))

## 4. JOIN DATASETS----
# Load the treatments associated with each individual

treatments <- read.csv("EmpetrumTreatments.csv", header = TRUE, sep = ";")
head(treatments)

# Join the two data frames by ID code. The column names are spelled differently, so we need to tell the function which columns represent a match. We have two columns that contain the same information in both datasets: zone and individual ID.

experiment <- left_join(elongation_long, treatments, by = c("indiv" = "Indiv", "zone" = "Zone"))

# left join because we want to keep all the information in elong_long, use fulljoin() to keep all
# We see that the new object has the same length as our first data frame, which is what we want. And the treatments corresponding to each plant have been added!

#base r version
experiment2 <- merge(elongation_long, treatments, by.x = c("zone", "indiv"), by.y = c("Zone", "Indiv"))  
# same result!

#plot new dataframe
boxplot(length ~ Treatment, data = experiment)

#Part 4 application challenge----

drags <- read.csv("dragons.csv", header = TRUE)   

# Check import and preview data
head(drags)   # first few observations
str(drags)    # types of variables
names(drags)[6] <- "turmeric" 
names(drags)[1] <- "ID" 
drags$ID <- as.factor(drags$ID)  

drags_long <- gather(drags, spice, length,  # in this order: data frame, key, value
                          c(tabasco, jalapeno, wasabi, turmeric)) 
drags_long$length <- as.numeric(drags_long$length)
drags_long$length <- drags_long$length/100

# this doesnt work for some reason
#drags_long[drags_long$species == "hungarian_horntail" & drags_long$spice == "tabasco", ]$length <- drags_long$length - 0.3

drags_error <- drags_long[drags_long$species == "hungarian_horntail" & drags_long$spice == "tabasco", ]
drags_error$length <- drags_error$length-0.3
drags_long2 <- left_join(drags_long, drags_error)
drag_grouped <- group_by(drags_long2, species) 

library(ggplot2)

ggplot(drag_grouped, aes(x=spice, y=length, fill=species)) + 
  geom_boxplot() +
  facet_wrap(~species)



