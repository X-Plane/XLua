//
//  xpdatarefs.cpp
//  xlua
//
//  Created by Ben Supnik on 3/20/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include <cstdio>
#include "xpdatarefs.h"

#include <XPLMDataAccess.h>
#include <XPLMPlugin.h>

#include <vector>
#include <assert.h>
#include <algorithm>

#include "../log.h"

using std::min;
using std::max;
using std::vector;

#define MSG_ADD_DATAREF 0x01000000
#if !MOBILE
#define STAT_PLUGIN_SIG "xplanesdk.examples.DataRefEditor"
#endif

//#define TRACE_DATAREFS printf
#define TRACE_DATAREFS(...)


struct	xlua_dref {
	xlua_dref *				m_next;
	string					m_name;
	XPLMDataRef				m_dref;
	int						m_index;	// -1 if index is NOT bound.
	XPLMDataTypeID			m_types;
	int						m_ours;		// 1 if we made, 0 if system
	xlua_dref_notify_f		m_notify_func;
	void *					m_notify_ref;
	
	// IF we made the dataref, this is where our storage is!
	double					m_number_storage;
	vector<double>			m_array_storage;
	string					m_string_storage;
};

static xlua_dref *		s_drefs = NULL;

// For nunmbers
static int	xlua_geti(void * ref)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	return r->m_number_storage;
}

static void	xlua_seti(void * ref, int v)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	double vv = v;
	if(r->m_number_storage != vv)
	{
		r->m_number_storage = vv;
		if(r->m_notify_func)
			r->m_notify_func(r, r->m_notify_ref);
	}
}

static float xlua_getf(void * ref)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	return r->m_number_storage;
}

static void	xlua_setf(void * ref, float v)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	double vv = v;
	if(r->m_number_storage != vv)
	{
		r->m_number_storage = vv;
		if(r->m_notify_func)
			r->m_notify_func(r, r->m_notify_ref);
	}
}

static double xlua_getd(void * ref)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	return r->m_number_storage;
}

static void	xlua_setd(void * ref, double v)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	double vv = v;
	if(r->m_number_storage != vv)
	{
		r->m_number_storage = vv;
		if(r->m_notify_func)
			r->m_notify_func(r, r->m_notify_ref);
	}
}

// For arrays
static int xlua_getvi(void * ref, int * values, int offset, int max)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	if(values == NULL)
		return r->m_array_storage.size();
	if(offset >= r->m_array_storage.size())
		return 0;
	int count = min(max, (int) r->m_array_storage.size() - offset);
	for(int i = 0; i < count; ++i)
		values[i] = r->m_array_storage[i + offset];
	return count;
}

static void xlua_setvi(void * ref, int * values, int offset, int max)
{
	assert(values);
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	if(offset >= r->m_array_storage.size())
		return;
	int count = min(max, (int) r->m_array_storage.size() - offset);
	int changed = 0;
	for(int i = 0; i < count; ++i)
	{
		double vv = values[i];
		if(r->m_array_storage[i + offset] != vv)
		{
			r->m_array_storage[i + offset] = vv;
			changed = 1;
		}
	}
	if(changed && r->m_notify_func)
		r->m_notify_func(r,r->m_notify_ref);
}

static int xlua_getvf(void * ref, float * values, int offset, int max)
{
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	if(values == NULL)
		return r->m_array_storage.size();
	if(offset >= r->m_array_storage.size())
		return 0;
	int count = min(max, (int) r->m_array_storage.size() - offset);
	for(int i = 0; i < count; ++i)
		values[i] = r->m_array_storage[i + offset];
	return count;
}

static void xlua_setvf(void * ref, float * values, int offset, int max)
{
	assert(values);
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	if(offset >= r->m_array_storage.size())
		return;
	int changed = 0;
	int count = min(max, (int) r->m_array_storage.size() - offset);
	for(int i = 0; i < count; ++i)
	{
		double vv = values[i];
		if(r->m_array_storage[i + offset] != vv)
		{
			r->m_array_storage[i + offset] = vv;
			changed = 1;
		}
	}
	if(changed && r->m_notify_func)
		r->m_notify_func(r,r->m_notify_ref);
}

// For strings
static int xlua_getvb(void * ref, void * values, int offset, int max)
{
	char * dst = (char *) values;
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	if(values == NULL)
		return r->m_string_storage.size();
	if(offset >= r->m_string_storage.size())
		return 0;
	int count = min(max, (int) r->m_string_storage.size() - offset);
	for(int i = 0; i < count; ++i)
		dst[i] = r->m_string_storage[i + offset];
	return count;
}

