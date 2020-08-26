#ifndef ALIX_INCLUDE_EFI_EFI_TYPES_H
#define ALIX_INCLUDE_EFI_EFI_TYPES_H	1

#if !defined (__STDC_VERSION__) || __STDC_VERSION__ < 199901L
#error EFI development requires C99
#endif

/* EFI Data types */
#include <stdint.h>

typedef int8_t			BOOLEAN;		/* Logical Boolean (1 byte) */

typedef long int			INTN;		/* Native integer size */
typedef unsigned long int	UINTN;		/* Native unsigned integer size */

typedef int8_t			INT8;			/* 8-bit signed integer */
typedef uint8_t			UINT8;			/* 8-bit unsigned integer */
typedef int16_t			INT16;			/* 16-bit signed integer */
typedef uint16_t		UINT16;			/* 16-bit unsigned integer */
typedef int32_t			INT32;			/* 32-bit signed integer */
typedef uint32_t		UINT32;			/* 32-bit unsigned integer */
typedef int64_t			INT64;			/* 64-bit signed integer */
typedef uint64_t		UINT64;			/* 64-bit unsigned integer */

typedef uint8_t			CHAR8;			/* 8-bit wide character */
typedef uint16_t		CHAR16;			/* 16-bit wide character */

typedef void			VOID;			/* void data type */

/* 128-bit buffer containing a unique identifier value */
typedef struct {
	UINT32 Data1;
	UINT16 Data2;
	UINT16 Data3;
	UINT8 Data4[8];
} EFI_GUID;

typedef UINTN			EFI_STATUS;		/* Status code */
typedef VOID *			EFI_HANDLE;		/* A collection of related interfaces */
typedef VOID *			EFI_EVENT;		/* Handle to an event structure */
typedef UINT64			EFI_LBA;		/* Logical block address */
typedef UINTN			EFI_TPL;		/* Task priority level */

typedef struct {
	UINT64	Signature;
	UINT32	Revision;
	UINT32	HeaderSize;
	UINT32	CRC32;
	UINT32	Reserved;
} EFI_TABLE_HEADER;

/* 32-byte buffer containing a network Media Access Control address */
typedef struct {
	UINT8 Addr[32];
} EFI_MAC_ADDRESS;

/* An IPv4 internet protocol address */
typedef struct _EFI_IPv4_ADDRESS {
	UINT8 Addr[4];
} EFI_IPv4_ADDRESS;

/* An IPv6 internet protocol address */
typedef struct _EFI_IPv6_ADDRESS {
	UINT8 Addr[16];
} EFI_IPv6_ADDRESS;

/* An IPv4 or IPv6 internet protocol address */
typedef union {
	UINT32				Addr[4];
	EFI_IPv4_ADDRESS	v4;
	EFI_IPv6_ADDRESS	v6;
} EFI_IP_ADDRESS;

/* Modifiers for common EFI data types */
#define IN			/**/
#define OUT			/**/
#define OPTIONAL	/**/
#define CONST		const
#define EFIAPI		/**/

#endif
