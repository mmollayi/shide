#ifndef FORMAT_H
#define FORMAT_H

#include "shide/sh_year_month_day.h"

static const std::string default_month_names[]{
        "Farvardin",
        "Ordibehesht",
        "Khordad",
        "Tir",
        "Mordad",
        "Shahrivar",
        "Mehr",
        "Aban",
        "Azar",
        "Dey",
        "Bahman",
        "Esfand",
        "Far",
        "Ord",
        "Kho",
        "Tir",
        "Mor",
        "Sha",
        "Meh",
        "Aba",
        "Aza",
        "Dey",
        "Bah",
        "Esf"
};
static const std::string default_weekday_names[]{
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat"
};
static const std::string default_ampm_names[]{
    "AM",
    "PM"
};

inline
std::pair<const std::string*, const std::string*>
month_names(const std::string nm[]=nullptr)
{
    return (nm == nullptr) ?
        std::make_pair(default_month_names, default_month_names + 24) : std::make_pair(nm, nm + 24);
}

inline
std::pair<const std::string*, const std::string*>
weekday_names(const std::string nm[] = nullptr)
{
    return (nm == nullptr) ?
        std::make_pair(default_weekday_names, default_weekday_names + 14) : std::make_pair(nm, nm + 14);
}

inline
std::pair<const std::string*, const std::string*>
ampm_names(const std::string nm[] = nullptr)
{
    return (nm == nullptr) ?
        std::make_pair(default_ampm_names, default_ampm_names + 2) : std::make_pair(nm, nm + 2);
}

inline
unsigned
extract_month(std::ostream& os, const sh_fields& fds)
{
    if (!fds.ymd.month().ok())
    {
        os.setstate(std::ios::failbit);
        return 0;
    }
    return static_cast<unsigned>(fds.ymd.month());
}

inline
unsigned
extract_weekday(std::ostream& os, const sh_fields& fds)
{
    if (!fds.ymd.ok() && !fds.wd.ok())
    {
        // fds does not contain a valid weekday
        os.setstate(std::ios::failbit);
        return 8;
    }
    weekday wd;
    if (fds.ymd.ok())
    {
        wd = weekday{ sys_days(fds.ymd) };
        if (fds.wd.ok() && wd != fds.wd)
        {
            // fds.ymd and fds.wd are inconsistent
            os.setstate(std::ios::failbit);
            return 8;
        }
    }
    else
        wd = fds.wd;
    return static_cast<unsigned>((wd - date::Sunday).count());
}

