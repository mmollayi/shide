#include "shide.h"
#include <shide/format.h>
#include <shide/make.h>

std::string get_current_tzone_cpp();
using string_pair_ptr = std::pair<const std::string*, const std::string*>;

auto
make_month_names(const cpp11::strings& names, const cpp11::strings& names_abbrev)
{
    constexpr int N{ 24 };
    std::array<std::string, N> nm;
    for (int i = 0; i < N/2; i++)
    {
        nm[i] = CHAR(names[i]);
    }

    for (int i = 0; i < N/2; i++)
    {
        nm[i+N/2] = CHAR(names_abbrev[i]);
    }

    return nm;
}

auto
make_weekday_names(const cpp11::strings& names, const cpp11::strings& names_abbrev)
{
    constexpr int N{ 14 };
    std::array<std::string, N> nm;
    for (int i = 0; i < N/2; i++)
    {
        nm[i] = CHAR(names[i]);
    }

    for (int i = 0; i < N/2; i++)
    {
        nm[i+N/2] = CHAR(names_abbrev[i]);
    }

    // rotate elements to align with the convention that sunday is the first weekday
    std::rotate(nm.begin(), nm.begin() + 1, nm.begin() + 7);
    std::rotate(nm.begin() + 7, nm.begin() + 8, nm.end());
    return nm;
}

auto
make_ampm_names(const cpp11::strings& names) {
    constexpr int N{ 2 };
    std::array<std::string, N> nm;;
    for (int i = 0; i < N; i++) {
        nm[i] = CHAR(names[i]);
    }

    return nm;
}

[[cpp11::register]]
cpp11::writable::strings
format_jdate_cpp(const cpp11::doubles x,
                 const cpp11::strings& format,
                 const cpp11::strings& month_nms,
                 const cpp11::strings& month_nms_abbrev,
                 const cpp11::strings& weekday_nms,
                 const cpp11::strings& weekday_nms_abbrev)
                 //const cpp11::strings& ampm_nms)
{
    if (format.size() != 1) {
        cpp11::stop("`format` must have size 1.");
    }

    const R_xlen_t size = x.size();
    cpp11::writable::strings out(size);
    const std::string format_(format[0]);
    const char* fmt = format_.c_str();
    const auto month_names = make_month_names(month_nms, month_nms_abbrev);
    const auto weekday_names = make_weekday_names(weekday_nms, weekday_nms_abbrev);

    date::local_days ld;
    sh_year_month_day ymd{};
    std::ostringstream os;
    os.imbue(std::locale::classic());

    for (R_xlen_t i = 0; i < size; ++i) {
        if (std::isnan(x[i])) {
            SET_STRING_ELT(out, i, NA_STRING);
            continue;
        }

        os.str(std::string());
        os.clear();

        ld = date::local_days{ date::days(static_cast<int>(x[i]))};
        ymd = sh_year_month_day{ ld };

        sh_to_stream(os, fmt, sh_fields{ ymd }, nullptr, nullptr,
                     month_names.data(), weekday_names.data());

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
                     const cpp11::strings& format,
                     const cpp11::strings& month_nms,
                     const cpp11::strings& month_nms_abbrev,
                     const cpp11::strings& weekday_nms,
                     const cpp11::strings& weekday_nms_abbrev,
                     const cpp11::strings& ampm_nms)
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
    date::sys_info info;

    const R_xlen_t size = xx.size();
    cpp11::writable::strings out(size);

    std::string format_(format[0]);
    const char* fmt = format_.c_str();
    const auto month_names = make_month_names(month_nms, month_nms_abbrev);
    const auto weekday_names = make_weekday_names(weekday_nms, weekday_nms_abbrev);
    const auto ampm_names = make_ampm_names(ampm_nms);

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
        auto fds = make_sh_fields(ls);
        sh_to_stream(os, fmt, fds, &tz_name, &info.offset,
                     month_names.data(), weekday_names.data(), ampm_names.data());

        if (os.fail()) {
            SET_STRING_ELT(out, i, NA_STRING);
            continue;
        }

        std::string str = os.str();
        SET_STRING_ELT(out, i, Rf_mkCharLenCE(str.c_str(), str.size(), CE_UTF8));
    }

    return out;
}
