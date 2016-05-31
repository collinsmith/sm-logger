#include <sourcemod>

#include "include/util/params.inc"

#include "include/logger/logger_t.inc"
#include "include/logger/severity_t.inc"
#include "include/logger/logger_const.inc"

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

/*
public native Logger(
    const Severity verbosity = Severity_Warn,
    const char[] nameFormat = "%p_%d",
    const char[] msgFormat  = "[%5v] [%t] %n::%f - %s",
    const char[] dateFormat = "%Y-%m-%d",
    const char[] timeFormat = "%H:%M:%S",
    const char[] pathFormat = "");
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
  len = strcopy(data[LoggerData_nameFormat], sizeof data[LoggerData_nameFormat], nameFormat);
  data[LoggerData_nameFormat][len] = EOS;
  len = strcopy(data[LoggerData_msgFormat], sizeof data[LoggerData_msgFormat], msgFormat);
  data[LoggerData_msgFormat][len] = EOS;
  len = strcopy(data[LoggerData_dateFormat], sizeof data[LoggerData_dateFormat], dateFormat);
  data[LoggerData_dateFormat][len] = EOS;
  len = strcopy(data[LoggerData_timeFormat], sizeof data[LoggerData_timeFormat], timeFormat);
  data[LoggerData_timeFormat][len] = EOS;
  len = strcopy(data[LoggerData_pathFormat], sizeof data[LoggerData_pathFormat], pathFormat);
  data[LoggerData_pathFormat][len] = EOS;

  int id = g_aLoggers.PushArray(data[0]);
  g_cachedLogger = indexToLogger(id);
  return view_as<int>(g_cachedLogger);
}

public int Native_GetVerbosity(Handle plugin, int numParams) {
  Params_ValidateEqual(1, numParams);
  if (g_aLoggers == null) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Illegal state exception: No loggers have been registered yet");
  }

  Logger logger = GetNativeCell(1);
  if (!isValidLogger(logger)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Illegal argument exception: Passed argument is not a valid logger");
  }

  loadLogger(logger);
  return view_as<int>(data[LoggerData_verbosity]);
}

public int Native_SetVerbosity(Handle plugin, int numParams) {
  Params_ValidateEqual(2, numParams);
  if (g_aLoggers == null) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Illegal state exception: No loggers have been registered yet");
  }

  Logger logger = GetNativeCell(1);
  if (!isValidLogger(logger)) {
    ThrowNativeError(SP_ERROR_NATIVE,
        "Illegal argument exception: Passed argument is not a valid logger");
  }

  Severity verbosity = GetNativeCell(2);
  loadLogger(logger);
  data[LoggerData_verbosity] = verbosity;
  commitLogger();
}