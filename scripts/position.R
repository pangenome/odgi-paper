#!/usr/bin/env Rscript

library(tidyverse)
library(ggbeeswarm)
library(knitr)
library(gridExtra)

args <- commandArgs(trailingOnly = T)

odgi_position_csv <- args[1]
vg_find_csv <- args[2]
position_csv <- args[3]

#odgi_position_csv <- "/home/heumos/git/odgi-paper/data/odgi_position_time.csv"
odgi_position <- read.delim(odgi_position_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(odgi_position) <- c("threads", "haps", "run", "time", "memory")
# time is in seconds
# memory is in kilobytes
odgi_position$tool <- "odgi position"
summary(odgi_position)

#vg_find_csv <- "/home/heumos/git/odgi-paper/data/vg_find_time.csv"
vg_find <- read.delim(vg_find_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(vg_find) <- c("threads", "haps", "run", "time", "memory")
vg_find$tool <- "vg find"
summary(vg_find)

position_supp <- rbind(odgi_position, vg_find)
position_supp$memory <- position_supp$memory/1000000
position_supp <- aggregate(cbind(memory,time) ~threads+haps+tool, data=position_supp, FUN=mean)
position_supp <- position_supp[order(position_supp$threads, position_supp$haps),]

position_latex <- setNames(data.frame(matrix(ncol = 6, nrow = 0)), 
                           c("threads", "haps", "time_odgi_position", "time_vg_find", "memory_odgi_position", "memory_vg_find"))
i <- 1
j <- i + 1

while(i < dim(position_supp)[1]) {
  row_row_row_your_boat <- c(position_supp[i,1], position_supp[i,2], position_supp[i,5], position_supp[j,5], position_supp[i,4], position_supp[j,4])
  position_latex <- rbind(position_latex, row_row_row_your_boat)
  i <- i + 2
  j <- i + 1
}
colnames(position_latex) <-  c("threads", "haps", "time_odgi_position", "time_vg_find", "memory_odgi_position", "memory_vg_find")

write.table(round(position_latex, 2), file = position_csv, sep = ",", row.names = F, quote = F)