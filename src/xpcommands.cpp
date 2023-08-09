//
//  xpcommands.cpp
//  xlua
//
//  Created by Benjamin Supnik on 4/12/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.


#include <cstdio>
#include "xpcommands.h"
#define XPLM200 1
#include <XPLMUtilities.h>
#include <XPLMProcessing.h>
#include <assert.h>
#include <string>

#include "log.h"

using std::string;

int ResetState(XPLMCommandRef inCommand, XPLMCommandPhase inPhase, void* inRefcon);

struct xlua_cmd {
	xlua_cmd *			m_next				= nullptr;
	string				m_name;
	XPLMCommandRef		m_cmd				= nullptr;
	int					m_ours				= 0;
	xlua_cmd_handler_f	m_pre_handler		= nullptr;
	notify_cb_t*		m_pre_ref			= nullptr;
	xlua_cmd_handler_f	m_main_handler		= nullptr;
	notify_cb_t*		m_main_ref			= nullptr;
	xlua_cmd_handler_f	m_post_handler		= nullptr;
	notify_cb_t*		m_post_ref			= nullptr;
	float				m_down_time			= 0;
	xlua_cmd_handler_f	m_filter_handler	= nullptr;
	notify_cb_t*		m_filter_ref		= nullptr;
	bool				m_filter_inited		= false;
	bool				m_filter_allow		= true;
	bool				m_filter_allow_release = false;
	bool				m_filter_sent_fake_end = false;
};

static xlua_cmd *		s_cmds = NULL;

static int xlua_std_pre_filter(XPLMCommandRef c, XPLMCommandPhase phase, void* ref)
{
	xlua_cmd* cmd = static_cast<xlua_cmd*>(ref);
	bool is_first_cb = !cmd->m_filter_inited;
	cmd->m_filter_inited = true;

	// Allow the command to be blocked at either 'down' or 'held' stages.
	if (phase == xplm_CommandBegin || phase == xplm_CommandContinue)
	{
		if (phase == xplm_CommandBegin || is_first_cb)
		{
			cmd->m_down_time = XPLMGetElapsedTime();
		}

		bool did_allow = cmd->m_filter_allow;
		if (cmd->m_filter_handler)
		{
			cmd->m_filter_allow = cmd->m_filter_handler(cmd, phase, XPLMGetElapsedTime() - cmd->m_down_time, cmd->m_filter_ref);
		}

		if (phase == xplm_CommandContinue && did_allow != cmd->m_filter_allow)
		{
			// If we're holding and the state has changed, jiggery-pokery ensues.

			// Can't use XPLMCommand[Begin|End])() here. They modify a global vector of expected start/end pairs, so
			// they must be kept in sync and we don't know whether this call was made via a 'normal' mechanism or
			// by a script/plugin calling one of these functions. They'll get out of wack, and we'd also be modifying
			// XPLM::gCommandMap from within a loop iterating over it. Baaaaaad.

			// Be nice to lua custom scripts, maybe? This does involve a little extra finagling; the sim's tracking the actual
			// up/down events as normal, but if we want to send the script fake begin/end events outside that then we need
			// to make sure any subsequent real ones don't make it through as well.
			// 
			// Allowed -> Blocked transition needs a fake end, plus the suppression of any real end event that arrives at the 'main' handler.
			//						If the user keeps the key held, we may eventually get back into 'allowed' status from 'continue' and will
			//						send the fake 'begin', below.
			//						If the user releases the key while blocked, we've already sent the fake end and the real end will be blocked.
			//						The next thing we're aware of in here is a new, genuine 'begin'.
			// 
			// Blocked -> Allowed transition needs a fake begin, but no suppression; the real begin has already been and gone, because this is
			//						a 'continue' block.
			if (cmd->m_main_handler != nullptr)
			{
				if (did_allow)
				{
					cmd->m_main_handler(cmd, xplm_CommandEnd, XPLMGetElapsedTime() - cmd->m_down_time, cmd->m_main_ref);
					cmd->m_filter_sent_fake_end = true;
				}
				else
				{
					cmd->m_main_handler(cmd, xplm_CommandBegin, XPLMGetElapsedTime() - cmd->m_down_time, cmd->m_main_ref);
					cmd->m_filter_sent_fake_end = false;
				}
			}
		}

		cmd->m_filter_allow_release |= cmd->m_filter_allow;
		return cmd->m_filter_allow;
	}
	else
	{
		bool do_allow_release = cmd->m_filter_allow_release;
		cmd->m_filter_allow_release = false;
		return do_allow_release;
	}
}

static int xlua_std_pre_handler(XPLMCommandRef c, XPLMCommandPhase phase, void* ref)
{
	xlua_cmd * me = (xlua_cmd *) ref;
	if(phase == xplm_CommandBegin)
		me->m_down_time = XPLMGetElapsedTime();
	if(me->m_pre_handler)
		me->m_pre_handler(me, phase, XPLMGetElapsedTime() - me->m_down_time, me->m_pre_ref);
	return 1;
}

static int xlua_std_main_handler(XPLMCommandRef c, XPLMCommandPhase phase, void* ref)
{
	xlua_cmd * me = (xlua_cmd *) ref;

	if (phase == xplm_CommandBegin)
		me->m_down_time = XPLMGetElapsedTime();
	else if (phase == xplm_CommandEnd && me->m_filter_sent_fake_end)
	{
		me->m_filter_sent_fake_end = false;
		return 1;
	}
	if(me->m_main_handler)
		me->m_main_handler(me, phase, XPLMGetElapsedTime() - me->m_down_time, me->m_main_ref);
	return 0;
}

