#ifndef _UNISTD_H
#define _UNISTD_H	1

#define _POSIX_VERSION	200112L
#define _POSIX2_VERSION	200112L

/* Optional POSIX features */
#define _POSIX_ADVISORY_INFO				(-1)
#define _POSIX_ASYNCHRONOUS_IO				(-1)
#define _POSIX_BARRIERS						(-1)
#define _POSIX_CHOWN_RESTRICTED				1
#define _POSIX_CLOCK_SELECTION				(-1)
#define _POSIX_CPUTIME						(-1)
#define _POSIX_FSYNC						(-1)
#define _POSIX_IPV6							(-1)
#define _POSIX_JOB_CONTROL					1
#define _POSIX_MAPPED_FILES					(-1)
#define _POSIX_MEMLOCK						(-1)
#define _POSIX_MEMLOCK_RANGE				(-1)
#define _POSIX_MEMORY_PROTECTION			(-1)
#define _POSIX_MESSAGE_PASSING				(-1)
#define _POSIX_MONOTONIC_CLOCK				(-1)
#define _POSIX_NO_TRUNC						1
#define _POSIX_PRIORITIZED_IO				(-1)
#define _POSIX_PRIORITY_SCHEDULING			(-1)
#define _POSIX_RAW_SOCKETS					(-1)
#define _POSIX_READER_WRITER_LOCKS			(-1)
#define _POSIX_REALTIME_SIGNALS				(-1)
#define _POSIX_REGEXP						1
#define _POSIX_SAVED_IDS					1
#define _POSIX_SEMAPHORES					(-1)
#define _POSIX_SHARED_MEMORY_OBJECTS		(-1)
#define _POSIX_SHELL						1
#define _POSIX_SPAWN						(-1)
#define _POSIX_SPIN_LOCKS					(-1)
#define _POSIX_SPORADIC_SERVER				(-1)
#define _POSIX_SYNCHRONIZED_IO				(-1)
#define _POSIX_THREAD_ATTR_STACKADDR		(-1)
#define _POSIX_THREAD_ATTR_STACKSIZE		(-1)
#define _POSIX_THREAD_CPUTIME				(-1)
#define _POSIX_THREAD_PRIO_INHERIT			(-1)
#define _POSIX_THREAD_PRIO_PROTECT			(-1)
#define _POSIX_THREAD_PRIORITY_SCHEDULING	(-1)
#define _POSIX_THREAD_PROCESS_SHARED		(-1)
#define _POSIX_THREAD_SAFE_FUNCTIONS		(-1)
#define _POSIX_THREAD_SPORADIC_SERVER		(-1)
#define _POSIX_THREADS						(-1)
#define _POSIX_TIMEOUTS						(-1)
#define _POSIX_TIMERS						(-1)
#define _POSIX_TRACE						(-1)
#define _POSIX_TRACE_EVENT_FILTER			(-1)
#define _POSIX_TRACE_INHERIT				(-1)
#define _POSIX_TRACE_LOG					(-1)
#define _POSIX_TYPED_MEMORY_OBJECTS			(-1)
#define _POSIX_VDISABLE						'\0'

#define _POSIX2_C_BIND						200112L
#define _POSIX2_C_DEV						(-1)
#define _POSIX2_CHAR_TERM					1
#define _POSIX2_FORT_DEV					(-1)
#define _POSIX2_FORT_RUN					(-1)
#define _POSIX2_LOCALDEF					(-1)
#define _POSIX2_PBS							(-1)
#define _POSIX2_PBS_ACCOUNTING				(-1)
#define _POSIX2_PBS_CHECKPOINT				(-1)
#define _POSIX2_PBS_LOCATE					(-1)
#define _POSIX2_PBS_MESSAGE					(-1)
#define _POSIX2_PBS_TRACK					(-1)
#define _POSIX2_SW_DEV						(-1)
#define _POSIX2_UPE							(-1)

#define _POSIX_V6_ILP32_OFF32				1
/*#define _POSIX_V6_ILP32_OFFBIG				1*/
/*#define _POSIX_V6_LP64_OFF64					1*/
/*#define _POSIX_V6_LPBIG_OFFBIG				1*/

#define _XBS5_ILP32_OFF32					1
/*#define _XBS5_ILP32_OFFBIG					1*/
/*#define _XBS5_LP64_OFF64						1*/
/*#define _XBS5_LPBIG_OFFBIG					1*/

/*#define _XOPEN_CRYPT							1*/
/*#define _XOPEN_ENH_I18N						1*/
/*#define _XOPEN_LEGACY							1*/
/*#define _XOPEN_REALTIME						1*/
/*#define _XOPEN_REALTIME_THREADS				1*/
/*#define _XOPEN_SHM							1*/
/*#define _XOPEM_STREAMS						1*/
/*#define _XOPEN_UNIX							1*/

