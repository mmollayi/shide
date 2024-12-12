#include "shide.h"

sh_year_month_day
first_day_next_month(const sh_year_month_day& ymd) {
    date::year_month ym{ ymd.year(), ymd.month() };
    ym += date::months{ 1 };
    return sh_year_month_day{ ym.year(), ym.month(), date::day{ 1 } };
}

bool sh_date_is_leap(const sh_year_month_day& ymd) {
    if (ymd.day() != date::day{ 30 })
        return false;

    if (ymd.month() != date::month{ 12 })
        return false;

    if (!year_is_leap(ymd.year()))
        return false;

    return false;
}

[[cpp11::register]]
cpp11::writable::doubles
jdate_seq_by_month_cpp(const cpp11::sexp& x, const cpp11::integers& dm)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = dm.size();
    cpp11::writable::doubles out(size);
    out[0] = xx[0];

    if (size == 1)
    {
        return out;
    }

    sh_year_month_day ymd{date::local_days{ date::days(static_cast<int>(xx[0])) } };
    date::days days_since_epoch;

    for (R_xlen_t i = 1; i < size; ++i)
    {
        ymd += date::months{ dm[i] - dm[i-1] };

        if (ymd.ok())
            days_since_epoch = local_days(ymd).time_since_epoch();
        else
            days_since_epoch = local_days(first_day_next_month(ymd)).time_since_epoch();

        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}

[[cpp11::register]]
cpp11::writable::doubles
jdate_seq_by_year_cpp(const cpp11::sexp& x, const cpp11::integers& dy)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = dy.size();
    cpp11::writable::doubles out(size);
    out[0] = xx[0];

    if (size == 1)
    {
        return out;
    }

    sh_year_month_day ymd{date::local_days{ date::days(static_cast<int>(xx[0])) } };
    date::days days_since_epoch;
    bool leap{ sh_date_is_leap(ymd) ? true : false };

    for (R_xlen_t i = 1; i < size; ++i)
    {
        ymd += date::years{ dy[i] - dy[i-1] };

        if (!leap)
            days_since_epoch = local_days(ymd).time_since_epoch();
        else
            days_since_epoch = local_days(first_day_next_month(ymd)).time_since_epoch();

        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}
