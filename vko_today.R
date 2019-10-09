time<-as.character(Sys.time()-60*60*24)
options(stringsAsFactors = FALSE)
library("RCurl")
library("XML")
library("plyr")


url<-"http://www.vnukovo.ru/flights/online-timetable/#tab-sortie"
html <- getURL(url, followlocation = TRUE,encoding="gzip",httpheader = c(`Accept-Encoding` = "gzip"),.encoding="UTF-8")

doc = htmlParse(html, asText=TRUE)
# now take basic info in common table

flights<- xpathSApply(doc, "//tr", xmlValue)
flights<-gsub("\n","",flights)
flights<-gsub("\r","",flights)


info<-list(1)
for (i in 1:length(flights)){
  t<-strsplit(flights[i],split="  ")[[1]]
  t<-unique(t[!t==""])
  info[[i]]<-paste0(t,collapse=";")
}
df<- data.frame(matrix(unlist(info), nrow=length(flights), byrow=T))
file<-as.character(paste("vko_D",time,sep="_"))
file_name<-paste(file,"csv",sep=".")
write.csv(df,file_name)
q(save="no")