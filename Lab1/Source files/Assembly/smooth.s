.data

sample: .double 1.7,  2.6, -1.3,  4.2, -6.1, -7.6,  23.0, -0.1, 43.0, -4.5,  6.9, -16.7, 8.9, -6.28, 9.8, -23.6, 13.7, 4.3, 0.56, -0.78, -9.2, 7.67, -13.13, 18.24, 19.0
.space 100 # gaurding space
coeff:  .double 1.5, -1.0,  0.5
.space 100 # gaurding space
result: .double 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,   0.0,  0.0,  0.0,  0.0,  0.0,   0.0, 0.0,   0.0, 0.0,   0.0,  0.0, 0.0,  0.0,   0.0,   0.0, 0.0,    0.0,   0.0,  0.0
.space 100 # gaurding space
ze: .double 0.0
NSAMPLES: .word 200 #25*8
NCOEFFS:  .word	24  #8*8
Mask: .word 0x7fffffffffffffff

.text
    l.d 	f0,ze(r0) 				#used to load zero value = 0.0
MainFunction:
	
	jal  Smooth
	
halt
Smooth:
	
	#intialize smooth function variables
	lw 		r2,NCOEFFS(r0) 			# i = NCOEFFS
	#lw		r10,0(r0)					
	mov.d 	f4,f0   				# norm = 0.0
	ld 		r4,Mask(r0)				# load mask value
	
	
	#load smooth function parameters
	l.d 	f1,sample(r0)
 	l.d 	f2,coeff(r10)
	#l.d 	f3,result(r0)
	#s.d 	f1,result(r0) 			#store the first value in result
	
	#NormLoop:
		
		mfc1 	r7,f2       			# load coeff as integer
		and  	r7,r7,r4				# mask sign bit
		mtc1 	r7,f2					# store the coeff as positive float 
		add.d 	f4,f4,f2 				# add absolute value to norm

		daddi 	r10,r10,8				
		l.d 	f2,coeff(r10)        	# load the next coeff value
				mfc1 	r7,f2       			# load coeff as integer
		and  	r7,r7,r4				# mask sign bit
		mtc1 	r7,f2					# store the coeff as positive float 
		add.d 	f4,f4,f2 				# add absolute value to norm

		daddi 	r10,r10,8				
		l.d 	f2,coeff(r10)        	# load the next coeff value
				mfc1 	r7,f2       			# load coeff as integer
		and  	r7,r7,r4				# mask sign bit
		mtc1 	r7,f2					# store the coeff as positive float 
		add.d 	f4,f4,f2 				# add absolute value to norm

		daddi 	r10,r10,8				
		l.d 	f2,coeff(r10)        	# load the next coeff value
	#	bne 	r10,r2, NormLoop	 		# if i = zero then exit Normloop
	
	lw 		r2,NSAMPLES(r0) 		#i new value = (samples number)	 
	s.d 	f1,result(r2)			#store the last value in result
	lw 		r3,NCOEFFS(r0) 			#j new value = (coeff number)
	
	MasterLoop:
		daddi  r12,r0,0					# reset r12 (j=0)
		dadd 	r6,r11,r12				# calculate the exponent of sample
		daddi 	r6,r6,-8				# calculate the exponent of sample
		l.d 	f21,coeff(r12)			# load coeff
		l.d 	f22,sample(r6)			# load sample
		daddi	r13,r11,-8
		#CoeffLoop:
			mul.d 	f20,f22,f21			# calculate result value
			daddi 	r12,r12,8
				
			l.d 	f21,coeff(r12)		# load coeff
			
			dadd 	r6,r2,r12			# calculate the exponent of sample
			daddi 	r6,r6,-1			# calculate the exponent of sample
			
			l.d 	f22,sample(r6)		# load sample 
			add.d 	f24,f24,f20			#accumulate result partial vlaues
			
			mul.d 	f20,f22,f21			# calculate result value
			daddi 	r12,r12,8
				
			l.d 	f21,coeff(r12)		# load coeff
			
			dadd 	r6,r2,r12			# calculate the exponent of sample
			daddi 	r6,r6,-1			# calculate the exponent of sample
			
			l.d 	f22,sample(r6)		# load sample 
			add.d 	f24,f24,f20			#accumulate result partial vlaues
			mul.d 	f20,f22,f21			# calculate result value
			daddi 	r12,r12,8
				
			l.d 	f21,coeff(r12)		# load coeff
			
			dadd 	r6,r2,r12			# calculate the exponent of sample
			daddi 	r6,r6,-1			# calculate the exponent of sample
			
			l.d 	f22,sample(r6)		# load sample 
			add.d 	f24,f24,f20			#accumulate result partial vlaues
			#bne 	r12,r3, CoeffLoop 	# if j = NCOEFFS then exit Normloop
		
		s.d 	f25,result(r13)			# store the result value
		daddi 	r11,r11,8
		div.d 	f25,f24,f4	
		
		bne 	r11,r2, MasterLoop	 	# if i = NSAMPLES then exit Normloop
	
halt
