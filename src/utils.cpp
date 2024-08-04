# include "shide.h"

date::local_seconds to_local_seconds(const date::sys_seconds& tp,
                                     const date::time_zone* p_time_zone,
                                     date::sys_info& info)
{
    tzdb::get_sys_info(tp, p_time_zone, info);
    return date::local_seconds{ (tp + info.offset).time_since_epoch() };
}

date::local_days to_local_days(const date::sys_seconds& tp,
                               const date::time_zone* p_time_zone,
                               date::sys_info& info)
{
    return date::floor<date::days>(to_local_seconds(tp, p_time_zone, info));
}

[[cpp11::register]]
cpp11::writable::doubles
sys_seconds_from_local_days_cpp(const cpp11::doubles x, const cpp11::strings& tzone)
{
    const std::string tz_name(tzone[0]);
    const date::time_zone* tz{};

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    const R_xlen_t size = x.size();
    cpp11::writable::doubles out(size);
    std::chrono::seconds seconds_since_epoch;
    date::local_seconds ls;
    date::local_info info;

    for (R_xlen_t i = 0; i < size; ++i) {
        if (std::isnan(x[i])) {
            out[i] = NA_REAL;
            continue;
        }

        ls = date::local_seconds{ date::days{ static_cast<int>(x[i]) }};
        tzdb::get_local_info(ls, tz, info);
        seconds_since_epoch = ls.time_since_epoch() - info.first.offset;
        out[i] = static_cast<double>(seconds_since_epoch.count());
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
local_days_from_sys_seconds_cpp(const cpp11::doubles x, const cpp11::strings& tzone)
{
    const std::string tz_name(tzone[0]);
    const date::time_zone* tz{};

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    const R_xlen_t size = x.size();
    cpp11::writable::doubles out(size);
    date::local_days ld{};
    date::sys_info info;
    date::sys_seconds ss{};

    for (R_xlen_t i = 0; i < size; ++i) {
        if (std::isnan(x[i])) {
            out[i] = NA_REAL;
            continue;
        }

        ss = sys_seconds_from_double(x[i]);
        ld = to_local_days(ss, tz, info);
        out[i] = static_cast<double>(ld.time_since_epoch().count());
    }

    return out;
}

std::string get_current_tzone_cpp() {
    auto get_current_tzone = cpp11::package("shide")["get_current_tzone"];
    cpp11::sexp result = get_current_tzone();
    cpp11::strings tz_name_ = cpp11::as_cpp<cpp11::strings>(result);
    std::string tz_name(tz_name_[0]);
    return tz_name;
}

date::sys_seconds sys_seconds_from_double(double x)
{
    return date::sys_seconds{ std::chrono::seconds{ static_cast<long long>(x) } };
}
