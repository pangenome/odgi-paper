#!/bin/bash

wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_16_pggb_wgg.88/chroms/chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz
gunzip chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz

G=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa

odgi build -g "$G" -o "$G".og -t 16 -P
odgi paths -i "$G".og -L -l -t 16 > "$G".paths
grep -E 'grch38|chm13' "$G".paths -v > "$G".non_ref.paths
cut -f 1,2 "$G".non_ref.paths -d '#' | sort| uniq > "$G".non_ref.haps

if [ -f odgi_build_threads_haps_time.csv ] ; then
    rm odgi_build_threads_haps_time.csv
fi
if [ -f vg_convert_threads_haps_time.csv ] ; then
    rm vg_convert_threads_haps_time.csv
fi

for H in 1 2 4 8 16 32 64
do  
    echo "hap: ""$H" 
    if [[ "$H" == 1 ]]; then
        echo "H == 1"
        grep grch38 "$G".paths | sed 's/\t1\t/\t0\t/g' > "$G"."$H"haps.bed
        cut -f 1 "$G"."$H"haps.bed > "$G"."$H"haps
    elif [[ "$H" == 2 ]]; then
        echo "H == 2"
        grep -E 'grch38|chm13' "$G".paths | sed 's/\t1\t/\t0\t/g' > "$G"."$H"haps.bed
        cut -f 1 "$G"."$H"haps.bed > "$G"."$H"haps
    else
        grep -E $(echo $(head -n $(expr "$H" - 2) "$G".non_ref.haps | sed -z 's/\n/\|/g')"grch38|chm13") "$G".paths | sed 's/\t1\t/\t0\t/g' > "$G"."$H"haps.bed
        cut -f 1 "$G"."$H"haps.bed > "$G"."$H"haps
    fi
    odgi extract -i "$G".og -o - -b "$G"."$H"haps.bed -p "$G"."$H"haps -t 16 -P | odgi sort -i - -O -o "$G"."$H"haps.og
    odgi view -i "$G"."$H"haps.og -g > "$G"."$H"haps.og.gfa
    for T in 1 2 4 8 16
    do
        for i in 1 2 3 4 5 6 7 8 9 10
        do
            echo "H: ""$H"" T: ""$T"" i: ""$i"
            /usr/bin/time --verbose odgi build -g "$G"."$H"haps.og.gfa -o "$G"."$H"haps.og.gfa.og -t "$T" 2> chr6_odgi_build_time_threads"$T"_haps_"$H"_"$i"
            /usr/bin/time --verbose vg convert -g -x -t "$T" "$G"."$H"haps.og.gfa 2> chr6_vg_convert_time_threads"$T"_haps_"$H"_"$i" 1> "$G"."$H"haps.og.gfa.xg
        done
    done
done

for H in 1 2 4 8 16 32 64
do
    for T in 1 2 4 8 16
    do
        for i in 1 2 3 4 5 6 7 8 9 10
        do
          echo "$T","$H","$i",$(grep Elapsed chr6_odgi_build_time_threads"$T"_haps_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_odgi_build_time_threads"$T"_haps_"$H"_"$i" | cut -f 6 -d ' ') >> odgi_build_threads_haps_time.csv
          echo "$T","$H","$i",$(grep Elapsed chr6_vg_convert_time_threads"$T"_haps_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_vg_convert_time_threads"$T"_haps_"$H"_"$i" | cut -f 6 -d ' ') >> vg_convert_threads_haps_time.csv
        done
    done
done

#Rscript ...
Rscript build.R odgi_build_threads_haps_time.csv vg_convert_threads_haps_time.csv build_eval.pdf build_supp.csv
