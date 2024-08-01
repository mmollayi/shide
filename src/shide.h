#ifndef SHIDE_H
#define SHIDE_H
#define ONLY_C_LOCALE 0
#include <tzdb/tzdb.h>
#include <tzdb/date.h>
#include <tzdb/tz.h>
#include <cpp11.hpp>
#include <R.h>
#include <Rinternals.h>
#include "sh_year_month_day.h"

const int jd_unix_epoch{ 2440588 };

date::sys_seconds sys_seconds_from_double(double x);

#endif
