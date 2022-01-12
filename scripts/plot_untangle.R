args <- commandArgs()
path_untangle_bed <- args[6]

library(ggplot2)
#library(knitr)
x <- read.table(path_untangle_bed, sep = '\t', header = T, comment.char = "$")
x$query.name <- gsub(":.*", "", x$query.name)
x$query.name <- gsub("#J.*", "", x$query.name)

x_subset <- subset(x, query.name %in% c(
  ##"chm13#chr6:31825251-31908851",
  #"grch38#chr6:31972046-32055647",
  ##"HG00438#1#JAHBCB010000040.1:24269348-24320210",
  #"HG00438#2#JAHBCA010000042.1:24398231-24449090",
  ##"HG01071#1#JAHBCF010000017.1:706180-783405",
  #"HG01071#2#JAHBCE010000076.1:7794179-7897781",
  #"HG01952#1#JAHAME010000044.1:28380191-28451052",
  #"HG01952#2#JAHAMD010000016.1:31974838-32052065",

  #"chm13#chr6",
  "grch38#chr6",
  #"HG00438#1",
  "HG00438#2",
  #"HG01071#1",
  "HG01071#2",
  "HG01952#1",
  "HG01952#2"
)
)

p <- ggplot(
  x_subset, aes(x = query.start, xend = query.end, y = ref.start, yend = ref.end)) +
  geom_segment(size = 0.3) +
  facet_grid(. ~ query.name) +
  coord_fixed() +
  #theme_bw() +
  theme(
    text = element_text(size = 12.6),
    axis.text.x = element_text(size = 12, angle = 90),
    axis.text.y = element_text(size = 12),

    #panel.grid.minor = element_line(size = 0.125),
    #panel.grid.major = element_line(size = 0.25)
  ) +
  xlab("Query start") +
  ylab("Reference start")


# C4A annotation
# https://stackoverflow.com/questions/65013846/why-geom-rect-looking-different-across-facets
p <- p +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 31982057 - 31972046, ymax = 32002681 - 31972046, fill = "#EE2222", alpha = .2, color = "#444444", size = 0.1)
#https://stackoverflow.com/questions/11889625/annotating-text-on-individual-facet-in-ggplot2
C4A_ann_text <- data.frame(
  `query.start` = 5000, `query.end` = 0, `ref.start` = 20000, `ref.end` = 0, `query.name` = factor("grch38#chr6", levels = unique(x_subset$query.name))
)
p <- p + geom_text(data = C4A_ann_text, label = 'C4A', size = 4)

# C4B annotation
# https://stackoverflow.com/questions/65013846/why-geom-rect-looking-different-across-facets
p <- p +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 32014795 - 31972046, ymax = 32035418 - 31972046, fill = "#2222EE", alpha = .2, color = "#444444", size = 0.1)
C4B_ann_text <- data.frame(
  `query.start` = 5000, `query.end` = 0, `ref.start` = 52500, `ref.end` = 0, `query.name` = factor("grch38#chr6", levels = unique(x_subset$query.name))
)
p <- p + geom_text(data = C4B_ann_text, label = 'C4B', size = 4)


filename <- paste0(gsub("\\.", "_", path_untangle_bed), '.pdf')
#knitr::plot_crop(filename)
ggsave(plot = p, filename, width = 32, height = 8, units = "cm", dpi = 300, bg = "transparent")
