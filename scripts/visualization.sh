#!/bin/bash

#======================================================================================================================
# odgi viz with C4A/C4B locus graph
#==================================

filename_chr6_gfa=chr6.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa

# Download and build the graph
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_07_30_pggb/chroms/${filename_chr6_gfa}.gz
gunzip ${filename_chr6_gfa}.gz
odgi build -g ${filename_chr6_gfa} -o ${filename_chr6_gfa}.og -t 16 -P

# TO_IGNORE
## Find C4 coordinates
#wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz
#zgrep 'gene_id "C4A"\|gene_id "C4B"' hg38.ncbiRefSeq.gtf.gz | awk '$1 == "chr6"' | cut -f 1,4,5 | bedtools sort | bedtools merge -d 15000 | sed 's/chr6/chm13#chr6/g' > C4.coordinates.bed
#odgi extract -i ${filename_chr6_gfa}.og -b C4.coordinates.bed -o - --full-range -L 130000 -t 16 -P | \
#odgi sort -i - -o - --optimize -t 16 -P | \
#odgi sort -i - -o ${filename_chr6_gfa}.og.C4.sorted.og -p Ygs -x 100 -t 16 -P
#odgi viz -i ${filename_chr6_gfa}.og.C4.sorted.og -o ${filename_chr6_gfa}.og.C4.sorted.png -w 150  -m -B Spectral:4
# TO_IGNORE

# Extraction, optimization, and sorting
odgi extract -i ${filename_chr6_gfa}.og -r grch38#chr6:31889244-32095493 -o - --full-range -t 16 -P | odgi explode -i - --biggest 1 --optimize -p ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493
odgi sort -i ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.og -o ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.og -p Ygs -x 100 -t 16 -P

# Default (binned) mode
odgi viz -i ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.og -o ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.png -w 150 -p chr6.selected_paths.txt

# Color by strand
odgi viz -i ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.og -o ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.z.png -w 150 -p chr6.selected_paths.txt -z

# Color by position
odgi viz -i ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.og -o ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.du.png -w 150 -p chr6.selected_paths.txt -du

# Color by depth
odgi viz -i ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.og -o ${filename_chr6_gfa}.og.grch38_chr6_31889244-32095493.0.sorted.m.png -w 150 -p chr6.selected_paths.txt -m -B Spectral:4

#======================================================================================================================
