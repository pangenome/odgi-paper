#!/bin/bash

#### FIXME once wgg.88 is in the HPRC repository ####
wget wget http://hypervolu.me/~guarracino/chr4.pan.fa.a2fb268.4030258.6a1ecc2.smooth.og.gz
gunzip chr4.pan.fa.a2fb268.4030258.6a1ecc2.smooth.og.gz
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz

# G=chr4.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa
G=chr4.pan.fa.a2fb268.4030258.6a1ecc2.smooth

zgrep HTT hg38.ncbiRefSeq.gtf | grep "exon_number \"1\"" | grep "gene_name \"HTT\"" | grep -P "\texon"
#chr4	ncbiRefSeq.2021-09-09	exon	3074681	3075088	.	+	.	gene_id "HTT"; transcript_id "NM_001388492.1"; exon_number "1"; exon_id "NM_001388492.1.1"; gene_name "HTT";
#chr4	ncbiRefSeq.2021-09-09	exon	3074681	3075088	.	+	.	gene_id "HTT"; transcript_id "NM_002111.8"; exon_number "1"; exon_id "NM_002111.8.1"; gene_name "HTT";

odgi build -g "$G" -o "$G".og -t 16 -P
odgi paths -L -i "$G".og > "$G".og.paths

odgi extract -i "$G".og -r grch38#chr4:3074681-3075088 -o "$G".og.HTTex1.og -P -t 16 -E
odgi sort -i "$G".og.HTTex1.og -o "$G".og.HTTex1.og.O.og -O

odgi depth -i "$G".og.HTTex1.og.O.og -r chm13#chr4:3073405-3073983 -P -t 16 | bedtools makewindows -b /dev/stdin -w 1 > chr4.HTT.chm13.depth.bed
odgi depth -i "$G".og.HTTex1.og.O.og -b chr4.HTT.chm13.depth.bed | bedtools sort > chr4.HTT.chm13.depth.w1.bed

odgi degree -i "$G".og.HTTex1.og.O.og -r chm13#chr4:3073405-3073983 -P -t 16 | bedtools makewindows -b /dev/stdin -w 1 > chr4.HTT.chm13.degree.bed
odgi degree -i "$G".og.HTTex1.og.O.og -b chr4.HTT.chm13.degree.bed | bedtools sort > chr4.HTT.chm13.degree.w1.bed

Rscript metrics.R chr4.HTT.chm13.depth.w1.bed chr4_HTT_chm13_depth_w1_bed.pdf chr4.HTT.chm13.degree.w1.bed chr4_HTT_chm13_degree_w1_bed.pdf

odgi stats -i "$G".og.HTTex1.og.O.og -m > "$G".og.HTTex1.og.O.og.stats.yml

# multiqc 1.11
multiqc .
# A nicer sample name for the paper.
sed -i 's/"smooth">smooth/"chr4.pan.HTTex1.gfa">chr4.pan.HTTex1.gfa/g' multiqc_report.html
#### MANUAL INTERVENTION ####
# A manual screenshot only from the Detailed ODGI stats table. Zoom in Firefox: 200%.
inkscape chr4_pan_HTTex1_gfa_multiqc_odgi_stats.png.svg --export-pdf=chr4_pan_HTTex1_gfa_multiqc_odgi_stats_svg.pdf

odgi paths -i "$G".og.HTTex1.og.O.og -L > "$G".og.HTTex1.og.O.og.paths
# we accidentally cut off stuff from chm13 and grch13 
cat "$G".og.HTTex1.og.O.og.paths | cut -f 1 -d':' | cut -f 1,2 -d'#' | grep -v "chm13\|grch38" | cut -c3- > "$G".og.HTTex1.og.O.og.paths_tiny
echo -e "chm13\ngrch38\n$(cat "$G".og.HTTex1.og.O.og.paths_tiny)" > "$G".og.HTTex1.og.O.og.paths_tiny
odgi view -i "$G".og.HTTex1.og.O.og -g > "$G".og.HTTex1.og.O.og.gfa
paste "$G".og.HTTex1.og.O.og.paths "$G".og.HTTex1.og.O.og.paths_tiny| while read n k; do sed -i "s/$n/$k/g" "$G".og.HTTex1.og.O.og.gfa; done
odgi build -g "$G".og.HTTex1.og.O.og.gfa -o "$G".og.HTTex1.og.O.og.tiny.og

