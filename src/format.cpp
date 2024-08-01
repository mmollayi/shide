#include "shide.h"
#include "jalali.h"

std::string get_current_tzone_cpp();

[[cpp11::register]]
cpp11::writable::strings
format_jdate_cpp(const cpp11::doubles x,
                   const cpp11::strings& format)
{
    int jd, year, month, day;

    if (format.size() != 1) {
        cpp11::stop("`format` must have size 1.");
    }

    const R_xlen_t size = x.size();
    cpp11::writable::strings out(size);

    const std::string format_(format[0]);
    const char* fmt = format_.c_str();

    std::ostringstream os;
    os.imbue(std::locale::classic());

    for (R_xlen_t i = 0; i < size; ++i) {
        if (std::isnan(x[i])) {
            SET_STRING_ELT(out, i, NA_STRING);
            continue;
        }

        os.str(std::string());
        os.clear();

        jd = static_cast<int>(x[i]) + jd_unix_epoch;
        day_to_ymd(jd, &year, &month, &day);
        auto ymd = date::year{year}/month/day;

        date::to_stream(os, fmt, ymd);

        if (os.fail()) {
            SET_STRING_ELT(out, i, NA_STRING);
            continue;
        }

        std::string str = os.str();
        SET_STRING_ELT(out, i, Rf_mkCharLenCE(str.c_str(), str.size(), CE_UTF8));
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::strings
format_jdatetime_cpp(const cpp11::sexp x,
                       const cpp11::strings& format)
{
    if (format.size() != 1) {
        cpp11::stop("`format` must have size 1.");
    }

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
    sh_year_month_day ymd{};
    date::year_month_day ymd2{};
    date::sys_info info;

    const R_xlen_t size = xx.size();
    cpp11::writable::strings out(size);

    std::string format_(format[0]);
    const char* fmt = format_.c_str();

    std::ostringstream os;
    os.imbue(std::locale::classic());

    for (R_xlen_t i = 0; i < size; ++i) {
        if (std::isnan(xx[i])) {
            SET_STRING_ELT(out, i, NA_STRING);
            continue;
        }

        os.str(std::string());
        os.clear();

        ss = sys_seconds_from_double(xx[i]);
        tzdb::get_sys_info(ss, tz, info);
        ls = date::local_seconds{(ss + info.offset).time_since_epoch()};
        ld = date::floor<date::days>(ls);
        auto tod = date::hh_mm_ss<std::chrono::seconds>{ ls - date::local_seconds{ ld } };
        ymd = sh_year_month_day{ ld };
        ymd2 = {ymd.year(), ymd.month(), ymd.day()};

        date::fields<std::chrono::seconds> fds{ ymd2, tod };
        date::to_stream(os, fmt, fds, &tz_name, &info.offset);

        if (os.fail()) {
            SET_STRING_ELT(out, i, NA_STRING);
            continue;
        }

        std::string str = os.str();
        SET_STRING_ELT(out, i, Rf_mkCharLenCE(str.c_str(), str.size(), CE_UTF8));
    }

    return out;
}
