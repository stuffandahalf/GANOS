#include <stdio.h>
#include <unistd.h>

#define XSI_CONFORMANT 1

const char *mf_paths[] = {
	"./makefile",
	"./Makefile"
#ifdef XSI_CONFORMANT
	,
	"./s.makefile",
	"SCSS/s.makefile",
	"./s.Makefile",
	"SCSS/s.Makefile"
#endif	/* XSI_CONFORMANT */
};
size_t mf_path_c = sizeof(mf_paths) / sizeof(const char *);

const char *s_tgt[] = {
	".DEFAULT",
	".IGNORE",
	".POSIX",
	".PRECIOUS",
	".SCCS_GET",
	".SILENT",
	".SUFFIXES"
};

int streq(const char *, const char *);

int
main(int argc, char *argv[])
{
	//char *s1 = "this is a test";
	//char *s2 = "this is a test";
	//char *s3 = "this is not a test";
	//printf("result is %d\n", streq(s1, s3));
	for (int i = 0; i < mf_path_c; i++) {
		printf("searching for \"%s\"\n", mf_paths[i]);
	}
	return 0;
}

int
streq(const char *s1, const char *s2)
{
	int eq;
	size_t i;

	eq = 1;
	i = 0;
	while ((s1[i] != '\0' || s2[i] != '\0') && eq) {
		if (s1[i] != s2[i]) {
			eq = 0;
		}
		++i;
	}

	return eq;
}

