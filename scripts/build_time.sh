wget http://hypervolu.me/~guarracino/chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.gz
gunzip chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa.gz

G=chr6.pan.fa.a2fb268.4030258.d9f1245.smooth.gfa

# t1
for i in {1..10}
do
    /usr/bin/time odgi build -g "$G" -o "$G".og -t 1 2> chr6_odgi_build_time_t1_"$i"
done

#t2
for i in {1..10}
do
    /usr/bin/time odgi build -g "$G" -o "$G".og -t 2 2> chr6_odgi_build_time_t2_"$i"
done

#t4
for i in {1..10}
do
    /usr/bin/time odgi build -g "$G" -o "$G".og -t 4 2> chr6_odgi_build_time_t4_"$i"
done

#t8
for i in {1..10}
do
    /usr/bin/time odgi build -g "$G" -o "$G".og -t 8 2> chr6_odgi_build_time_t8_"$i"
done

#t16
for i in {1..10}
do
    /usr/bin/time odgi build -g "$G" -o "$G".og -t 16 2> chr6_odgi_build_time_t16_"$i"
done

for T in 1 2 4 8 16
do
    grep elapsed chr6_odgi_build_time_t"$T"_* | tr ' ' '\n' | grep elapsed | sed 's/elapsed//g' | awk -F: '{ print ($1 * 60) + ($2) + $3 }' | sed -e "s/$/,$T/" >> mean_build_time.csv
    
done

Rscript time.R mean_build_time.csv mean_build_time.pdf
