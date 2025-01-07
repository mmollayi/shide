#include "seq.h"
#include <cpp11.hpp>
#include "R_ext/Print.h"

double jdate_from_local_days(const date::local_days& ld);

[[cpp11::register]]
cpp11::writable::doubles
jdate_seq_by_month_cpp(const cpp11::sexp& x, const cpp11::integers& dm)
{
    const cpp11::doubles xx = cpp11::as_cpp<cpp11::doubles>(x);
    const R_xlen_t size = dm.size();
    cpp11::writable::doubles out(size);
    out[0] = xx[0];

    if (size == 1)
        return out;

    sh_year_month_day ymd{date::local_days{ date::days(static_cast<int>(xx[0])) } };
    local_days ld;

    for (R_xlen_t i = 1; i < size; ++i)
    {
        ymd += date::months{ dm[i] - dm[i-1] };

        if (ymd.ok())
            ld = local_days(ymd);
        else
            ld = local_days(first_day_next_month(ymd));

        out[i] = jdate_from_local_days(ld);
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
        return out;

    sh_year_month_day ymd{date::local_days{ date::days(static_cast<int>(xx[0])) } };

    for (R_xlen_t i = 1; i < size; ++i)
    {
        ymd += date::years{ dy[i] - dy[i-1] };
        out[i] = jdate_from_local_days(local_days(ymd));
    }

    return out;
}
