#ifndef SH_YEAR_MONTH_DAY_H
#define SH_YEAR_MONTH_DAY_H
#include <tzdb/date.h>
#include "jalali.h"

namespace constants
{
    constexpr int MONTH_DATA_CUM[13]{ 0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336, 366 };
}

using days = date::days;
using months = date::months;
using years = date::years;
using local_days = date::local_days;

class sh_year_month_day;
class sh_year_month_day_last;

inline
bool
year_is_leap(const date::year& y)
{
    return year_is_leap(int{ y });
}

class sh_year_month_day
{
    date::year  y_;
    date::month m_;
    date::day   d_;

public:
    sh_year_month_day() = default;
    constexpr sh_year_month_day(const date::year& y, const date::month& m,
                                const date::day& d) NOEXCEPT;
    constexpr sh_year_month_day(const sh_year_month_day_last& ymdl) NOEXCEPT;

    constexpr sh_year_month_day(const date::year_month_day& ymd) NOEXCEPT;
    explicit sh_year_month_day(local_days dp) NOEXCEPT;

    constexpr sh_year_month_day& operator+=(const months& m) NOEXCEPT;
    constexpr sh_year_month_day& operator-=(const months& m) NOEXCEPT;
    constexpr sh_year_month_day& operator+=(const years& y)  NOEXCEPT;
    constexpr sh_year_month_day& operator-=(const years& y)  NOEXCEPT;

    constexpr date::year  year()  const NOEXCEPT;
    constexpr date::month month() const NOEXCEPT;
    constexpr date::day   day()   const NOEXCEPT;

    explicit operator local_days() const NOEXCEPT;
    bool ok() const NOEXCEPT;

private:
    static sh_year_month_day from_days(days dp) NOEXCEPT;
    days to_days() const NOEXCEPT;
};

constexpr sh_year_month_day operator+(const sh_year_month_day& ymd, const months& dm) NOEXCEPT;
constexpr sh_year_month_day operator+(const months& dm, const sh_year_month_day& ymd) NOEXCEPT;
constexpr sh_year_month_day operator-(const sh_year_month_day& ymd, const months& dm) NOEXCEPT;
constexpr sh_year_month_day operator+(const sh_year_month_day& ymd, const years& dy)  NOEXCEPT;
constexpr sh_year_month_day operator+(const years& dy, const sh_year_month_day& ymd)  NOEXCEPT;
constexpr sh_year_month_day operator-(const sh_year_month_day& ymd, const years& dy)  NOEXCEPT;

constexpr
inline
sh_year_month_day::sh_year_month_day(const date::year& y, const date::month& m,
                                     const date::day& d) NOEXCEPT
: y_(y)
    , m_(m)
    , d_(d)
                                     {}

constexpr
inline
sh_year_month_day::sh_year_month_day(const date::year_month_day& ymd) NOEXCEPT
: y_(ymd.year())
    , m_(ymd.month())
    , d_(ymd.day())
{}

inline
sh_year_month_day::sh_year_month_day(local_days dp) NOEXCEPT
: sh_year_month_day(from_days(dp.time_since_epoch()))
{}

constexpr inline date::year sh_year_month_day::year() const NOEXCEPT { return y_; }
constexpr inline date::month sh_year_month_day::month() const NOEXCEPT { return m_; }
constexpr inline date::day sh_year_month_day::day() const NOEXCEPT { return d_; }

inline
bool
sh_year_month_day::ok() const NOEXCEPT
{
    auto const y = static_cast<int>(y_);
    auto const m = static_cast<int>(static_cast<unsigned>(m_));
    auto const d = static_cast<int>(static_cast<unsigned>(d_));
    return year_month_day_ok(y, m, d);
}

inline
days
sh_year_month_day::to_days() const NOEXCEPT
{
    auto const y = static_cast<int>(y_);
    auto const m = static_cast<int>(static_cast<unsigned>(m_));
    auto const d = static_cast<int>(static_cast<unsigned>(d_));
    return days{ jalali_jd0(y) + constants::MONTH_DATA_CUM[m - 1] + d - jd_unix_epoch };
}