odgi paths -i "$G".og.HTTex1.og.O.og.tiny.og -f > "$G".og.HTTex1.og.O.og.tiny.og.fasta
samtools faidx "$G".og.HTTex1.og.O.og.tiny.og.fasta

cat "$G".og.HTTex1.og.O.og.tiny.og.fasta.fai | sort -k2 -r | head -n 24 | grep "chm13" -v | cut -f 1 > paths_to_viz
# take care of chm13 and grch13
echo -e "chm13\ngrch38\n$(cat paths_to_viz)" > paths_to_viz
odgi viz -i "$G".og.HTTex1.og.O.og.tiny.og -o "$G".og.HTTex1.og.O.og.tiny.og.png -a 3  -p paths_to_viz

#### MANUAL INTERVENTION ####
# Go to https://drububu.com/tutorial/bitmap-to-vector.html. 
# Drag and drop "$G".og.HTTex1.og.O.og.tiny.og.png into the dashed field.
# Click "save as svg" to "$G".og.HTTex1.og.O.og.tiny.og.png.svg.

#### CAREFUL ####
# check if the svg already exists, else boil out
if [[ -f "$G".og.HTTex1.og.O.og.tiny.og.png.svg ]]
then
    inkscape "$G".og.HTTex1.og.O.og.tiny.og.png.svg --export-pdf=chr4_pan_fa_a2fb268_4030258_6a1ecc2_smooth_gfa_og_HTTex1_og_O_og_tiny_og_png_svg.pdf
else
    echo "Please create a perfect lossless SVG from the PNG via https://drububu.com/tutorial/bitmap-to-vector.html and save it as "$G".og.HTTex1.og.O.og.tiny.og.png.svg!"
fi

odgi extract -i "$G".og -r grch38#chr4:3074871-3074938 -o - -P -t 16 -E | odgi sort -i - -o chr4.pan.HTTex1.STR.og -O
odgi chop -c 1 -i chr4.pan.HTTex1.STR.og -o chr4.pan.HTTex1.STR.og.c1.og
odgi paths -i chr4.pan.HTTex1.STR.og.c1.og -L | head -n 10 > paths_to_STR
# grep -f <(tr ',' '\n' < ~/Downloads/odgi_paper/HTT_exon1/paths_to_viz) paths_to_STR > paths_to_STR_24

odgi extract -i chr4.pan.HTTex1.STR.og.c1.og -o - -r grch38#chr4:3074723-3074944:140-300 -E -p paths_to_STR | odgi sort -i - -o chr4.pan.HTTex1.STR.og.c1.og.T.og -O
odgi unchop -i chr4.pan.HTTex1.STR.og.c1.og.T.og -o chr4.pan.HTTex1.STR.og.c1.og.T.og.unchop.og
odgi view -i chr4.pan.HTTex1.STR.og.c1.og.T.og.unchop.og -g > chr4.pan.HTTex1.STR.og.gfa

vg view -F -v chr4.pan.HTTex1.STR.og.gfa > chr4.pan.HTTex1.STR.vg
vg index -x chr4.pan.HTTex1.STR.xg chr4.pan.HTTex1.STR.vg
vg viz -x chr4.pan.HTTex1.STR.xg -o chr4.pan.HTTex1.STR.xg.svg

#### MANUAL INTERVENTION ####
# remove the names of the paths from the SVG using Inkscape
inkscape chr4.pan.HTTex1.STR.xg.svg --export-pdf=chr4_pan_HTTex1_STR_xg_svg.pdf
