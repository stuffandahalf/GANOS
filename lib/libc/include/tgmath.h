#ifndef _ALIX_LIBC_TGMATH_H
#define _ALIX_LIBC_TGMATH_H		1

#include <complex.h>
#include <math.h>

#if __STDC_VERSION__ >= 201107L
/* Use _Generic */
#define GENERIC_FUNC(func, x) \
	_Generic((x), \
			long double: func##l, \
			default: func, \
			float: funcf)((x))

#else
/* Use GCC style extensions */
/* https://pubs.opengroup.org/onlinepubs/009695399/basedefs/tgmath.h.html */
/* https://web.archive.org/web/20131205042841/http://carolina.mff.cuni.cz/~trmac/blog/2005/the-ugliest-c-feature-tgmathh/ */

#endif

#endif

