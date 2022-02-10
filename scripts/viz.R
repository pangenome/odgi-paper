#!/usr/bin/env Rscript

library(tidyverse)
library(ggbeeswarm)
library(knitr)
library(gridExtra)

args <- commandArgs(trailingOnly = T)

odgi_viz_csv <- args[1]
vg_viz_csv <- args[2]
viz_pdf <- args[3]
viz_csv <- args[4]

#odgi_viz_csv <- "/home/heumos/git/odgi-paper/data/odgi_viz_time.csv"
odgi_viz <- read.delim(odgi_viz_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(odgi_viz) <- c("haps", "run", "time", "memory")
# time is in seconds
# memory is in kilobytes
odgi_viz$tool <- "odgi viz"
summary(odgi_viz)

#vg_viz_csv <- "/home/heumos/git/odgi-paper/data/vg_viz_time.csv"
vg_viz <- read.delim(vg_viz_csv, sep = ",", as.is = T, header = F, stringsAsFactors = F, strip.white = T)
colnames(vg_viz) <- c("haps", "run", "time", "memory")
vg_viz$tool <- "vg viz"
summary(vg_viz)

viz <- rbind(odgi_viz, vg_viz)
viz$haps <- factor(viz$haps, levels=unique(viz$haps))
viz$memory <- as.numeric(viz$memory)/1000000

dodge <- position_dodge(width = 0.0)

first_column <- c(1,2,4,8,16,32,64)
second_column <- c("*", "**", "**", "**", "**", "**", "**")
df <- data.frame(first_column, second_column)
colnames(df) <- c("haps", "label")


vh_p_t <- ggplot(viz, aes(x=haps, y=time, fill=tool, color = tool)) +
  geom_violin(position = dodge) +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of haplotypes", y = "time in seconds") +
  expand_limits(x = 0, y = 0) + theme(legend.direction = "horizontal") + 
  labs(color = "tool   ") + 
  labs(fill = "tool   ") + 
  theme(legend.title = element_text(size=15)) +
  theme(legend.key.size = unit(0.4, 'cm')) +
  annotate("text", label = "*", x =1, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 1,]$time)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =2, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 2,]$time)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =3, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 4,]$time)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =4, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 8,]$time)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =5, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 16,]$time)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =6, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 32,]$time)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =7, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 64,]$time)), size = 7.5, colour = "black")
vh_p_t

get_legend <- function(a.gplot) {
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

legend <- get_legend(vh_p_t)
vh_p_t <- vh_p_t + theme(legend.position = "none")

# collapse memory by run and take the mean
viz_m <- aggregate(cbind(memory,time) ~haps+tool, data=viz, FUN=mean)
vh_p_m <- ggplot(viz_m, aes(x=haps, y=memory, fill=tool, color = tool, group = tool)) +
  geom_point() + geom_line() +
  #geom_beeswarm(size=0.5) +
  labs(x = "number of threads", y = "memory in gigabytes") +
  expand_limits(x = 0, y = 0) +
  theme(legend.position = "none")+
  annotate("text", label = "*", x =1, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 1,]$memory)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =2, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 2,]$memory)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =3, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 4,]$memory)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =4, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 8,]$memory)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =5, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 16,]$memory)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =6, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 32,]$memory)), size = 7.5, colour = "black") +
  annotate("text", label = "**", x =7, y = (5 + max(viz[viz$tool == "vg viz" & viz$haps == 64,]$memory)), size = 7.5, colour = "black")
vh_p_m

grid.arrange(arrangeGrob(vh_p_t, vh_p_m, nrow = 1), legend, nrow = 2, heights = c(1,0.05))

viz <- arrangeGrob(arrangeGrob(vh_p_t, vh_p_m, nrow = 1), legend, nrow = 2, heights = c(1,0.05))
ggsave(file=viz_pdf, viz, width = 7, height = 5)
file.remove("Rplots.pdf")

viz_supp <- rbind(odgi_viz, vg_viz)
viz_supp$memory <- viz_supp$memory/1000000
viz_supp <- aggregate(cbind(memory,time) ~haps+tool, data=viz_supp, FUN=mean)
viz_supp <- viz_supp[order(viz_supp$haps),]

write.table(viz_supp, file = viz_csv, sep = ",", row.names = F, quote = F)
