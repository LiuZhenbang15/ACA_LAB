#include <stdio.h>

#define N_SAMPLES	25
#define N_COEFFS	3

double	sample[N_SAMPLES] = {1, 2, 1, 2, 1,6,23,1,43,45,6,7,89,28,98,6,13,43,56,78,9,67,13,24,19};
double	coeff[N_COEFFS]= {1.5,1.1,1.3};
double	result[N_SAMPLES];

void smooth(double sample[], double coeff[], double result[], int n)
{
	int i, j;
	double norm=0.0;
	
	norm+= Abs(coeff[0]);
	norm+= Abs(coeff[1]);
	norm+= Abs(coeff[2]);
	
	inter_norm = 1/norm;
	result[0] = sample[0];
	result[n-1] = sample[n-1];
	
	for (i=1; i<n-1; i++){
		result[i]=0.0;
		/* try to use different registers to decrease raws */
		/* the current implementation use many instruction between the multiplication to remove raws */
		result[i] += sample[i-1]*coeff[0];
		result[i] += sample[i]*coeff[1];
		result[i] += sample[i+1]*coeff[2];
		
		result[i]*=inter_norm;
	}
}

int main(int argc, char *arvg[])
{
	int i;

	if (N_SAMPLES>=N_COEFFS)
		smooth(sample, coeff, result, N_SAMPLES);

	for (i=0; i<N_SAMPLES; i++)
		printf("%f\n", result[i]);
}
