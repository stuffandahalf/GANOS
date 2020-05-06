#ifndef _X86__TYPES_H
#define _X86__TYPES_H	1

typedef signed char				__int8_t;
typedef unsigned char			__uint8_t;
typedef short int				__int16_t;
typedef unsigned short int		__uint16_t;
typedef int						__int32_t;
typedef unsigned int			__uint32_t;
#ifdef __LP64__
typedef long int				__int64_t;
typedef unsigned long int		__uint64_t;
#else
typedef long long int			__int64_t;
typedef unsigned long long int	__uint64_t;
#endif

#ifdef __LP64__
typedef __uint64_t	__size_t;
typedef __int64_t	__ssize_t;
#endif

#endif

