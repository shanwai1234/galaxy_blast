#!/bin/sh
set -e
echo "This will update test files using the current version of BLAST+"

if [ -f "tools/ncbi_blast_plus/make_ncbi_blast_plus.sh" ]
then
echo "Good, in the expected directory"
else
echo "ERROR. Run this from the GitHub repository root directory."
exit 1
fi

cd test-data

export EXT="6 std sallseqid score nident positive gaps ppos qframe sframe qseq sseq qlen slen salltitles"

echo
echo makeblastdb
echo ===========
#Doing this first in case future tests use one of the local databases
#Note we delete any old database to avoid this line in the log:
#"Deleted existing BLAST database with identical name."

echo "four_human_proteins.fasta"
rm -f test-data/four_human_proteins.fasta.p*
makeblastdb -out four_human_proteins.fasta -hash_index -in four_human_proteins.fasta  -title "Just 4 human proteins" -dbtype prot > four_human_proteins.fasta.log

echo "four_human_proteins_taxid.fasta"
#Bar the *.pin file and *.log with trivial differences due to a time stamp,
#only real difference expected is the TaxID embedded in the *.phr file:
rm -f test-data/four_human_proteins_taxid.fasta.p*
makeblastdb -out four_human_proteins_taxid.fasta -hash_index -in four_human_proteins.fasta  -title "Just 4 human proteins" -dbtype prot -taxid 9606 > four_human_proteins_taxid.fasta.log

echo
echo makeprofiledb
echo =============

echo "cd00003_and_cd00008"
#Rather than supplying a file listing *.smp inputs, using stdin
echo "cd00003.smp cd00008.smp" | makeprofiledb -in /dev/stdin -out cd00003_and_cd00008 -title "Just 2 PSSM matrices"

echo
echo Masking
echo =======

echo "segmasker_four_human.fasta"
segmasker -in four_human_proteins.fasta -window 12 -locut 2.2 -hicut 2.5 -out segmasker_four_human.fasta -outfmt fasta

echo "segmasker_four_human.maskinfo-asn1"
segmasker -in four_human_proteins.fasta -window 12 -locut 2.2 -hicut 2.5 -out segmasker_four_human.maskinfo-asn1 -outfmt maskinfo_asn1_text

echo "segmasker_four_human.maskinfo-asn1-binary"
segmasker -in four_human_proteins.fasta -window 12 -locut 2.2 -hicut 2.5 -out segmasker_four_human.maskinfo-asn1-binary -outfmt maskinfo_asn1_bin

echo
echo Main
echo ====

echo "blastn_rhodopsin_vs_three_human.xml"
blastn -query rhodopsin_nucs.fasta -subject three_human_mRNA.fasta -task megablast -evalue 1e-40 -out blastn_rhodopsin_vs_three_human.xml -outfmt 5

echo "blastn_rhodopsin_vs_three_human.tabular"
blastn -query rhodopsin_nucs.fasta -subject three_human_mRNA.fasta -task megablast -evalue 1e-40 -out blastn_rhodopsin_vs_three_human.tabular -outfmt 6

echo "blastn_rhodopsin_vs_three_human.columns.tabular"
blastn -query rhodopsin_nucs.fasta -subject three_human_mRNA.fasta -task megablast -evalue 1e-40 -out blastn_rhodopsin_vs_three_human.columns.tabular -outfmt "6 qseqid sseqid pident qlen slen"

echo "blastp_four_human_vs_rhodopsin.xml"
blastp -query four_human_proteins.fasta -subject rhodopsin_proteins.fasta -task blastp -evalue 1e-08 -qcov_hsp_perc 25 -out blastp_four_human_vs_rhodopsin.xml -outfmt 5 -seg no -matrix BLOSUM62 -parse_deflines

echo "blastp_four_human_vs_rhodopsin.tabular"
blastp -query four_human_proteins.fasta -subject rhodopsin_proteins.fasta -task blastp -evalue 1e-08 -qcov_hsp_perc 25 -out blastp_four_human_vs_rhodopsin.tabular -outfmt 6 -seg no -matrix BLOSUM62 -parse_deflines

echo "blastp_four_human_vs_rhodopsin_ext.tabular"
blastp -query four_human_proteins.fasta -subject rhodopsin_proteins.fasta -task blastp -evalue 1e-08 -qcov_hsp_perc 25 -out blastp_four_human_vs_rhodopsin_ext.tabular -outfmt "$EXT" -seg no -matrix BLOSUM62 -parse_deflines

echo "blastp_rhodopsin_vs_four_human.tabular"
blastp -query rhodopsin_proteins.fasta -subject four_human_proteins.fasta -task blastp -evalue 1e-8 -out blastp_rhodopsin_vs_four_human.tabular -outfmt 6 -seg no -matrix BLOSUM62 -parse_deflines

echo "blastx_rhodopsin_vs_four_human.xml"
blastx -query rhodopsin_nucs.fasta -subject four_human_proteins.fasta -query_gencode 1 -evalue 1e-10 -out blastx_rhodopsin_vs_four_human.xml -outfmt 5

echo "blastx_rhodopsin_vs_four_human.tabular"
blastx -query rhodopsin_nucs.fasta -subject four_human_proteins.fasta -query_gencode 1 -evalue 1e-10 -out blastx_rhodopsin_vs_four_human.tabular -outfmt 6

echo "blastx_rhodopsin_vs_four_human_ext.tabular"
blastx -query rhodopsin_nucs.fasta -subject four_human_proteins.fasta -query_gencode 1 -evalue 1e-10 -out blastx_rhodopsin_vs_four_human_ext.tabular -outfmt "$EXT"