#define _POSIX_ASYNC_IO						(-1)
#define _POSIX_PRIO_IO						(-1)
#define _POSIX_SYNC_IO						(-1)

/* null pointer */
#include <sys/_null.h>

/* access flags */
#define F_OK	0
#define R_OK	1
#define W_OK	2
#define X_OK	4

/* constants for confstr */
#define _CS_PATH							0
#define _CS_POSIX_V6_ILP32_OFF32_CFLAGS		10
#define _CS_POSIX_V6_ILP32_OFF32_LDFLAGS	11
#define _CS_POSIX_V6_ILP32_OFF32_LIBS		12
#define _CS_POSIX_V6_ILP32_OFFBIG_CFLAGS	20
#define _CS_POSIX_V6_ILP32_OFFBIG_LDFLAGS	21
#define _CS_POSIX_V6_ILP32_OFFBIG_LIBS		22
#define _CS_POSIX_V6_LP64_OFF64_CFLAGS		30
#define _CS_POSIX_V6_LP64_OFF64_LDFLAGS		31
#define _CS_POSIX_V6_LP64_OFF64_LIBS		32
#define _CS_POSIX_V6_LPBIG_OFFBIG_CFLAGS	40
#define _CS_POSIX_V6_LPBIG_OFFBIG_LDFLAGS	41
#define _CS_POSIX_V6_LPBIG_OFFBIG_LIBS		42
#define _CS_POSIX_V6_WIDTH_RESTRICTED_ENVS	1
/* legacy confstr flags */
#define _CS_XBS5_ILP32_OFF32_CFLAGS			13
#define _CS_XBS5_ILP32_OFF32_LDFLAGS		14
#define _CS_XBS5_ILP32_OFF32_LIBS			15
#define _CS_XBS5_ILP32_OFF32_LINTFLAGS		16
#define _CS_XBS5_ILP32_OFFBIG_CFLAGS		23
#define _CS_XBS5_ILP32_OFFBIG_LDFLAGS		24
#define _CS_XBS5_ILP32_OFFBIG_LIBS			25
#define _CS_XBS5_ILP32_OFFBIG_LINTFLAGS		26
#define _CS_XBS5_LP64_OFF64_CFLAGS			33
#define _CS_XBS5_LP64_OFF64_LDFLAGS			34
#define _CS_XBS5_LP64_OFF64_LIBS			35
#define _CS_XBS5_LP64_OFF64_LINTFLAGS		36
#define _CS_XBS5_LPBIG_OFFBIG_CFLAGS		43
#define _CS_XBS5_LPBIG_OFFBIG_LDFLAGS		44
#define _CS_XBS5_LPBIG_OFFBIG_LIBS			45
#define _CS_XBS5_LPBIG_OFFBIG_LINTFLAGS		46

/* constants for lseek and fcntl */
#define SEEK_SET	0
#define SEEK_CUR	1
#define SEEK_END	2

/* constants for lockf */
#define F_ULOCK 0
#define F_LOCK	1
#define F_TEST	2
#define F_TLOCK	3

