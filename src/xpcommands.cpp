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
	xlua_cmd() : m_next(NULL),m_cmd(NULL),m_ours(0),
		m_pre_handler(NULL),m_pre_ref(NULL),
		m_main_handler(NULL),m_main_ref(NULL),
		m_post_handler(NULL),m_post_ref(NULL) { }

	xlua_cmd *			m_next;
	string				m_name;
	XPLMCommandRef		m_cmd;
	int					m_ours;
	xlua_cmd_handler_f	m_pre_handler;
	void *				m_pre_ref;
	xlua_cmd_handler_f	m_main_handler;
	void *				m_main_ref;
	xlua_cmd_handler_f	m_post_handler;
	void *				m_post_ref;
	float				m_down_time;
};

static xlua_cmd *		s_cmds = NULL;

static int xlua_std_pre_handler(XPLMCommandRef c, XPLMCommandPhase phase, void * ref)
{
	xlua_cmd * me = (xlua_cmd *) ref;
	if(phase == xplm_CommandBegin)
		me->m_down_time = XPLMGetElapsedTime();
	if(me->m_pre_handler)
		me->m_pre_handler(me, phase, XPLMGetElapsedTime() - me->m_down_time, me->m_pre_ref);
	return 1;
}

static int xlua_std_main_handler(XPLMCommandRef c, XPLMCommandPhase phase, void * ref)
{
	xlua_cmd * me = (xlua_cmd *) ref;
	if(phase == xplm_CommandBegin)
		me->m_down_time = XPLMGetElapsedTime();
	if(me->m_main_handler)
		me->m_main_handler(me, phase, XPLMGetElapsedTime() - me->m_down_time, me->m_main_ref);
	return 0;
}

static int xlua_std_post_handler(XPLMCommandRef c, XPLMCommandPhase phase, void * ref)
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

xlua_cmd * xlua_create_cmd(const char * name, const char * desc)
{
	for(xlua_cmd * i = s_cmds; i; i = i->m_next)
	if(i->m_name == name)
	{
		if(i->m_ours)
		{
			printf("ERROR: command already exists: %s\n", name);
			log_message("ERROR: command already exists: %s\n", name);
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
//		printf("ERROR: command already in use by other plugin or X-Plane: %s\n", name);
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

void xlua_cmd_install_handler(xlua_cmd * cmd, xlua_cmd_handler_f handler, void * ref)
{
	if(cmd->m_main_handler != NULL)
	{
		printf("ERROR: there is already a main handler installed: %s.\n", cmd->m_name.c_str());
		log_message("ERROR: there is already a main handler installed: %s.\n", cmd->m_name.c_str());
		return;
	}
	cmd->m_main_handler = handler;
	cmd->m_main_ref = ref;
	XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_main_handler, 1, cmd);
}


void xlua_cmd_install_pre_wrapper(xlua_cmd * cmd, xlua_cmd_handler_f handler, void * ref)
{
	if(cmd->m_pre_handler != NULL)
	{
		printf("ERROR: there is already a pre handler installed: %s.\n", cmd->m_name.c_str());
		log_message("ERROR: there is already a pre handler installed: %s.\n", cmd->m_name.c_str());
		return;
	}
	cmd->m_pre_handler = handler;
	cmd->m_pre_ref = ref;
	XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_pre_handler, 1, cmd);
}

void xlua_cmd_install_post_wrapper(xlua_cmd * cmd, xlua_cmd_handler_f handler, void * ref)
{
	if(cmd->m_post_handler != NULL)
	{
		printf("ERROR: there is already a post handler installed: %s.\n", cmd->m_name.c_str());
		log_message("ERROR: there is already a post handler installed: %s.\n", cmd->m_name.c_str());
		return;	
	}
	cmd->m_post_handler = handler;
	cmd->m_post_ref = ref;
	XPLMRegisterCommandHandler(cmd->m_cmd, xlua_std_post_handler, 0, cmd);
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
