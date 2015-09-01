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
#define MAX_INPUT_LEN   40
// maximum length of filter than can be handled
#define MAX_FLT_LEN     3
// buffer to hold all of the input samples
#define BUFFER_LEN      (MAX_FLT_LEN - 1 + MAX_INPUT_LEN)
 
// array to hold input samples
int16_t insamp[ BUFFER_LEN ];
 
// FIR init
void firFixedInit( void )
{
    memset( insamp, 0, sizeof( insamp ) );
}
 
// the FIR filter function
void firFixed( int16_t *coeffs, int16_t *input, int16_t *output,
       int length, int filterLength )
{
    int32_t acc;     // accumulator for MACs
    int16_t *coeffp; // pointer to coefficients
    int16_t *inputp; // pointer to input samples
    int n;
    int k;
 
    // put the new samples at the high end of the buffer
    memcpy( &insamp[filterLength - 1], input,
            length * sizeof(int16_t) );
 
    // apply the filter to each input sample
    for ( n = 0; n < length; n++ ) {
        // calculate output n
        coeffp = coeffs;
        inputp = &insamp[filterLength - 1 + n];
        // load rounding constant
        acc = 1 << 14;
        // perform the multiply-accumulate
        for ( k = 0; k < filterLength; k++ ) {
            acc += (int32_t)(*coeffp++) * (int32_t)(*inputp--);
        }
        // saturate the result
        if ( acc > 0x3fffffff ) {
            acc = 0x3fffffff;
        } else if ( acc < -0x40000000 ) {
            acc = -0x40000000;
        }
        // convert from Q30 to Q15
        output[n] = (int16_t)(acc >> 15);
    }
 
    // shift input samples back in time for next time
    memmove( &insamp[0], &insamp[length],
            (filterLength - 1) * sizeof(int16_t) );
 
}
 
//////////////////////////////////////////////////////////////
//  Test program
//////////////////////////////////////////////////////////////
 
// bandpass filter centred around 1000 Hz
// sampling rate = 8000 Hz
// gain at 1000 Hz is about 1.13

#define FLOAT_SCALE (32768)

#define FILTER_LEN  3
int16_t coeffs[ FILTER_LEN ] =
{
 1311, 1638, 983
};
 
// number of samples to read per loop
#define SAMPLES   40
 
int main( void )
{
    int size;
    int16_t input[SAMPLES];
    int16_t output[SAMPLES];
    FILE   *in_fid;
    FILE   *out_fid;
 
    // initialize the filter
    firFixedInit();

    size = 40;

    int i;
    double f;
    for(i = 0; i < SAMPLES; i++)
    {
        f = (i%16) / 16.0;
        input[i] = (f * 32768) + 0.5; // float round method
    }

 
   
    // perform the filtering
    firFixed( coeffs, input, output, size, FILTER_LEN );
   
    for(i=0; i <SAMPLES; i++)
    {
      cout << output[i] << endl;
    }
 
    return 0;
}