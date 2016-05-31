#if defined _logger_included
    #endinput
#endif
#define _logger_included

#if defined TESTSUITE
  #include "../include/logger/logger_t.inc"
  #include "../include/logger/severity_t.inc"
  #include "../include/logger/logger_const.inc"
#else
  #include "include/logger/logger_t.inc"
  #include "include/logger/severity_t.inc"
  #include "include/logger/logger_const.inc"
#endif

/*******************************************************************************
 * NATIVES
 ******************************************************************************/
