#include "shide.h"
#include <map>
#include <stdlib.h>

int sh_qday(const sh_year_month_day& ymd);
int sh_yday(const sh_year_month_day& ymd);
int sh_wday(const date::local_days& ld);

enum class Unit {year, quarter, month, week, day};

Unit string_to_unit(const std::string& unit_name) {
    static const std::map<std::string, Unit> unit_map{
        {"year", Unit::year},
        {"quarter", Unit::quarter},
        {"month", Unit::month},
        {"week", Unit::week},
        {"day", Unit::day},
    };

    auto it = unit_map.find(unit_name);
    if (it != unit_map.end()) {
        return it->second;
    }
    else {
        Rf_error("Invalid unit: (%s)", unit_name.c_str());
    }
}

date::local_days
jdate_ceiling(const date::local_days& ld, const Unit& unit)
{
    sh_year_month_day ymd{ld};
    sh_year_month_day_last ymdl{ ymd.year(), date::month_day_last{ ymd.month()} };
    date::local_days ld_out{ld};

    switch (unit)
    {
    case Unit::year:
        ymdl = { ymdl.year(), date::month_day_last{ date::month(12)} };
        ld_out = date::local_days{ ymdl } + date::days{ 1 };
        break;
    case Unit::quarter:
        ymdl += date::months{ (3 - static_cast<unsigned>(ymdl.month()) % 3) % 3 };
        ld_out = date::local_days{ ymdl } + date::days{ 1 };
        break;
    case Unit::month:
        ld_out = date::local_days{ ymdl } + date::days{ 1 };
        break;
    case Unit::week:
        ld_out = ld + date::days{7 - sh_wday(ld)} + date::days{ 1 };
        break;
    case Unit::day:
        break;
    }

    return ld_out;
}

date::local_days
jdate_floor(const date::local_days& ld, const Unit& unit)
{
    sh_year_month_day ymd{ ld };
    date::local_days ld_out{ ld };

    switch (unit)
    {
    case Unit::year:
        ld_out = ld - date::days(sh_yday(ymd) - 1);
        break;
    case Unit::quarter:
        ld_out = ld - date::days(sh_qday(ymd) - 1);
        break;
    case Unit::month:
        ld_out = ld - date::days(static_cast<unsigned>(ymd.day()) - 1);
        break;
    case Unit::week:
        ld_out = ld - date::days(sh_wday(ld) - 1);
        break;
    case Unit::day:
        break;
    }

    return ld_out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdate_ceiling_cpp(const cpp11::sexp x, const std::string& unit_name)
{
    const auto unit{ string_to_unit(unit_name) };
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::days days_since_epoch;
    date::local_days ld;
    date::local_days ld_out;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ld = date::local_days{ date::days(static_cast<int>(xx[i])) };
        ld_out = jdate_ceiling(ld, unit);
        days_since_epoch = ld_out.time_since_epoch();
        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdate_floor_cpp(const cpp11::sexp x, const std::string& unit_name)
{
    const auto unit{ string_to_unit(unit_name) };
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = xx.size();
    cpp11::writable::doubles out(size);
    date::days days_since_epoch;
    date::local_days ld;
    date::local_days ld_out;

    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (std::isnan(xx[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ld = date::local_days{ date::days(static_cast<int>(xx[i])) };
        ld_out = jdate_floor(ld, unit);
        days_since_epoch = ld_out.time_since_epoch();
        out[i] = static_cast<double>(days_since_epoch.count());
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
