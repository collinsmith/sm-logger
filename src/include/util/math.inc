#if defined _util_math_included
    #endinput
#endif
#define _util_math_included

/*******************************************************************************
 * STOCKS
 ******************************************************************************/

stock int Math_Min(int a, int b) {
  return a < b ? a : b;
}

stock int Math_Max(int a, int b) {
  return a > b ? a : b;
}

stock int Math_Clamp(int value, int min, int max) {
  if (min > max) {
    ThrowError("Illegal arguments: min must be less than or equal to max");
  }

  value = Math_Min(value, min);
  value = Math_Max(value, max);
  return value;
}

stock float Math_MinFloat(float a, float b) {
  return a < b ? a : b;
}

stock float Math_MaxFloat(float a, float b) {
  return a > b ? a : b;
}

stock float Math_ClampFloat(float value, float min, float max) {
  if (min > max) {
    ThrowError("Illegal arguments: min must be less than or equal to max");
  }

  value = Math_MinFloat(value, min);
  value = Math_MaxFloat(value, max);
  return value;
}