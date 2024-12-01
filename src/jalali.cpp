#include <cstring>
#include "shide.h"

constexpr int JALALI_ZERO{ 1947954 };
constexpr int LOWER_PERSIAN_YEAR {-1096};
constexpr int UPPER_PERSIAN_YEAR {2327};
constexpr int LOWER_JD{ 1547650 };
constexpr int UPPER_JD{ 2797873 };
constexpr int MONTH_DATA[12] { 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29 };
constexpr int MONTH_DATA_CUM[13] { 0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336, 366 };

int jalali_jd0(const int year) {
    static constexpr int breaks[12] { -708, -221,   -3,    6,  394,  720,
                                      786, 1145, 1635, 1701, 1866, 2328 };
    static constexpr int deltas[12] { 1108, 1047,  984, 1249,  952,  891,
                                      930,  866,  869,  844,  848,  852 };

    // this case is equivalent to i=8 and is the most common case that may happen in practice
    if (year >= breaks[7] && year < breaks[8])
    {
        return JALALI_ZERO + year * 365 + (deltas[8] + year * 303) / 1250 ;
    }

    if (year < LOWER_PERSIAN_YEAR || year > UPPER_PERSIAN_YEAR)
        return 0;           // out of valid range

    int rval{ 0 };
    for (int i{ 0 }; i < 12; ++i)
    {
        if (year < breaks[i])
        {
            rval = JALALI_ZERO + year * 365 + (deltas[i] + year * 303) / 1250;
            if (i < 3)  // zero point drops one day in first three blocks
                --rval;
            break;
        }
    }

    return rval;
}

int ymd_to_day(int year, int month, int day)
{
    return jalali_jd0(year) + MONTH_DATA_CUM[month - 1] + day;
}

int mod( int x, int y)
{
    int rval = x % y;

    if( rval < 0)
        rval += y;
    return(rval);
}

int approx_year( int jd)
{
    int year, n1 = 0, n2 = 0, calendar_epoch, day_in_cycle;
    n1 = 2820;           /* exact values which overflow on 32 bits */
    n2 = 2820 * 365 + 683;
    calendar_epoch = JALALI_ZERO + 1;

    jd -= calendar_epoch;
    day_in_cycle = mod(jd, n2);
    year = n1 * (( jd - day_in_cycle) / n2);
    double tmp = (double)n1 / n2;
    year += day_in_cycle * tmp;
    return(year);
}

void day_to_ymd(int jd, int* year, int* month, int* day)
{
    *year = approx_year(jd);
    *day = -1;           /* to signal an error */
    int year_ends[2]{};
    do
    {
        year_ends[0] = jalali_jd0(*year) + 1;
        year_ends[1] = jalali_jd0(*year + 1);
        if (!(year_ends[0] && year_ends[1]))
            return;
        if (year_ends[0] > jd)
        {
            (*year)--;
            continue;
        }

        if (year_ends[1] < jd)
        {
            (*year)++;
            continue;
        }

    } while (year_ends[0] > jd || year_ends[1] < jd);

    int yday{ jd - year_ends[0] + 1 };
    for (int i{ 1 }; i < 13; ++i)
    {
        if (yday <= MONTH_DATA_CUM[i])
        {
            *month = i;
            *day = yday - MONTH_DATA_CUM[i - 1];
            break;
        }
    }
    return;
}

bool year_is_leap(const int year)
{
    return(jalali_jd0(year + 1L) - jalali_jd0(year) == 366);
}

bool year_month_day_ok(const int year, const int month, const int day)
{
    if (!(LOWER_PERSIAN_YEAR < year && year < UPPER_PERSIAN_YEAR))
        return false;

    if (!(1 <= month && month <= 12))
        return false;

    char month_data[12];
    memset(month_data, 31, 6);
    memset(month_data + 6, 30, 5);
    month_data[11] = (char)(29 + year_is_leap(year));

    if (!(1 <= day && day <= month_data[month - 1]))
        return false;

    return true;
}

bool year_is_in_range(const int year)
{
    if (!(LOWER_PERSIAN_YEAR < year && year < UPPER_PERSIAN_YEAR))
        return false;

    return true;
}
