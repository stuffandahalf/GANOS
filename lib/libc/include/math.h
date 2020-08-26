#ifndef _ALIX_LIBC_MATH_H
#define _ALIX_LIBC_MATH_H

#if !FLT_EVAL_METHOD
typedef float		float_t;
typedef double		double_t;
#elif FLT_EVAL_METHOD == 1
typedef double		float_t;
typedef double		double_t;
#elif FLT_EVAL_METHOD == 2
typedef long double	float_t;
typedef long double	double_t;
#endif	/* FLT_EVAL_METHOD */

double		acos(double);
float		acosf(float);
double		acosh(double);
float		acoshf(float);
long double	acoshl(long double);
long double	acosl(long double);

double		asin(double);
float		asinf(float);
double		asinh(double);
float		asinhf(float);
long double	asinhl(long double);
long double	asinl(long double);

double		atan(double);
double		atan2(double, double);
float		atan2f(float, float);
long double	atan2l(long double, long double);
float		atanf(float);
double		atanh(double);
float		atanhf(float);
long double	atanhl(long double);
long double	atanl(long double);

#endif /* _ALIX_LIBC_MATH_H */

