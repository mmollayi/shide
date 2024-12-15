#ifndef SEQ_H
#define SEQ_H
#include "sh_year_month_day.h"

constexpr
inline
sh_year_month_day
first_day_next_month(const sh_year_month_day& ymd) {
	date::year_month ym{ ymd.year(), ymd.month() };
	ym += date::months{ 1 };
	return sh_year_month_day{ ym.year(), ym.month(), date::day{ 1 } };
}

constexpr
inline
bool
sh_date_is_leap(const sh_year_month_day& ymd) {
	return (ymd.month() == date::month(12)) && (ymd.day() == date::day(30));
}

#endif
 