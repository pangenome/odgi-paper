wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/scratch/2021_11_16_pggb_wgg.88/chroms/chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz
gunzip chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa.gz

G=chr6.pan.fa.a2fb268.4030258.6a1ecc2.smooth.gfa

odgi paths -i "$G" -L -l -t 16 > "$G".paths

# build our graphs by number of haplotypes
for H in 1 2 4 8 16 32 64
do
    if [[ H == 1 ]]; then
        grep grch38 "$G".paths | sed 's/\t1\t/\t0\t/g' > "$G"."$H"haps.bed
        cut -f 1 "$G"."$H"haps.bed > "$G"."$H"haps
    elif [[ H == 2 ]]; then
        grep -E 'grch38|chm13' "$G".paths | sed 's/\t1\t/\t0\t/g' > "$G"."$H"haps.bed
        cut -f 1 "$G"."$H"haps.bed > "$G"."$H"haps
    else
        grep -E $(echo $(head -n $(expr "$H" - 2) "$G".non_ref.haps | sed -z 's/\n/\|/g')"grch38|chm13") "$G".paths | sed 's/\t1\t/\t0\t/g' > "$G"."$H"haps.bed
        cut -f 1 "$G"."$H"haps.bed > "$G"."$H"haps
    fi
    odgi extract -i "$G" -o - -b "G$"."$H"haps.bed -p "$G"."$H"haps -t 16 -P | odgi sort -i - -O -o "$G"."$H"haps.og
    odgi view -i "$G"."$H"haps.og -g > "$G"."$H"haps.og.gfa
    for i in {1..10}
    do
        /usr/bin/time --verbose odgi build -g "$G"."$H"haps.og.gfa -o "$G"."$H"haps.og.gfa.og -t 16
        /usr/bin/time --verbose vg convert -g -x -t 16 "$G"."$H"haps.og.gfa > "$G"."$H"haps.og.gfa.xg
    done
done

for H in 1 2 4 8 16 32 64
do
    for T in 1 2 4 8 16
    do
        for i in {1..10}
        do
            /usr/bin/time --verbose odgi extract -i "$G"."$H"haps.og.gfa.og -t "$T" -c 10 -r grch38#chr6:58553888-59829934 -o "$G"."$H"haps.og.gfa.og.centromeres.og 2> chr6_odgi_extract_time_"$T"_"$H"_"$i"
            # TODO this never finished with 28 threads so far, maybe we can't run it!
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
        for i in {1..10}
        do
            echo "$T","$H","$i",$(grep Elapsed chr6_odgi_extract_time_"$T"_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_odgi_extract_time_"$T"_"$H"_"$i" | cut -f 6 -d ' ') >> odgi_extract_time.csv
            #TODO if we can actually produce something...
            echo "$T","$H","$i",$(grep Elapsed chr6_vg_chunk_time_"$T"_"$H"_"$i" | cut -f 8 -d ' ' | awk -F: '{ print ($1 * 60) + ($2) + $3 }'),$(grep "Maximum" chr6_vg_chunk_time_"$T"_"$H"_"$i" | cut -f 6 -d ' ') >> vg_chunk_time.csv 
        done
    done
done

#TODO
#Rscript ...
