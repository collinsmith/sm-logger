#include <sourcemod>

#include "include/util/params.inc"

#include "include/logger/logger_t.inc"
#include "include/logger/severity_t.inc"
#include "include/logger/logger_const.inc"
#include "include/logger/logger_operations.inc"

public Plugin pluginInfo = {
    name = "logger",
    author = "Tirant",
    description = "Creates and handles loggers",
    version = "0.0.1",
    url = "http://www.sourcemod.net/"
};

enum LoggerData {

  Severity: LoggerData_verbosity,
  String: LoggerData_nameFormat[64],
  String: LoggerData_msgFormat[64],
  String: LoggerData_dateFormat[32],
  String: LoggerData_timeFormat[32],
  String: LoggerData_pathFormat[PLATFORM_MAX_PATH]

};

static data[LoggerData];
static Logger g_cachedLogger = null;
static ArrayList g_aLoggers = null;

public APLRes AskPluginLoad2(Handle h, bool isLate, char[] err, int errLen) {
  CreateNatives();
  return APLRes_Success;
}

void CreateNatives() {
  CreateNative("Logger.Logger", Native_CreateLogger);

  CreateNative("Logger.GetVerbosity", Native_GetVerbosity);
  CreateNative("Logger.SetVerbosity", Native_SetVerbosity);

  CreateNative("Logger.GetNameFormat", Native_GetNameFormat);
  CreateNative("Logger.SetNameFormat", Native_SetNameFormat);

  CreateNative("Logger.GetMessageFormat", Native_GetMessageFormat);
  CreateNative("Logger.SetMessageFormat", Native_SetMessageFormat);

  CreateNative("Logger.GetDateFormat", Native_GetDateFormat);
  CreateNative("Logger.SetDateFormat", Native_SetDateFormat);

  CreateNative("Logger.GetTimeFormat", Native_GetTimeFormat);
  CreateNative("Logger.SetTimeFormat", Native_SetTimeFormat);

  CreateNative("Logger.GetPathFormat", Native_GetPathFormat);
  CreateNative("Logger.SetPathFormat", Native_SetPathFormat);

  CreateNative("Logger.Log", Native_Log);
}
public void OnPluginStart() {
    //...
}

public void OnPluginEnd() {
    //...
}

void loadLogger(Logger logger) {
  if (g_cachedLogger == logger) {
    return;
  }

  g_cachedLogger = logger;
  g_aLoggers.GetArray(loggerToIndex(g_cachedLogger), data[0]);
}

void commitLogger() {
  g_aLoggers.SetArray(loggerToIndex(g_cachedLogger), data[0]);
}

bool isValidLogger(any i) {
  return 1 <= i && i <= g_aLoggers.Length;
}

int loggerToIndex(Logger logger) {
  assert isValidLogger(logger);
  return view_as<int>(logger) - 1;
}

Logger indexToLogger(int index) {
  return view_as<Logger>(index + 1);
}

void validateState() {
  if (g_aLoggers == null) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Illegal state exception: No loggers have been registered yet");
  }
}

void validateLogger(Logger logger) {
  if (!isValidLogger(logger)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Illegal argument exception: Passed argument is not a valid logger");
  }
}

/**
 * public native Logger(
 *     const Severity verbosity = Severity_Warn,
 *     const char[] nameFormat = "%p_%d",
 *     const char[] msgFormat  = "[%5v] [%t] %n::%f - %s",
 *     const char[] dateFormat = "%Y-%m-%d",
 *     const char[] timeFormat = "%H:%M:%S",
 *     const char[] pathFormat = "");
 */
