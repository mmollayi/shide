#include <cpp11.hpp>
#include <R.h>
#include <Rinternals.h>

bool year_is_in_range(const int year);
bool year_is_leap(const int year);

[[cpp11::register]]
cpp11::writable::logicals year_is_leap_cpp(const cpp11::integers& x)
{
    const R_xlen_t size = x.size();
    cpp11::writable::logicals out(size);
    for (R_xlen_t i = 0; i < size; ++i)
    {
        if (x[i] == NA_INTEGER)
        {
            out[i] = NA_LOGICAL;
            continue;
        }

        if (!year_is_in_range(x[i]))
            cpp11::stop("year is out of valid range.");


        if (year_is_leap(x[i]))
            out[i] = true;
        else
            out[i] = false;
    }

    return out;
}
