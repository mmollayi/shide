#include "shide.h"
#include <shide/round.h>
#include <shide/make.h>
#include <stdlib.h>

std::string get_current_tzone_cpp();

[[cpp11::register]]
cpp11::writable::doubles
jdate_ceiling_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const auto opt{ string_to_unit(unit_name) };
    if (!opt)
        cpp11::stop("Invalid unit: (%s)", unit_name.c_str());

    const auto unit{*opt};
    if (unit < Unit::day)
        cpp11::stop("Invalid unit: (%s)", unit_name.c_str());

    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::local_days ld;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ld = date::local_days{ date::days(static_cast<int>(xx[i])) };
        out[i] = make_jdate(ceiling_jdate(ld, unit, n));
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdate_floor_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const auto opt{ string_to_unit(unit_name) };
    if (!opt)
        cpp11::stop("Invalid unit: (%s)", unit_name.c_str());

    const auto unit{*opt};
    if (unit < Unit::day)
        cpp11::stop("Invalid unit: (%s)", unit_name.c_str());

    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::local_days ld;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ld = date::local_days{ date::days(static_cast<int>(xx[i])) };
        out[i] = make_jdate(floor_jdate(ld, unit, n));
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdatetime_floor_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const cpp11::strings tz_name_ =  cpp11::as_cpp<cpp11::strings>(x.attr("tzone"));
    std::string tz_name(tz_name_[0]);
    const date::time_zone* tz{};

    if (!tz_name.size())
        tz_name = get_current_tzone_cpp();

    if (!tzdb::locate_zone(tz_name, tz))
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());

    const auto opt{ string_to_unit(unit_name) };
    if (!opt)
        cpp11::stop("Invalid unit: (%s)", unit_name.c_str());

    const auto unit{*opt};
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::sys_seconds ss;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ss = floor_jdatetime(sys_seconds_from_double(xx[i]), tz, unit, n);
        out[i] = static_cast<double>(ss.time_since_epoch().count());
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdatetime_ceiling_cpp(const cpp11::sexp x, const std::string& unit_name, const int n)
{
    const cpp11::strings tz_name_ =  cpp11::as_cpp<cpp11::strings>(x.attr("tzone"));
    std::string tz_name(tz_name_[0]);
    const date::time_zone* tz{};

    if (!tz_name.size())
        tz_name = get_current_tzone_cpp();

    if (!tzdb::locate_zone(tz_name, tz))
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());

    const auto opt{ string_to_unit(unit_name) };
    if (!opt)
        cpp11::stop("Invalid unit: (%s)", unit_name.c_str());

    const auto unit{*opt};
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::sys_seconds ss;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ss = ceiling_jdatetime(sys_seconds_from_double(xx[i]), tz, unit, n);
        out[i] = static_cast<double>(ss.time_since_epoch().count());
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::list
parse_unit_cpp(const cpp11::strings& unit) {
    const std::string unit_(unit[0]);
    const char* unit_char{unit_.c_str()};
    char* end;
    double d{strtod(unit_char, &end)};

    if (unit_char == end)
    {
        d = 1;
    }

    const char* ws = " \t\n\r\f\v";
    std::string s{end};
    // trim from beginning of string
    s.erase(0, s.find_first_not_of(ws));
    // trim from end of string (right)
    s.erase(s.find_last_not_of(ws) + 1);

    cpp11::writable::list out({
        cpp11::writable::doubles{d},
        cpp11::writable::strings{s}
    });
    out.names() = {"n", "unit"};
    return out;
}
