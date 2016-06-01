#if defined _severity_t_included
    #endinput
#endif
#define _severity_t_included

#include <string>

enum Severity {
  /**
   * Constant used to represent invalid Severities
   * 
   * @deprecated
   */
  Severity_Invalid = -1,

  /**
   * Constant used to represent no Severity (i.e., disables logging)
   */
  Severity_None    = 0,

  /**
   * Constant used to represent the debugging Severity
   */
  Severity_Debug   = 1,

  /**
   * Constant used to represent the lowest Severity (i.e., the most verbose)
   */
  Severity_Lowest  = Severity_Debug,

  /**
   * Constant used to represent the informational Severity
   */
  Severity_Info    = 101,

  /**
   * Constant used to represent the warn Severity
   */
  Severity_Warn    = 201,

  /**
   * Constant used to represent the warn Severity
   * 
   * @note duplicate of {@literal #Severity_Warn}
   */
  Severity_Warning = Severity_Warn,

  /**
   * Constant used to represent the error Severity
   */
  Severity_Error   = 301,

  /**
   * Constant used to represent the highest Severity (i.e., the least verbose)
   * 
   * @note this will not disable logging, it will just make only the most
   *       important messages log
   */
  Severity_Highest = Severity_Error
};

methodmap Severity {

  property int Value {
    public get() {
      return view_as<int>(this);
    }
  }

  /*property static Severity None {
    public get() {
      return Severity_None;
    }
  }

  property Severity Debug {
    public get() {
      return Severity_Debug;
    }
  }

  property Severity Info {
    public get() {
      return Severity_Info;
    }
  }

  property Severity Warn {
    public get() {
      return Severity_Warn;
    }
  }

  property Severity Error {
    public get() {
      return Severity_Error;
    }
  }*/
  
  public int GetName(char[] dst, int len) {
    switch (this.Value) {
      case Severity_Invalid: return strcopy(dst, len, "INVALID");
      case Severity_None:    return strcopy(dst, len, "NONE");
      case Severity_Debug:   return strcopy(dst, len, "DEBUG");
      case Severity_Info:    return strcopy(dst, len, "INFO");
      case Severity_Warn:    return strcopy(dst, len, "WARN");
      case Severity_Error:   return strcopy(dst, len, "ERROR");
      default:               return IntToString(this.Value, dst, len);
    }

    return 0;
  }

};