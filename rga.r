#R Google Analytics with a for loop to run through all the properties!!

#install.packages("RCurl")
#install.packages("rjson")

require("RCurl")
require("rjson")

library("RGoogleAnalytics", lib.loc="C:/Users/jglenn/Documents/R/win-library/3.0")


# Loading the RGoogleAnalytics library
require("RGoogleAnalytics")

# Step 1. Authorize your account and paste the accesstoken 
query <- QueryBuilder()
access_token <- query$authorize()                                                


# Step 2. Initialize the configuration object
conf <- Configuration()

# Retrieving a list of Accounts
ga.account <- conf$GetAccounts() 
ga.account

# Retrieving a list of Web Properties
# With passing parameter as (ga.account$id[index]) will retrieve list of web properties under that account 
ga.webProperty <- conf$GetWebProperty()
ga.webProperty

# Retrieving a list of web profiles available for specific Google Analytics account and Web property
# by passing with two parameters - (ga.account$id,ga.webProperty$id).
# With passing No parameters will retrieve all of web profiles
ga.webProfile <- conf$GetWebProfile()
ga.webProfile

# Retrieving a list of Goals
# With passing three parameters (ga.account$id[index],ga.webProperty$id[index], ga.webProfile$id[index])
# will retrieve specific goals
#ga.goals <- conf$GetGoals()
#ga.goals

# For retrieving a list of Advanced segments
#ga.segments <- conf$GetSegments()
#ga.segments

# Step 3. Create a new Google Analytics API object
ga <- RGoogleAnalytics()

# Old way to retrieve profiles from Google Analytics 
ga.profiles <- ga$GetProfileData(access_token)

# List the GA profiles 
ga.profiles


#I need to try this next, i think this will work  :) 
# Step 4. Setting up the input parameters

filter.mobileSite <- "ga:hostName=~^m\\."
filter.desktopSite <- "ga:hostname!~siteencore\\.com|^m\\."


ga.data <- NULL
uri <- NULL
df <- NULL

for (i in 1:nrow(profiles.desktop)) {
  tryCatch({
    
    profile <- profiles.desktop$id[i] 
    startdate <- "2013-06-01"
    enddate <- "2013-06-30"
    dimension <- NULL
    metric <- "ga:visitors, ga:pageViews, ga:visits, ga:timeOnSite, ga:avgTimeOnSite"
    filter <- filter.desktopSite
    segment <- NULL
    sort <- "-ga:visits"
    maxresults <- 99
    
    
    # Step 5. Build the query string, use the profile by setting its index value 
    query$Init(start.date = startdate,
               end.date = enddate,
               dimensions = dimension,
               metrics = metric,
               sort = sort,
               filters= filter,
               segment=segment,
               max.results = maxresults,
               table.id = paste("ga:",profile,sep="",collapse=","),
               access_token=access_token)
    
    # Step 6. Make a request to get the data from the API
    ga.data <- ga$GetReportData(query)
    
    ga.data <- cbind(profiles.desktop[i,], ga.data)
    
    df <- rbind(df, ga.data )
    
    
    #If you want to see the final generated URL, use:
    #uri[i] <- query$to.uri()
    
    
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}


c("startdate: ", startdate)
c("enddate: ", enddate)
c("Filter: ", filter)


cat("Please enter a file name ...")
filename <- readLines(con="stdin", 1)
cat(fil, "\n")

write.csv(df, file = paste(filename, "csv", sep="."))
