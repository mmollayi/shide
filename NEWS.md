# shide (development version)

# shide 0.2.0

* New `sh_year_is_leap()` determines if a Jalali year is a leap year.

* New accessor and replacement functions are added to get/set the components of Jalali date-time objects.

* New family of functions for rounding Jalali dates to a specific unit of time:

	*  `sh_floor()` rounds a `jdate` object down to the previous unit of time.
	
	*  `sh_ceiling()` rounds a `jdate` object up to the next unit of time.
	
	*  `sh_round()` rounds a `jdate` object up or down, depending on what is closer.
	
* New `seq.jdate()` generates regular sequences of Jalali dates.

* `as.POSIXlt()` now errors with `jdate` and `jdatetime` input. In order to cast
  `jdate` and `jdatetime` to `POSIXlt`, first, they should be converted to `Date` and `POSIXct` 
  respectively.
  
* `jdate()` now truncates numeric input toward zero before generating a `jdate` object.

* `jdatetime()` now truncates numeric input toward zero before generating a `jdatetime` object.

* Fixed a bug where names were dropped after calling `format()` upon a `jdate` or `jdatetime`
  object.

# shide 0.1.2

* Initial CRAN submission.
* Added a `NEWS.md` file to track changes to the package.