static void xlua_setvb(void * ref, void * values, int offset, int max)
{
	assert(values);
	const char * src = (const char *) values;
	int new_len = offset + max;
	xlua_dref * r = (xlua_dref *) ref;
	assert(r->m_ours);
	string orig(r->m_string_storage);
	r->m_string_storage.resize(new_len);
	for(int i = 0; i < max; ++i)
		r->m_string_storage[i + offset] = src[i];
	if(r->m_notify_func && r->m_string_storage != orig)
		r->m_notify_func(r,r->m_notify_ref);
}

static void resolve_dref(xlua_dref * d)
{
	assert(d->m_dref == NULL);
	assert(d->m_types == 0);
	assert(d->m_index == -1);
	assert(d->m_ours == 0);
	d->m_dref = XPLMFindDataRef(d->m_name.c_str());
	if(d->m_dref)
	{
		d->m_index = -1;
		d->m_types = XPLMGetDataRefTypes(d->m_dref);
	}
	else
	{
		string::size_type obrace = d->m_name.find('[');
		string::size_type cbrace = d->m_name.find(']');
		if(obrace != d->m_name.npos && cbrace != d->m_name.npos)			// Gotta have found the braces
		if(obrace > 0)														// dref name can't be empty
		if(cbrace > obrace)													// braces must be in-order - avoids unsigned math insanity
		if((cbrace - obrace) > 1)											// Gotta have SOMETHING in between the braces
		{
			string number = d->m_name.substr(obrace+1,cbrace - obrace - 1);
			string refname = d->m_name.substr(0,obrace);
			
			XPLMDataRef arr = XPLMFindDataRef(refname.c_str());				// Only if we have a valid name
			if(arr)
			{
				XPLMDataTypeID tid = XPLMGetDataRefTypes(arr);
				if(tid & (xplmType_FloatArray | xplmType_IntArray))			// AND are array type
				{
					int idx = atoi(number.c_str());							// AND have a non-negetive index
					if(idx >= 0)
					{
						d->m_dref = arr;									// Now we know we're good, record all of our info
						d->m_types = tid;
						d->m_index = idx;
					}
				}
			}
		}
	}
}

void			xlua_validate_drefs()
{
#if MOBILE
	bool dref_missing = false;
	for(xlua_dref * f = s_drefs; f; f = f->m_next)
	{
		if(f->m_dref == NULL)
		{
			dref_missing = true;
			printf("WARNING: dataref %s is used but not defined.\n", f->m_name.c_str());
		}
	}
	
	assert(!dref_missing);
	
#else
	for(xlua_dref * f = s_drefs; f; f = f->m_next)
	{
		if(f->m_dref == NULL)
#if defined (NO_LOG_MESSAGE)
			printf("WARNING: dataref %s is used but not defined.\n", f->m_name.c_str());
#else
			log_message("xlua: WARNING: dataref %s is used but not defined.\n", f->m_name.c_str());
#endif
	}
#endif
}

xlua_dref *		xlua_find_dref(const char * name)
{
	for(xlua_dref * f = s_drefs; f; f = f->m_next)
	if(f->m_name == name)
	{
		TRACE_DATAREFS("Found %s as %p\n", name,f);
		return f;
	}
	// We have never tried to find this dref before - make a new record
	xlua_dref * d = new xlua_dref;
	d->m_next = s_drefs;
	s_drefs = d;
	d->m_name = name;
	d->m_dref = NULL;
	d->m_index = -1;
	d->m_types = 0;
	d->m_ours = 0;
	d->m_notify_func = NULL;
	d->m_notify_ref = NULL;
	d->m_number_storage = 0;
	
	resolve_dref(d);

	TRACE_DATAREFS("Speculating %s as %p\n", name,d);

	return d;
}

