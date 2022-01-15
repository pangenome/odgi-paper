wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_16_pggb_wgg.88/chroms/chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz
gunzip chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz

G=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa

odgi build -g "$G" -o "$G".og -t 16 -P
odgi paths -i "$G".og -L -l -t 16 > "$G".paths
grep -E 'grch38|chm13' "$G".paths -v > "$G".non_ref.paths
cut -f 1,2 "$G".non_ref.paths -d '#' | sort| uniq > "$G".non_ref.haps

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
    for T in 1 2 4 8 16
    do
        for i in {1..2}
        do
            echo "H: ""$H"" T: ""$T"" i: ""$i"
            /usr/bin/time --verbose odgi extract -i "$G"."$H"haps.og.gfa.og -t "$T" -c 10 -r grch38#chr6:58553888-59829934 -o "$G"."$H"haps.og.gfa.og.centromeres.og 2> chr6_odgi_extract_time_"$T"_"$H"_"$i"
            /usr/bin/time --verbose vg chunk -x "$G"."$H"haps.og.gfa.xg -t "$T" -p grch38#chr6:58553888-59829934 -c 10 2> chr6_vg_chunk_time_"$T"_"$H"_"$i" 1> "$G"."$H"haps.og.gfa.xg.centromeres.vg
        done
    done
done

if [ -f odgi_extract_time.csv ] ; then
    rm odgi_extract_time.csv
fi
if [ -f vg_chunk_time.csv ] ; then
    rm vg_chunk_time.csv 
fi

for H in 1 2 4 8 16 32 64
do
    for T in 1 2 4 8 16
    do
        for i in {1..2}
        do
            echo "$T","$H","$i",$(grep Elapsed chr6_odgi_extract_time_"$T"_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_odgi_extract_time_"$T"_"$H"_"$i" | cut -f 6 -d ' ') >> odgi_extract_time.csv
            echo "$T","$H","$i",$(grep Elapsed chr6_vg_chunk_time_"$T"_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_vg_chunk_time_"$T"_"$H"_"$i" | cut -f 6 -d ' ') >> vg_chunk_time.csv 
        done
    done
done

#TODO
#Rscript ...
