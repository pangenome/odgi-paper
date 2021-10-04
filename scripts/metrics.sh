#!/bin/bash

wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_07_30_pggb/chroms/chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.gz
gunzip chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.gz
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz
gunzip hg38.ncbiRefSeq.gtf.gz

grep HTT hg38.ncbiRefSeq.gtf | grep "exon_number \"1\"" | grep "gene_name \"HTT\"" | grep -P "\texon"
#chr4	ncbiRefSeq.2021-09-09	exon	3074681	3075088	.	+	.	gene_id "HTT"; transcript_id "NM_001388492.1"; exon_number "1"; exon_id "NM_001388492.1.1"; gene_name "HTT";
#chr4	ncbiRefSeq.2021-09-09	exon	3074681	3075088	.	+	.	gene_id "HTT"; transcript_id "NM_002111.8"; exon_number "1"; exon_id "NM_002111.8.1"; gene_name "HTT";

odgi build -g chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa -o chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og -t 16 -P
odgi paths -L -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og > chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.paths

odgi extract -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og -r grch38#chr4:3074681-3075088 -o chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og -P -t 16 -E
odgi sort -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og -o chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -O
odgi viz -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -o chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og.png
odgi viz -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -w 2 -o chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og.w2.png
convert -size 852x940 xc:white chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og.w2.png -gravity West -composite chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og.w2.convert.png

odgi depth -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -r chm13#chr4:3073405-3073983 -P -t 16 | bedtools makewindows -b /dev/stdin -w 1 > chr4.HTT.chm13.depth.bed
odgi depth -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -b chr4.HTT.chm13.depth.bed | bedtools sort > chr4.HTT.chm13.depth.w1.bed

odgi degree -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -r chm13#chr4:3073405-3073983 -P -t 16 | bedtools makewindows -b /dev/stdin -w 1 > chr4.HTT.chm13.degree.bed
odgi degree -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -b chr4.HTT.chm13.degree.bed | bedtools sort > chr4.HTT.chm13.degree.w1.bed

Rscript metrics.R chr4.HTT.chm13.depth.w1.bed chr4.HTT.chm13.depth.w1.bed.pdf chr4.HTT.chm13.degree.w1.bed chr4.HTT.chm13.degree.w1.bed.pdf

odgi stats -i chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og -m > chr4.pan.fa.a2fb268.e820cd3.9ea71d8.smooth.gfa.og.HTTex1.og.O.og.stats.yml

# multiqc 1.11
multiqc .
# A nicer sample name for the paper.
sed -i 's/"smooth">smooth/"chr4.pan.HTTex1.gfa">chr4.pan.HTTex1.gfa/g' multiqc_report.html
# A manual screenshot only from the Detailed ODGI stats table. Zoom in Firefox: 200%.
