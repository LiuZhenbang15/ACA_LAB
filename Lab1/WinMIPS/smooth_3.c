#include <stdio.h>

#define N_SAMPLES	25
#define N_COEFFS	7

double	sample[N_SAMPLES] = {1, 2, 1, 2, 1,6,23,1,43,45,6,7,89,28,98,6,13,43,56,78,9,67,13,24,19};
double	coeff[N_COEFFS]= {1.5, 1, 0.5,0.3,0.7,1.1,1.3};
double	result[N_SAMPLES];

void smooth(double sample[], double coeff[], double result[], int n)
{
	int i, j;
	double norm=0.0;
	double products[N_COEFFS][n];
	/*
	for (i=0; i<N_COEFFS; i++)
	{
		norm+= coeff[i]>0 ? coeff[i] : -coeff[i];
	}
	*/
	for (j=0; j<N_COEFFS; j++)
	{
		norm+= coeff[j]>0 ? coeff[j] : -coeff[j];
		for (i=1; i<n-1; i++){
			products[j][i] = coeff[j] * sample[i];
		}
	}
	result[0] = sample[0];
	result[n-1] = sample[n-1];
	/*
	for (i=1; i<n-1; i++){
		result[i]=0.0;
		for (j=0; j<N_COEFFS; j++)
		{
			result[i] += sample[i-1+j]*coeff[j];
		}
		result[i]/=norm;
	}
	*/
	for (i=1; i<n-1; i++){
		result[i]=0.0;
		for (j=0; j<N_COEFFS; j++)
		{
			result[i] += products[j][i] ;
		}
		result[i]/=norm;
		
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
