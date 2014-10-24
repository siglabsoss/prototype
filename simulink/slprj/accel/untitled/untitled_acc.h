/*
 * untitled_acc.h
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
#ifndef RTW_HEADER_untitled_acc_h_
#define RTW_HEADER_untitled_acc_h_
#ifndef untitled_acc_COMMON_INCLUDES_
# define untitled_acc_COMMON_INCLUDES_
#include <stdlib.h>
#include <stddef.h>
#define S_FUNCTION_NAME                simulink_only_sfcn
#define S_FUNCTION_LEVEL               2
#define RTW_GENERATED_S_FUNCTION
#include "rtwtypes.h"
#include "simstruc.h"
#include "fixedpoint.h"
#include "mwmathutil.h"
#endif                                 /* untitled_acc_COMMON_INCLUDES_ */

#include "untitled_acc_types.h"

/* Block signals (auto storage) */
typedef struct {
  real_T B_0_4_0;                      /* '<S1>/Gain' */
  real_T B_0_6_0;                      /* '<S1>/initialFreq' */
  real_T B_0_9_0;                      /* '<S1>/Output' */
} BlockIO;

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  struct {
    void *LoggedData;
  } Scope_PWORK;                       /* '<Root>/Scope' */
} D_Work;

/* Parameters (auto storage) */
struct Parameters_ {
  real_T P_0;                          /* Expression: 2*pi*(f2-f1)
                                        * Referenced by: '<S1>/deltaFreq'
                                        */
  real_T P_1;                          /* Expression: T
                                        * Referenced by: '<S1>/targetTime'
                                        */
  real_T P_2;                          /* Expression: 0.5
                                        * Referenced by: '<S1>/Gain'
                                        */
  real_T P_3;                          /* Expression: 2*pi*f1
                                        * Referenced by: '<S1>/initialFreq'
                                        */
};

extern Parameters rtDefaultParameters; /* parameters */

#endif                                 /* RTW_HEADER_untitled_acc_h_ */
