#/bin/sh
export PERL5LIB=~/nsip/sif-rest-perl/lib:~/nsip/sif-xml-parse-perl/lib
echo $PERL5LIB
perl bin/app.pl --environment=scott
