#ifndef ALIX_MAKE_DYNARRAY_H
#define ALIX_MAKE_DYNARRAY_H	1

#include <stdio.h>
#include <stdlib.h>
#include "static_assert.h"

#define DYNARRAY(T) \
	struct { \
		T *array; \
		size_t len; \
		size_t sizeof_T; \
	}

#define dynarray_init(T, arr) { \
	arr.array = NULL; \
	arr.len = 0; \
	arr.sizeof_T = sizeof(T); \
}

#define dynarray_append(arr, elem) { \
	arr.len++; \
	if (arr.array == NULL) { \
		arr.array = malloc(arr.sizeof_T); \
	} else { \
		arr.array = realloc(arr.array, arr.sizeof_T * arr.len); \
	} \
	if (arr.array == NULL) { \
		fprintf(stderr, "Failed to allocate space for new element in dynamic " \
			"array \"%s\"\n", #arr); \
		exit(EXIT_FAILURE); \
	} \
	arr.array[arr.len - 1] = elem; \
}

#define dynarray_release(arr) \
	free(arr.array)

#endif /* ALIX_MAKE_DYNARRAY_H */
