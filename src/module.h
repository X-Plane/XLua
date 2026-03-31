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

#define XLUA_VERSION "2.0.0a1"

#define NOMINMAX

#include <stddef.h>
#include <sys/types.h>
#include <stdint.h>
#if defined(_MSC_VER)
	typedef int64_t ssize_t;
#endif

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

#include <string>
#include <map>
#include <array>

#include "XPLMDefs.h"

using std::string;

struct module_alloc_block;

struct version_triplet : public std::array<int, 3>
{
public:
	auto operator<=>(version_triplet const& other) const = default;
	bool init_from_string(std::string ver_str);
};

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
	bool				is_started(void) const { return m_interp != nullptr; }
	bool				is_enabled(void) const { return m_enabled; }
	version_triplet const& get_required_version(void) const { return m_xlua_compat; }

			void *		module_alloc_tracked(size_t amount);
			
			// Pushes error string or chunk onto interp stack, returns error code or 0.  
			int			load_module_relative_path(const string& path);
	std::string const&	get_log_path(void) const { return m_log_path; }
	std::string const&	get_script_path(void) const { return m_path; }

	void		acf_load();
	void		acf_unload();
	void		flight_start();
	void		flight_crash();
	void		post_replay();

			// Module-level equivalents of XPLM plugin setup/admin calls.
			bool		_XPluginStart(void);
			void		_XPluginStop(void);
			void		_XPluginReceiveMessage(XPLMPluginID inFromWho, int inMessage, void* inParam);
			bool		_XPluginEnable(void);				// TODO: Add a UI to allow individual scripts to be enabled/disabled.
			void		_XPluginDisable(void);

			// Internal housekeeping, possibly required even for XLua 2+ .
			void		pre_physics();
			void		post_physics();

			void		start_profile(void);
			void		stop_profile(void);
			void		dump_profile() const;
			void		clear_profile(void) { m_profile.clear(); }

			void		set_jit_mode(bool enable);
			bool		get_jit_mode(void);

			struct prof_data
			{
				ssize_t cumulative = 0;
				ssize_t self = 0;
			};

			std::map<std::string, prof_data> m_profile;
			bool m_profile_line_level = false;
private:

		void			do_callout(const char * call_name);
		void			shutdown_lua(void);

	lua_State *				m_interp;
	module_alloc_block *	m_memory;
	string					m_path;
	string					m_log_path;
	int						m_debug_proc;
	bool					m_enabled;
	version_triplet			m_xlua_compat;

	module();
	module(const module& rhs);

};


#endif /* module_h */
