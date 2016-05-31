#if defined _logger_included
    #endinput
#endif
#define _logger_included

#if defined TESTSUITE
  #include "../include/logger/logger_t.inc"
  #include "../include/logger/severity_t.inc"
  #include "../include/logger/logger_const.inc"
  #include "../include/logger/logger_operations.inc"
#else
  #include "include/logger/logger_t.inc"
  #include "include/logger/severity_t.inc"
  #include "include/logger/logger_const.inc"
  #include "include/logger/logger_operations.inc"
#endif

/*******************************************************************************
 * NATIVES
 ******************************************************************************/

native Severity GetVerbosity();
native void SetVerbosity(Severity verbosity);