#!/usr/bin/Rscript

library(docopt)
library(ggplot2)

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


'usage: draw_fig_easy_no_opt.R <input> ... [--mean=<output1>] [--maxbsld=<output2>] [--maxwait=<output3>]
        draw_fig_easy_no_opt.R -h | --help

options:
 <input>                   The input data.
 --mean=<output>           Output file [Default: tmp1.pdf]
 --maxwait=<output>        Output file [Default: tmp2.pdf]
 --maxbsld=<output>        Output file [Default: tmp3.pdf]
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

filelist=c("fcfs","random")
plotlist=list()
bwmdf=data.frame()
bwmedf=data.frame()
i=0

for (folder in args$input) {
  i=i+1
  df=data.frame()
  dfm=data.frame()
  for (filename in filelist) {
    swf_filename=paste(folder,filename,sep="/")
    data=read.csv(swf_filename,sep=' ',header=FALSE)
    names(data)=c('meanwait','maxwait','meanbsld','maxbsld','meanflow','maxflow','name')
    data$type=filename
    data$fold=folder

    bwmdf=rbind(bwmdf,data.frame(trace=folder,algorithm=filename,maxmaxbsld=max(data$maxbsld),meanmeanbsld=mean(data$meanbsld)))
    bwmedf=rbind(bwmedf,data.frame(trace=folder,algorithm=filename,maxmaxwait=max(data$maxwait),meanmeanwait=mean(data$meanwait)))

    df=rbind(df,data)
    dfm=rbind(dfm,data.frame(meanmax=mean(data$maxflow),meanmean=mean(data$meanflow),type=filename,fold=folder))
  }

  span = max(df$meanflow)- min(df$meanflow)
  bw = span/15
  plotlist[[i]]=ggplot(df,aes(x=meanwait,fill=factor(type)))+
    geom_histogram(aes(y=100*(..ndensity..)), binwidth=bw)+
    theme_bw_tuned()+
    theme(legend.position="none")+
    #scale_x_continuous(breaks = brk)+
    xlab(basename(folder))+
    ylab("% runs")+
    scale_fill_grey(start = 0, end = .5)
}


summary(bwmdf)

pdf(file=args$mean,width=10,height=7)
#plotlist[[2]]
do.call(multiplot, plotlist)
#pdf(file=args$max,width=10,height=7)
#do.call(multiplot, plotlist2)

write.table(bwmdf, args$maxbsld )
write.table(bwmedf, args$maxwait )
#pmeanflow
#pdf(file=args$max,width=20,height=7)
#pmaxflow
