#!/bin/bash

# Find C4 coordinates
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz
zgrep 'gene_id "C4A"\|gene_id "C4B"' hg38.ncbiRefSeq.gtf.gz |
  awk '$1 == "chr6"' | cut -f 1,4,5 |
  bedtools sort | bedtools merge -d 15000 | bedtools slop -l 10000 -r 20000 -g hg38.chrom.sizes |
  sed 's/chr6/grch38#chr6/g' > hg38.ncbiRefSeq.C4.coordinates.bed


filename_chr6_gfa=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth

# Download and build the graph
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_04_pggb_wgg.87/chroms/${filename_chr6_gfa}.gfa.gz
gunzip ${filename_chr6_gfa}.gfa.gz
odgi build -g ${filename_chr6_gfa}.gfa -o ${filename_chr6_gfa}.og -t 16 -P


# Extraction, explosion, optimization, and sorting
odgi extract -i ${filename_chr6_gfa}.og -b hg38.ncbiRefSeq.C4.coordinates.bed -o - --full-range -t 16 -P |
  odgi explode -i - --biggest 1 --sorting-criteria P --optimize -p ${filename_chr6_gfa}.C4
odgi sort -i ${filename_chr6_gfa}.C4.0.og -o ${filename_chr6_gfa}.C4.sorted.og -p Ygs -x 100 -t 16 -P


# Select haplotypes
odgi paths -i ${filename_chr6_gfa}.C4.sorted.og -L | grep 'chr6\|HG00438\|HG0107\|HG01952' > chr6.selected_paths.txt


# odgi viz: default (binned) mode
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted.png -a 9 -c 12 -w 100 -y 50 -p chr6.selected_paths.txt

# odgi viz: color by strand
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted_z.png -a 9 -c 12 -w 100 -y 50 -p chr6.selected_paths.txt -z

# odgi viz: color by position
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted_du.png -a 9 -c 12 -w 100 -y 50 -p chr6.selected_paths.txt -du

# odgi viz: color by depth
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted_m.png -a 9 -c 12 -w 100 -y 50 -p chr6.selected_paths.txt -m -B Spectral:4


# Compute layout
odgi layout -i ${filename_chr6_gfa}.C4.sorted.og -o ${filename_chr6_gfa}.C4.sorted.lay -T ${filename_chr6_gfa}.C4.sorted.tsv -x 300 -t 16 -P

# odgi draw
odgi draw -i ${filename_chr6_gfa}.C4.sorted.og -c ${filename_chr6_gfa}.C4.sorted.lay -p "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted_layout.png -H 1000 -w 1000 -B 500


# Get C4-GTF
zgrep 'gene_id "C4A"\|gene_id "C4B"' hg38.ncbiRefSeq.gtf.gz | awk '$1 == "chr6" && $3 == "transcript"' | cut -f 1 -d';' | sed 's/gene_id //g' | sed 's/"//g' | sed 's/chr6/grch38#chr6/g' | head -n 2 > chr6.C4.gtf
#grch38#chr6	ncbiRefSeq.2021-09-09	transcript	32014795	32035418	.	+	.	C4B
#grch38#chr6	ncbiRefSeq.2021-09-09	transcript	31982057	32002681	.	+	.	C4A


# Compute Bandage annotations
odgi position -i ${filename_chr6_gfa}.C4.sorted.og -E chr6.C4.gtf -t 16 > ${filename_chr6_gfa}.C4.sorted.anno.csv

# Convert to GFA for Bandage
odgi view -i ${filename_chr6_gfa}.C4.sorted.og -g > ${filename_chr6_gfa}.C4.sorted.gfa


# Untangle
( echo query.name query.start query.end ref.name ref.start ref.end score inv self.cov x|
  tr ' ' '\t'; odgi untangle -i ${filename_chr6_gfa}.C4.sorted.og -r $(odgi paths -i ${filename_chr6_gfa}.C4.sorted.og -L | grep grch38) -t 16 -m 256 -P |
  bedtools sort -i - ) | awk '$8 == "-" { x=$6; $6=$5; $5=x; } { print }' |
  tr ' ' '\t'   >${filename_chr6_gfa}.C4.sorted.untangle.bed

# cat ${filename_chr6_gfa}.C4.sorted.untangle.bed | grep '^chm13\|^grch38\|^HG00438\|^HG0107\|^HG01952'

# R
library(ggplot2)
#library(knitr)
x <- read.table('/home/guarracino/Desktop/pangenomics/odgi_pub/chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.C4.sorted.untangle.bed', sep = '\t', header = T, comment.char="$")
x$query.name <- gsub(":.*","",x$query.name)
x$query.name <- gsub("#J.*","",x$query.name)

ggplot(
  subset(x, query.name %in% c(
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
  ), aes(x=query.start, xend=query.end, y=ref.start, yend=ref.end)) +
    geom_segment(size=0.3) +
    facet_grid(. ~ query.name) +
    coord_fixed() +
    #theme_bw() +
    theme(
      text = element_text(size = 12.6),
      axis.text.x = element_text(size = 12, angle = 90),
      axis.text.y = element_text(size = 12),

      #panel.grid.minor = element_line(size = 0.125),
      #panel.grid.major = element_line(size = 0.25)
    )  +
      xlab("Query start") +
      ylab("Reference start")
filename <- 'chr6_pan_fa_a2fb268_4030258_6a1ecc2_smooth_C4_sorted_untangle_bed.pdf'
ggsave(filename, width = 32, height = 8,  units = "cm", dpi = 300,  bg = "transparent")
knitr::plot_crop(filename)