static int xlua_std_post_handler(XPLMCommandRef c, XPLMCommandPhase phase, void* ref)
{
	xlua_cmd * me = (xlua_cmd *) ref;
	if(phase == xplm_CommandBegin)
		me->m_down_time = XPLMGetElapsedTime();
	if(me->m_post_handler)
		me->m_post_handler(me, phase, XPLMGetElapsedTime() - me->m_down_time, me->m_post_ref);
	return 1;
}

xlua_cmd * xlua_find_cmd(const char * name)
{
	for(xlua_cmd * i = s_cmds; i; i = i->m_next)
	if(i->m_name == name)
		return i;
		
	XPLMCommandRef c = XPLMFindCommand(name);	
	if(c == NULL) return NULL;	
		
	xlua_cmd * nc = new xlua_cmd;
	nc->m_next = s_cmds;
	s_cmds = nc;
	nc->m_name = name;
	nc->m_cmd = c;
	return nc;
}

xlua_cmd * xlua_create_cmd(lua_State* L, const char * name, const char * desc)
{
	for(xlua_cmd * i = s_cmds; i; i = i->m_next)
	if(i->m_name == name)
	{
		if(i->m_ours)
		{
			log_message(L, "ERROR: command already exists: %s\n", name);
			return NULL;
		}
		i->m_ours = 1;
		return i;
	}

	// Ben says: we used to try to barf on commands taken over from other plugins but
	// we can get spooked by our own shadow - if we had a command last run and the user 
	// bound it to a joystick and saved prefs then...it will ALREADY exist!  So don't
	// FTFO here.

//	if(XPLMFindCommand(name) != NULL)
//	{
//		log_message(L, "ERROR: command already in use by other plugin or X-Plane: %s\n", name);
//		return NULL;
//	}

	xlua_cmd * nc = new xlua_cmd;
	nc->m_next = s_cmds;
	s_cmds = nc;
	nc->m_name = name;
	nc->m_cmd = XPLMCreateCommand(name,desc);
	nc->m_ours = 1;
	return nc;
}

void xlua_cmd_install_handler(lua_State* L, xlua_cmd * cmd, xlua_cmd_handler_f handler, notify_cb_t* ref)
{
	if(cmd->m_main_handler != NULL)
	{
		log_message(L, "ERROR: there is already a main handler installed: %s.\n", cmd->m_name.c_str());
		return;
	}
	cmd->m_main_handler = handler;
	cmd->m_main_ref = ref;

	// If there's already a filter or a pre handler, adding the main will make the call sequence be "main->(pre/filter)->post".
	if (cmd->m_pre_handler != nullptr)
	{
		XPLMUnregisterCommandHandler(cmd->m_cmd, xlua_std_pre_handler, 1, cmd);
	}
	if (cmd->m_filter_handler != nullptr)
	{
		XPLMUnregisterCommandHandler(cmd->m_cmd, xlua_std_pre_filter, 1, cmd);
	}
	XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_main_handler, 1, static_cast<void*>(cmd));
	if (cmd->m_pre_handler != nullptr)
	{
		XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_pre_handler, 1, cmd);
	}
	if (cmd->m_filter_handler != nullptr)
	{
		XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_pre_filter, 1, cmd);
	}
}

void xlua_cmd_install_filter(lua_State* L, xlua_cmd* cmd, xlua_cmd_handler_f handler, notify_cb_t* ref)
{
	if (cmd->m_filter_handler != nullptr)
	{
		log_message(L, "ERROR: there is already a filter handler installed: %s.\n", cmd->m_name.c_str());
		return;
	}

	cmd->m_filter_handler = handler;
	cmd->m_filter_ref = ref;

	XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_pre_filter, 1, static_cast<void*>(cmd));
}

void xlua_cmd_install_pre_wrapper(lua_State* L, xlua_cmd * cmd, xlua_cmd_handler_f handler, notify_cb_t* ref)
{
	if(cmd->m_pre_handler != NULL)
	{
		log_message(L, "ERROR: there is already a pre handler installed: %s.\n", cmd->m_name.c_str());
		return;
	}
	cmd->m_pre_handler = handler;
	cmd->m_pre_ref = ref;

	XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_pre_handler, 1, static_cast<void*>(cmd));
}

void xlua_cmd_install_post_wrapper(lua_State* L, xlua_cmd * cmd, xlua_cmd_handler_f handler, notify_cb_t* ref)
{
	if(cmd->m_post_handler != NULL)
	{
		log_message(L, "ERROR: there is already a post handler installed: %s.\n", cmd->m_name.c_str());
		return;	
	}
	cmd->m_post_handler = handler;
	cmd->m_post_ref = ref;
	XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_post_handler, 0, static_cast<void*>(cmd));
}

void xlua_cmd_start(xlua_cmd * cmd)
{
	XPLMCommandBegin(cmd->m_cmd);
}
void xlua_cmd_stop(xlua_cmd * cmd)
{
	XPLMCommandEnd(cmd->m_cmd);
}

void xlua_cmd_once(xlua_cmd * cmd)
{
	XPLMCommandOnce(cmd->m_cmd);
}

void xlua_cmd_cleanup()
{
	while(s_cmds)
	{
		xlua_cmd * k = s_cmds;
		if(k->m_pre_handler)
			XPLMUnregisterCommandHandler(k->m_cmd, xlua_std_pre_handler, 1, k);
		if(k->m_main_handler)
			XPLMUnregisterCommandHandler(k->m_cmd, xlua_std_main_handler, 1, k);
		if(k->m_post_handler)
			XPLMUnregisterCommandHandler(k->m_cmd, xlua_std_post_handler, 0, k);
		s_cmds = s_cmds->m_next;
		delete k;
	}

	assert(s_cmds == nullptr);
}

void xlua_cmd_mark_reload_on_change()
{
	g_bReloadOnFlightChange = true;
}
