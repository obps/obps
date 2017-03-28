#!/usr/bin/Rscript

library(docopt)
'usage: accuracy.R <input> ... [--mean=<output1>] [--max=<output2>]

options:
<input>                   The input data.
' -> doc

args<- docopt(doc)

maxscore=0
best=NULL
for (filename in args$input) {
  d=read.table(filename)
  pos=length(which(d$V1>0))/length(d$V1)
  neg=length(which(d$V1<0))/length(d$V1)
  score=pos/(neg+pos)
  if (score>maxscore  ) {
    best=filename
    maxscore=score 
  }
  print(score)
}
print(maxscore)
print(best)
