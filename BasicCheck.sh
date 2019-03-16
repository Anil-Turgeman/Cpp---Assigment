#!/bin/bash
dirPath=$1
program=$2
arguments=${@:3}

cd $dirPath
make &> /dev/null
if [[ $? -gt 0 ]]; then
	firstANS=1
	exit 7
 else	# valgrind memory leak check
	 firstANS=0
	 
	 valgrind --tool=memcheck --leak-check=full --error-exitcode=3 -q ./$program $arguments &> /dev/null
	 if [[ $? -gt 0 ]] ; then
		 secondANS=1
	 	 else
		 secondANS=0
	 fi	# valgrind--helgrind thread race check
	 
	 valgrind --tool=helgrind --error-exitcode=3 -q ./$program $arguments &> /dev/null
	 if [[ $? -gt 0 ]]; then
		 thirdANS=1
	 else
		 thirdANS=0
	 fi

 fi	# binary ans request and print it in the end

 ANS=$firstANS$secondANS$thirdANS
 if [ $ANS == '000' ]; then
	 echo -e "Compilation   Memory leaks   Thread race\n    PASS         PASS           PASS"
	 exit 0;
fi
if [ $ANS == '010' ]; then
	echo -e "Compilation   Memory leaks   Thread race\n    PASS         FAIL           PASS"
	exit 2;
fi
if [ $ANS == '001' ]; then
	echo -e "Compilation   Memory leaks   Thread race\n    PASS         PASS           FAIL"
	exit 1;
fi

if [ $ANS == '011' ]; then
	echo -e "Compilation   Memory leaks   Thread race\n    PASS         FAIL           FAIL"
	exit 3;
 else
 echo -e "wrong program  - 111"
 exit 7;
 fi
