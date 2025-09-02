#ifndef FORMAT_H
#define FORMAT_H

#include "shide/sh_year_month_day.h"

std::ostringstream&
sh_to_stream(std::ostringstream& os, const char* fmt, const sh_fields& fds)
{
    using std::chrono::duration_cast;
    using std::chrono::seconds;
    using std::chrono::minutes;
    using std::chrono::hours;
    using date::detail::save_ostream;
    os.fill(' ');
    os.flags(std::ios::skipws | std::ios::dec);
    os.width(0);
    bool insert_negative = fds.has_tod && fds.tod.to_duration() < seconds::zero();
    const char* command = nullptr;
    for (; *fmt; ++fmt)
    {
        switch (*fmt)
        {
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
            if (command)
            {
                if (!fds.ymd.ok())
                    os.setstate(std::ios::failbit);
                auto const& ymd = fds.ymd;
                save_ostream<char> _(os);
                os.imbue(std::locale::classic());
                os.fill('0');
                os.flags(std::ios::dec | std::ios::right);
                os.width(4);
                os << static_cast<int>(ymd.year()) << char{ '-' };
                os.width(2);
                os << static_cast<unsigned>(ymd.month()) << char{ '-' };
                os.width(2);
                os << static_cast<unsigned>(ymd.day());
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
        case 'n':
            if (command)
            {
                os << char{ '\n' };
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
