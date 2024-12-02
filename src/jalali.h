#ifndef JALALI_H
#define JALALI_H
constexpr int jd_unix_epoch{ 2440588 };

int jalali_jd0(const int year);
bool year_is_leap(int year);
bool year_month_day_ok(int year, int month, int day);
int approx_year(int jd);

#endif
