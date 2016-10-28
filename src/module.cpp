//
//  module.cpp
//  xlua
//
//  Created by Ben Supnik on 3/19/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include "module.h"
#include <XPLMUtilities.h>
#include "xpfuncs.h"
#include <stdlib.h>
#include <assert.h>
#include "lua_helpers.h"

#define MALLOC_CHUNK_SIZE 4096

struct module_alloc_block {
	module_alloc_block *		next;
	char *					ptr;
	size_t					remaining;
	char						data[MALLOC_CHUNK_SIZE];
};

static module_alloc_block * make_alloc_block()
{
	module_alloc_block * r = (module_alloc_block *) malloc(MALLOC_CHUNK_SIZE);
	assert(r);
	r->next = NULL;
	r->ptr = r->data;
	r->remaining = MALLOC_CHUNK_SIZE;
	return r;
}

static void * alloc_from_block(module_alloc_block *& head, size_t amt)
{
	assert(amt <= MALLOC_CHUNK_SIZE);
	
	if(head != NULL && head->remaining >= amt)
	{
		void * r = head->ptr;
		head->ptr += amt;
		head->remaining -= amt;
		return r;
	}
	else
	{
		module_alloc_block * nb = make_alloc_block();
		nb->next = head;
		head = nb;
	}	

	void * r = head->ptr;
	head->ptr += amt;
	head->remaining -= amt;
	return r;
}

static void destroy_alloc_block(module_alloc_block * head)
{
	while(head)
	{
		module_alloc_block * k = head;
		head = head->next;
		free(k);
	}
}

#define CTOR_FAIL(errcode,msg) \
if(errcode != 0) { \
	const char * s = lua_tostring(m_interp, -1); \
	printf("%s\n%s failed: %d\n",s,msg,errcode); \
	XPLMDebugString(msg); \
	lua_close(m_interp); \
	m_interp = NULL; \
	return; }

module::module(
							const char *		in_module_path,
							const char *		in_init_script,
							const char *		in_module_script,
							void *				(* in_alloc_func)(void *msp, void *ptr, size_t osize, size_t nsize),
							void *				in_alloc_ref) :
	m_interp(NULL),
	m_memory(NULL),
	m_path(in_module_path)
{
	printf("Running %s/%s\n", in_init_script, in_module_script);
	
#if MOBILE
	m_interp = luaL_newstate();
#else
	m_interp = lua_newstate(in_alloc_func, in_alloc_ref);
#endif

	if(m_interp == NULL)
	{
		XPLMDebugString("Unable to set up Lua.");
		return;
	}
	luaL_openlibs(m_interp);

	lua_pushlightuserdata(m_interp, this);
	lua_setglobal(m_interp, "__module_ptr");		
		
	add_xpfuncs_to_interp(m_interp);
	
	int load_result = luaL_loadfile(m_interp, in_init_script);
	CTOR_FAIL(load_result, "load init script")

	int init_script_result = lua_pcall(m_interp, 0, 0, 0);
	CTOR_FAIL(init_script_result, "run init script");
	
	lua_getfield(m_interp, LUA_GLOBALSINDEX, "run_module_in_namespace");
	
	int module_load_result = luaL_loadfile(m_interp, in_module_script);
	CTOR_FAIL(module_load_result,"load module");
	
	int module_run_result = lua_pcall(m_interp, 1, 0, 0);
	CTOR_FAIL(module_run_result,"run module");
}

module * module::module_from_interp(lua_State * interp)
{
	lua_getglobal(interp,"__module_ptr");
	
	if(lua_islightuserdata(interp, -1))
	{
		module * me = (module *) lua_touserdata(interp, -1);
		lua_pop(interp, 1);
		return me;
	} 
	else
	{
		assert(!"No defined module");
		lua_pop(interp, 1);
		return NULL;
	}
}

void *		module::module_alloc_tracked(size_t amount)
{
	return alloc_from_block(m_memory, amount);
}

void		module::acf_load()
{
	do_callout("aircraft_load");
}

void		module::acf_unload()
{
	do_callout("aircraft_unload");
}

void		module::flight_init()
{
	do_callout("flight_start");
}

void		module::flight_crash()
{
	do_callout("flight_crash");
}

void		module::pre_physics()
{
	do_callout("before_physics");
}

void		module::post_physics()
{
	do_callout("after_physics");
}

void		module::post_replay()
{
	do_callout("after_replay");
}

void module::do_callout(const char * f)
{
	if(m_interp == NULL)
		return;
	lua_getfield(m_interp, LUA_GLOBALSINDEX, "do_callout");
	if(lua_isnil(m_interp, -1))
	{
		lua_pop(m_interp, 1);
	}
	else
	{	
		fmt_pcall_stdvars(m_interp,"s",f);	
	}
}

module::~module()
{
	if(m_interp)
		lua_close(m_interp);
	destroy_alloc_block(m_memory);
		
}
