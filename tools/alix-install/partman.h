#ifndef ALIX_INSTALL_PARTMAN_H
#define ALIX_INSTALL_PARTMAN_H	1

#define FORMAT_TYPE_X86_FLOPPY
#define FORMAT_TYPE_X86_MBR
#define FORMAT_TYPE_X86_GPT

void format_i(int fd);

void format_x86(int fd, int type);

#endif /* ALIX_INSTALL_PARTMAN_H */
