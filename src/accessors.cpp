#include "shide.h"

std::string get_current_tzone_cpp();
sh_fields make_sh_fields(const date::local_seconds& ls);
date::local_seconds to_local_seconds(const date::sys_seconds& tp,
                                     const date::time_zone* p_time_zone,
                                     date::sys_info& info);

[[cpp11::register]]
cpp11::writable::list
jdate_get_fields_cpp(const cpp11::sexp x)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::integers year(size);
    cpp11::writable::integers month(size);
    cpp11::writable::integers day(size);

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            year[i] = NA_INTEGER;
            month[i] = NA_INTEGER;
            day[i] = NA_INTEGER;
            continue;
        }

        auto ymd = sh_year_month_day{ date::local_days{ date::days(static_cast<int>(xx[i])) } };
        year[i] = int{ ymd.year() };
        month[i] = static_cast<int>(unsigned{ ymd.month() });
        day[i] = static_cast<int>(unsigned{ ymd.day() });
    }

    cpp11::writable::list out({year, month, day});
    out.names() = {"year", "month", "day"};
    return out;
}

[[cpp11::register]]
cpp11::writable::list
jdatetime_get_fields_cpp(const cpp11::sexp x)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const cpp11::strings tz_name_ =  cpp11::as_cpp<cpp11::strings>(x.attr("tzone"));
    std::string tz_name(tz_name_[0]);
    const date::time_zone* tz{};

    if (!tz_name.size())
    {
        tz_name = get_current_tzone_cpp();
    }

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    date::sys_seconds ss;
    date::sys_info info;

    const R_xlen_t size = xx.size();
    cpp11::writable::integers year(size);
    cpp11::writable::integers month(size);
    cpp11::writable::integers day(size);
    cpp11::writable::integers hour(size);
    cpp11::writable::integers minute(size);
    cpp11::writable::integers second(size);

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            year[i] = NA_INTEGER;
            month[i] = NA_INTEGER;
            day[i] = NA_INTEGER;
            hour[i] = NA_INTEGER;
            minute[i] = NA_INTEGER;
            second[i] = NA_INTEGER;
            continue;
        }

        ss = sys_seconds_from_double(xx[i]);
        auto fds = make_sh_fields( to_local_seconds(ss, tz, info) );

        year[i] = int{ fds.ymd.year() };
        month[i] = static_cast<int>(unsigned{ fds.ymd.month() });
        day[i] = static_cast<int>(unsigned{ fds.ymd.day() });
        hour[i] = fds.tod.hours().count();
        minute[i] = fds.tod.minutes().count();
        second[i] = static_cast<int>(fds.tod.seconds().count());
    }

    cpp11::writable::list out({year, month, day, hour, minute, second});
    out.names() = {"year", "month", "day", "hour", "minute", "second"};
    return out;
}

[[cpp11::register]]
cpp11::writable::integers
jdate_get_yday_cpp(const cpp11::sexp x)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::integers out(size);

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_INTEGER;
            continue;
        }

        auto ymd = sh_year_month_day{ date::local_days{ date::days(static_cast<int>(xx[i])) } };
        out[i] = sh_yday(ymd).count();
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::integers
jdate_get_wday_cpp(const cpp11::sexp x)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::integers out(size);
    date::local_days ld{};

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_INTEGER;
            continue;
        }

        ld = date::local_days{ date::days(static_cast<int>(xx[i])) };
        out[i] = sh_wday(ld).count();
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::integers
jdate_get_qday_cpp(const cpp11::sexp x)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::integers out(size);

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_INTEGER;
            continue;
        }

        auto ymd = sh_year_month_day{ date::local_days{ date::days(static_cast<int>(xx[i])) } };
        out[i] = sh_qday(ymd).count();
    }

    return out;
}
