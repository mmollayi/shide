#include "shide.h"
#include "jalali.h"

std::string get_current_tzone_cpp();

[[cpp11::register]]
cpp11::writable::list
get_local_info_cpp(const cpp11::strings& x, const cpp11::strings& tzone)
{
    const date::time_zone* tz{};
    std::string tz_name(tzone[0]);

    if (!tz_name.size())
    {
        tz_name = get_current_tzone_cpp();
    }

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    std::istringstream is;
    const char* fmt{ "%Y-%m-%d %H:%M:%S" };
    std::chrono::minutes offset{};
    date::fields<std::chrono::seconds> fds{};
    fds.has_tod = true;
    std::string* tz_name_{};
    std::string res;

    const R_xlen_t size = x.size();
    cpp11::writable::strings type(size);
    cpp11::writable::doubles first_dst(size);
    cpp11::writable::doubles first_offset(size);
    cpp11::writable::strings first_abbreviation(size);
    cpp11::writable::doubles second_dst(size);
    cpp11::writable::doubles second_offset(size);
    cpp11::writable::strings second_abbreviation(size);
    date::local_info info;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        SEXP elt = x[i];
        const char* p_elt = Rf_translateCharUTF8(elt);
        is.str(p_elt);
        date::from_stream(is, fmt, fds, tz_name_, &offset);

        auto ymd = sh_year_month_day{ fds.ymd };
        auto ld = date::local_days{ ymd };
        auto ls = ld + fds.tod.to_duration();
        tzdb::get_local_info(ls, tz, info);

        switch (info.result)
        {
        case date::local_info::nonexistent:
            res = "nonexistent";
            second_dst[i] = static_cast<double>(info.second.save.count());
            second_offset[i] = static_cast<double>(info.second.offset.count());
            SET_STRING_ELT(second_abbreviation, i,
                           Rf_mkCharLenCE(info.second.abbrev.c_str(), info.second.abbrev.size(), CE_UTF8));
            break;
        case date::local_info::unique:
            res = "unique";
            second_dst[i] = NA_REAL;
            second_offset[i] = NA_REAL;
            SET_STRING_ELT(second_abbreviation, i, NA_STRING);
            break;
        case date::local_info::ambiguous:
            res = "ambiguous";
            second_dst[i] = static_cast<double>(info.second.save.count());
            second_offset[i] = static_cast<double>(info.second.offset.count());
            SET_STRING_ELT(second_abbreviation, i,
                           Rf_mkCharLenCE(info.second.abbrev.c_str(), info.second.abbrev.size(), CE_UTF8));
            break;
        }

        SET_STRING_ELT(type, i, Rf_mkCharLenCE(res.c_str(), res.size(), CE_UTF8));
        first_dst[i] = static_cast<double>(info.first.save.count());
        first_offset[i] = static_cast<double>(info.first.offset.count());
        SET_STRING_ELT(first_abbreviation, i,
                       Rf_mkCharLenCE(info.first.abbrev.c_str(), info.first.abbrev.size(), CE_UTF8));
    }

    cpp11::writable::list out({
        cpp11::writable::strings{tz_name},
        type,
        cpp11::writable::list{first_offset, first_dst, first_abbreviation},
        cpp11::writable::list{second_offset, second_dst, second_abbreviation}
    });
    out.names() = {"name", "type", "first", "second"};
    return out;
}

[[cpp11::register]]
cpp11::writable::list
get_sys_info_cpp(const cpp11::sexp x)
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

    const R_xlen_t size = xx.size();
    cpp11::writable::doubles dst(size);
    cpp11::writable::doubles offset(size);
    cpp11::writable::strings abbreviation(size);
    date::sys_seconds ss;
    date::sys_info info;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            dst[i] = NA_REAL;
            offset[i] = NA_REAL;
            SET_STRING_ELT(abbreviation, i, NA_STRING);
            continue;
        }

        ss = date::sys_seconds{ std::chrono::seconds{ static_cast<int>(xx[0]) } };
        tzdb::get_sys_info(ss, tz, info);
        dst[i] = static_cast<double>(info.save.count());
        offset[i] = static_cast<double>(info.offset.count());
        SET_STRING_ELT(abbreviation, i, Rf_mkCharLenCE(info.abbrev.c_str(), info.abbrev.size(), CE_UTF8));
    }

    cpp11::writable::list out({
        cpp11::writable::strings{tz_name},
        offset,
        dst,
        abbreviation
    });
    out.names() = {"name", "offset", "dst", "abbreviation"};
    return out;
}
