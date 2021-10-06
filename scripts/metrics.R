#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = T)

bed_depth <- args[1]
depth_pdf <- args[2]

depth <- read.table(bed_depth, sep = "\t", quote = "", as.is = T, 
                    check.names = F, header = F, comment.char = "")
pdf(depth_pdf, height = 3, width = 14)
plot(depth$V2, depth$V4, pch=20, 
#     main = "odgi depth - chm13#chr4:3073405-3073983 - HTT exon1", 
     xlab = "position of chm13 in HTT exon1",
     ylab = "depth")
lines(depth$V2, depth$V4, xlim=range(depth$V2), ylim=range(depth$V4), pch=1)
dev.off()

bed_degree <- args[3]
degree_pdf <- args[4]

degree <- read.table(bed_degree, sep = "\t", quote = "", as.is = T, 
                     check.names = F, header = F, comment.char = "")
pdf(degree_pdf, height = 3, width = 14)
plot(degree$V2, degree$V4, pch=20, 
#     main = "odgi degree - chm13#chr4:3073405-3073983 - HTT exon1", 
     xlab = "position of chm13 in HTT exon1",
     ylab = "degree")
lines(degree$V2, degree$V4, xlim=range(degree$V2), ylim=range(degree$V4), pch=1)
dev.off()