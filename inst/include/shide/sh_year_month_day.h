#ifndef SH_YEAR_MONTH_DAY_H
#define SH_YEAR_MONTH_DAY_H
#include "shide/date.h"

namespace internal
{
	constexpr int JALALI_ZERO{ 1947954 };
	constexpr int JD_UNIX_EPOCH{ 2440588 };
	constexpr int LOWER_PERSIAN_YEAR{ -1096 };
	constexpr int UPPER_PERSIAN_YEAR{ 2327 };
	static constexpr int MONTH_DATA_CUM[13]{ 0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336, 366 };
	constexpr date::local_days nan_local_days{ date::local_days(date::nanyear / 0 / 0) };
}

namespace detail
{
	constexpr
	inline
	int 
	jalali_jd0(const int year) {
		using namespace internal;
		constexpr int breaks[12]{ -708, -221,   -3,    6,  394,  720,
										  786, 1145, 1635, 1701, 1866, 2328 };
		constexpr int deltas[12]{ 1108, 1047,  984, 1249,  952,  891,
										  930,  866,  869,  844,  848,  852 };

		// this case is equivalent to i=8 and is the most common case that may happen in practice
		if (year >= breaks[7] && year < breaks[8])
		{
			return JALALI_ZERO + year * 365 + (deltas[8] + year * 303) / 1250;
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
					rval--;
				break;
			}
		}

		return rval;
	}

	constexpr
	inline
	int
	mod(const int x, const int y)
	{
		const int rval{ x % y };
		return rval < 0 ? rval + y : rval;
	}

	constexpr
	inline
	int 
	approx_year(int jd)
	{
		constexpr int calendar_epoch{ internal::JALALI_ZERO + 1 };
		constexpr int n1{ 2820 }; /* exact values which overflow on 32 bits */
		constexpr int n2{ 2820 * 365 + 683 };

		jd -= calendar_epoch;
		const int day_in_cycle{ mod(jd, n2) };
		const double tmp{ (static_cast<double>(n1) / n2) * day_in_cycle };
		int year{ n1 * ((jd - day_in_cycle) / n2) };
		year += static_cast<int>(tmp);
		return year;
	}
}

using days = date::days;
using months = date::months;
using years = date::years;
using local_days = date::local_days;
using date::literals::last;

class sh_year_month_day;
class sh_year_month_day_last;

constexpr
inline
bool
year_is_leap(const date::year& y)
{
	using namespace detail;
	return (jalali_jd0(static_cast<int>(y)+1) - jalali_jd0(static_cast<int>(y)) == 366);
}

class sh_year_month_day
{
	date::year  y_;
	date::month m_;
	date::day   d_;

public:
	sh_year_month_day() = default;
	constexpr sh_year_month_day(const date::year& y, const date::month& m,
		const date::day& d) NOEXCEPT;
	constexpr sh_year_month_day(const sh_year_month_day_last& ymdl) NOEXCEPT;

	constexpr sh_year_month_day(const date::year_month_day& ymd) NOEXCEPT;
	constexpr explicit sh_year_month_day(local_days dp) NOEXCEPT;

	constexpr sh_year_month_day& operator+=(const months& m) NOEXCEPT;
	constexpr sh_year_month_day& operator-=(const months& m) NOEXCEPT;
	constexpr sh_year_month_day& operator+=(const years& y)  NOEXCEPT;
	constexpr sh_year_month_day& operator-=(const years& y)  NOEXCEPT;

	constexpr date::year  year()  const NOEXCEPT;
	constexpr date::month month() const NOEXCEPT;
	constexpr date::day   day()   const NOEXCEPT;

	constexpr explicit operator local_days() const NOEXCEPT;
	constexpr bool ok() const NOEXCEPT;

private:
	static constexpr sh_year_month_day from_days(days dp) NOEXCEPT;
	constexpr days to_days() const NOEXCEPT;
};

constexpr sh_year_month_day operator+(const sh_year_month_day& ymd, const months& dm) NOEXCEPT;
constexpr sh_year_month_day operator+(const months& dm, const sh_year_month_day& ymd) NOEXCEPT;
constexpr sh_year_month_day operator-(const sh_year_month_day& ymd, const months& dm) NOEXCEPT;
constexpr sh_year_month_day operator+(const sh_year_month_day& ymd, const years& dy)  NOEXCEPT;
constexpr sh_year_month_day operator+(const years& dy, const sh_year_month_day& ymd)  NOEXCEPT;
constexpr sh_year_month_day operator-(const sh_year_month_day& ymd, const years& dy)  NOEXCEPT;

