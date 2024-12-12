#include <cpp11.hpp>
#include <R.h>
#include <Rinternals.h>
#include "sh_year_month_day.h"

[[cpp11::register]]
cpp11::writable::logicals year_is_leap_cpp(const cpp11::integers& x)
{
    using namespace internal;
    const R_xlen_t size = x.size();
    cpp11::writable::logicals out(size);
    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (x[i] == NA_INTEGER)
        {
            out[i] = NA_LOGICAL;
            continue;
        }

        if (x[i] < LOWER_PERSIAN_YEAR || x[i] > UPPER_PERSIAN_YEAR)
            cpp11::stop("year is out of valid range.");

        out[i] = year_is_leap(date::year{x[i]});
    }

    return out;
}
