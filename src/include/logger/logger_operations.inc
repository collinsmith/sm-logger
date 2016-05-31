#if defined _logger_operations_included
    #endinput
#endif
#define _logger_operations_included

/*******************************************************************************
 * STOCKS
 ******************************************************************************/

stock Severity toSeverity(int value) {
  return view_as<Severity>(value);
}

stock Severity operator=(int oper) {
  return toSeverity(oper);
}

stock bool operator==(Severity oper1, int oper2) {
  return oper1 == toSeverity(oper2);
}

stock bool operator!=(Severity oper1, int oper2) {
  return oper1 != toSeverity(oper2);
}

stock bool operator>(Severity oper1, int oper2) {
  return oper1 > toSeverity(oper2);
}

stock bool operator>(int oper1, Severity oper2) {
  return toSeverity(oper1) > oper2;
}

stock bool operator>=(Severity oper1, int oper2) {
  return oper1 >= toSeverity(oper2);
}

stock bool operator>=(int oper1, Severity oper2) {
  return toSeverity(oper1) >= oper2;
}

stock bool operator<(Severity oper1, int oper2) {
  return oper1 < toSeverity(oper2);
}

stock bool operator<(int oper1, Severity oper2) {
  return toSeverity(oper1) < oper2;
}

stock bool operator<=(Severity oper1, int oper2) {
  return oper1 <= toSeverity(oper2);
}

stock bool operator<=(int oper1, Severity oper2) {
  return toSeverity(oper1) <= oper2;
}