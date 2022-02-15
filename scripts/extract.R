#!/usr/bin/env Rscript

library(tidyverse)
library(ggbeeswarm)
library(knitr)
library(gridExtra)

args <- commandArgs(trailingOnly = T)

odgi_extract_csv <- args[1]
vg_chunk_csv <- args[2]
extract_pdf <- args[3]
extract_csv <- args[4]

#odgi_extract_csv <- "/home/heumos/git/odgi-paper/data/odgi_extract_time.csv"
odgi_extract <- read.delim(odgi_extract_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(odgi_extract) <- c("threads", "haps", "run", "time", "memory")
# time is in seconds
# memory is in kilobytes
odgi_extract$tool <- "odgi extract"
summary(odgi_extract)

#vg_chunk_csv <- "/home/heumos/git/odgi-paper/data/vg_chunk_time.csv"
vg_chunk <- read.delim(vg_chunk_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(vg_chunk) <- c("threads", "haps", "run", "time", "memory")
vg_chunk$tool <- "vg chunk"
summary(vg_chunk)

extract <- rbind(odgi_extract, vg_chunk)
extract$threads <- factor(extract$threads, levels=unique(extract$threads))
extract$haps <- factor(extract$haps, levels=unique(extract$haps))
# extract$memory <- factor(extract$memory, levels=unique(extract$memory))
extract$memory <- as.numeric(extract$memory)/1000000

extract_64haps <- extract[extract$haps == 64,]
extract_64haps_m <- aggregate(cbind(memory,time) ~threads+haps+tool, data=extract_64haps, FUN=mean)
extract_16threads <- extract[extract$threads == 16,]
extract_16threads_m <- aggregate(cbind(memory,time) ~threads+haps+tool, data=extract_16threads, FUN=mean)

et_p_t <- ggplot(extract_64haps_m, aes(x=threads, y=time, fill=tool, color = tool, group=tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of threads", y = "time in seconds") +
  expand_limits(x = 0, y = 0) + 
  theme(legend.position = "none")
et_p_t

eh_p_t <- ggplot(extract_16threads_m, aes(x=haps, y=time, fill=tool, color = tool, group=tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of haplotypes", y = "time in seconds") +
  expand_limits(x = 0, y = 0) + theme(legend.direction = "horizontal") + 
  labs(color = "tool   ") + 
  labs(fill = "tool   ") + 
  theme(legend.title = element_text(size=15)) +
  theme(legend.key.size = unit(0.4, 'cm'))
eh_p_t

get_legend <- function(a.gplot) {
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

legend <- get_legend(eh_p_t)
eh_p_t <- eh_p_t + theme(legend.position = "none")

# collapse memory by run and take the mean
et_p_m <- ggplot(extract_64haps_m, aes(x=threads, y=memory, fill=tool, color = tool, group = tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of threads", y = "memory in gigabytes") +
  expand_limits(x = 0, y = 0) +
  theme(legend.position = "none")
et_p_m

eh_p_m <- ggplot(extract_16threads_m, aes(x=haps, y=memory, fill=tool, color = tool, group = tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of haplotypes", y = "memory in gigabytes") +
  expand_limits(x = 0, y = 0) +
  theme(legend.position = "none")
eh_p_m

grid.arrange(arrangeGrob(et_p_t, eh_p_t, nrow = 1), arrangeGrob(et_p_m, eh_p_m, nrow = 1), legend, nrow = 3, heights = c(1,1,0.1))

extract <- arrangeGrob(arrangeGrob(et_p_t, eh_p_t, nrow = 1), arrangeGrob(et_p_m, eh_p_m, nrow = 1), legend, nrow = 3, heights = c(1,1,0.1))
ggsave(file=extract_pdf, extract, width = 7, height = 5)
file.remove("Rplots.pdf")

extract_supp <- rbind(odgi_extract, vg_chunk)
extract_supp$memory <- extract_supp$memory/1000000
extract_supp <- aggregate(cbind(memory,time) ~threads+haps+tool, data=extract_supp, FUN=mean)
extract_supp <- extract_supp[order(extract_supp$threads, extract_supp$haps),]

extract_latex <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), 
                          c("threads", "haps", "time_odgi_extract", "time_vg_chunk", "memory_odgi_extract", "memory_vg_chunk"))
i <- 1
j <- i + 1

while(i < dim(extract_supp)[1]) {
  row_row_row_your_boat <- c(extract_supp[i,1], extract_supp[i,2], extract_supp[i,5], extract_supp[j,5], extract_supp[i,4], extract_supp[j,4])
  extract_latex <- rbind(extract_latex, row_row_row_your_boat)
  i <- i + 2
  j <- i + 1
}
colnames(extract_latex) <-  c("threads", "haps", "time_odgi_extract", "time_vg_chunk", "memory_odgi_extract", "memory_vg_chunk")

write.table(round(extract_latex,2), file = extract_csv, sep = ",", row.names = F, quote = F)
