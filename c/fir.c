
#include <iostream>
using namespace std;

#include <stdio.h>
#include <stdint.h>
#include <string.h>
 
//////////////////////////////////////////////////////////////
//  Filter Code Definitions
//////////////////////////////////////////////////////////////
 
// maximum number of inputs that can be handled
// in one function call
#define MAX_INPUT_LEN   80
// maximum length of filter than can be handled
#define MAX_FLT_LEN     63
// buffer to hold all of the input samples
#define BUFFER_LEN      (MAX_FLT_LEN - 1 + MAX_INPUT_LEN)
 
// array to hold input samples
double insamp[ BUFFER_LEN ];
 
// FIR init
void firFloatInit( void )
{
    memset( insamp, 0, sizeof( insamp ) );
}
 
// the FIR filter function
void firFloat( double *coeffs, double *input, double *output,
       int length, int filterLength )
{
    double acc;     // accumulator for MACs
    double *coeffp; // pointer to coefficients
    double *inputp; // pointer to input samples
    int n;
    int k;
 
    // put the new samples at the high end of the buffer
    memcpy( &insamp[filterLength - 1], input,
            length * sizeof(double) );
 
    // apply the filter to each input sample
    for ( n = 0; n < length; n++ ) {
        // calculate output n
        coeffp = coeffs;
        inputp = &insamp[filterLength - 1 + n];
        acc = 0;
        for ( k = 0; k < filterLength; k++ ) {
            acc += (*coeffp++) * (*inputp--);
        }
        output[n] = acc;
    }
    // shift input samples back in time for next time
    memmove( &insamp[0], &insamp[length],
            (filterLength - 1) * sizeof(double) );
 
}
  
#define FILTER_LEN  3
double coeffs[ FILTER_LEN ] =
{
  0.04,  0.05, 0.03
};

// number of samples to read per loop
#define SAMPLES   40
 
int main( void )
{
    int size;
    int16_t input[SAMPLES];
    int16_t output[SAMPLES];
    double floatInput[SAMPLES];
    double floatOutput[SAMPLES];
    FILE   *in_fid;
    FILE   *out_fid;
 
    // initialize the filter
    firFloatInit();
 
    size = 40;

    int i;
    for(i = 0; i < SAMPLES; i++)
    {
      floatInput[i] = i%16;
    }

    // perform the filtering
    firFloat( coeffs, floatInput, floatOutput, size,
           FILTER_LEN );
    for(i=0; i <SAMPLES; i++)
    {
      cout << floatOutput[i] << endl;
    }
 
    return 0;
}