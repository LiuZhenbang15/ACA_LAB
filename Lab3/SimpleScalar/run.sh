#directory checks
# check if result folder exist
	if [ -d "../SimpleScalar/results" ]; then 
		echo result folder exist ;
		rm -r "../SimpleScalar/results" 
		echo result folder deleted ;
		mkdir  "../SimpleScalar/results" 
		echo result folder created ;
	else 
		echo result folder does not exist ;
		mkdir  "../SimpleScalar/results" 
		echo result folder created ;
	fi

## declare arrays for parameters
	# bench marks files names
	declare -a bench=("fibonacci" "matmul" "memcopy" "whetstone" "pi")
	# question num
	declare -a Qnum=("Q1" "Q2" "Q3" "Q5")
	# branching values
	# taken is excluded
	declare -a Q1Param1=("nottaken" "perfect" "bimod" "2lev" "comb")
	# in/out of order
	declare -a Q2Param1=("true" "false")
	#resources values
	declare -a Q2Param2=("1" "2" "4" "8")
	#ruu
	declare -a Q3Param1=("16" "32" "32" "64" "64")
	#lsq
	declare -a Q3Param2=("8" "8" "16" "16" "32")

## now loop through the above arrays
for i in "${Qnum[@]}"
do
	if [ $i == "Q1" ]; then 
		echo $i start execute ; 
		for j in "${Q1Param1[@]}"
		do
			for k in "${bench[@]}"
			do
# single issue, in-order execution. one integer and floating point alu and mult unit. 2 memport.
				./sim-outorder -fetch:ifqsize 1 -decode:width 1 -issue:width 1 -commit:width 1 -issue:inorder true -res:memport 2 -res:ialu 1 -res:imult 1 -res:fpalu 1 -res:fpmult 1 -bpred $j -redir:sim ../SimpleScalar/results/$i-$j-$k.result ../SimpleScalar/benchmarks/$k
			done
		done
	fi
	
	if [ $i == "Q2" ]; then 
		echo $i start execute ; 
		for j in "${Q2Param1[@]}"
		do
			for h in "${Q2Param2[@]}"
			do
				for k in "${bench[@]}"
				do
# increasing the fetch, decode, issue, commit width and the number of resources using param h. 2lev branching. memport =2 (default)
					./sim-outorder -fetch:ifqsize $h -decode:width $h -issue:width $h -commit:width $h -issue:inorder $j -res:memport 2 -res:ialu $h -res:imult $h -res:fpalu $h -res:fpmult $h -bpred 2lev -redir:sim ../SimpleScalar/results/$i-inorder-$j-$h-$k.result ../SimpleScalar/benchmarks/$k
				done
			done
		done
		for j in "${Q2Param1[@]}"
		do
			for k in "${bench[@]}"
			do
# run Q2 default resources --> width of 8, 4 ialu, 1 imult, 4 fpalu, 1 imult.
				./sim-outorder -fetch:ifqsize 8 -decode:width 8 -issue:width 8 -commit:width 8 -issue:inorder $j -res:memport 2 -res:ialu 4 -res:imult 1 -res:fpalu 4 -res:fpmult 1 -bpred 2lev -redir:sim ../SimpleScalar/results/$i-inorder-$j-default-$k.result ../SimpleScalar/benchmarks/$k
			done
		done
                
	fi

	if [ $i == "Q3" ]; then 
		echo $i start execute ; 
# normal resources
		for j in {0..4};
		do
			for k in "${bench[@]}"
			do
# width = 8 , inorder = false, branching = 2lev, memport =2
				./sim-outorder -fetch:ifqsize 8 -decode:width 8 -issue:width 8 -commit:width 8 -issue:inorder false -res:memport 2 -res:ialu 4 -res:imult 1 -res:fpalu 4 -res:fpmult 1 -bpred 2lev -ruu:size "${Q3Param1[$j]}" -lsq:size "${Q3Param2[$j]}" -redir:sim ../SimpleScalar/results/$i-ruu-"${Q3Param1[$j]}"-lsq-"${Q3Param2[$j]}"-$k.result ../SimpleScalar/benchmarks/$k
			done
		done
# double resources
		for j in {0..4};
		do
			for k in "${bench[@]}"
			do
# width = 8 , inorder = false, branching = 2lev, memport =2
				./sim-outorder -fetch:ifqsize 8 -decode:width 8 -issue:width 8 -commit:width 8 -issue:inorder false -res:memport 2 -res:ialu 8 -res:imult 2 -res:fpalu 8 -res:fpmult 2 -bpred 2lev -ruu:size "${Q3Param1[$j]}" -lsq:size "${Q3Param2[$j]}" -redir:sim ../SimpleScalar/results/$i-ruu-"${Q3Param1[$j]}"-lsq-"${Q3Param2[$j]}"-$k.result ../SimpleScalar/benchmarks/$k
			done
		done		
	fi

done

#extract results
cd results
grep IPC -H *.result | cut -d "#" -f1 > reults.csv


