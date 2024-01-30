#ifndef SH_YEAR_MONTH_DAY_H
#define SH_YEAR_MONTH_DAY_H
#include <tzdb/date.h>
#include "jalali.h"

using days = date::days;
using months = date::months;
using years = date::years;
using day = date::day;
using month = date::month;
using year = date::year;
using local_days = date::local_days;

class sh_year_month_day
{
    year  y_;
    month m_;
    day   d_;

public:
    sh_year_month_day() = default;
    constexpr sh_year_month_day(const date::year& y, const date::month& m,
                                const date::day& d) NOEXCEPT;

    constexpr sh_year_month_day(const date::year_month_day& ymd) NOEXCEPT;
    explicit sh_year_month_day(local_days dp) NOEXCEPT;

    constexpr sh_year_month_day& operator+=(const months& m) NOEXCEPT;
    constexpr sh_year_month_day& operator-=(const months& m) NOEXCEPT;
    constexpr sh_year_month_day& operator+=(const years& y)  NOEXCEPT;
    constexpr sh_year_month_day& operator-=(const years& y)  NOEXCEPT;

    constexpr year  year()  const NOEXCEPT;
    constexpr month month() const NOEXCEPT;
    constexpr day   day()   const NOEXCEPT;

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

constexpr inline year sh_year_month_day::year() const NOEXCEPT { return y_; }
constexpr inline month sh_year_month_day::month() const NOEXCEPT { return m_; }
constexpr inline day sh_year_month_day::day() const NOEXCEPT { return d_; }

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
    return days{ ymd_to_day(y, m, d) - 2440588 };
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
    auto const jd = dp.count() + 2440588;
    int y, m, d;
    day_to_ymd(jd, &y, &m, &d);
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


#endif
