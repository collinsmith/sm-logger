#define TESTSUITE

#include <sourcemod>
#include <testing>

#include "../include/logger.inc"

public Plugin pluginInfo = {
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
    RegServerCmd("tests.logger.SetVerbosity", Command_Test_SetVerbosity);
}

void SetTestingContext() {
    char filename[32];
    GetPluginFilename(null, filename, sizeof filename - 1);
    SetTestContext(filename);
}

public Action Command_TestAll(int args) {
    Command_Test_Create(0);
    Command_Test_SetVerbosity(0);
}

public Action Command_Test_Create(int args) {
    SetTestingContext();

    Severity testVerbosity = view_as<Severity>(31);
    Logger logger = new Logger(testVerbosity);
    Severity verbosity = logger.GetVerbosity();
    AssertTrue("logger.GetVerbosity() == 31", verbosity == testVerbosity);
}

public Action Command_Test_SetVerbosity(int args) {
    SetTestingContext();

    Severity testVerbosity = view_as<Severity>(31);
    Logger logger = new Logger(testVerbosity);
    Severity verbosity = logger.GetVerbosity();
    AssertTrue("logger.GetVerbosity() == 31", verbosity == testVerbosity);
    testVerbosity = view_as<Severity>(33);
    logger.SetVerbosity(testVerbosity);
    verbosity = logger.GetVerbosity();
    AssertTrue("logger.SetVerbosity(33)", verbosity == testVerbosity);
}