std::ostream&
sh_to_stream(std::ostream& os, const char* fmt, const sh_fields& fds,
    const std::string* abbrev, const std::chrono::seconds* offset_sec,
    const std::string month_nms[] = nullptr, const std::string weekday_nms[] = nullptr,
    const std::string ampm_nms[] = nullptr)
{
    using std::chrono::duration_cast;
    using std::chrono::seconds;
    using std::chrono::minutes;
    using std::chrono::hours;
    using date::detail::save_ostream;
    os.fill(' ');
    os.flags(std::ios::skipws | std::ios::dec);
    os.width(0);
    tm tm{};
    bool insert_negative = fds.has_tod && fds.tod.to_duration() < seconds::zero();
    const char* command = nullptr;
    for (; *fmt; ++fmt)
    {
        switch (*fmt)
        {
        case 'a':
        case 'A':
            if (command)
            {
                tm.tm_wday = static_cast<int>(extract_weekday(os, fds));
                if (os.fail())
                    return os;

                os << weekday_names(weekday_nms).first[tm.tm_wday + 7 * (*fmt == 'a')];
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'b':
        case 'B':
            if (command)
            {
                tm.tm_mon = static_cast<int>(extract_month(os, fds)) - 1;
                os << month_names(month_nms).first[tm.tm_mon + 12 * (*fmt != 'B')];
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'C':
            if (command)
            {
                if (!fds.ymd.year().ok())
                    os.setstate(std::ios::failbit);
                auto y = static_cast<int>(fds.ymd.year());
                save_ostream<char> _(os);
                os.fill('0');
                os.flags(std::ios::dec | std::ios::right);
                if (y >= 0)
                {
                    os.width(2);
                    os << y / 100;
                }
                else
                {
                    os << char{ '-' };
                    os.width(2);
                    os << -(y - 99) / 100;
                }
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'd':
        case 'e':
            if (command)
            {
                if (!fds.ymd.day().ok())
                    os.setstate(std::ios::failbit);
                auto d = static_cast<int>(static_cast<unsigned>(fds.ymd.day()));
                save_ostream<char> _(os);
                if (*fmt == char{ 'd' })
                    os.fill('0');
                else
                    os.fill(' ');
                os.flags(std::ios::dec | std::ios::right);
                os.width(2);
                os << d;
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'F':
        case 'J':
            if (command)
            {
                if (!fds.ymd.ok())
                    os.setstate(std::ios::failbit);
                auto const& ymd = fds.ymd;
                save_ostream<char> _(os);
                const auto sep = (*fmt == 'F') ? '-' : '/';
                os.imbue(std::locale::classic());
                os.fill('0');
                os.flags(std::ios::dec | std::ios::right);
                os.width(4);
                os << static_cast<int>(ymd.year()) << sep;
                os.width(2);
                os << static_cast<unsigned>(ymd.month()) << sep;
                os.width(2);
                os << static_cast<unsigned>(ymd.day());
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'H':
        case 'I':
            if (command)
            {
                if (!fds.has_tod)
                    os.setstate(std::ios::failbit);
                if (insert_negative)
                {
                    os << '-';
                    insert_negative = false;
                }
                auto hms = fds.tod;
                auto h = *fmt == char{ 'I' } ? date::make12(hms.hours()) : hms.hours();
                if (h < hours{ 10 })
                    os << char{ '0' };
                os << h.count();
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'j':
            if (command)
            {
                if (fds.ymd.ok())
                {
                    auto doy = sh_yday(fds.ymd);
                    save_ostream<char> _(os);
                    os.fill('0');
                    os.flags(std::ios::dec | std::ios::right);
                    os.width(3);
                    os << doy.count();
                }
                else
                {
                    os.setstate(std::ios::failbit);
                }
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'm':
            if (command)
            {
                if (!fds.ymd.month().ok())
                    os.setstate(std::ios::failbit);
                auto m = static_cast<unsigned>(fds.ymd.month());
                if (m < 10)
                    os << char{ '0' };
                os << m;
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'M':
            if (command)
            {
                if (!fds.has_tod)
                    os.setstate(std::ios::failbit);
                if (insert_negative)
                {
                    os << '-';
                    insert_negative = false;
                }
                if (fds.tod.minutes() < minutes{ 10 })
                    os << char{ '0' };
                os << fds.tod.minutes().count();
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'n':
            if (command)
            {
                os << char{ '\n' };
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'p':
            if (command)
            {
                if (!fds.has_tod)
                    os.setstate(std::ios::failbit);
                auto const& tod = fds.tod;
                if (date::is_am(tod.hours()))
                    os << ampm_names(ampm_nms).first[0];
                else
                    os << ampm_names(ampm_nms).first[1];
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'r':
            if (command)
            {
                if (!fds.has_tod)
                    os.setstate(std::ios::failbit);
                auto const& tod = fds.tod;
                save_ostream<char> _(os);
                os.fill('0');
                os.width(2);
                os << date::make12(tod.hours()).count() << char{ ':' };
                os.width(2);
                os << tod.minutes().count() << char{ ':' };
                os.width(2);
                os << tod.seconds().count() << char{ ' ' };
                if (date::is_am(tod.hours()))
                    os << ampm_names(ampm_nms).first[0];
                else
                    os << ampm_names(ampm_nms).first[1];
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'R':
            if (command)
            {
                if (!fds.has_tod)
                    os.setstate(std::ios::failbit);
                if (fds.tod.hours() < hours{ 10 })
                    os << char{ '0' };
                os << fds.tod.hours().count() << char{ ':' };
                if (fds.tod.minutes() < minutes{ 10 })
                    os << char{ '0' };
                os << fds.tod.minutes().count();
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'S':
            if (command)
            {
                if (!fds.has_tod)
                    os.setstate(std::ios::failbit);
                if (insert_negative)
                {
                    os << '-';
                    insert_negative = false;
                }
                if (fds.tod.seconds() < seconds{ 10 })
                    os << char{ '0' };
                os << fds.tod.seconds().count();
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 't':
            if (command)
            {
                os << char{ '\t' };
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'T':
            if (command)
            {
                if (!fds.has_tod)
                    os.setstate(std::ios::failbit);
                os << fds.tod;
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'y':
            if (command)
            {
                if (!fds.ymd.year().ok())
                    os.setstate(std::ios::failbit);
                auto y = static_cast<int>(fds.ymd.year());
                y = std::abs(y) % 100;
                if (y < 10)
                    os << char{ '0' };
                os << y;
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'Y':
            if (command)
            {
                if (!fds.ymd.year().ok())
                    os.setstate(std::ios::failbit);
                auto y = fds.ymd.year();
                save_ostream<char> _(os);
                os.imbue(std::locale::classic());
                os << y;
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'z':
            if (command)
            {
                if (offset_sec == nullptr)
                {
                    // Can not format %z with unknown offset
                    os.setstate(std::ios::failbit);
                    return os;
                }
                auto m = duration_cast<minutes>(*offset_sec);
                auto neg = m < minutes{ 0 };
                m = date::abs(m);
                auto h = duration_cast<hours>(m);
                m -= h;
                if (neg)
                    os << char{ '-' };
                else
                    os << char{ '+' };
                if (h < hours{ 10 })
                    os << char{ '0' };
                os << h.count();
                if (m < minutes{ 10 })
                    os << char{ '0' };
                os << m.count();
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case 'Z':
            if (command)
            {
                if (abbrev == nullptr)
                {
                    // Can not format %Z with unknown time_zone
                    os.setstate(std::ios::failbit);
                    return os;
                }
                for (auto c : *abbrev)
                    os << c;
                command = nullptr;
            }
            else
                os << *fmt;
            break;
        case '%':
            if (command)
            {
                os << char{ '%' };
                command = nullptr;

            }
            else
                command = fmt;
            break;
        default:
            if (command)
            {
                os << char{ '%' };
                command = nullptr;
            }
            os << *fmt;
            break;
        }
    }
    if (command)
        os << char{ '%' };
    return os;
}

#endif
