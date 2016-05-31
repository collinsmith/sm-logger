#if defined _util_param_testing_included
    #endinput
#endif
#define _util_param_testing_included

#include <functions>

#if defined TESTSUITE
  #include "../include/util/math.inc"
  #include "../include/util/strings.inc"
#else
  #include "include/util/math.inc"
  #include "include/util/strings.inc"
#endif

/*******************************************************************************
 * STOCKS
 ******************************************************************************/

stock bool Params_Equal(int expected, int actual) {
  return expected == actual;
}

stock bool Params_LessThan(int expected, int actual) {
  return actual < expected;
}

stock bool Params_LessEqual(int expected, int actual) {
  return actual <= expected;
}

stock bool Params_GreaterThan(int expected, int actual) {
  return expected < actual;
}

stock bool Params_GreaterEqual(int expected, int actual) {
  return expected <= actual;
}

stock void Params_ValidateEqual(int expected, int actual) {
  if (!Params_Equal(expected, actual)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Invalid number of params: Expected %d, actual %d",
        expected, actual);
  }
}

stock void Params_ValidateLessThan(int expected, int actual) {
  if (!Params_LessThan(expected, actual)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Invalid number of params: Expected less than %d, actual %d",
        expected, actual);
  }
}

stock void Params_ValidateLessEqual(int expected, int actual) {
  if (!Params_LessEqual(expected, actual)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Invalid number of params: Expected less than or equal to %d, \
         actual %d",
        expected, actual);
  }
}

stock void Params_ValidateGreaterThan(int expected, int actual) {
  if (!Params_GreaterThan(expected, actual)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Invalid number of params: Expected greater than %d, actual %d",
        expected, actual);
  }
}

stock void Params_ValidateGreaterEqual(int expected, int actual) {
  if (!Params_GreaterEqual(expected, actual)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Invalid number of params: Expected greater than or equal to %d, \
         actual %d",
        expected, actual);
  }
}

stock void Params_ValidateOneOf(int[] set, int sizeofSet, int actual) {
  int id = Array_FindValue(set, sizeof set, actual);
  if (id == -1) {
    char tmp[64];
    Array_IntsToString(tmp, sizeof tmp, set, sizeofSet);
    ThrowNativeError(SP_ERROR_NATIVE,
        "Invalid number of params: Expected one of %s, actual %d",
        tmp, actual);
  }
}

stock void Params_ValidateTrue(bool condition, const char[] message) {
  if (!condition) {
    ThrowNativeError(SP_ERROR_NATIVE, message);
  }
}

stock void Params_ValidateFalse(bool condition, const char[] message) {
  if (condition) {
    ThrowNativeError(SP_ERROR_NATIVE, message);
  }
}