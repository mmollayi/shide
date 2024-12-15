#include "seq.h"
#include <cpp11.hpp>
#include "R_ext/Print.h"

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

    for (R_xlen_t i = 1; i < size; ++i)
    {
        ymd += date::years{ dy[i] - dy[i-1] };
        days_since_epoch = local_days(ymd).time_since_epoch();
        out[i] = static_cast<double>(days_since_epoch.count());
    }

    return out;
}
