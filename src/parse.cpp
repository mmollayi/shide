#include "shide.h"
#include <optional>

enum class choose;
std::optional<choose> string_to_choose(const std::string& choose_str);
double jdatetime_from_local_seconds(const date::local_seconds& ls, const date::time_zone* tz,
                                    date::local_info& info, choose c,
                                    const date::sys_seconds* ss_ref=nullptr);
double make_jdate(const sh_year_month_day& ymd);

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
        out[i] = make_jdate(ymd);
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
    date::local_seconds ls;
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

        ls = local_days(ymd) + fds.tod.to_duration();
        out[i] = jdatetime_from_local_seconds(ls, tz, info, Ambiguous);
    }

    return out;
}
