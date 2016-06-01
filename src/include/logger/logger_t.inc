#if defined _logger_t_included
    #endinput
#endif
#define _logger_t_included

#if defined TESTSUITE
  #include "../include/logger/severity_t.inc"
#else
  #include "include/logger/severity_t.inc"
#endif

enum Logger {

  All_Loggers = -1,
  No_Logger = 0,
  Invalid_Logger = No_Logger

};

methodmap Logger < Handle {
  
  public native Logger(
      const Severity verbosity = Severity_Warn,
      const char[] nameFormat  = "%p_%d",
      const char[] msgFormat   = "[%5v] [%t] %n::%f - %s",
      const char[] dateFormat  = "%Y-%m-%d",
      const char[] timeFormat  = "%H:%M:%S",
      const char[] pathFormat  = "",
      const char[] traceFormat = "    at %n::%f : %l");

  public native bool IsLogging();

  public native Severity GetVerbosity();
  public native void SetVerbosity(Severity verbosity);

  public native void GetNameFormat(char[] dst, int len);
  public native void SetNameFormat(const char[] nameFormat);

  public native void GetMessageFormat(char[] dst, int len);
  public native void SetMessageFormat(const char[] msgFormat);

  public native void GetDateFormat(char[] dst, int len);
  public native void SetDateFormat(const char[] dateFormat);

  public native void GetTimeFormat(char[] dst, int len);
  public native void SetTimeFormat(const char[] timeFormat);

  public native void GetPathFormat(char[] dst, int len);
  public native void SetPathFormat(const char[] pathFormat);

  public native void GetTraceFormat(char[] dst, int len);
  public native void SetTraceFormat(const char[] traceFormat);

  public native void Log(Severity severity, const char[] format, any ...);
  
};