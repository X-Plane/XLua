#include "log.h"

#include <cstdio>

#include <XPLMUtilities.h>

int log_message(char const* const format, ...)
{
    char buffer[2048];
	va_list args;
    va_start(args, format);
    int result = vsprintf_s(buffer, sizeof(buffer), format, args);
    va_end(args);

    XPLMDebugString(buffer);
	
    return result;
}
