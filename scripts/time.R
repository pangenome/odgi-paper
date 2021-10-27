#!/usr/bin/env Rscript

library(ggplot2)

args <- commandArgs(trailingOnly = T)

times_csv <- args[1]
times_pdf <- args[2]

# times_csv <- "/home/heumos/Downloads/odgi_paper/MHC/mean_build_time.csv"

times <- read.table(times_csv, sep = ",", quote = "", as.is = T, 
                    check.names = F, header = F, comment.char = "")
colnames(times) <- c("time", "threads")

times$threads <- as.character(times$threads)
times$threads <- factor(times$threads, levels=unique(times$threads))

#+++++++++++++++++++++++++
# Function to calculate the mean and the standard deviation
# for each group
#+++++++++++++++++++++++++
# data : a data frame
# varname : the name of a column containing the variable
#to be summariezed
# groupnames : vector of column names to be used as
# grouping variables
data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}

df2 <- data_summary(times, varname="time", 
                    groupnames=c("threads"))
df2$threads=factor(df2$threads, levels=unique(times$threads))

p <- ggplot(data=df2, aes(x=threads, y=time, color=threads, group=1)) +
  geom_errorbar(aes(ymin=time-sd, ymax=time+sd), width=.2) +
  geom_line(color = "black") +
  geom_point(size = 1) + 
  # geom_bar(stat="identity") +
  # scale_fill_brewer(palette="Dark2") +
  labs(x = "number of threads", y = "time in seconds")
pdf(times_pdf, height = 2, width = 3)
p
dev.off()
