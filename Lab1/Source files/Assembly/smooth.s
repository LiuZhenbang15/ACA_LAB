.data

sample: .double 1.7, 2.6, -1.3, 4.2, -6.1,-7.6,23,-0.1,43,-4.5,6.9,-16.7,8.9,-6.28,9.8,-23.6,13.7,4.3,0.56,-0.78,-9.2,7.67,-16.13,18.24,19
coeff: .double 1.5, -1, 0.5,-0.3,-0.7,1.1,-1.3
result: .double 0.0, 0.0, 0.0, 0.0, 0.0
ze: .double 0.0
NSAMPLES: .word 200 #25*8
NCOEFFS: .word	56  #7*8

.text
    l.d f0,ze(r0) #used to load zero value = 0.0
Smooth:
	
	#intialize smooth function variables
	lw r2,NCOEFFS(r0) 
	mov.d f4,f0   #norm = 0.0
	#lw r2,0(r0)  #i=0
	#lw r3,0(r0)  #j=0
	
	#load smooth function parameters
	l.d f1,sample(r0)
#	l.d f2,coeff(r0)
	l.d f3,result(r0)

	NormLoop:
		
		beqz r2, NormLoopExit 		# if i>=NCOEFFS then exit Normloop
		
#abs.d f4,f4		#if used can can optmize the code as it will remove the branch below

			c.lt.d f2,f0      		# determine if coeff value is less than zero 
			bc1t NormSub	  		# the condition is satisfied so branch to then statment 
			add.d f4,f4,f2	  		# add positive coeff to norm value (else statment)
			j NormExit		  		# jump to the end of if statment to not excute then statment
			NormSub:
				sub.d f4,f4,f2	  	# subtarct negative coeff from norm value (then statment)
			NormExit:

		daddi r2,r2,-8
		l.d f2,coeff(r2)        	#load the next coeff value
		j NormLoop
	NormLoopExit:
	
	
	
	halt