xlua_dref *		xlua_create_dref(const char * name, xlua_dref_type type, int dim, int writable, xlua_dref_notify_f func, void * ref)
{
	assert(type != xlua_none);
	assert(name);
	assert(type != xlua_array || dim > 0);
	assert(writable || func == NULL);
	
	string n(name);
	xlua_dref * f;
	for(f = s_drefs; f; f = f->m_next)
	if(f->m_name == n)
	{
		if(f->m_ours || f->m_dref)
		{
#if defined (NO_LOG_MESSAGE)
			printf("ERROR: %s is already a dataref.\n",name);
#else
			log_message("xlua: ERROR: %s is already a dataref.\n", name);
#endif
			return NULL;
		}
		TRACE_DATAREFS("Reusing %s as %p\n", name,f);		
		break;
	}
	
	if(n.find('[') != n.npos)
	{
#if defined (NO_LOG_MESSAGE)
		printf("ERROR: %s contains brackets in its name.\n", name);
#else
		log_message("xlua: ERROR: %s contains brackets in its name.\n", name);
#endif
		return NULL;
	}
	
	XPLMDataRef other = XPLMFindDataRef(name);
	if(other && XPLMIsDataRefGood(other))
	{
#if defined (NO_LOG_MESSAGE)
		printf("ERROR: %s is used by another plugin.\n", name);
#else
		log_message("xlua: ERROR: %s is used by another plugin.\n", name);
#endif
		return NULL;
	}
	
	xlua_dref * d = f;
	if(!d)
	{
		d = new xlua_dref;
		d->m_next = s_drefs;
		s_drefs = d;
		TRACE_DATAREFS("Creating %s as %p\n", name,d);		
	}
	d->m_name = name;
	d->m_index = -1;
	d->m_ours = 1;
	d->m_notify_func = func;
	d->m_notify_ref = ref;
	d->m_number_storage = 0;

	switch(type) {
	case xlua_number:
		d->m_types = xplmType_Int|xplmType_Float|xplmType_Double;
		d->m_dref = XPLMRegisterDataAccessor(name, d->m_types, writable,
						xlua_geti, xlua_seti,
						xlua_getf, xlua_setf,
						xlua_getd, xlua_setd,
						NULL, NULL,
						NULL, NULL,
						NULL, NULL,
						d, d);
		break;
	case xlua_array:
		d->m_types = xplmType_FloatArray|xplmType_IntArray;
		d->m_dref = XPLMRegisterDataAccessor(name, d->m_types, writable,
						NULL, NULL,
						NULL, NULL,
						NULL, NULL,
						xlua_getvi, xlua_setvi,
						xlua_getvf, xlua_setvf,
						NULL, NULL,
						d, d);
		d->m_array_storage.resize(dim);
		break;
	case xlua_string:
		d->m_types = xplmType_Data;
		d->m_dref = XPLMRegisterDataAccessor(name, d->m_types, writable,
						NULL, NULL,
						NULL, NULL,
						NULL, NULL,
						NULL, NULL,
						NULL, NULL,
						xlua_getvb, xlua_setvb,
						d, d);
		break;
	case xlua_none:
		break;
	}

	return d;
}

xlua_dref_type	xlua_dref_get_type(xlua_dref * who)
{
	if(who->m_types & xplmType_Data)
		return xlua_string;
	if(who->m_index >= 0)
		return  xlua_number;
	if(who->m_types & (xplmType_FloatArray|xplmType_IntArray))
		return xlua_array;
	if(who->m_types & (xplmType_Int|xplmType_Float|xplmType_Double))
		return xlua_number;
	return xlua_none;
}

int	xlua_dref_get_dim(xlua_dref * who)
{
	if(who->m_ours)
		return who->m_array_storage.size();
	if(who->m_types & xplmType_Data)
		return 0;
	if(who->m_index >= 0)
		return  1;
	if(who->m_types & xplmType_FloatArray)
	{
		return XPLMGetDatavf(who->m_dref, NULL, 0, 0);
	}
	if(who->m_types & xplmType_IntArray)
	{
		return XPLMGetDatavi(who->m_dref, NULL, 0, 0);
	}
	if(who->m_types & (xplmType_Int|xplmType_Float|xplmType_Double))
		return 1;
	return 0;
}

double			xlua_dref_get_number(xlua_dref * d)
{
	if(d->m_ours)
		return d->m_number_storage;
	
	if(d->m_index >= 0)
	{
		if(d->m_types & xplmType_FloatArray)
		{
			float r;
			if(XPLMGetDatavf(d->m_dref, &r, d->m_index, 1))
				return r;
			return 0.0;
		}
		if(d->m_types & xplmType_IntArray)
		{
			int r;
			if(XPLMGetDatavi(d->m_dref, &r, d->m_index, 1))
				return r;
			return 0.0;
		}
		return 0.0;
	}
	if(d->m_types & xplmType_Double)
	{
		return XPLMGetDatad(d->m_dref);
	}
	if(d->m_types & xplmType_Float)
	{
		return XPLMGetDataf(d->m_dref);
	}
	if(d->m_types & xplmType_Int)
	{
		return XPLMGetDatai(d->m_dref);
	}
	return 0.0;
}

