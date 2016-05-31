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
static Severity g_globalVerbosity;
static Logger g_cachedLogger = null;
static ArrayList g_aLoggers = null;

public APLRes AskPluginLoad2(Handle h, bool isLate, char[] err, int errLen) {
  CreateNatives();
  return APLRes_Success;
}

void CreateNatives() {
  CreateNative("GetVerbosity", Native_GetGlobalVerbosity);
  CreateNative("SetVerbosity", Native_SetGlobalVerbosity);

  CreateNative("Logger.Logger", Native_CreateLogger);

  CreateNative("Logger.IsLogging", Native_IsLogging);

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

bool parseFormat(const char[] c, int &offset,
    char &specifier, bool &lJustify, int &width, int &precision) {
  specifier = ' ';
  lJustify = false;
  width = -1;
  precision = -1;
  if (c[offset] != '%') {
    return false;
  }

  int temp;
  offset++;
  switch (c[offset]) {
    case '\0':
      return false;
    case '-': {
      lJustify = true;
      offset++;
      if (c[offset] == '\0') {
        return false;
      }
    }
    case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
      if (0 <= (temp = c[offset] - '0') && temp <= 9) {
        width = temp;
        offset++;
        while (0 <= (temp = c[offset] - '0') && temp <= 9) {
          width *= 10;
          width += temp;
          offset++;
        }
      } else {
      }

      if (c[offset] == '\0') {
        return false;
      }
    }
    case '.': {
      if (c[offset] == '.') {
        offset++;
        if (0 <= (temp = c[offset] - '0') && temp <= 9) {
          precision = temp;
          offset++;
          while (0 <= (temp = c[offset] - '0') && temp <= 9) {
            precision *= 10;
            precision += temp;
            offset++;
          }
        } else {
          return false;
        }
      } else {
      }

      if (c[offset] == '\0') {
        return false;
      }
    }
    case 'd', 'f', 'i', 'l', 'm', 'n', 'p', 's', 't', 'v', '%':
      switch (c[offset]) {
        case 'd', 'f', 'i', 'l', 'm', 'n', 'p', 's', 't', 'v', '%': {
          specifier = c[offset];
          return true;
        }
      }
  }

  return false;
}

bool isValidFormat(const char[] str, int &percentLoc, int &errorLoc) {
  percentLoc = -1;
  errorLoc = -1;

  char specifier;
  bool lJustify;
  int width, precision;
  int offset = 0;
  for (; str[offset] != '\0'; offset++) {
    if (str[offset] != '%') {
      continue;
    }

    percentLoc = offset;
    if (!parseFormat(str, offset, specifier, lJustify, width, precision)) {
      errorLoc = offset;
      return false;
    }
  }

  return true;
}

/**
 * native Severity GetVerbosity();
 */
public int Native_GetGlobalVerbosity(Handle plugin, int numParams) {
  Params_ValidateEqual(0, numParams);
  return g_globalVerbosity.Value;
}

/**
 * native void SetVerbosity(Severity verbosity);
 */
public int Native_SetGlobalVerbosity(Handle plugin, int numParams) {
  Params_ValidateEqual(1, numParams);

  Severity verbosity = GetNativeCell(1);
  g_globalVerbosity = verbosity;
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
 * public native bool IsLogging();
 */
public int Native_IsLogging(Handle plugin, int numParams) {
  Params_ValidateEqual(1, numParams);
  validateState();
  Logger logger = GetNativeCell(1);
  validateLogger(logger);

  if (g_globalVerbosity > Severity_None) {
    return true;
  }

  loadLogger(logger);
  Severity verbosity = data[LoggerData_verbosity].Value;
  return verbosity > Severity_None;
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
  return data[LoggerData_verbosity].Value;
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