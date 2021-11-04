#!/bin/bash

wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_06_27_pggb/chroms/chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.gz
gunzip chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.gz

# paths
odgi paths -i chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og -L > chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.paths
# ref paths
grep "chm13\|grch38" chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.paths > chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.ref_paths
# tips
odgi tips -i chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og -t 28 -P -R chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.ref_paths -v chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.tips.no_ref_hit.tsv -w 50000 -j > chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.tips.bed
bedtools sort -i chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.tips.bed > chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.tips.bed.sorted.bed

#### TODO ####
# we got this cytobands annoation after personal communication with Mitchell R. Vollger
grep -P "^chm13#chr8\t" chm13.CytoBandIdeo.v2.txt | grep p23.1

odgi sort -i chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og -t 28 -G 10 -x 100 -o chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og -Y -P
odgi extract -i chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og -E -r chm13#chr8:6054497-13066158 -t 28 -P -o chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og.p23.1.og
odgi paths -f -i chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og.p23.1.og > chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og.p23.1.og.fa
samtools faidx chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og.p23.1.og.fa
sort -k 2,2nr chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og.p23.1.og.fa.fai | grep -v "grch38\|chm13" | head -n 88 > 88paths_to_viz
echo -e "$(grep "grch38\|chm13" chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og.p23.1.og.fa.fai | cut -f 1)\n$(cat 88paths_to_viz)" | cut -f 1 > 90paths_to_viz
odgi viz -i chr8.pan.fa.c3d3224.7748b33.395c7f4.smooth.og.Y.og.p23.1.og -m -o chr8_pan_fa_c3d3224_7748b33.395c7f4_smooth_og_Y_og_p23_1_og_90paths_m.png -p 90paths_to_viz -a 2
