int jalali_jd0(int year);
int ymd_to_day(int year, int month, int day);
void day_to_ymd(int jd, int *day, int *month, int *year);
int get_calendar_data(int year, int *days, char *month_data);
bool year_is_leap(int year);
bool year_month_day_ok(int year, int month, int day);
