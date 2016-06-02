#define TESTSUITE

#include <sourcemod>
#include <testing>

#include "../include/logger.inc"

public Plugin myinfo = {
  name = "loggerTests",
  author = "Tirant",
  description = "Tests for logger.sp",
  version = "0.0.1",
  url = "http://www.sourcemod.net/"
};

public void OnPluginStart() {
  RegServerCmd("tests", Command_TestAll);
  RegServerCmd("tests.logger", Command_TestAll);
  RegServerCmd("tests.logger.create", Command_Test_Create);
  RegServerCmd("tests.logger.Log", Command_Test_Log);
  RegServerCmd("tests.logger.SetVerbosity", Command_Test_SetVerbosity);
}

void SetTestingContext() {
  char filename[32];
  GetPluginFilename(null, filename, sizeof filename - 1);
  SetTestContext(filename);
}

public Action Command_TestAll(int args) {
  Command_Test_Create(0);
  Command_Test_Log(0);
  Command_Test_SetVerbosity(0);
}

public Action Command_Test_Create(int args) {
  SetTestingContext();

  Severity testVerbosity = 31;
  Logger logger = new Logger(testVerbosity);
  Severity verbosity = logger.GetVerbosity();
  AssertTrue("logger.GetVerbosity() == 31", verbosity == testVerbosity);
}

public Action Command_Test_Log(int args) {
  SetTestingContext();

  Logger logger = new Logger(Severity_Lowest);
  logger.Log(Severity_Info, "This is a test log message!");
}

public Action Command_Test_SetVerbosity(int args) {
  SetTestingContext();

  Severity testVerbosity = 31;
  Logger logger = new Logger(testVerbosity);
  Severity verbosity = logger.GetVerbosity();
  AssertTrue("logger.GetVerbosity() == 31", verbosity == testVerbosity);
  testVerbosity = 33;
  logger.SetVerbosity(testVerbosity);
  verbosity = logger.GetVerbosity();
  AssertTrue("logger.SetVerbosity(33)", verbosity == testVerbosity);
}