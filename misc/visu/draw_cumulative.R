#!/usr/bin/env Rscript

'usage: tool.R <input_file> ... [-o <output_pdf>] [-l <lineinput>]
tool.R -h | --help

options:
 <input_file>                   The input data.
 -o <output_pdf>                Output file in case of pdf/tikz/png output.
 -l <lineinput>                lineinput.
 -h , --help                    Show this screen.
 ' -> doc

library(docopt)
args<- docopt(doc)
print(args)
args$r=as.numeric(args$r)
args$H=as.numeric(args$H)

png(file=args$o,width=1800,height=800)

library('TTR')
library('gridExtra')
library('ggplot2')
library('reshape2')
library('plyr')

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

swf_read <- function(f)
{
    	df <- read.table(f,comment.char=';')
print(f)
    	names(df) <- c('job_id','submit_time','wait_time','run_time','proc_alloc','cpu_time_used','mem_used','proc_req','time_req','mem_req','status','user_id','group_id','exec_id','queue_id','partition_id','previous_job_id','think_time')
	return(df)
}

flow <- function(swf){
  nbefore = nrow(data)
  data = data[which(!is.na(data$wait_time)),]
  if( nbefore != nrow(data))
    print(paste("There were", nbefore-nrow(data), "jobs with corrupted wait time or run time"))
  return(data$wait_time)
}

utilization <- function( data,utilization_start=0 )
{

  data = arrange(data, submit_time)
  # get start time and stop time of the jobs
  start <- data$submit_time + data$wait_time
  stop <- data$submit_time + data$wait_time + data$run_time
  # because jobs still running have an -1 runtime
  stop[which(data$run_time == -1 & data$wait_time != -1)] = max(stop)
  # because jobs not schedlued yet have an -1 runtime and wait time
  stop[which(data$run_time == -1 & data$wait_time == -1)] = max(stop)
  start[which(data$run_time == -1 & data$wait_time == -1)] = max(stop)

  first_sub = min(data$submit_time)
  first_row = data.frame(timestamp=first_sub, cores_instant=utilization_start)

  # link events with cores number (+/-)
  startU <- cbind(start, data$proc_alloc)
  endU <- cbind(stop, -data$proc_alloc)

  # make one big dataframe
  U  <- rbind(startU, endU)
  colnames(U) <- c("timestamp","cores_instant")
  U <- rbind(as.data.frame(first_row), U)
  U <- as.data.frame(U)

  # merge duplicate rows by summing the cores nb modifications
  U <- aggregate(U$cores_instant, list(timestamp=U$timestamp), sum)

  # make a cumulative sum over the dataframe
  U <- cbind(U[,1],cumsum(U[,2]))                  # TODO: if goes under '0', maybe try something for discovering the utilization offset... difficult
  colnames(U) <- c("timestamp","cores_used")
  U <- as.data.frame(U)
  # return the dataframe
  return(U)
}

timestamp_to_date <- function(timestamp){
    return(as.POSIXct(timestamp, origin="1970-01-01 01:00.00", tz="Europe/Paris")) 
}

queue_size<- function(swf)
{
  # get start time of the jobs
  start <- swf$submit_time + swf$wait_time

  # link events with cores number (+/-)
  submits <- cbind(swf$submit_time, swf$proc_req)
  starts <- cbind(start, -swf$proc_req)

  #   submits <- cbind(swf$submit_time, swf$proc_alloc)
  #   starts <- cbind(start, -swf$proc_alloc)

  # because jobs still queued have an -1 wait_time
  starts[which(swf$wait_time == -1)] = max(starts) + 1

  # make one big dataframe
  U  <- rbind(submits, starts)
  colnames(U) <- c("timestamp","cores_instant")
  U <- as.data.frame(U)

  # merge duplicate rows by summing the cores nb modifications
  U <- aggregate(U$cores_instant, list(timestamp=U$timestamp), sum)

  # make a cumulative sum over the dataframe
  U <- cbind(U[,1],cumsum(U[,2]))
  colnames(U) <- c("timestamp","cores_queued")
  U <- as.data.frame(U)

  # add a new column: dates
  U <- cbind(U, timestamp_to_date(U$timestamp))
  colnames(U) <- c("timestamp","cores_queued","date")
  U <- as.data.frame(U)

  # return the dataframe
  U

}

dfs=data.frame()
dfsq=data.frame()

for (swf_filename in args$input_file){
  data=swf_read(swf_filename)
  data$values=as.numeric(flow(data))

  d=data[order(data$submit_time),]
  data$csum=cumsum(as.numeric(data$values))
  cum=data$csum
  time=data$submit_time
  ema=EMA(data$value,n=nrow(data)/100)
  values=data$values
  values=values[order(time)]

  r=data.frame(cumsumbsld=cum,
               emabsld=ema,
               wvalues=values,
               time=time,
               type=basename(swf_filename))

  table <- utilization(data)
  table <- as.data.frame(table)
  table$time=table$timestamp
  table$cores_ema=EMA(n=nrow(data)/1000,table$cores_used[order(table$time)])

  r<-merge(r,table,by="time")
  r<-r[order(time),]

  queue = queue_size(data)

  queue$type=basename(swf_filename)
  dfsq=rbind(dfsq,queue)
  dfs=rbind(dfs,r)

}
dfs=dfs[which(!is.na(dfs$timestamp)),]

dfsq$time=dfsq$timestamp
mintime=min(dfs$time)
maxtime=max(dfs$time)
timespan=maxtime-mintime

df1 <- melt(dfs, measure.vars = c("wvalues","emabsld", "cores_used","cumsumbsld"))
df2 <- melt(dfsq, measure.vars = c("cores_queued"))
keeps <- c("time","value","variable","type")

dff=rbind(df1[keeps],df2[keeps])
dff$variable <- factor(dff$variable,
                       levels = c("emabsld",
                                  "cores_used",
                                  "cumsumbsld",
                                  "wvalues",
                                  "cores_queued"),
                       labels = c("flow m.a.",
                                  "Cores Used",
                                  "cum. flow",
                                  "wvalues",
                                  "Cores Queued"))

brk=seq(mintime,maxtime,timespan/(20))

li = read.table(args$l)
names(li) <- c("v1")

ggplot() +
  geom_step(data=subset(dff, variable=="cum. flow"),
            aes(x = time, y = value, color = type)) +
  geom_vline(data=li, aes(xintercept = v1)) +
  scale_x_continuous(breaks = brk)+
  scale_color_brewer("File",palette="Dark2")+
  xlab("Time (seconds)") +
  theme_bw_tuned() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.y=element_blank(),
        strip.text.y = element_text(size=8, face="bold"),
        strip.background = element_rect(colour="White", fill="#FFFFFF"))

#png(file=args$b,width=1800,height=800)

##summary(dff)
#df2=subset(dff, variable=="wvalues")
#df2=df2[which(df2$variable=="wvalues"),]
#df2$week= df2$time %/% 604800

#df2$week=as.numeric(df2$week)
#df2$value=as.numeric(df2$value)

##summary(df2)
#df3 = aggregate(value ~ week * type,df2,mean)
#print(df3)

#ggplot() +
  #geom_line(data=df3,aes(x=week,y=value,color=type)) +
  #geom_line(data=df3,aes(x=week,y=value,color=type)) +
  #theme_bw_tuned()