/* constats for sysconf */
#define _SC_2_C_BIND						1
#define _SC_2_C_DEV							2
#define _SC_2_CHAR_TERM						3
#define _SC_2_FORT_DEV						4
#define _SC_2_FORT_RUN						5
#define _SC_2_LOCALEDEF						6
#define _SC_2_PBS							7
#define _SC_2_PBS_ACCOUNTING				8
#define _SC_2_PBS_CHECKPOINT				9
#define _SC_2_PBS_LOCATE					10
#define _SC_2_PBS_MESSAGE					11
#define _SC_2_PBS_TRACK						12
#define _SC_2_SW_DEV						13
#define _SC_2_UPE							14
#define _SC_2_VERSION						15
#define _SC_ADVISORY_INFO					16
#define _SC_AIO_LISTIO_MAX					17
#define _SC_AIO_MAX							18
#define _SC_AIO_PRIO_DELTA_MAX				19
#define _SC_ARG_MAX							20
#define _SC_ASYNCHRONOUS_IO					21
#define _SC_ATEXIT_MAX						22
#define _SC_BARRIERS						23
#define _SC_BC_BASE_MAX						24
#define _SC_BC_DIM_MAX						25
#define _SC_BC_SCALE_MAX					26
#define _SC_BC_STRING_MAX					27
#define _SC_CHILD_MAX						28
#define _SC_CLK_TCK							29
#define _SC_CLOCK_SELECTION					30
#define _SC_COLL_WEIGHTS_MAX				31
#define _SC_CPUTIME							32
#define _SC_DELAYTIMER_MAX					33
#define _SC_EXPR_NEST_MAX					34
#define _SC_FSYNC							35
#define _SC_GETGR_R_SIZE_MAX				36
#define _SC_GETPW_R_SIZE_MAX				37
#define _SC_HOST_NAME_MAX					38
#define _SC_IOV_MAX							39
#define _SC_IPV6							40
#define _SC_JOB_CONTROL						41
#define _SC_LINE_MAX						42
#define _SC_LOGIN_NAME_MAX					43
#define _SC_MAPPED_FILES					44
#define _SC_MEMLOCK							45
#define _SC_MEMLOCK_RANGE					46
#define _SC_MEMORY_PROTECTION				47
#define _SC_MESSAGE_PASSING					48
#define _SC_MONOTONIC_CLOCK					49
#define _SC_MQ_OPEN_MAX						50
#define _SC_MQ_PRIO_MAX						51
#define _SC_NGROUPS_MAX						52
#define _SC_OPEN_MAX						53
#define _SC_PAGE_SIZE						54
#define _SC_PAGESIZE						54
#define _SC_PRIORITIZED_IO					55
#define _SC_PRIORITY_SCHEDULING				56
#define _SC_RAW_SOCKETS						57
#define _SC_RE_DUP_MAX						58
#define _SC_READER_WRITER_LOCKS				59
#define _SC_REALTIME_SIGNALS				60
#define _SC_REGEXP							61
#define _SC_RTSIG_MAX						62
#define _SC_SAVED_IDS						63
#define _SC_SEM_NSEMS_MAX					64
#define _SC_SEM_VALUE_MAX					65
#define _SC_SEMAPHORES						66
#define _SC_SHARED_MEMORY_OBJECTS			67
#define _SC_SHELL							68
#define _SC_SIGQUEUE_MAX					69
#define _SC_SPAWN							70
#define _SC_SPIN_LOCKS						71
#define _SC_SPORADIC_SERVER					72
#define _SC_SS_REPL_MAX						73
#define _SC_STREAM_MAX						74
#define _SC_SYMLOOP_MAX						75
#define _SC_SYNCHRONIZED_IO					76
#define _SC_THREAD_ATTR_STACKADDR			77
#define _SC_THREAD_ATTR_STACKSIZE			78
#define _SC_THREAD_CPUTIME					79
#define _SC_THREAD_DESTRUCTOR_ITERATIONS	80
#define _SC_THREAD_KEYS_MAX					81
#define _SC_THREAD_PRIO_INHERIT				82
#define _SC_THREAD_PRIO_PROTECT				83
#define _SC_THREAD_PRIORITY_SCHEDULING		84
#define _SC_THREAD_PROCESS_SHARED			85
#define _SC_THREAD_SAFE_FUNCTIONS			86
#define _SC_THREAD_SPORADIC_SERVER			87
#define _SC_THREAD_STACK_MIN				88
#define _SC_THREAD_THREADS_MAX				89
#define _SC_THREADS							90
#define _SC_TIMEOUTS						91
#define _SC_TIMER_MAX						92
#define _SC_TIMERS							93
#define _SC_TRACE							94
#define _SC_TRACE_EVENT_FILTER				95
#define _SC_TRACE_EVENT_NAME_MAX			96
#define _SC_TRACE_INHERIT					97
#define _SC_TRACE_LOG						98
#define _SC_TRACE_NAME_MAX					99
#define _SC_TRACE_SYS_MAX					100
#define _SC_TRACE_USER_EVENT_MAX			101
#define _SC_TTY_NAME_MAX					102
#define _SC_TYPED_MEMORY_OBJECTS			103
#define _SC_TZNAME_MAX						104
#define _SC_V6_ILP32_OFF32					105
#define _SC_V6_ILP32_OFFBIG					106
#define _SC_V6_LP64_OFF64					107
#define _SC_V6_LPBIG_OFFBIG					108
#define _SC_VERSION							109
#define _SC_XBS5_ILP32_OFF32				110
#define _SC_XBS5_ILP32_OFFBIG				111
#define _SC_XBS5_LP64_OFF64					112
#define _SC_XBS5_LPBIG_OFFBIG				113
#define _SC_XOPEN_CRYPT						114
#define _SC_XOPEN_ENH_I18N					115
#define _SC_XOPEN_LEGACY					116
#define _SC_XOPEN_REALTIME					117
#define _SC_XOPEN_REALTIME_THREADS			118
#define _SC_XOPEN_SHM						119
#define _SC_XOPEN_STREAMS					120
#define _SC_XOPEN_UNIX						121
#define _SC_XOPEN_VERSION					122

/* file streams */
#define STDERR_FILENO	2
#define STDIN_FILENO	0
#define STDOUT_FILENO	1

#ifndef DEFINED_SIZE_T
//typedef 
#define DEFINED_SIZE_T	1
#endif

#endif /* !defined(_UNISTD_H) */