inline
sh_year_month_day::operator local_days() const NOEXCEPT
{
    return local_days{ to_days() };
}

inline
sh_year_month_day
sh_year_month_day::from_days(days dp) NOEXCEPT
{
    auto const jd = dp.count() + jd_unix_epoch;
    int m{ 1 };
    int y{ approx_year(jd) };
    int year_ends[2]{};
    do
    {
        year_ends[0] = jalali_jd0(y) + 1;
        year_ends[1] = jalali_jd0(y + 1);
        assert(year_ends[0] && year_ends[1]);

        if (year_ends[0] > jd)
        {
            y--;
            continue;
        }

        if (year_ends[1] < jd)
        {
            y++;
            continue;
        }

    } while (year_ends[0] > jd || year_ends[1] < jd);

    const int doy{ jd - year_ends[0] + 1 };
    for (int i{ 1 }; i < 13; ++i)
    {
        if (doy <= constants::MONTH_DATA_CUM[i])
        {
            m = i;
            break;
        }
    }

    const int d{ doy - constants::MONTH_DATA_CUM[m - 1] };
    return sh_year_month_day{ date::year(y), date::month(m), date::day(d) };
}

constexpr
inline
sh_year_month_day&
    sh_year_month_day::operator+=(const months& m) NOEXCEPT
    {
        *this = *this + m;
        return *this;
    }

constexpr
inline
sh_year_month_day&
    sh_year_month_day::operator-=(const months& m) NOEXCEPT
    {
        *this = *this - m;
        return *this;
    }

constexpr
inline
sh_year_month_day&
    sh_year_month_day::operator+=(const years& y) NOEXCEPT
    {
        *this = *this + y;
        return *this;
    }

constexpr
inline
sh_year_month_day&
    sh_year_month_day::operator-=(const years& y) NOEXCEPT
    {
        *this = *this - y;
        return *this;
    }

constexpr
inline
sh_year_month_day
operator+(const sh_year_month_day& ymd, const months& dm) NOEXCEPT
{
    return sh_year_month_day{ (ymd.year() / ymd.month() + dm) / ymd.day() };
}

constexpr
inline
sh_year_month_day
operator+(const months& dm, const sh_year_month_day& ymd) NOEXCEPT
{
    return ymd + dm;
}

constexpr
inline
sh_year_month_day
operator-(const sh_year_month_day& ymd, const months& dm) NOEXCEPT
{
    return ymd + (-dm);
}

constexpr
inline
sh_year_month_day
operator+(const sh_year_month_day& ymd, const years& dy) NOEXCEPT
{
    return sh_year_month_day{ (ymd.year() + dy) / ymd.month() / ymd.day() };
}

constexpr
inline
sh_year_month_day
operator+(const years& dy, const sh_year_month_day& ymd) NOEXCEPT
{
    return ymd + dy;
}

constexpr
inline
sh_year_month_day
operator-(const sh_year_month_day& ymd, const years& dy) NOEXCEPT
{
    return ymd + (-dy);
}

class sh_year_month_day_last
{
    date::year           y_;
    date::month_day_last mdl_;

public:
    constexpr sh_year_month_day_last(const date::year& y,
                                     const date::month_day_last& mdl) NOEXCEPT;

    constexpr sh_year_month_day_last& operator+=(const months& m) NOEXCEPT;
    constexpr sh_year_month_day_last& operator-=(const months& m) NOEXCEPT;
    constexpr sh_year_month_day_last& operator+=(const years& y)  NOEXCEPT;
    constexpr sh_year_month_day_last& operator-=(const years& y)  NOEXCEPT;

    constexpr date::year           year()           const NOEXCEPT;
    constexpr date::month          month()          const NOEXCEPT;
    constexpr date::month_day_last month_day_last() const NOEXCEPT;
    constexpr date::day            day()            const NOEXCEPT;

