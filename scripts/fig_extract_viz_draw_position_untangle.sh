#!/bin/bash

prefix_chr6_smooth=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth

# Download and build the graph
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_16_pggb_wgg.88/chroms/${prefix_chr6_smooth}.gfa.gz
gunzip ${prefix_chr6_smooth}.gfa.gz
odgi build -g ${prefix_chr6_smooth}.gfa -o ${prefix_chr6_smooth}.og -t 16 -P


# Extraction and optimization of the MHC locus
odgi extract -i ${prefix_chr6_smooth}.og -r grch38#chr6:29000000-34000000 -o - --full-range -t 16 -P | odgi sort -i - -o ${prefix_chr6_smooth}.mhc.og --optimize


# MHC locus layout
odgi layout -i ${prefix_chr6_smooth}.mhc.og -o ${prefix_chr6_smooth}.mhc.lay -T ${prefix_chr6_smooth}.mhc.tsv -x 100 -t 16 -P
odgi draw -i ${prefix_chr6_smooth}.mhc.og -c ${prefix_chr6_smooth}.mhc.lay -p "$(echo ${prefix_chr6_smooth} | tr '.' '_' )"_mhc_H1000w10.png -H 1000 -w 120 -C -t 16 -P
# Add red box (30px) around C4 locus using GIMP


# Find C4 coordinates
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz
zgrep 'gene_id "C4A"\|gene_id "C4B"' hg38.ncbiRefSeq.gtf.gz |
  awk '$1 == "chr6"' | cut -f 1,4,5 |
  bedtools sort | bedtools merge -d 15000 | bedtools slop -l 10000 -r 20000 -g hg38.chrom.sizes |
  sed 's/chr6/grch38#chr6/g' > hg38.ncbiRefSeq.C4.coordinates.bed


# Extraction, explosion, optimization, and sorting
odgi extract -i ${prefix_chr6_smooth}.og -b hg38.ncbiRefSeq.C4.coordinates.bed -o - --full-range -t 16 -P |
  odgi explode -i - --biggest 1 --sorting-criteria P --optimize -p ${prefix_chr6_smooth}.C4
odgi sort -i ${prefix_chr6_smooth}.C4.0.og -o ${prefix_chr6_smooth}.C4.sorted.og -p Ygs -x 100 -t 16 -P


# Select haplotypes
odgi paths -i ${prefix_chr6_smooth}.C4.sorted.og -L | grep 'chr6\|HG00438\|HG0107\|HG01952' > chr6.selected_paths.txt


# odgi viz: default (binned) mode
odgi viz -i ${prefix_chr6_smooth}.C4.sorted.og -o "$(echo ${prefix_chr6_smooth} | tr '.' '_' )"_C4_sorted.png -c 12 -w 100 -y 50 -p chr6.selected_paths.txt

# odgi viz: color by strand
odgi viz -i ${prefix_chr6_smooth}.C4.sorted.og -o "$(echo ${prefix_chr6_smooth} | tr '.' '_' )"_C4_sorted_z.png -c 12 -w 100 -y 50 -p chr6.selected_paths.txt -z

# odgi viz: color by position
odgi viz -i ${prefix_chr6_smooth}.C4.sorted.og -o "$(echo ${prefix_chr6_smooth} | tr '.' '_' )"_C4_sorted_du.png -c 12 -w 100 -y 50 -p chr6.selected_paths.txt -du

# odgi viz: color by depth
odgi viz -i ${prefix_chr6_smooth}.C4.sorted.og -o "$(echo ${prefix_chr6_smooth} | tr '.' '_' )"_C4_sorted_m.png -c 12 -w 100 -y 50 -p chr6.selected_paths.txt -m -B Spectral:4


# Compute layout
#odgi layout -i ${prefix_chr6_smooth}.C4.sorted.og -o ${prefix_chr6_smooth}.C4.sorted.lay -T ${prefix_chr6_smooth}.C4.sorted.tsv -x 300 -t 16 -P

# odgi draw
#odgi draw -i ${prefix_chr6_smooth}.C4.sorted.og -c ${prefix_chr6_smooth}.C4.sorted.lay -p "$(echo ${prefix_chr6_smooth} | tr '.' '_' )"_C4_sorted_layout.png -H 1000 -w 1000 -B 500


# Get C4-GTF
zgrep 'gene_id "C4A"\|gene_id "C4B"' hg38.ncbiRefSeq.gtf.gz | awk '$1 == "chr6" && $3 == "transcript"' | cut -f 1 -d';' | sed 's/gene_id //g' | sed 's/"//g' | sed 's/chr6/grch38#chr6/g' | head -n 2 > chr6.C4.gtf
#grch38#chr6	ncbiRefSeq.2021-09-09	transcript	32014795	32035418	.	+	.	C4B
#grch38#chr6	ncbiRefSeq.2021-09-09	transcript	31982057	32002681	.	+	.	C4A


# Compute Bandage annotations
odgi position -i ${prefix_chr6_smooth}.C4.sorted.og -E chr6.C4.gtf -t 16 > ${prefix_chr6_smooth}.C4.sorted.anno.csv

# Convert to GFA for Bandage
odgi view -i ${prefix_chr6_smooth}.C4.sorted.og -g > ${prefix_chr6_smooth}.C4.sorted.gfa


# Untangle
( echo query.name query.start query.end ref.name ref.start ref.end score inv self.cov x|
  tr ' ' '\t'; odgi untangle -i ${prefix_chr6_smooth}.C4.sorted.og -r $(odgi paths -i ${prefix_chr6_smooth}.C4.sorted.og -L | grep grch38) -t 16 -m 256 -P |
  bedtools sort -i - ) | awk '$8 == "-" { x=$6; $6=$5; $5=x; } { print }' |
  tr ' ' '\t'   >${prefix_chr6_smooth}.C4.sorted.untangle.bed

# cat ${prefix_chr6_smooth}.C4.sorted.untangle.bed | grep '^chm13\|^grch38\|^HG00438\|^HG0107\|^HG01952'

Rscript ~/Desktop/SharedFolder/odgi-paper/scripts/plot_untangle.R chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.C4.sorted.untangle.bed
