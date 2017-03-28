#!/usr/bin/Rscript

library(docopt)
library(TTR)

'usage: accuracy.R <input> ... [--out=<out>]

options:
<input>                   The input data.
--out=<out>               The output pdf.
' -> doc

args<- docopt(doc)

theme_bw_tuned<-function()
{
	return(theme_bw() +theme(
		plot.title = element_text(face="bold", size=10),
		axis.title.x = element_text(face="bold", size=10),
		axis.title.y = element_text(face="bold", size=10, angle=90),
		axis.text.x = element_text(size=10),
		axis.text.y = element_text(size=10),
		panel.grid.minor = element_blank(),
		legend.key = element_rect(colour="white"))
         )
}

print(args)
maxscore=0
best=NULL
for (filename in args$input) {
  d=read.table(filename)

  #ema=EMA(d,n=5000)
  ema=EMA(d,n=5000)
  pdf(file=paste(filename,args$out,sep="-"),width=10,height=7)
  #plot(cumsum(d$V1))
  plot(ema)
  dev.off()
}
