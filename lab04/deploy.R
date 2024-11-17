#install.packages("rsconnect")
#install.packages("config")

library(config)
library(rsconnect)

config <- config::get(file = "lab_4.dcf")

name <- config$name
token <- config$token
secret <- config$secret

rsconnect::setAccountInfo(name=name,
                          token=token,
                          secret=secret)

# this file require running from lab04 relation dir
app_dir <- file.path(getwd(), "Taxi")

rsconnect::deployApp(app_dir)
