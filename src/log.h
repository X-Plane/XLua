#pragma once

enum class xlua_log_level { debug, info, warn, error };

// Desktop ignores the level: the E/I letter there still comes from whether L has a live stack, so Log.txt stays as it
// was. On mobile the level is what reaches the sim log, and each call becomes exactly one sim log entry.
int log_message(xlua_log_level level, lua_State *L, char const* const format, ...);
