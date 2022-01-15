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

    odgi build -g "$G"."$H"haps.og.gfa -o "$G"."$H"haps.og.gfa.og -t 16 -P
    vg convert -g -x -t 16 "$G"."$H"haps.og.gfa > "$G"."$H"haps.og.gfa.xg
done

for H in 1 2 4 8 16 32 64
do
    for i in {1..2}
    do
        /usr/bin/time --verbose odgi viz -i "$G"."$H"haps.og.gfa.og -o "$G"."$H"haps.og.gfa.og.png 2> chr6_odgi_viz_time_"$H"_"$i"
        #TODO if we can actually produce something...
        /usr/bin/time --verbose vg viz -D -x "$G"."$H"haps.og.gfa.xg -o "$G"."$H"haps.og.gfa.xg.svg 2> chr6_vg_viz_time_"$H"_"$i"
    done
done

if [ -f odgi_viz_time.csv ] ; then
    rm odgi_viz_time.csv
fi
if [ -f vg_viz_time.csv ] ; then
    rm vg_viz_time.csv 
fi

for H in 1 2 4 8 16 32 64
do
    for i in {1..2}
    do
        echo "$H","$i",$(grep Elapsed chr6_odgi_viz_time_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_odgi_viz_time_"$H"_"$i" | cut -f 6 -d ' ') >> odgi_viz_time.csv
        #TODO if we can actually produce something...
        echo "$H","$i",$(grep Elapsed chr6_vg_viz_time_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_vg_viz_time_"$H"_"$i" | cut -f 6 -d ' ') >> vg_viz_time.csv 
    done
done

#TODO
#Rscript ...
