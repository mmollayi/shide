% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seq.R
\name{seq.jdate}
\alias{seq.jdate}
\title{Generate regular sequences of Jalali dates}
\usage{
\method{seq}{jdate}(from, to, by, length.out = NULL, along.with = NULL, ...)
}
\arguments{
\item{from}{starting date.  Required.}

\item{to}{end date.  Optional.}

\item{by}{increment of the sequence.  Optional.  See \sQuote{Details}.}

\item{length.out}{integer, optional.  Desired length of the sequence.}

\item{along.with}{take the length from the length of this argument.}

\item{...}{arguments passed to or from other methods.}
}
\value{
A vector of \code{jdate} objects.
}
\description{
The method for \link{seq} for objects of class \code{jdate}.
}
\details{
\code{by} can be specified in several ways:
\itemize{
\item A number, taken to be in days.
\item A object of class \link{difftime}.
\item A character string, containing one of "day", "week", "month", "quarter" or "year".
This can optionally be preceded by a (positive or negative) integer
and a space, or followed by "s".
}
}
\section{Comparison with \code{seq.Date()}}{

The source code of \code{seq.jdate()} is a modified version of the code used in \code{base::seq.Date()}.
But a few behaviors of the latter are changed:
\itemize{
\item In base R, invalid dates resolve by overflowing according to the number of days that the
date is invalid by. But \code{seq.jdate()} resolves invalid dates by rolling forward to the
first day of the next month.
\item If usage of \code{to} and \code{length.out} results in a fractional sequence between \code{from} and \code{to},
base R keeps the fraction in the underlying data of the output \code{Date} object. But since
\code{jdate} is built upon whole numbers, the fractional part is dropped in the output.
}

These differences are illustrated in the examples.
}

\examples{
# by days
seq(jdate("1402-01-01"), jdate("1402-01-10"), 1)
# by 2 weeks
seq(jdate("1402-01-01"), jdate("1402-04-01"), "2 weeks")
# first days of years
seq(jdate("1390-01-01"), jdate("1399-01-01"), "years")
# by month
seq(jdate("1400-01-01"), by = "month", length.out = 12)
# quarters
seq(jdate("1400-01-01"), jdate("1403-01-01"), by = "quarter")

# fractional dates are allowed in `seq.Date()`, but not in `seq.jdate()`
unclass(seq(as.Date(0), as.Date(3), length.out = 3))
unclass(seq(jdate(0), jdate(2), length.out = 3))

# resloving strategy for invalid dates is different in 'seq.jdate()' compared to 'seq.Date()'
seq(as.Date("2021-01-31"), by = "months", length.out = 2)
seq(jdate("1402-06-31"), by = "6 months", length.out = 2)
}
\seealso{
\code{\link[base:seq.Date]{base::seq.Date()}}
}
