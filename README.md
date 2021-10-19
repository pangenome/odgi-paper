# odgi-paper

## resources

The grch38 FASTAs we used can be found at https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/. The corresponding GTF file at https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz.

## building the manuscript

```bash
# Dependencies
sudo apt-get -y install texlive texlive-latex-recommended \
        texlive-pictures texlive-latex-extra texlive-fonts-extra \
        texlive-science

sudo apt install graphviz

git clone https://github.com/pangenome/odgi-paper
cd odgi-paper/manuscript && make -k
```

## Bx author instructions
https://academic.oup.com/bioinformatics/pages/instructions_for_authors 