public int Native_CreateLogger(Handle plugin, int numParams) {
  Params_ValidateEqual(6, numParams);
  Severity verbosity = GetNativeCell(1);

  int len;
  GetNativeStringLength(2, len);
  char[] nameFormat = new char[len];
  GetNativeString(2, nameFormat, len+1);

  GetNativeStringLength(3, len);
  char[] msgFormat = new char[len];
  GetNativeString(3, msgFormat, len+1);

  GetNativeStringLength(4, len);
  char[] dateFormat = new char[len];
  GetNativeString(4, dateFormat, len+1);

  GetNativeStringLength(5, len);
  char[] timeFormat = new char[len];
  GetNativeString(5, timeFormat, len+1);

  GetNativeStringLength(6, len);
  char[] pathFormat = new char[len];
  GetNativeString(6, pathFormat, len+1);

  if (g_aLoggers == null) {
    g_aLoggers = new ArrayList(view_as<int>(LoggerData));
  }

  data[LoggerData_verbosity] = verbosity;
  len = strcopy(data[LoggerData_nameFormat],
      sizeof data[LoggerData_nameFormat] - 1, nameFormat);
  data[LoggerData_nameFormat][len] = EOS;
  len = strcopy(data[LoggerData_msgFormat],
      sizeof data[LoggerData_msgFormat] - 1, msgFormat);
  data[LoggerData_msgFormat][len] = EOS;
  len = strcopy(data[LoggerData_dateFormat],
      sizeof data[LoggerData_dateFormat] - 1, dateFormat);
  data[LoggerData_dateFormat][len] = EOS;
  len = strcopy(data[LoggerData_timeFormat],
      sizeof data[LoggerData_timeFormat] - 1, timeFormat);
  data[LoggerData_timeFormat][len] = EOS;
  len = strcopy(data[LoggerData_pathFormat],
      sizeof data[LoggerData_pathFormat] - 1, pathFormat);
  data[LoggerData_pathFormat][len] = EOS;

  int id = g_aLoggers.PushArray(data[0]);
  g_cachedLogger = indexToLogger(id);
  return view_as<int>(g_cachedLogger);
}

/**
 * public native Severity GetVerbosity();
 */
public int Native_GetVerbosity(Handle plugin, int numParams) {
  Params_ValidateEqual(1, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  return view_as<int>(data[LoggerData_verbosity]);
}

/**
 * public native void SetVerbosity(Severity verbosity);
 */
public int Native_SetVerbosity(Handle plugin, int numParams) {
  Params_ValidateEqual(2, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  Severity verbosity = GetNativeCell(2);
  loadLogger(logger);
  data[LoggerData_verbosity] = verbosity;
  commitLogger();
}

/**
 * public native void GetNameFormat(char[] dst, int len);
 */
public int Native_GetNameFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(3, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  int bytes;
  int len = GetNativeCell(3);
  SetNativeString(2, data[LoggerData_nameFormat], len, .bytes = bytes);
  return bytes;
}

/**
 * public native void SetNameFormat(const char[] nameFormat);
 */
public int Native_SetNameFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(2, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  GetNativeString(2, data[LoggerData_nameFormat],
      sizeof data[LoggerData_nameFormat] - 1);
  commitLogger();
}

/**
 * public native void GetMessageFormat(char[] dst, int len);
 */
public int Native_GetMessageFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(3, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  int bytes;
  int len = GetNativeCell(3);
  SetNativeString(2, data[LoggerData_msgFormat], len, .bytes = bytes);
  return bytes;
}

/**
 * public native void SetMessageFormat(const char[] msgFormat);
 */
public int Native_SetMessageFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(2, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  GetNativeString(2, data[LoggerData_msgFormat],
      sizeof data[LoggerData_msgFormat] - 1);
  commitLogger();
}

/**
 * public native void GetDateFormat(char[] dst, int len);
 */
public int Native_GetDateFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(3, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  int bytes;
  int len = GetNativeCell(3);
  SetNativeString(2, data[LoggerData_dateFormat], len, .bytes = bytes);
  return bytes;
}

/**
 * public native void SetDateFormat(const char[] dateFormat);
 */
public int Native_SetDateFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(2, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  GetNativeString(2, data[LoggerData_dateFormat],
      sizeof data[LoggerData_dateFormat] - 1);
  commitLogger();
}

/**
 * public native void GetTimeFormat(char[] dst, int len);
 */
public int Native_GetTimeFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(3, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  int bytes;
  int len = GetNativeCell(3);
  SetNativeString(2, data[LoggerData_timeFormat], len, .bytes = bytes);
  return bytes;
}

/**
 * public native void SetTimeFormat(const char[] timeFormat);
 */
public int Native_SetTimeFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(2, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  GetNativeString(2, data[LoggerData_timeFormat],
      sizeof data[LoggerData_timeFormat] - 1);
  commitLogger();
}

/**
 * public native void GetPathFormat(char[] dst, int len);
 */
public int Native_GetPathFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(3, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  int bytes;
  int len = GetNativeCell(3);
  SetNativeString(2, data[LoggerData_pathFormat], len, .bytes = bytes);
  return bytes;
}

/**
 * public native void SetPathFormat(const char[] pathFormat);
 */
public int Native_SetPathFormat(Handle plugin, int numParams) {
  Params_ValidateEqual(2, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  GetNativeString(2, data[LoggerData_pathFormat],
      sizeof data[LoggerData_pathFormat] - 1);
  commitLogger();
}

/**
 * public native void Log(const char[] format, any ...);
 */
public int Native_Log(Handle plugin, int numParams) {
  Params_ValidateGreaterEqual(2, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  loadLogger(logger);
  //...
}