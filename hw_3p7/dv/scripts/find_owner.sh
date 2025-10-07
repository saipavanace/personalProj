
#!/bin/bash
path=$1

a="DCE SCB"
b="ADDR MGR"
c="HBFAIL"
d="NCBU3 SCB ERROR"
ace="ACE CACHE MODEL"

chi="CHIRAG"
abh="ABHINAV"
sat="SATYA"
sug="SUGUN"
dav="DAVID"
muf="MUFFADAL"
bha="BHAVYA"

if [[ -n $( find $path -name "regr.log" | xargs grep -e "$b" -e "$a" ) ]]
then
    printf "\n$abh is responsible for\n" 
    find $path -name "regr.log" | xargs grep -e "$b" -e "$a" | awk '{ $2 = "";$1 = ""; print }'
fi

if [[ -n $( find $path -name "regr.log" | xargs grep -e "$ace" ) ]]
then
    printf "\n$sat is responsible for\n"
    find $path -name "regr.log" | xargs grep -e "$ace"  | awk '{ $2 = "";$1 = ""; print }' 
fi

if [[ -n $( find $path -name "regr.log" | xargs grep -e "$c" ) ]]
then
    printf "\n$chi is responsible for\n"
    find $path -name "regr.log" | xargs grep -e "$c"  | awk '{ $2 = "";$1 = ""; print }'  
fi

if [[ -n $( find $path -name "regr.log" | xargs grep -e "$d" ) ]]
then
    printf "\n$muf is responsible for\n"
    find $path -name "*regr.log" | xargs grep -e "$d"  | awk '{ $2 = "";$1 = ""; print }'
fi


