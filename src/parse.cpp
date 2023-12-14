#include "shide.h"
#include "jalali.h"

[[cpp11::register]]
cpp11::writable::doubles
jdate_parse_cpp(const cpp11::strings& x, const cpp11::strings& format)
{
    if (format.size() != 1) {
        cpp11::stop("`format` must have size 1.");
    }

    int year, month, day, days_since_epoch;

    const R_xlen_t size = x.size();
    cpp11::writable::doubles out(size);

    std::string format_(format[0]);
    const char* fmt = format_.c_str();

    std::istringstream is;
    std::chrono::minutes* offptr{};
    std::string* abbrev{};

    for (R_xlen_t i = 0; i < size; ++i)
    {
        const SEXP elt = x[i];

        if (elt == NA_STRING)
        {
            out[i] = NA_REAL;
            continue;
        }

        const char* p_elt = Rf_translateCharUTF8(elt);
        is.str(p_elt);
        is.clear();
        is.seekg(0);

        date::fields<std::chrono::seconds> fds{};
        date::from_stream(is, fmt, fds, abbrev, offptr);

        if (is.fail())
        {
            out[i] = NA_REAL;
            continue;
        }

        year = static_cast<int>(fds.ymd.year());
        month = static_cast<int>(static_cast<unsigned>(fds.ymd.month()));
        day = static_cast<int>(static_cast<unsigned>(fds.ymd.day()));

        if (!year_month_day_ok(year, month, day))
        {
            out[i] = NA_REAL;
            continue;
        }

        days_since_epoch = ymd_to_day(year, month, day) - jd_unix_epoch;
        out[i] = static_cast<double>(days_since_epoch);
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdatetime_parse_cpp(const cpp11::strings& x, const cpp11::strings& format, const cpp11::strings& tzone)
{
    if (format.size() != 1) {
        cpp11::stop("`format` must have size 1.");
    }

    int year, month, day, days_since_epoch;
    date::local_seconds ls;
    std::chrono::seconds seconds_since_epoch;
    const date::time_zone* tz{};
    date::local_info info;
    const std::string tz_name(tzone[0]);

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    const R_xlen_t size = x.size();
    cpp11::writable::doubles out(size);

    std::string format_(format[0]);
    const char* fmt = format_.c_str();

    std::istringstream is;
    std::chrono::minutes* offptr{};
    std::string* abbrev{};

    for (R_xlen_t i = 0; i < size; ++i)
    {
        const SEXP elt = x[i];

        if (elt == NA_STRING)
        {
            out[i] = NA_REAL;
            continue;
        }

        const char* p_elt = Rf_translateCharUTF8(elt);
        is.str(p_elt);
        is.clear();
        is.seekg(0);

        date::fields<std::chrono::seconds> fds{};
        fds.has_tod = true;
        date::from_stream(is, fmt, fds, abbrev, offptr);

        if (is.fail())
        {
            out[i] = NA_REAL;
            continue;
        }

        if (!fds.tod.in_conventional_range())
        {
            out[i] = NA_REAL;
            continue;
        }

        year = static_cast<int>(fds.ymd.year());
        month = static_cast<int>(static_cast<unsigned>(fds.ymd.month()));
        day = static_cast<int>(static_cast<unsigned>(fds.ymd.day()));

        if (!year_month_day_ok(year, month, day))
        {
            out[i] = NA_REAL;
            continue;
        }

        days_since_epoch = ymd_to_day(year, month, day) - jd_unix_epoch;
        ls = date::local_seconds{ date::days{ days_since_epoch } + fds.tod.to_duration() };
        tzdb::get_local_info(ls, tz, info);
        switch (info.result)
        {
        case date::local_info::unique:
            break;
        case date::local_info::nonexistent:
            out[i] = NA_REAL;
            continue;
        case date::local_info::ambiguous:
            out[i] = NA_REAL;
            continue;
        }

        seconds_since_epoch = ls.time_since_epoch() - info.first.offset;
        out[i] = static_cast<double>(seconds_since_epoch.count());
    }

    return out;
}
