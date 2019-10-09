# set the url and time of parsing

url<-"http://www.svo.aero/timetable/today/"
time<-as.character(Sys.time())
options(stringsAsFactors = FALSE)

# required packages for work
library("RCurl")
library("XML")
library("plyr")

# parsing html
html <- getURL(url, followlocation = TRUE,encoding="gzip",httpheader = c(`Accept-Encoding` = "gzip"))
doc = htmlParse(html, asText=TRUE)
# now take basic info in common table
plain.text <- xpathSApply(doc, "//td", xmlValue)
n<-length(plain.text)
dates<-plain.text[seq(4,n-7,8)]
times<-plain.text[seq(5,n-6,8)]
companies<-plain.text[seq(6,n-5,8)]
routes<-plain.text[seq(7,n-4,8)]
city2<-plain.text[seq(9,n-2,8)]
terminals<-plain.text[seq(10,n-1,8)]
status<-plain.text[seq(11,n,8)]
svo<-cbind(dates,times,companies,routes,city2,terminals,status)

# take only rows with flights, need to remove first - there is no flight
plain.text <- xpathSApply(doc, "//a/@href")
indx<-grep("/timetable/today",plain.text)
plain.text<-plain.text[indx]
plain.text<-(unique(plain.text))
plain.text<-plain.text[!plain.text=="/en/timetable/today/" & !plain.text=="/timetable/today/"]
# dop infor from separate urls
more_info<-data.frame(matrix(c(1:6),ncol=6))
# departure or arrival letters

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x)-1)
}

dest<-as.character(substrRight(plain.text,2))

######################## parsing dop info
list_of_dop_info<-list(1)

for( i in 1:length(plain.text)){
  url_flight<-paste("http://www.svo.aero",plain.text[[i]][1],sep="")
  html_flight <- getURL(url_flight, followlocation = TRUE,encoding="gzip",httpheader = c(`Accept-Encoding` = "gzip"))
  doc_flight = htmlParse(html_flight, asText=TRUE)
  list_of_dop_info[[i]]<- xpathSApply(doc_flight, "//td", xmlValue)
  list_of_dop_info[[i]]<-paste0(list_of_dop_info[[i]],collapse=";")
}
df <- data.frame(matrix(unlist(list_of_dop_info), nrow=length(plain.text), byrow=T))
today<-cbind(svo,dest,df)
file<-as.character(paste("svo_today",time,sep="_"))
file_name<-paste(file,"csv",sep=".")
write.csv(today,file_name)
q(save="no")
########################