echo "blastx_rhodopsin_vs_four_human_all.tabular"
blastx -query rhodopsin_nucs.fasta -subject four_human_proteins.fasta -query_gencode 1 -evalue 1e-10 -out blastx_rhodopsin_vs_four_human_all.tabular -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore sallseqid score nident positive gaps ppos qframe sframe qseq sseq qlen slen salltitles qgi qacc qaccver sallseqid sgi sallgi sacc saccver sallacc stitle sstrand frames btop qcovs qcovhsp staxids sscinames scomnames sblastnames sskingdoms"

echo "tblastn_four_human_vs_rhodopsin.xml"
tblastn -query four_human_proteins.fasta -subject rhodopsin_nucs.fasta -evalue 1e-10 -out tblastn_four_human_vs_rhodopsin.xml -outfmt 5 -db_gencode 1 -seg no -matrix BLOSUM80

echo "tblastn_four_human_vs_rhodopsin.html"
tblastn -query four_human_proteins.fasta -subject rhodopsin_nucs.fasta -evalue 1e-10 -out tblastn_four_human_vs_rhodopsin.html -outfmt 0 -html -db_gencode 1 -seg no -matrix BLOSUM80

echo "tblastn_four_human_vs_rhodopsin.tabular"
tblastn -query four_human_proteins.fasta -subject rhodopsin_nucs.fasta -evalue 1e-10 -out tblastn_four_human_vs_rhodopsin.tabular -outfmt 6 -db_gencode 1 -seg no -matrix BLOSUM80

echo "tblastn_four_human_vs_rhodopsin_ext.tabular"
tblastn -query four_human_proteins.fasta -subject rhodopsin_nucs.fasta -evalue 1e-10 -out tblastn_four_human_vs_rhodopsin_ext.tabular -outfmt "$EXT" -db_gencode 1 -seg no -matrix BLOSUM80

echo "tblastx_rhodopsin_vs_three_human.tabular"
tblastx -query rhodopsin_nucs.fasta -subject three_human_mRNA.fasta -evalue 1e-40 -out tblastx_rhodopsin_vs_three_human.tabular -outfmt 6

echo
echo blastxml_to_tabular
echo ===================

echo "blastn_rhodopsin_vs_three_human_converted.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c std -o blastn_rhodopsin_vs_three_human_converted.tabular blastn_rhodopsin_vs_three_human.xml

echo "blastp_four_human_vs_rhodopsin_converted.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c std -o blastp_four_human_vs_rhodopsin_converted.tabular blastp_four_human_vs_rhodopsin.xml

echo "blastp_four_human_vs_rhodopsin_converted_ext.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c ext -o blastp_four_human_vs_rhodopsin_converted_ext.tabular blastp_four_human_vs_rhodopsin.xml

echo "blastp_sample_converted.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c std -o blastp_sample_converted.tabular blastp_sample.xml

echo "blastx_rhodopsin_vs_four_human_converted.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c std -o blastx_rhodopsin_vs_four_human_converted.tabular blastx_rhodopsin_vs_four_human.xml

echo "blastx_rhodopsin_vs_four_human_converted_ext.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c ext -o blastx_rhodopsin_vs_four_human_converted_ext.tabular blastx_rhodopsin_vs_four_human.xml

echo "blastx_sample_converted.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c std -o blastx_sample_converted.tabular blastx_sample.xml

echo "blastp_human_vs_pdb_seg_no_converted_std.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c std -o blastp_human_vs_pdb_seg_no_converted_std.tabular blastp_human_vs_pdb_seg_no.xml

echo "blastp_human_vs_pdb_seg_no_converted_ext.tabular"
python ../tools/ncbi_blast_plus/blastxml_to_tabular.py -c ext -o blastp_human_vs_pdb_seg_no_converted_ext.tabular blastp_human_vs_pdb_seg_no.xml

echo
echo deltablast
echo ==========

#It will be a problem if the exact version of the cdd_delta database alters the test output...
#Following (or similar) works for deltablast to find the cdd_delta database automatically:
#export BLASTDB=/data/blastdb/ncbi/cdd:/data/blastdb/ncbi
#Or, we can make it explicit (but specific to local setup) via -rpsdb
export CDD_DELTA=/data/blastdb/ncbi/cdd/cdd_delta

echo "deltablast_four_human_vs_rhodopsin.xml"
deltablast -query four_human_proteins.fasta -subject rhodopsin_proteins.fasta -evalue 1e-08 -out deltablast_four_human_vs_rhodopsin.xml -outfmt 5 -matrix BLOSUM62 -seg no -parse_deflines -rpsdb $CDD_DELTA

echo "deltablast_four_human_vs_rhodopsin.tabular"
deltablast -query four_human_proteins.fasta -subject rhodopsin_proteins.fasta -evalue 1e-08 -out deltablast_four_human_vs_rhodopsin.tabular -outfmt 6 -matrix BLOSUM62 -seg no -parse_deflines -rpsdb $CDD_DELTA

echo "deltablast_four_human_vs_rhodopsin_ext.tabular"
deltablast -query four_human_proteins.fasta -subject rhodopsin_proteins.fasta -evalue 1e-08 -out deltablast_four_human_vs_rhodopsin_ext.tabular -outfmt "$EXT" -matrix BLOSUM62 -seg no -parse_deflines -rpsdb $CDD_DELTA

echo "deltablast_rhodopsin_vs_four_human.tabular"
deltablast -query rhodopsin_proteins.fasta -subject four_human_proteins.fasta -evalue 1e-08 -out deltablast_rhodopsin_vs_four_human.tabular -outfmt 6 -rpsdb $CDD_DELTA