    explicit operator local_days() const NOEXCEPT;
    constexpr bool ok() const NOEXCEPT;
};

constexpr sh_year_month_day_last operator+(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT;
constexpr sh_year_month_day_last operator+(const months& dm, const sh_year_month_day_last& ymdl) NOEXCEPT;
constexpr sh_year_month_day_last operator+(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT;
constexpr sh_year_month_day_last operator+(const years& dy, const sh_year_month_day_last& ymdl) NOEXCEPT;
constexpr sh_year_month_day_last operator-(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT;
constexpr sh_year_month_day_last operator-(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT;

constexpr
inline
sh_year_month_day_last::sh_year_month_day_last(const date::year& y,
                                               const date::month_day_last& mdl) NOEXCEPT
: y_(y)
    , mdl_(mdl)
                                               {}

constexpr
inline
sh_year_month_day_last&
    sh_year_month_day_last::operator+=(const months& m) NOEXCEPT
    {
        *this = *this + m;
        return *this;
    }

constexpr
inline
sh_year_month_day_last&
    sh_year_month_day_last::operator-=(const months& m) NOEXCEPT
    {
        *this = *this - m;
        return *this;
    }

constexpr
inline
sh_year_month_day_last&
    sh_year_month_day_last::operator+=(const years& y) NOEXCEPT
    {
        *this = *this + y;
        return *this;
    }

constexpr
inline
sh_year_month_day_last&
    sh_year_month_day_last::operator-=(const years& y) NOEXCEPT
    {
        *this = *this - y;
        return *this;
    }

constexpr inline date::year sh_year_month_day_last::year() const NOEXCEPT { return y_; }
constexpr inline date::month sh_year_month_day_last::month() const NOEXCEPT { return mdl_.month(); }

constexpr
inline
date::month_day_last
sh_year_month_day_last::month_day_last() const NOEXCEPT
{
    return mdl_;
}

constexpr
inline
date::day
sh_year_month_day_last::day() const NOEXCEPT
{
    constexpr date::day d[] =
        {
        date::day(31), date::day(31), date::day(31),
        date::day(31), date::day(31), date::day(31),
        date::day(30), date::day(30), date::day(30),
        date::day(30), date::day(30), date::day(29)
        };
    return (month() != date::month(12) || !year_is_leap(y_)) && mdl_.ok() ?
    d[static_cast<unsigned>(month()) - 1] : date::day{ 30 };
}

inline
sh_year_month_day_last::operator local_days() const NOEXCEPT
{
    return local_days(sh_year_month_day{ year(),  month(), day() });
}

constexpr
inline
bool
sh_year_month_day_last::ok() const NOEXCEPT
{
    return y_.ok() && mdl_.ok();
}

constexpr
inline
sh_year_month_day_last
operator+(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT
{
    date::year_month ym{ymdl.year(), ymdl.month()};
    ym += dm;
    return sh_year_month_day_last{ ym.year(), date::month_day_last{ ym.month() } };
}

constexpr
inline
sh_year_month_day_last
operator+(const months& dm, const sh_year_month_day_last& ymdl) NOEXCEPT
{
    return ymdl + dm;
}

constexpr
inline
sh_year_month_day_last
operator-(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT
{
    return ymdl + (-dm);
}

constexpr
inline
sh_year_month_day_last
operator+(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT
{
    return { ymdl.year() + dy, ymdl.month_day_last() };
}

constexpr
inline
sh_year_month_day_last
operator+(const years& dy, const sh_year_month_day_last& ymdl) NOEXCEPT
{
    return ymdl + dy;
}

constexpr
inline
sh_year_month_day_last
operator-(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT
{
    return ymdl + (-dy);
}

constexpr
inline
sh_year_month_day::sh_year_month_day(const sh_year_month_day_last& ymdl) NOEXCEPT
: y_(ymdl.year())
    , m_(ymdl.month())
    , d_(ymdl.day())
{}

#endif
