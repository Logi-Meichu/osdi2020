#include "common.h"
#include "string.h"

int strcmp(const char *s1, const char *s2)
{
    while(*s1 && (*s1 == *s2))
    {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

void * memcpy (void *dest, const void *src, size_t len)
{
  char *d = dest;
  const char *s = src;
  while (len--)
    *d++ = *s++;
  return dest;
}


void *memset(void *str, int c, size_t n)
{

    size_t i = 0;
    while (i < n)
    {
        *(char *)str = c;
        str += 1;
        ++i;
    }
    return str;
}
