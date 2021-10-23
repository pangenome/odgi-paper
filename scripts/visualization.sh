#!/bin/bash

#======================================================================================================================
# odgi viz with C4A/C4B locus graph
#==================================

filename_chr6_gfa=chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa

# Download and build the graph
wget http://hypervolu.me/~guarracino/${filename_chr6_gfa}.gz
gunzip ${filename_chr6_gfa}.gz
odgi build -g ${filename_chr6_gfa} -o ${filename_chr6_gfa}.og -t 16 -P

# Find C4 coordinates
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz
zgrep 'gene_id "C4A"\|gene_id "C4B"' hg38.ncbiRefSeq.gtf.gz | awk '$1 == "chr6"' | cut -f 1,4,5 | bedtools sort | bedtools merge -d 15000 | bedtools slop -l 10000 -r 20000 -g hg38.chrom.sizes | sed 's/chr6/grch38#chr6/g' >C4.coordinates.bed

# Extraction, explosion, optimization, and sorting
odgi extract -i ${filename_chr6_gfa}.og -b C4.coordinates.bed -o - --full-range -t 16 -P |
  odgi explode -i - --biggest 1 --sorting-criteria P --optimize -p ${filename_chr6_gfa}.C4
odgi sort -i ${filename_chr6_gfa}.C4.0.og -o ${filename_chr6_gfa}.C4.sorted.og -p Ygs -x 100 -t 16 -P

odgi paths -i ${filename_chr6_gfa}.C4.sorted.og -L | grep 'chr6\|HG00438\|HG0107\|HG01952' > chr6.selected_paths.txt

# Default (binned) mode
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted.png -w 50 -y 50 -p chr6.selected_paths.txt

# Color by strand
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted_z.png -w 50 -y 50 -p chr6.selected_paths.txt -z

# Color by position
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted_du.png -w 50 -y 50 -p chr6.selected_paths.txt -du

# Color by depth
odgi viz -i ${filename_chr6_gfa}.C4.sorted.og -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_sorted_m.png -w 50 -y 50 -p chr6.selected_paths.txt -m -B Spectral:4

#======================================================================================================================


odgi layout -i ${filename_chr6_gfa}.C4.sorted.og -o ${filename_chr6_gfa}.C4.sorted.lay -T ${filename_chr6_gfa}.C4.sorted.tsv -x 100 -t 16 -P
odgi draw -i ${filename_chr6_gfa}.C4.sorted.og -c ${filename_chr6_gfa}.C4.sorted.lay -p ${filename_chr6_gfa}.C4.sorted.layout.png

