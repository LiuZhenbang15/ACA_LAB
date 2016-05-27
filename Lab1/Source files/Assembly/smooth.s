.data
NCOEFFS: .word 3
coeff: .double 0.5 , 1.0 , 0.5
NSAMPLES: .word 5
sample: .double 1.0,2.0,1.0,2.0,1.0
result: .double  0.0, 0.0, 0.0, 0.0, 0.0

ze: .double 0.0
onef: .double 1
Mask: .word 0x7fffffffffffffff

#All reg zero at start, number of coeffs always 3

.text
	lw 		r2,NSAMPLES(r0) 			# i new value = (samples number)
	ld 		r4,Mask(r0)					# load mask value
	daddi	r2,r2,-1					# n-1
	daddi 	r5,r0,8						# setup reg with value 8
	dmul	r2,r2,r5	 				# Account for double size 
	


	#Calc norm val for 3 coeffs and setup first and last result
	#coeff  0 = f5, 1 = f6, 2 = f7
	
		l.d 	f5,coeff(r10)			# load the first coeff value #### what the content of r10 is it zero??
		daddi 	r10,r10,8				# increment the coeff address
		mfc1 	r7,f5       			# load coeff as integer
		and  	r7,r7,r4				# mask sign bit
		mtc1 	r7,f5					# store the coeff as positive float 
		add.d 	f4,f4,f5 				# add absolute value to norm
				
		l.d 	f6,coeff(r10)        	# load the next coeff value
		daddi 	r10,r10,8				# increment the coeff address
		mfc1 	r7,f6       			# load coeff as integer	
		and  	r7,r7,r4				# mask sign bit
		l.d 	f11,onef(r0) 			# used to load one value = 1.0 
		mtc1 	r7,f6					# store the coeff as positive float 
		add.d 	f4,f4,f6 				# add absolute value to norm

		l.d 	f7,coeff(r10)        	# load the next coeff value
		mfc1 	r7,f7       			# load coeff as integer
		and  	r7,r7,r4				# mask sign bit
		mtc1 	r7,f7					# store the coeff as positive float 
		add.d 	f4,f4,f7 				# add absolute value to norm

		div.d 	f12,f11,f4				# inverse norm
		l.d		f8,sample(r2)			# load the last sample value
		#s.d 	f1,result(r0)			# store the first value in result
		l.d 	f1,sample(r0)			# load the first sample
		s.d		f8,result(r2)			# store the n-1 value in result
		
	# f24 --> final result 
	# f22 --> First sample,  f20 --> first multiply result 
	# f25 --> second sample, f21 --> second multiply result 
	# f26 --> third sample,  f23 --> second multiply result 
	
	# r5 --> loop counter (i), r6 --> i-1
	
	MasterLoop:
			
			add.d 	f24,f24,f23			# accumulate result third partial values
			l.d 	f22,sample(r6)		# load sample
			mul.d 	f20,f22,f5			# calculate result value
			
			l.d 	f25,sample(r5)		# load sample
			mul.d 	f24,f24,f12			# normalize
			daddi 	r5,r5,8				# i + 1
			mul.d 	f21,f25,f6			# calculate result value
			s.d 	f24,result(r6)		# store the total result value
			l.d 	f26,sample(r5)		# load sample 
			add.d 	f24,f0,f20			# accumulate result first partial vlaues
			mul.d 	f23,f26,f7			# calculate result value			
			add.d 	f24,f24,f21			# accumulate result second partial values
			
			#daddi 	r6,r5,-8			# (i-1) + 1
			
		bne 	r5,r2, MasterLoop	 	# if i = NSAMPLES then exit Normloop
		#s.d 	f24,result(r6)			# store the result value
		daddi 	r6,r5,-8				# (i-1) + 1
		
		add.d 	f24,f24,f23				# accumulate result third partial values
		s.d 	f1,result(r0)			# store the first value in result
		mul.d 	f24,f24,f12				# normalize
		s.d 	f24,result(r6)			# store the result value
		
halt
