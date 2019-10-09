time<-as.character(Sys.time()-60*60*24)
options(stringsAsFactors = FALSE)
library("RCurl")
library("XML")
library("plyr")
df<-list(1)

j<-1
repeat{
  url<-paste("http://www.domodedovo.ru/passengers/flight/live-board/?searchText=&column=4&sort=1&start=0&end=4440&direction=D&page=",j,"&count=&isSlider=1",sep="")
  html <- getURL(url, followlocation = TRUE,encoding="gzip",httpheader = c(`Accept-Encoding` = "gzip"))
  doc = htmlParse(html, asText=TRUE)
  # now take basic info in common table
  doc
  flights<- xpathSApply(doc, "//tr[@class='vat ']", xmlValue) 
  if(length(flights)==0){
    break
  }
  flights<-gsub("\n","",flights)
  flights<-gsub("\r","",flights)
  #flights<-gsub("           "," ",flights)
  flights
  info<-list(1)
  for (i in 1:length(flights)){
    t<-strsplit(flights[i],split="  ")[[1]]
    t<-unique(t[!t==""])
    info[[i]]<-paste0(t,collapse=";")
  }
  df[j]<- data.frame(matrix(unlist(info), nrow=length(flights), byrow=T))
 
 
  
  j<-j+1
}
data<-as.data.frame(unlist(df))
file<-as.character(paste("dme_D",time,sep="_"))
file_name<-paste(file,"csv",sep=".")
write.csv(data,file_name)


################## Arrivals

df2<-list(1)

j<-1
repeat{
  url<-paste("http://www.domodedovo.ru/passengers/flight/live-board/?searchText=&column=4&sort=1&start=0&end=4440&direction=A&page=",j,"&count=&isSlider=1",sep="")
  html <- getURL(url, followlocation = TRUE,encoding="gzip",httpheader = c(`Accept-Encoding` = "gzip"))
  doc = htmlParse(html, asText=TRUE)
  # now take basic info in common table
  doc
  flights<- xpathSApply(doc, "//tr[@class='vat ']", xmlValue) 
  if(length(flights)==0){
    break
  }
  flights<-gsub("\n","",flights)
  flights<-gsub("\r","",flights)
  #flights<-gsub("           "," ",flights)
  flights
  info<-list(1)
  for (i in 1:length(flights)){
    t<-strsplit(flights[i],split="  ")[[1]]
    t<-unique(t[!t==""])
    info[[i]]<-paste0(t,collapse=";")
  }
  df[j]<- data.frame(matrix(unlist(info), nrow=length(flights), byrow=T))
  j<-j+1
}
data2<-as.data.frame(unlist(df))
file<-as.character(paste("dme_A",time,sep="_"))
file_name<-paste(file,"csv",sep=".")
write.csv(data2,file_name)
q(save="no")