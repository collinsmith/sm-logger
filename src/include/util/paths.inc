#if defined _paths_included
    #endinput
#endif
#define _paths_included

#include <files>

#define PATH_SEPARATOR      '/'
#define PATH_SEPARATOR_ALT  '\\'

stock bool Paths_FixPathSeparator(char[] path, int index) {
  switch (path[index]) {
    case PATH_SEPARATOR_ALT: {
      path[index] = PATH_SEPARATOR;
      return true;
    }
    case PATH_SEPARATOR:
      return true;
    default:
      return false;
  }

  return false;
}

stock int Paths_FixPath(char[] path, int len) {
  int i;
  for (i = 0; i < len && path[i] != EOS; i++) {
    Paths_FixPathSeparator(path, i);
  }

  return i-1;
}

stock int Paths_FixPathAndMkdir(char[] path, int len, int mode = 448) {
  int i;
  for (i = 0; i < len && path[i] != EOS; i++) {
    if (Paths_FixPathSeparator(path, i)) {
      path[i] = EOS;
      CreateDirectory(path, mode);
      path[i] = PATH_SEPARATOR;
    }
  }

  return len-1;
}