wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_04_pggb_wgg.87/chroms/chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz
gunzip chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz

MHC=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.og
odgi build -g chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa -o "$MHC" -t 28 -P
odgi extract -i "$MHC" -o "$MHC".mhc.og -E -P -t 28 -r grch38#chr6:29000000-34000000
odgi sort -i "$MHC".mhc.og -o "$MHC".mhc.og.O.og -O
odgi layout -i "$MHC".mhc.og.O.og -o "$MHC".mhc.og.O.og.lay -T "$MHC".mhc.og.O.og.lay.tsv -P -t 28 -x 100
odgi draw -i chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.og.mhc.og.O.og -c chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.og.mhc.og.O.og.lay -p chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.og.mhc.og.O.og.lay.H1000w10.png -H 1000 -C -w 10 -t 28 -P

#### MANUAL INTERVENTION ####
# Go to https://drububu.com/tutorial/bitmap-to-vector.html. 
# Drag and drop chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.og.mhc.og.O.og.lay.H1000w100.png into the dashed field.
# Click "save as svg" to chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.og.mhc.og.O.og.lay.H1000w100.png.svg. This might take some time, be patient!

inkscape chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.og.mhc.og.O.og.lay.H1000w100.png.svg --export-pdf=chr6_pan_fa_a2fb268_4030258_d9f1245_smooth_gfa_og_mhc_og_O_og_lay_H1000w100_png_svg.pdf

#### MANUAL INTERVENTION ####
# Add box around C4 using Inkscape


