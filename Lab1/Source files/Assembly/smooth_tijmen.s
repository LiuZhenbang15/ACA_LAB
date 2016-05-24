.data
NCOEFFS: .word 3
coeff:  .double 1.5, -1.0,  0.5
NSAMPLES: .word 25
sample: .double 1.7,  2.6, -1.3,  4.2, -6.1, -7.6,  23.0, -0.1, 43.0, -4.5,  6.9, -16.7, 8.9, -6.28, 9.8, -23.6, 13.7, 4.3, 0.56, -0.78, -9.2, 7.67, -13.13, 18.24, 19.0
result: .double 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,   0.0,  0.0,  0.0,  0.0,  0.0,   0.0, 0.0,   0.0, 0.0,   0.0,  0.0, 0.0,  0.0,   0.0,   0.0, 0.0,    0.0,   0.0,  0.0
ze: .double 0.0
onei: .word 1
onef: .double 1
Mask: .word 0x7fffffffffffffff

#All reg zero at start, number of coeffs always 3

.text
	lw 		r2,NSAMPLES(r0) 		#i new value = (samples number)
	daddi		r2,r2,-1			#n-1
	daddi 		r5,r0,8				#setup reg with value 8
	dmul		r2,r2,r5	 		#Account for double size
	ld 		r4,Mask(r0)				# load mask value


	#Calc norm val for 3 coeffs and setup first and last result
		l.d 	f5,coeff(r10)	
		l.d 	f1,sample(r0)
		c.lt.d 	f5,f0
		daddi 	r14,r10,8
		mfc1 	r7,f5       			# load coeff as integer
		and  	r7,r7,r4				# mask sign bit
		lw	r1,onei(r0) 				# setup int reg with value 1
		mtc1 	r7,f2					# store the coeff as positive float 
		add.d 	f4,f4,f2 				# add absolute value to norm

				
		l.d 	f6,coeff(r10)        	# load the next coeff value
		l.d	f8,sample(r2)
		s.d 	f1,result(r0)			#store the first value in result
		daddi 	r10,r10,8	
		mfc1 	r7,f6       			# load coeff as integer
		l.d 	f11,onef(r0) 				#used to load zero value = 0.0				
		and  	r7,r7,r4				# mask sign bit
		mtc1 	r7,f2					# store the coeff as positive float 
		add.d 	f4,f4,f2 				# add absolute value to norm

		l.d 	f7,coeff(r10)        	# load the next coeff value
		s.d	f8,result(r2)			#store the n-1 value in result
		daddi	r11,r1,7
		mfc1 	r7,f7       			# load coeff as integer
		and  	r7,r7,r4				# mask sign bit
		mtc1 	r7,f2					# store the coeff as positive float 
		add.d 	f4,f4,f2 				# add absolute value to norm
		div.d 	f12,f11,f4				#inverse norm

		#coeff  0 = f5, 2 = f6, 3 = f7
	MasterLoop:
			l.d 	f22,sample(r6)			# load sample

			mul.d 	f20,f22,f5			# calculate result value
			mov.d 	f24,f0   				# norm = 0.0	
			l.d 	f22,sample(r11)		# load sample 

			mul.d 	f21,f22,f6			# calculate result value
			daddi 	r11,r11,8	
			add.d 	f24,f24,f20			#accumulate result partial vlaues
			l.d 	f22,sample(r11)		# load sample 
			add.d 	f24,f24,f21			#accumulate result partial values
			mul.d 	f23,f22,f7			# calculate result value

			add.d 	f24,f24,f23			#accumulate result partial values

			mul.d 	f24,f24,f12			# normalize
			daddi 	r6,r11,-8
		bne 	r11,r2, MasterLoop	 	# if i = NSAMPLES then exit Normloop
		s.d 	f24,result(r6)			# store the result value

	
halt
