#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
#endif

int main(int argc, char ** argv)
{
  printf("hello world\n");

#ifdef _WIN32
  MessageBoxA(NULL, "Hello world", "Hello Box", MB_OK);
#endif
  return 0;
}
