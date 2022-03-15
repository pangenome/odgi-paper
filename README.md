# odgi-paper

## resources

The input graphs can be found at https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=pangenomes/scratch/2021_11_16_pggb_wgg.88/. \
The GRCh38 FASTAs we used can be found at https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/. \
The corresponding GTF file at https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz.

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

Original papers: approximately 5,000 words
The abstracts should be succinct and contain only material relevant to the headings. A maximum of 150 words is recommended.
