#include "shide.h"
#include <map>
#include <math.h>

enum class choose { earliest, latest, NA };
choose string_to_choose(const std::string& choose_str) {
    static const std::map<std::string, choose> choose_map{
        {"earliest", choose::earliest},
        {"latest", choose::latest},
        {"NA", choose::NA},
    };

    auto it = choose_map.find(choose_str);
    if (it != choose_map.end()) {
        return it->second;
    }
    else {
        cpp11::stop("Invalid ambiguous relolution strategy: (%s)", choose_str.c_str());
    }
}

double jdatetime_from_local_seconds(const date::local_seconds& ls, const date::time_zone* tz,
                                    date::local_info& info, const choose& c)
{
    using std::chrono::seconds;
    tzdb::get_local_info(ls, tz, info);
    seconds s{};
    if (info.result == date::local_info::unique)
    {
        s = ls.time_since_epoch() - info.first.offset;
    }
    else if (info.result == date::local_info::ambiguous)
    {
        switch (c)
        {
        case choose::earliest:
            s = ls.time_since_epoch() - info.first.offset;
            break;
        case choose::latest:
            s = ls.time_since_epoch() - info.second.offset;
            break;
        case choose::NA:
            return NA_REAL;
        }
    }
    else
    {
        return NA_REAL;
    }

    return static_cast<double>(s.count());
}

bool hour_minute_second_ok(const int hour, const int minute, const int second)
{
    if (!(0 <= hour && hour <= 23))
        return false;

    if (!(0 <= minute && minute <= 59))
        return false;

    if (!(0 <= second && second <= 59))
        return false;

    return true;
}

[[cpp11::register]]
cpp11::doubles jdate_make_cpp(cpp11::list_of<cpp11::integers> fields) {
    date::days days_since_epoch;

    const cpp11::integers year = fields[0];
    const cpp11::integers month = fields[1];
    const cpp11::integers day = fields[2];

    const R_xlen_t size = year.size();
    cpp11::writable::doubles out(size);
    sh_year_month_day ymd{};

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        ymd = {date::year(year[i]), date::month(month[i]), date::day(day[i])};

        if (!ymd.ok())
        {
            out[i] = NA_REAL;
            continue;
        }

        days_since_epoch = local_days(ymd).time_since_epoch();
        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}

[[cpp11::register]]
cpp11::doubles jdatetime_make_cpp(cpp11::list_of<cpp11::integers> fields,
                                  const cpp11::strings& tzone, const std::string& ambiguous) {
    using std::chrono::hours;
    using std::chrono::minutes;
    using std::chrono::seconds;

    const auto Ambiguous{ string_to_choose(ambiguous) };
    const date::time_zone* tz{};
    date::local_info info;
    sh_year_month_day ymd{};
    const std::string tz_name(tzone[0]);

    if (!tzdb::locate_zone(tz_name, tz))
    {
        cpp11::stop(std::string(tz_name + " not found in timezone database").c_str());
    }

    date::local_seconds ls;

    const cpp11::integers year = fields[0];
    const cpp11::integers month = fields[1];
    const cpp11::integers day = fields[2];
    const cpp11::integers hour = fields[3];
    const cpp11::integers minute = fields[4];
    const cpp11::integers second = fields[5];

    const R_xlen_t size = year.size();
    cpp11::writable::doubles out(size);

    for (R_xlen_t i = 0; i < size; ++i) {
        if (year[i] == NA_INTEGER) {
            out[i] = NA_REAL;
            continue;
        }

        ymd = {date::year(year[i]), date::month(month[i]), date::day(day[i])};

        if (!ymd.ok())
        {
            out[i] = NA_REAL;
            continue;
        }

        if (!hour_minute_second_ok(hour[i], minute[i], second[i]))
        {
            out[i] = NA_REAL;
            continue;
        }

        ls = local_days(ymd) + hours{ hour[i] } + minutes{ minute[i] } + seconds{ second[i] };
        out[i] = jdatetime_from_local_seconds(ls, tz, info, Ambiguous);
    }

    return out;
}
