/*
 * This file is not available for use in any application other than as a
 * MATLAB(R) MEX file for use with the Simulink(R) product.
 */

/*
 * untitled_acc.c
 *
 * Real-Time Workshop code generation for Simulink model "untitled_acc.mdl".
 *
 * Model version              : 1.0
 * Real-Time Workshop version : 7.5  (R2010a)  25-Jan-2010
 * C source code generated on : Wed Oct 22 20:34:51 2014
 *
 * Target selection: accel.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: 32-bit Generic
 * Emulation hardware selection:
 *    Differs from embedded hardware (MATLAB Host)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */
#include <math.h>
#include "untitled_acc.h"
#include "untitled_acc_private.h"
#include <stdio.h>
#include "simstruc.h"
#include "fixedpoint.h"
#define CodeFormat                     S-Function
#define AccDefine1                     Accelerator_S-Function

/* Outputs for root system: '<Root>' */
static void mdlOutputs(SimStruct *S, int_T tid)
{
  /* local block i/o variables */
  real_T B_0_0_0;

  /* Clock: '<S1>/Clock1' */
  B_0_0_0 = ssGetT(S);
  if (ssIsSampleHit(S, 1, 0)) {
    ((BlockIO *) _ssGetBlockIO(S))->B_0_4_0 = ((Parameters *) ssGetDefaultParam
      (S))->P_0 / ((Parameters *) ssGetDefaultParam(S))->P_1 * ((Parameters *)
      ssGetDefaultParam(S))->P_2;
  }

  if (ssIsSampleHit(S, 1, 0)) {
    ((BlockIO *) _ssGetBlockIO(S))->B_0_6_0 = ((Parameters *) ssGetDefaultParam
      (S))->P_3;
  }

  ((BlockIO *) _ssGetBlockIO(S))->B_0_9_0 = muDoubleScalarSin((B_0_0_0 *
    ((BlockIO *) _ssGetBlockIO(S))->B_0_4_0 + ((BlockIO *) _ssGetBlockIO(S))
    ->B_0_6_0) * B_0_0_0);

  /* Scope: '<Root>/Scope' */

  /* Call into Simulink for Scope */
  ssCallAccelRunBlock(S, 0, 10, SS_CALL_MDL_OUTPUTS);

  /* tid is required for a uniform function interface.
   * Argument tid is not used in the function. */
  UNUSED_PARAMETER(tid);
}

/* Update for root system: '<Root>' */
#define MDL_UPDATE

static void mdlUpdate(SimStruct *S, int_T tid)
{
  /* tid is required for a uniform function interface.
   * Argument tid is not used in the function. */
  UNUSED_PARAMETER(tid);
}

/* Function to initialize sizes */
static void mdlInitializeSizes(SimStruct *S)
{
  /* checksum */
  ssSetChecksumVal(S, 0, 2198617575U);
  ssSetChecksumVal(S, 1, 3640781038U);
  ssSetChecksumVal(S, 2, 1004574556U);
  ssSetChecksumVal(S, 3, 883120106U);

  /* options */
  ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

  /* Accelerator check memory map size match for DWork */
  if (ssGetSizeofDWork(S) != sizeof(D_Work)) {
    ssSetErrorStatus(S,"Unexpected error: Internal DWork sizes do "
                     "not match for accelerator mex file.");
  }

  /* Accelerator check memory map size match for BlockIO */
  if (ssGetSizeofGlobalBlockIO(S) != sizeof(BlockIO)) {
    ssSetErrorStatus(S,"Unexpected error: Internal BlockIO sizes do "
                     "not match for accelerator mex file.");
  }

  /* model parameters */
  _ssSetDefaultParam(S, (real_T *) &rtDefaultParameters);
}

/* mdlInitializeSampleTimes function (used to set up function-call connections) */
static void mdlInitializeSampleTimes(SimStruct *S)
{
}

/* Empty mdlTerminate function (never called) */
static void mdlTerminate(SimStruct *S)
{
}

/* MATLAB MEX Glue */
#include "simulink.c"
