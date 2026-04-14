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

#include "lua.h"

#include <XPLMUtilities.h>

#include <memory>
#include <string>

class	notify_cb_t;
struct xlua_cmd;

typedef int (* xlua_cmd_handler_f)(xlua_cmd * cmd, int phase, float duration, std::shared_ptr<notify_cb_t> ref);

struct xlua_cmd {
public:
	xlua_cmd() = delete;
	xlua_cmd(std::string const& name, XPLMCommandRef cmd) : m_name(name), m_cmd(cmd) {}
	~xlua_cmd();

	std::string			m_name;
	XPLMCommandRef		m_cmd = nullptr;
	bool				m_ours = false;
	xlua_cmd_handler_f	m_pre_handler = nullptr;
	std::shared_ptr<notify_cb_t> m_pre_ref = nullptr;
	xlua_cmd_handler_f	m_main_handler = nullptr;
	std::shared_ptr<notify_cb_t> m_main_ref = nullptr;
	xlua_cmd_handler_f	m_post_handler = nullptr;
	std::shared_ptr<notify_cb_t> m_post_ref = nullptr;
	float				m_down_time = 0;
	xlua_cmd_handler_f	m_filter_handler = nullptr;
	std::shared_ptr<notify_cb_t> m_filter_ref = nullptr;
	bool				m_filter_inited = false;
	bool				m_filter_allow = true;
	bool				m_filter_allow_release = false;
	bool				m_filter_sent_fake_end = false;
};

xlua_cmd * xlua_find_cmd(const char * name);
xlua_cmd * xlua_create_cmd(lua_State* L, const char * name, const char * desc);

// The main handler can be used to provide guts to our command or REPLACE an existing
// command. The pre/post handlers always augment.
void xlua_cmd_install_handler(lua_State* L, xlua_cmd* cmd, xlua_cmd_handler_f handler, std::shared_ptr<notify_cb_t> ref);
void xlua_cmd_install_pre_wrapper(lua_State* L, xlua_cmd* cmd, xlua_cmd_handler_f handler, std::shared_ptr<notify_cb_t> ref);
void xlua_cmd_install_post_wrapper(lua_State* L, xlua_cmd* cmd, xlua_cmd_handler_f handler, std::shared_ptr<notify_cb_t> ref);
void xlua_cmd_install_filter(lua_State* L, xlua_cmd* cmd, xlua_cmd_handler_f handler, std::shared_ptr<notify_cb_t> ref);

void xlua_cmd_start(xlua_cmd * cmd);
void xlua_cmd_stop(xlua_cmd * cmd);
void xlua_cmd_once(xlua_cmd * cmd);

void xlua_cmd_cleanup();

void xlua_cmd_mark_reload_on_change(void);
extern bool g_bReloadOnFlightChange;

#endif /* xpcommands_h */
