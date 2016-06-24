# AdzunaDataBot

At The Data Lab, we would like to keep our fingers on the pulse of data science jobs in the UK. To do this we are creating a small service to help us and others track this over time.

This is a work in progress.

The project is an excercise in using AWS to set up a microservice as follows;
- Every night we query the [Adzuna API](https://developer.adzuna.com/) to retrieve records pertaining to "data science"- We store this in a MySQL database hosted on AWS RDS
- We then do some cleaning and generate a static html dashboard (using [flexdashboard](http://rmarkdown.rstudio.com/flexdashboard/) in R) 

Currently the [public preview](https://s3-eu-west-1.amazonaws.com/adzunadata/dashboard/AdzunaFlexDashboard.html) of this project is available however please excercise extreme caution as this is very much under development.
