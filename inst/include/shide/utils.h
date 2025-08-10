#ifndef UTILS_H
#define UTILS_H

#include "shide/sh_year_month_day.h"
#include "shide/tzdb.h"

using date::sys_seconds;
using date::local_seconds;
using date::sys_info;
using date::local_info;

inline
local_seconds
to_local_seconds(const sys_seconds& tp, const date::time_zone* p_time_zone, sys_info& info)
{
    tzdb::get_sys_info(tp, p_time_zone, info);
    return local_seconds{ (tp + info.offset).time_since_epoch() };
}

inline
local_seconds
to_local_seconds(const sys_seconds& tp, const date::time_zone* p_time_zone)
{
    sys_info info;
    tzdb::get_sys_info(tp, p_time_zone, info);
    return local_seconds{ (tp + info.offset).time_since_epoch() };
}

inline
local_days
to_local_days(const sys_seconds& tp, const date::time_zone* p_time_zone, sys_info& info)
{
    return date::floor<date::days>(to_local_seconds(tp, p_time_zone, info));
}

inline
sys_seconds
to_sys_seconds(const local_seconds& tp, const date::time_zone* p_time_zone, local_info& info)
{
    tzdb::get_local_info(tp, p_time_zone, info);
    return sys_seconds{ tp.time_since_epoch() - info.first.offset };
}

inline
sys_seconds
to_sys_seconds(const local_seconds& tp, const date::time_zone* p_time_zone)
{
    local_info info;
    tzdb::get_local_info(tp, p_time_zone, info);
    return sys_seconds{ tp.time_since_epoch() - info.first.offset };
}

#endif
