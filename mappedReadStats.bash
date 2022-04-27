#!/bin/bash


enable_lmod
module load samtools
module load parallel

BAMPATH=$(echo $1 | sed "s/\/$//")

if [[ -z "$2" ]]; then
	BAMPATTERN="-RG.bam"
else
	BAMPATTERN=$2
fi

avgBP () {
	BAMFILE=$1
        samtools view $BAMFILE | \
                cut -f10 | \
                awk '{ print length }' | \
                awk '{ sum += $1 } END { if (NR > 0) print sum / NR }' 
}
export -f avgBP

avgDP () {
	# return mean depth for positions with coverage
	BAMFILE=$1
	samtools depth -s $BAMFILE | \
		cut -f3 | \
		awk '{ sum += $1 } END { if (NR > 0) print sum / NR }'
}
export -f avgDP

posWWOCVG () {
	# return num pos with and without coverage
	# 3 cols
	# num_pos num_pos_w_cvg 
	BAMFILE=$1
	samtools coverage $BAMFILE | \
		cut -f3,5 | \
		awk 'BEGIN { OFS = "\t" } {for (i=1;i<=NF;i++) a[i]+=$i} END{for (i=1;i<=NF;i++) printf a[i] OFS; printf "\n"}' 

}
export -f posWWOCVG

ls $BAMPATH/*$BAMPATTERN | \
	parallel --no-notice -j 20 "echo {} && samtools view -c {} && avgBP {} && avgDP {} && posWWOCVG {}" | \
 	paste - - - - - | \
	awk 'BEGIN { OFS = "\t" } NR>=1 {$7 = $4 * $6 / $5} 1' | \
        awk 'BEGIN { OFS = "\t" } NR>=1 {$8 = 100 * $6 / $5} 1'


# output
# filename numreads meanreadlength meandepth_wcvg numpos numpos_wcvg meandepth pctpos_wcvg

