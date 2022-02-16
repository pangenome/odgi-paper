wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_16_pggb_wgg.88/chroms/chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz
gunzip chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz

G=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa

odgi build -g "$G" -o "$G".og -t 16 -P
odgi paths -i "$G".og -L -l -t 16 > "$G".paths
grep -E 'grch38|chm13' "$G".paths -v > "$G".non_ref.paths
cut -f 1,2 "$G".non_ref.paths -d '#' | sort| uniq > "$G".non_ref.haps

vg_find_helper="#!/bin/bash

if [ -f \"\$G\".\"\$H\"haps.og.gfa.xg.find ] ; then
    rm \"\$G\".\"\$H\"haps.og.gfa.xg.find
fi

G=\"\$1\"
H=\"\$2\"
T=\"\$3\"
n=\"\$4\"

while IFS= read -r pos
    do
    if [[ \"\$pos\" != *\"strand.vs.ref\" ]]; then
        vg find -x \"\$G\".\"\$H\"haps.og.gfa.xg -P \$(echo \"\$pos\" | cut -f 2 | grep \"target.path.pos\" -v | cut -f 1 -d ',') -n \"\$n\" >> \"\$G\".\"\$H\"haps.og.gfa.xg.find
    fi
done < \"\$G\".\"\$H\"haps.og.gfa.og.pos"

echo "$vg_find_helper" > vg_find_helper.sh
chmod +x vg_find_helper.sh

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
    # replace the output path names with the original ones, because we always take the full paths
    if [ -f "$G"."$H"haps.og.gfa.orig.gfa ] ; then
        rm "$G"."$H"haps.og.gfa.orig.gfa
    fi
    while IFS= read -r line
    do
      if [[ "$line" == P* ]]; then
            ORIG=$(echo "$line" | cut -f 2)
            NEW=$(echo "$ORIG" | cut -f 1 -d ':')
            # echo "$NEW"
            echo "$line" | sed "s/$ORIG/$NEW/g" >> "$G"."$H"haps.og.gfa.orig.gfa
      else
        echo "$line" >> "$G"."$H"haps.og.gfa.orig.gfa
      fi
    done < "$G"."$H"haps.og.gfa

    odgi build -g "$G"."$H"haps.og.gfa.orig.gfa -o "$G"."$H"haps.og.gfa.og -t 16 -P
    vg convert -g -x -t 16 "$G"."$H"haps.og.gfa.orig.gfa > "$G"."$H"haps.og.gfa.xg
done

for H in 1 2 4 8 16 32 64
do
    # we take a position relative to the middle of graphs with more than 1 haplotype
    odgi position -i "$G"."$H"haps.og.gfa.og -p grch38#chr6,147658481,+ -t 1 -v > "$G"."$H"haps.og.gfa.og.graphpos
    for T in 1 2 4 8 16
    do
        for i in 1 2 3 4 5 6 7 8 9 10
        do
            echo "H: ""$H"" T: ""$T"" i: ""$i"
            /usr/bin/time --verbose odgi position -i "$G"."$H"haps.og.gfa.og -g $(cat "$G"."$H"haps.og.gfa.og.graphpos | grep -v "target.graph.pos" | cut -f 2 | cut -f 1 -d ',') -t "$T" -I 2> chr6_odgi_position_time_"$T"_"$H"_"$i" 1> "$G"."$H"haps.og.gfa.og.pos
            /usr/bin/time --verbose ./vg_find_helper.sh "$G" "$H" "$T" $(cat "$G"."$H"haps.og.gfa.og.graphpos | grep -v "target.graph.pos" | cut -f 2 | cut -f 1 -d ',') 2> chr6_vg_find_time_"$T"_"$H"_"$i"
        done
    done
done

if [ -f odgi_position_time.csv ] ; then
    rm odgi_position_time.csv
fi
if [ -f vg_find_time.csv ] ; then
    rm vg_find_time.csv 
fi

for H in 1 2 4 8 16 32 64
do
    for T in 1 2 4 8 16
    do
        for i in 1 2 3 4 5 6 7 8 9 10
        do
            echo "$T","$H","$i",$(grep Elapsed chr6_odgi_position_time_"$T"_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_odgi_position_time_"$T"_"$H"_"$i" | cut -f 6 -d ' ') >> odgi_position_time.csv
            #TODO if we can actually produce something...
            echo "$T","$H","$i",$(grep Elapsed chr6_vg_find_time_"$T"_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_vg_find_time_"$T"_"$H"_"$i" | cut -f 6 -d ' ') >> vg_find_time.csv 
        done
    done
done

rm vg_find_helper.sh

Rscript position.R odgi_position_time.csv vg_find_time.csv position_supp.csv
