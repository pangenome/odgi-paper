#!/usr/bin/env Rscript

library(karyoploteR)
library(BSgenome)
library(data.table)

args <- commandArgs(trailingOnly = T)

chroms.bed <- args[1]
chm13.cyto <- args[2]
beta_in <- args[3]
pdf_out <- args[4]

chr.start.end <- read.table(chroms.bed, as.is = T, header = F, sep = "\t", check.names = F, quote = "", comment.char = "")
colnames(chr.start.end) <- c("chr", "start", "end")
chr.start.end$start <- chr.start.end$start + 1

chr.start.end <- chr.start.end[chr.start.end$chr == "chm13#chr8",]

# chm13.cyto="chm13.CytoBandIdeo.v2.p23.1.txt"
CYTO_COLORS = getCytobandColors()
CYTOtmp = toGRanges(fread(chm13.cyto, col.names = c("chr","start","end", "name","gieStain")))

p23.1_start <- start(CYTOtmp)
p23.1_end <- end(CYTOtmp)

chr.start.end$start <- p23.1_start
chr.start.end$end <- p23.1_end

CYTOtmp <- GenomicRanges::shift(CYTOtmp, -p23.1_start)
CYTO_FULL <- c(CYTOtmp)

chroms_split <- strsplit(chr.start.end$chr, "#")
chroms <- c()
for (chrom in chroms_split) {
  chroms <- c(chroms, chrom[[2]])
}
chroms <- unique(chroms)

for (chrom in chroms) {

beta <- GRanges(chr.start.end)
beta <- GenomicRanges::shift(beta, -p23.1_start)
pp <- getDefaultPlotParams(plot.type=1)
pp$leftmargin <- 0.15
pp$data1height <- 500
pp$data1inmargin <- 25
pp$data2inmargin <- 0
pp$ideogramheight <- 100
beta.bed <- read.table(beta_in, as.is = T, header = F, sep = "\t", check.names = F, quote = "", comment.char = "")
colnames(beta.bed) <- c("chr", "start", "end", "median_range", "path", "path_pos", "walking_from_front", "jaccard")
beta.bed$start <- beta.bed$start + 1
beta.bed <- beta.bed[beta.bed$start >= p23.1_start & beta.bed$end <= p23.1_end,]

beta.ranges <- GRanges(beta.bed)
beta.ranges <- GenomicRanges::shift(beta.ranges, -p23.1_start)

chr.start.end$start <- chr.start.end$start - p23.1_start
chr.start.end$end <- chr.start.end$end - p23.1_start

# final_name <- paste("chr8_chm13_beta_defensin_locus_odgi_tips_w50000", collapse = "", sep = "")
# pdf(paste(final_name,".karyoploteR.pdf", collapse = "", sep = ""), width = 9, height = 3)
pdf(pdf_out, width = 9, height = 3)
CYTO_LOCAL <- CYTO_FULL
kp <- plotKaryotype(genome = beta, plot.params = pp, plot.type = 1, cex = 1, cytobands = CYTO_LOCAL)
kp <- kpPlotDensity(kp, data=beta.ranges, r0=0, r1=1.0, window.size = 10000, border=darker("#1E90FF"), col="#1E90FF", clipping = F)
kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, r0=0, r1=1, cex=1.0, label.margin = 0.05)
kpAddLabels(kp, labels="Density BED Ranges", r0=0, r1=1, data.panel = 1, cex = 1.0, label.margin = 0.1, srt = 90, pos = 3)
kpAddCytobandLabels(kp, force.all=TRUE, srt=90, col="black", cex=0.5)
dev.off()

}