void			xlua_dref_set_number(xlua_dref * d, double value)
{
	if(d->m_ours)
	{
		d->m_number_storage = value;
		return;
	}

	if(d->m_index >= 0)
	{
		if(d->m_types & xplmType_FloatArray)
		{
			float r = value;
			XPLMSetDatavf(d->m_dref, &r, d->m_index, 1);
		}
		if(d->m_types & xplmType_IntArray)
		{
			int r = value;
			XPLMSetDatavi(d->m_dref, &r, d->m_index, 1);
		}
	}
	if(d->m_types & xplmType_Double)
	{
		XPLMSetDatad(d->m_dref, value);
	}
	if(d->m_types & xplmType_Float)
	{
		XPLMSetDataf(d->m_dref, value);
	}
	if(d->m_types & xplmType_Int)
	{
		XPLMSetDatai(d->m_dref, value);
	}
}

double			xlua_dref_get_array(xlua_dref * d, int n)
{
	assert(n >= 0);
	if(d->m_ours)
	{
		if(n < d->m_array_storage.size())
			return d->m_array_storage[n];
		return 0.0;
	}
	if(d->m_types & xplmType_FloatArray)
	{
		float r;
		if(XPLMGetDatavf(d->m_dref, &r, n, 1))
			return r;
		return 0.0;
	}
	if(d->m_types & xplmType_IntArray)
	{
		int r;
		if(XPLMGetDatavi(d->m_dref, &r, n, 1))
			return r;
		return 0.0;
	}
	return 0.0;
}

void			xlua_dref_set_array(xlua_dref * d, int n, double value)
{
	assert(n >= 0);
	if(d->m_ours)
	{
		if(n < d->m_array_storage.size())
			d->m_array_storage[n] = value;
		return;
	}
	if(d->m_types & xplmType_FloatArray)
	{
		float r = value;
		XPLMSetDatavf(d->m_dref, &r, n, 1);
	}
	if(d->m_types & xplmType_IntArray)
	{
		int r = value;
		XPLMSetDatavi(d->m_dref, &r, n, 1);
	}
}

string			xlua_dref_get_string(xlua_dref * d)
{
	if(d->m_ours)
		return d->m_string_storage;
	
	if(d->m_types & xplmType_Data)
	{
		int l = XPLMGetDatab(d->m_dref, NULL, 0, 0);
		if(l > 0)
		{
			vector<char>	buf(l);
			l = XPLMGetDatab(d->m_dref, &buf[0], 0, l);
			assert(l <= buf.size());
			if(l == buf.size())
			{
				return string(buf.begin(),buf.end());
			}
		}
	}
	return string();
}

void			xlua_dref_set_string(xlua_dref * d, const string& value)
{
	if(d->m_ours)
	{
		d->m_string_storage = value;
		return;
	}
	if(d->m_types & xplmType_Data)
	{
		const char * begin = value.c_str();
		const char * end = begin + value.size();
		if(end > begin)
		{
			XPLMSetDatab(d->m_dref, (void *) begin, 0, end - begin);
		}
	}
}

// This attempts to re-establish the name->dref link for any unresolved drefs.  This can be used if we declare
// our dref early and then ANOTHER add-on is loaded that defines it.
void			xlua_relink_all_drefs()
{
#if !MOBILE
	XPLMPluginID dre = XPLMFindPluginBySignature(STAT_PLUGIN_SIG);
	if(dre != XPLM_NO_PLUGIN_ID)
	if(!XPLMIsPluginEnabled(dre))
	{
#if defined (NO_LOG_MESSAGE)
		printf("WARNING: can't register drefs - DRE is not enabled.\n");
#else
		log_message("xlua: WARNING: can't register drefs - DRE is not enabled.\n");
#endif
		dre = XPLM_NO_PLUGIN_ID;
	}
#endif
	for(xlua_dref * d = s_drefs; d; d = d->m_next)
	{
		if(d->m_dref == NULL)
		{
			assert(!d->m_ours);
			resolve_dref(d);
		}
#if !MOBILE
		if(d->m_ours)
		if(dre != XPLM_NO_PLUGIN_ID)
		{
//			printf("registered: %s\n", d->m_name.c_str());
			XPLMSendMessageToPlugin(dre, MSG_ADD_DATAREF, (void *)d->m_name.c_str());		
		}		
#endif
	}
}

void			xlua_dref_cleanup()
{
	while(s_drefs)
	{
		xlua_dref *	kill = s_drefs;
		s_drefs = s_drefs->m_next;
		
		if(kill->m_dref && kill->m_ours)
		{
			XPLMUnregisterDataAccessor(kill->m_dref);
		}
		
		delete kill;
	}

	assert(s_drefs == nullptr);
}



