#!/usr/bin/env Rscript

library(tidyverse)
library(ggbeeswarm)
library(knitr)
library(gridExtra)
library(R.devices)

args <- commandArgs(trailingOnly = T)

odgi_build_csv <- args[1]
vg_convert_csv <- args[2]
build_pdf <- args[3]
build_csv <- args[4]

#odgi_build_csv <- "/home/heumos/git/odgi-paper/data/odgi_build_threads_haps_time.csv"
odgi_build <- read.delim(odgi_build_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(odgi_build) <- c("threads", "haps", "run", "time", "memory")
# time is in seconds
# memory is in kilobytes
odgi_build$tool <- "odgi build"
summary(odgi_build)

#vg_convert_csv <- "/home/heumos/git/odgi-paper/data/vg_convert_threads_haps_time.csv"
vg_convert <- read.delim(vg_convert_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(vg_convert) <- c("threads", "haps", "run", "time", "memory")
vg_convert$tool <- "vg convert"
summary(vg_convert)

construct <- rbind(odgi_build, vg_convert)
construct$threads <- factor(construct$threads, levels=unique(construct$threads))
construct$haps <- factor(construct$haps, levels=unique(construct$haps))
# construct$memory <- factor(construct$memory, levels=unique(construct$memory))
construct$memory <- as.numeric(construct$memory)/1000000

construct_64haps <- construct[construct$haps == 64,]
construct_64haps_m <- aggregate(cbind(memory,time) ~threads+haps+tool, data=construct_64haps, FUN=mean)
construct_16threads <- construct[construct$threads == 16,]
construct_16threads_m <- aggregate(cbind(memory,time) ~threads+haps+tool, data=construct_16threads, FUN=mean)

ct_p_t <- ggplot(construct_64haps_m, aes(x=threads, y=time, fill=tool, color = tool, group=tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of threads", y = "time in seconds") +
  expand_limits(x = 0, y = 0) + 
  theme(legend.position = "none")
ct_p_t

ch_p_t <- ggplot(construct_16threads_m,aes(x=haps, y=time, fill=tool, color = tool, group=tool)) +
  geom_point() + geom_line() +
    #geom_beeswarm(size=0.5) +
    labs(x = "number of haplotypes", y = "time in seconds") +
    expand_limits(x = 0, y = 0) + theme(legend.direction = "horizontal") + 
    labs(color = "tool   ") + 
    labs(fill = "tool   ") + 
    theme(legend.title = element_text(size=15)) +
    theme(legend.key.size = unit(0.4, 'cm'))
ch_p_t

get_legend <- function(a.gplot) {
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

legend <- get_legend(ch_p_t)
ch_p_t <- ch_p_t + theme(legend.position = "none")

# collapse memory by run and take the mean
ct_p_m <- ggplot(construct_64haps_m, aes(x=threads, y=memory, fill=tool, color = tool, group = tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of threads", y = "memory in gigabytes") +
  expand_limits(x = 0, y = 0) +
  theme(legend.position = "none")
ct_p_m

ch_p_m <- ggplot(construct_16threads_m, aes(x=haps, y=memory, fill=tool, color = tool, group = tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of haplotypes", y = "memory in gigabytes") +
  expand_limits(x = 0, y = 0) +
  theme(legend.position = "none")
ch_p_m

grid.arrange(arrangeGrob(ct_p_t, ch_p_t, nrow = 1), arrangeGrob(ct_p_m, ch_p_m, nrow = 1), legend, nrow = 3, heights = c(1,1,0.1))

build <- arrangeGrob(arrangeGrob(ct_p_t, ch_p_t, nrow = 1), arrangeGrob(ct_p_m, ch_p_m, nrow = 1), legend, nrow = 3, heights = c(1,1,0.1))
suppressGraphics(ggsave(file=build_pdf, build, width = 7, height = 5))
file.remove("Rplots.pdf")

construct_supp <- rbind(odgi_build, vg_convert)
construct_supp$memory <- construct_supp$memory/1000000
construct_supp <- aggregate(cbind(memory,time) ~threads+haps+tool, data=construct_supp, FUN=mean)
construct_supp <- construct_supp[order(construct_supp$threads, construct_supp$haps),]

construct_latex <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), 
                            c("threads", "haps", "time_odgi_build", "time_vg_convert", "memory_odgi_build", "memory_vg_convert"))
i <- 1
j <- i + 1

while(i < dim(construct_supp)[1]) {
  row_row_row_your_boat <- c(construct_supp[i,1], construct_supp[i,2], construct_supp[i,5], construct_supp[j,5], construct_supp[i,4], construct_supp[j,4])
  construct_latex <- rbind(construct_latex, row_row_row_your_boat)
  i <- i + 2
  j <- i + 1
}
colnames(construct_latex) <-  c("threads", "haps", "time_odgi_build", "time_vg_convert", "memory_odgi_build", "memory_vg_convert")

write.table(round(construct_latex,2), file = build_csv, sep = ",", row.names = F, quote = F)