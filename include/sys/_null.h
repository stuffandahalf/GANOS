#ifndef NULL

#ifdef __cplusplus
#if __cplusplus >= 201103L
#define NULL	nullptr
#else
#define NULL	0
#endif /* __cplusplus >= 201103L */
#else
#define NULL	((void *)0)
#endif /* defined(NULL) */

#endif /* !defined(NULL) */

