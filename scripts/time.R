#!/usr/bin/env Rscript

library(tidyverse)
library(ggbeeswarm)
library(knitr)

args <- commandArgs(trailingOnly = T)

times_csv <- args[1]
times_pdf <- args[2]

# times_csv <- "/home/heumos/git/odgi-paper/data/mean_build_time.csv"

times <- read.delim(times_csv, sep = ",", as.is = T, header = T)

summary(times)

times$threads <- factor(times$threads, levels=unique(times$threads))

p <- ggplot(times, aes(x=threads, y=time, group=threads)) +
    geom_violin() +
    #geom_beeswarm(size=0.5) +
    labs(x = "number of threads", y = "time in seconds") +
    expand_limits(x = 0, y = 0)
#pdf(times_pdf, height = 2.5, width = 3)
ggsave(times_pdf, device = cairo_pdf, height = 2.5, width = 3)
knitr::plot_crop(times_pdf)

