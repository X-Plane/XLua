//
//  xpcommands.h
//  xlua
//
//  Created by Benjamin Supnik on 4/12/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#ifndef xpcommands_h
#define xpcommands_h

struct	xlua_cmd;

typedef void (* xlua_cmd_handler_f)(xlua_cmd * cmd, int phase, float duration, void * ref);

xlua_cmd * xlua_find_cmd(const char * name);
xlua_cmd * xlua_create_cmd(const char * name, const char * desc);

// The main handler can be used to provide guts to our command or REPLACE an existing
// command. The pre/post handlers always augment.
void xlua_cmd_install_handler(xlua_cmd * cmd, xlua_cmd_handler_f handler, void * ref);
void xlua_cmd_install_pre_wrapper(xlua_cmd * cmd, xlua_cmd_handler_f handler, void * ref);
void xlua_cmd_install_post_wrapper(xlua_cmd * cmd, xlua_cmd_handler_f handler, void * ref);

void xlua_cmd_start(xlua_cmd * cmd);
void xlua_cmd_stop(xlua_cmd * cmd);
void xlua_cmd_once(xlua_cmd * cmd);

void xlua_cmd_cleanup();

void xlua_cmd_mark_reload_on_change(void);
extern bool g_bReloadOnFlightChange;

#endif /* xpcommands_h */
