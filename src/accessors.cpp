#include "shide.h"

std::string get_current_tzone_cpp();

int
local_ydays(const sh_year_month_day& ymd)
{
    static const int month_data_cum[12] = {0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336};
    int m{static_cast<int>(unsigned{ ymd.month() })};
    int d{static_cast<int>(unsigned{ ymd.day() })};
    return month_data_cum[m-1] + d;
}

[[cpp11::register]]
cpp11::writable::list
jdate_get_fields_cpp(const cpp11::sexp x)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::integers year(size);
    cpp11::writable::integers month(size);
    cpp11::writable::integers day(size);
    sh_year_month_day ymd{};

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            year[i] = NA_INTEGER;
            month[i] = NA_INTEGER;
            day[i] = NA_INTEGER;
            continue;
        }

        ymd = sh_year_month_day{ date::local_days{ date::days(static_cast<int>(xx[i])) } };
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

    date::local_seconds ls;
    date::sys_seconds ss;
    date::local_days ld;
    date::sys_info info;

    const R_xlen_t size = xx.size();
    cpp11::writable::integers year(size);
    cpp11::writable::integers month(size);
    cpp11::writable::integers day(size);
    cpp11::writable::integers hour(size);
    cpp11::writable::integers minute(size);
    cpp11::writable::integers second(size);
    sh_year_month_day ymd{};

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

        ss = date::sys_seconds{ std::chrono::seconds{ static_cast<int>(xx[i]) } };
        tzdb::get_sys_info(ss, tz, info);
        ls = date::local_seconds{(ss + info.offset).time_since_epoch()};
        ld = date::floor<date::days>(ls);
        ymd = sh_year_month_day{ ld };
        auto tod = date::hh_mm_ss<std::chrono::seconds>{ ls - date::local_seconds{ ld } };

        year[i] = int{ ymd.year() };
        month[i] = static_cast<int>(unsigned{ ymd.month() });
        day[i] = static_cast<int>(unsigned{ ymd.day() });
        hour[i] = tod.hours().count();
        minute[i] = tod.minutes().count();
        second[i] = static_cast<int>(tod.seconds().count());
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
    sh_year_month_day ymd{};

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_INTEGER;
            continue;
        }

        ymd = sh_year_month_day{ date::local_days{ date::days(static_cast<int>(xx[i])) } };
        out[i] = local_ydays(ymd);
    }

    return out;
}
