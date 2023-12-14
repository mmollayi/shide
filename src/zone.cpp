#include "shide.h"
#include "jalali.h"

[[cpp11::register]]
cpp11::writable::strings
get_zone_info(const cpp11::strings& x, const cpp11::strings& tzone)
{
    const date::time_zone* tz{};
    const std::string tz_name(tzone[0]);

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    cpp11::writable::strings out(1);
    date::local_info info;
    std::istringstream is;
    const SEXP elt = x[0];

    // if (elt == NA_STRING)
    // {
    //     out[i] = NA_REAL;
    //     continue;
    // }

    const char* p_elt = Rf_translateCharUTF8(elt);
    is.str(p_elt);
    const char* fmt{ "%Y-%m-%d %H:%M:%S" };
    std::chrono::minutes offset{};
    date::fields<std::chrono::seconds> fds{};
    fds.has_tod = true;
    std::string* tz_name_{};
    date::from_stream(is, fmt, fds, tz_name_, &offset);

    int year = static_cast<int>(fds.ymd.year());
    int month = static_cast<int>(static_cast<unsigned>(fds.ymd.month()));
    int day = static_cast<int>(static_cast<unsigned>(fds.ymd.day()));

    int days_since_epoch = ymd_to_day(year, month, day) - jd_unix_epoch;
    auto ls = date::local_seconds{ date::days{ days_since_epoch } + fds.tod.to_duration() };
    tzdb::get_local_info(ls, tz, info);

    std::string res;
    switch (info.result)
    {
    case date::local_info::nonexistent:
        res = "nonexistent";
        break;
    case date::local_info::unique:
        res = "unique";
        break;
    case date::local_info::ambiguous:
        res = "ambiguous";
        break;
    }

    SET_STRING_ELT(out, 0, Rf_mkCharLenCE(res.c_str(), res.size(), CE_UTF8));
    return out;
}