class sh_year_month_day_last
{
	date::year           y_;
	date::month_day_last mdl_;

public:
	constexpr sh_year_month_day_last(const date::year& y,
		const date::month_day_last& mdl) NOEXCEPT;

	constexpr sh_year_month_day_last& operator+=(const months& m) NOEXCEPT;
	constexpr sh_year_month_day_last& operator-=(const months& m) NOEXCEPT;
	constexpr sh_year_month_day_last& operator+=(const years& y)  NOEXCEPT;
	constexpr sh_year_month_day_last& operator-=(const years& y)  NOEXCEPT;

	constexpr date::year           year()           const NOEXCEPT;
	constexpr date::month          month()          const NOEXCEPT;
	constexpr date::month_day_last month_day_last() const NOEXCEPT;
	constexpr date::day            day()            const NOEXCEPT;

	constexpr explicit operator local_days() const NOEXCEPT;
	constexpr bool ok() const NOEXCEPT;
};

constexpr sh_year_month_day_last operator+(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT;
constexpr sh_year_month_day_last operator+(const months& dm, const sh_year_month_day_last& ymdl) NOEXCEPT;
constexpr sh_year_month_day_last operator+(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT;
constexpr sh_year_month_day_last operator+(const years& dy, const sh_year_month_day_last& ymdl) NOEXCEPT;
constexpr sh_year_month_day_last operator-(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT;
constexpr sh_year_month_day_last operator-(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT;

constexpr
inline
sh_year_month_day::sh_year_month_day(const date::year& y, const date::month& m,
	const date::day& d) NOEXCEPT
	: y_(y)
	, m_(m)
	, d_(d)
{}

constexpr
inline
sh_year_month_day::sh_year_month_day(const date::year_month_day& ymd) NOEXCEPT
	: y_(ymd.year())
	, m_(ymd.month())
	, d_(ymd.day())
{}

constexpr
inline
sh_year_month_day::sh_year_month_day(local_days dp) NOEXCEPT
	: sh_year_month_day(from_days(dp.time_since_epoch()))
{}

constexpr inline date::year sh_year_month_day::year() const NOEXCEPT { return y_; }
constexpr inline date::month sh_year_month_day::month() const NOEXCEPT { return m_; }
constexpr inline date::day sh_year_month_day::day() const NOEXCEPT { return d_; }

constexpr
inline
bool
sh_year_month_day::ok() const NOEXCEPT
{
	if (!(y_.ok() && m_.ok()))
		return false;
	return date::day{ 1 } <= d_ && d_ <= sh_year_month_day_last{y_, (m_ / last)}.day();
}

constexpr
inline
days
sh_year_month_day::to_days() const NOEXCEPT
{
	using namespace detail;
	using namespace internal;
	auto const y = static_cast<int>(y_);
	auto const m = static_cast<int>(static_cast<unsigned>(m_));
	auto const d = static_cast<int>(static_cast<unsigned>(d_));
	return days{ jalali_jd0(y) + MONTH_DATA_CUM[m - 1] + d - JD_UNIX_EPOCH };
}

constexpr
inline
sh_year_month_day::operator local_days() const NOEXCEPT
{
	return local_days{ to_days() };
}

constexpr
inline
sh_year_month_day
sh_year_month_day::from_days(days dp) NOEXCEPT
{
	using namespace internal;
	using namespace detail;
	auto const jd = dp.count() + JD_UNIX_EPOCH;
	int m{ 1 };
	int y{ approx_year(jd) };
	int year_ends[2]{};
	do
	{
		year_ends[0] = jalali_jd0(y) + 1;
		year_ends[1] = jalali_jd0(y + 1);
		assert(year_ends[0] && year_ends[1]);

		if (year_ends[0] > jd)
		{
			y--;
			continue;
		}

		if (year_ends[1] < jd)
		{
			y++;
			continue;
		}

	} while (year_ends[0] > jd || year_ends[1] < jd);

	const int doy{ jd - year_ends[0] + 1 };
	for (int i{ 1 }; i < 13; ++i)
	{
		if (doy <= MONTH_DATA_CUM[i])
		{
			m = i;
			break;
		}
	}

	const int d{ doy - MONTH_DATA_CUM[m - 1] };
	return sh_year_month_day{ date::year(y), date::month(m), date::day(d) };
}

constexpr
inline
sh_year_month_day&
sh_year_month_day::operator+=(const months& m) NOEXCEPT
{
	*this = *this + m;
	return *this;
}

constexpr
inline
sh_year_month_day&
sh_year_month_day::operator-=(const months& m) NOEXCEPT
{
	*this = *this - m;
	return *this;
}

constexpr
inline
sh_year_month_day&
sh_year_month_day::operator+=(const years& y) NOEXCEPT
{
	*this = *this + y;
	return *this;
}

constexpr
inline
sh_year_month_day&
sh_year_month_day::operator-=(const years& y) NOEXCEPT
{
	*this = *this - y;
	return *this;
}

constexpr
inline
sh_year_month_day
operator+(const sh_year_month_day& ymd, const months& dm) NOEXCEPT
{
	return sh_year_month_day{ (ymd.year() / ymd.month() + dm) / ymd.day() };
}

constexpr
inline
sh_year_month_day
operator+(const months& dm, const sh_year_month_day& ymd) NOEXCEPT
{
	return ymd + dm;
}

constexpr
inline
sh_year_month_day
operator-(const sh_year_month_day& ymd, const months& dm) NOEXCEPT
{
	return ymd + (-dm);
}

constexpr
inline
sh_year_month_day
operator+(const sh_year_month_day& ymd, const years& dy) NOEXCEPT
{
	return sh_year_month_day{ (ymd.year() + dy) / ymd.month() / ymd.day() };
}

constexpr
inline
sh_year_month_day
operator+(const years& dy, const sh_year_month_day& ymd) NOEXCEPT
{
	return ymd + dy;
}

constexpr
inline
sh_year_month_day
operator-(const sh_year_month_day& ymd, const years& dy) NOEXCEPT
{
	return ymd + (-dy);
}

constexpr
inline
sh_year_month_day_last::sh_year_month_day_last(const date::year& y,
	const date::month_day_last& mdl) NOEXCEPT
	: y_(y)
	, mdl_(mdl)
{}

constexpr
inline
sh_year_month_day_last&
sh_year_month_day_last::operator+=(const months& m) NOEXCEPT
{
	*this = *this + m;
	return *this;
}

constexpr
inline
sh_year_month_day_last&
sh_year_month_day_last::operator-=(const months& m) NOEXCEPT
{
	*this = *this - m;
	return *this;
}

constexpr
inline
sh_year_month_day_last&
sh_year_month_day_last::operator+=(const years& y) NOEXCEPT
{
	*this = *this + y;
	return *this;
}

constexpr
inline
sh_year_month_day_last&
sh_year_month_day_last::operator-=(const years& y) NOEXCEPT
{
	*this = *this - y;
	return *this;
}

constexpr inline date::year sh_year_month_day_last::year() const NOEXCEPT { return y_; }
constexpr inline date::month sh_year_month_day_last::month() const NOEXCEPT { return mdl_.month(); }

constexpr
inline
date::month_day_last
sh_year_month_day_last::month_day_last() const NOEXCEPT
{
	return mdl_;
}

constexpr
inline
date::day
sh_year_month_day_last::day() const NOEXCEPT
{
	constexpr date::day d[] =
	{
		date::day(31), date::day(31), date::day(31),
		date::day(31), date::day(31), date::day(31),
		date::day(30), date::day(30), date::day(30),
		date::day(30), date::day(30), date::day(29)
	};
	return (month() != date::month(12) || !year_is_leap(y_)) && mdl_.ok() ?
		d[static_cast<unsigned>(month()) - 1] : date::day{ 30 };
}

constexpr
inline
sh_year_month_day_last::operator local_days() const NOEXCEPT
{
	return local_days(sh_year_month_day{ year(),  month(), day() });
}

constexpr
inline
bool
sh_year_month_day_last::ok() const NOEXCEPT
{
	return y_.ok() && mdl_.ok();
}

constexpr
inline
sh_year_month_day_last
operator+(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT
{
	date::year_month ym{ymdl.year(), ymdl.month()};
	ym += dm;
	return sh_year_month_day_last{ ym.year(), date::month_day_last{ ym.month() } };
}

constexpr
inline
sh_year_month_day_last
operator+(const months& dm, const sh_year_month_day_last& ymdl) NOEXCEPT
{
	return ymdl + dm;
}

constexpr
inline
sh_year_month_day_last
operator-(const sh_year_month_day_last& ymdl, const months& dm) NOEXCEPT
{
	return ymdl + (-dm);
}

constexpr
inline
sh_year_month_day_last
operator+(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT
{
	return { ymdl.year() + dy, ymdl.month_day_last() };
}

constexpr
inline
sh_year_month_day_last
operator+(const years& dy, const sh_year_month_day_last& ymdl) NOEXCEPT
{
	return ymdl + dy;
}

constexpr
inline
sh_year_month_day_last
operator-(const sh_year_month_day_last& ymdl, const years& dy) NOEXCEPT
{
	return ymdl + (-dy);
}

constexpr
inline
sh_year_month_day::sh_year_month_day(const sh_year_month_day_last& ymdl) NOEXCEPT
	: y_(ymdl.year())
	, m_(ymdl.month())
	, d_(ymdl.day())
{}

class hour_minute_second
{
	std::chrono::hours h_;
	std::chrono::minutes m_;
	std::chrono::seconds s_;

public:
	constexpr hour_minute_second() noexcept
		: hour_minute_second(std::chrono::seconds::zero())
	{}

	constexpr explicit hour_minute_second(std::chrono::seconds d) noexcept
		: h_(std::chrono::duration_cast<std::chrono::hours>(std::chrono::abs(d)))
		, m_(std::chrono::duration_cast<std::chrono::minutes>(std::chrono::abs(d)) - h_)
		, s_(std::chrono::abs(d) - h_ - m_)
	{}

	constexpr hour_minute_second(const std::chrono::hours& h, const std::chrono::minutes& m,
		const std::chrono::seconds& s) noexcept;

	constexpr std::chrono::hours hours() const noexcept { return h_; }
	constexpr std::chrono::minutes minutes() const noexcept { return m_; }
	constexpr std::chrono::seconds seconds() const noexcept { return s_; }
	constexpr std::chrono::seconds to_duration() const noexcept
	{
		return s_ + m_ + h_;
	}

	constexpr bool in_conventional_range() const noexcept
	{
		return h_ < date::days{ 1 } && m_ < std::chrono::hours{ 1 } &&
			s_ < std::chrono::minutes{ 1 };
	}

private:

	friend
		std::ostringstream&
		operator<<(std::ostringstream& os, hour_minute_second const& tod)
	{
		if (tod.h_ < std::chrono::hours{ 10 })
			os << '0';
		os << tod.h_.count() << ':';
		if (tod.m_ < std::chrono::minutes{ 10 })
			os << '0';
		os << tod.m_.count() << ':' << tod.s_.count();
		return os;
	}
};

constexpr
inline
hour_minute_second::hour_minute_second(const std::chrono::hours& h, const std::chrono::minutes& m,
	const std::chrono::seconds& s) noexcept
	: h_(h)
	, m_(m)
	, s_(s)
{}

struct sh_fields
{
	sh_year_month_day     ymd{ date::nanyear, date::month(0), date::day(0) };
	hour_minute_second    tod{};
	bool                  has_tod = false;

	constexpr sh_fields() = default;
	constexpr sh_fields(sh_year_month_day ymd_) : ymd(ymd_) {}
	constexpr sh_fields(hour_minute_second tod_) : tod(tod_), has_tod(true) {}
	constexpr sh_fields(sh_year_month_day ymd_, hour_minute_second tod_) : ymd(ymd_), tod(tod_),
		has_tod(true) {}
};

constexpr
inline
days
sh_yday(const sh_year_month_day& ymd)
{
	using namespace internal;
	return days{ MONTH_DATA_CUM[unsigned{ ymd.month() } - 1] + unsigned{ ymd.day() } };
}

constexpr
inline
days
sh_qday(const sh_year_month_day& ymd)
{
	constexpr int quarter_data[12] = { 0, 31, 62, 0, 31, 62, 0, 30, 60, 0, 30, 60 };
	return days{ quarter_data[unsigned{ ymd.month() } - 1] + unsigned{ ymd.day() } };
}

constexpr
inline
days
sh_wday(const date::local_days& ld)
{
	date::weekday wd{ ld };
	return days{ (wd.c_encoding() + 1) % 7 + 1 };
}

#endif
