#ifndef SHIDE_H
#define SHIDE_H
#include "shide/tzdb.h"
#include <cpp11.hpp>
#include <R.h>
#include <Rinternals.h>
#include <shide/sh_year_month_day.h>

date::sys_seconds sys_seconds_from_double(double x);

#endif
