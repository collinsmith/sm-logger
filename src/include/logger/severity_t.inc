#if defined _severity_t_included
    #endinput
#endif
#define _severity_t_included

/*methodmap Severity {
  
  public native void GetName(char[] dst, int len);

  property int Value {
    public native get();
  }

}*/

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
}