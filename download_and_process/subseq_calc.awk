#this script calculates the walue for the Subseq table
#the imput is generated by the appropriate parts in scripts.sql
BEGIN{
	FS=","
}
{
	if($1==uid){
		print $2, $1, $3-gtime, $4-gbet, $5-pwin, gout,  gpay
	}
	uid=$1
	gtime=$3
	gbet=$4
	pwin=$5
	gout=$6
	gpay=$7
}
