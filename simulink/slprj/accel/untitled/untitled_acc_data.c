/*
 * untitled_acc_data.c
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

#include "untitled_acc.h"
#include "untitled_acc_private.h"

/* Block parameters (auto storage) */
Parameters rtDefaultParameters = {
  5.6548667764616276E+000,             /* Expression: 2*pi*(f2-f1)
                                        * Referenced by: '<S1>/deltaFreq'
                                        */
  100.0,                               /* Expression: T
                                        * Referenced by: '<S1>/targetTime'
                                        */
  0.5,                                 /* Expression: 0.5
                                        * Referenced by: '<S1>/Gain'
                                        */
  6.2831853071795862E-001              /* Expression: 2*pi*f1
                                        * Referenced by: '<S1>/initialFreq'
                                        */
};
