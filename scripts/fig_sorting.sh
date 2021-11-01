#!/bin/bash

filename_chr6_gfa=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth

# Take the ${filename_chr6_gfa}.C4.0.og from `fig_extract_viz_draw_position_untangle.sh`

odgi sort -i chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.C4.sorted.og -o - -x 1 -Y | odgi viz -i - -o "$(echo ${filename_chr6_gfa} | tr '.' '_' )"_C4_bad_sorted.png -c 12 -w 100 -y 50 -p chr6.selected_paths.txt -m -B Spectral:4
