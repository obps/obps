#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)

'usage: tool.R <input>... [--out=<output>]
        tool.R -h | --help

options:
 --in=<input>    Input file  [Default: none]
 --lab=<lab>     Plot label  [Default: none]
 --out=<output>  Output file [Default: tmpmixed.pdf]
 ' -> doc

args <- docopt(doc)

options(stringsAsFactors=FALSE)

df <- data.frame(id=double(),
                 meanwait=double(),
                sd=double(),
                q1=double(),
                q2=double())

names(df)=c('id','meanwait','sd','q1','q2')


for (i in 1:length(args$"<input>")){
  data=read.csv(args$"<input>"[i],sep=' ',header=FALSE, stringsAsFactors=FALSE)
  names(data)=c('meanwait','maxwait','meanbsld','maxbsld','meanflow','maxflow','name')

  print(args$"<input>"[i])
  dempt=data[which(is.na(data$meanwait)),]
  print(dempt)
  if (nrow(dempt)>0) {
    print("ERROR: detected a NA in the awkstat file. Deleting the awkstats file AND the original simulated swf.")
    system(paste("rm ",args$"<input>"[i],sep=""))
    system(paste("rm o/perv-evolution.zmk/",data[which(is.na(data$meanwait)),2],sep=""))
  }

  quant=quantile(as.numeric(data$meanwait),probs=c(0.20,0.80))

  nr = list(i,
            mean(as.numeric(data$meanwait)),
            sd(as.numeric(data$meanwait)),
            quant[[1]],
            quant[[2]])


  df <- rbind.data.frame(nr,df)
}
print("EE")

names(df)=c('id','meanwait','sd','q1','q2')

print(df)

write.csv(df,file=args$"out")
