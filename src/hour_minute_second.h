#ifndef HOUR_MINUTE_SECOND_H
#define HOUR_MINUTE_SECOND_H

#include <tzdb/date.h>

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
};

constexpr
inline
hour_minute_second::hour_minute_second(const std::chrono::hours& h, const std::chrono::minutes& m,
    const std::chrono::seconds& s) noexcept
    : h_(h)
    , m_(m)
    , s_(s)
{}

#endif
