## Resubmission

There are no references describing the methods in the package.

This is a resubmission. In this version I have:

* updated the description text.
* updated documentation files:
    * removed shide-vctrs.Rd
    * added shide-arithmetic.Rd that describes arithmetic operations for the classes that are implemented.
    * added shide-math.Rd that describes math methods for the classes that are implemented.
    * added vec_cast.jdate.Rd, vec_cast.jdatetime.Rd, vec_ptype2.jdate.Rd, vec_ptype2.jdatetime.Rd.
      In these files no examples or return value type is provided since these are internal functions
      and are exported so that the classes that are implemented would work with `vctrs` infrastructure.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
