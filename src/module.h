//
//  module.h
//  xlua
//
//  Created by Ben Supnik on 3/19/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#ifndef module_h
#define module_h

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

#include <array>
#include <string>

using std::string;
using std::array;

struct module_alloc_block;

class module {
public:

						 module(
							const char *		in_module_path,
							const char *		in_init_script,
							const char *		in_module_script,
							void *				(* in_alloc_func)(void *msp, void *ptr, size_t osize, size_t nsize),
							void *				in_alloc_ref);
						~module();

	static module *		module_from_interp(lua_State * interp);
	static int			debug_proc_from_interp(lua_State * interp);

			void *		module_alloc_tracked(size_t amount);
			
			// Pushes error string or chunk onto interp stack, returns error code or 0.  
			int			load_module_relative_path(const string& path);
	const	string		&get_log_path(void) const { return m_log_path; }

			void		acf_load();
			void		acf_unload();
			void		flight_start();
			void		flight_crash();
			
			void		pre_physics();
			void		post_physics();
			void		post_replay();

			lua_State*	interp() const { return m_interp; }

			bool		has_pre_physics() const { return m_callout_refs[kCalloutBeforePhysics] != LUA_NOREF; }
			bool		has_post_physics() const { return m_callout_refs[kCalloutAfterPhysics] != LUA_NOREF; }
			bool		has_post_replay() const { return m_callout_refs[kCalloutAfterReplay] != LUA_NOREF; }

private:

		enum CalloutId {
			kCalloutAircraftLoad = 0,
			kCalloutAircraftUnload,
			kCalloutFlightStart,
			kCalloutFlightCrash,
			kCalloutBeforePhysics,
			kCalloutAfterPhysics,
			kCalloutAfterReplay,
			kCalloutCount
		};

		int				capture_callout(const char * call_name);
		void			register_callout_with_stp(int func_index, const char * call_name);
		void			invoke_callout(CalloutId which);

	lua_State *				m_interp;
	module_alloc_block *	m_memory;
	string					m_path;
	string					m_log_path;
	int						m_debug_proc;
	array<int, kCalloutCount> m_callout_refs;

	module();
	module(const module& rhs);
	module& operator=(const module& rhs);

};


#endif /* module_h */
