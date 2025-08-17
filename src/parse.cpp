#include "shide.h"
#include <shide/make.h>

[[cpp11::register]]
cpp11::writable::doubles
jdate_parse_cpp(const cpp11::strings& x, const cpp11::strings& format)
{
    if (format.size() != 1) {
        cpp11::stop("`format` must have size 1.");
    }

    const R_xlen_t size = x.size();
    cpp11::writable::doubles out(size);

    std::string format_(format[0]);
    const char* fmt = format_.c_str();

    std::istringstream is;
    std::chrono::minutes* offptr{};
    std::string* abbrev{};
    std::optional<double> d{};

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

        auto ymd = sh_year_month_day{fds.ymd.year(), fds.ymd.month(), fds.ymd.day()};
        d = make_jdate(ymd);
        out[i] = d.has_value() ? *d : NA_REAL;
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdatetime_parse_cpp(const cpp11::strings& x, const cpp11::strings& format,
                    const cpp11::strings& tzone, const std::string& ambiguous)
{
    if (format.size() != 1) {
        cpp11::stop("`format` must have size 1.");
    }

    const auto opt{ string_to_choose(ambiguous) };

    if (!opt) {
        cpp11::stop("Invalid ambiguous relolution strategy");
    }

    const auto Ambiguous{*opt};
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
    sh_year_month_day ymd{};
    sh_fields sh_fds{};
    sh_fds.has_tod = true;
    std::optional<double> dt{};

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

        ymd = {fds.ymd.year(), fds.ymd.month(), fds.ymd.day()};

        if (!ymd.ok())
        {
            out[i] = NA_REAL;
            continue;
        }

        sh_fds.ymd = ymd;
        sh_fds.tod = hour_minute_second(fds.tod.to_duration());
        dt = make_jdatetime(sh_fds, tz, info, Ambiguous);
        out[i] = dt.has_value() ? *dt : NA_REAL;
    }

    return out;
}
