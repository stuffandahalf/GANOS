/*
 * SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2021 Gregory Norton <gregory.norton@me.com>
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY of FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

#include <fcntl.h>
#include <limits.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "partman.h"

size_t dev_path_len = 0;
char *dev_path = NULL;
int fd = -1;

int configure(int argc, char **argv);

void release(void)
{
	if (dev_path) {
		free(dev_path);
	}
}

int main(int argc, char **argv)
{
	char *c;
	
	setlocale(LC_ALL, "");
	atexit(release);
	
	if (!configure(argc, argv)) {
		return 1;
	}
	
	if (fd < 0) {
		if ((dev_path = malloc(sizeof(char) * (PATH_MAX + 1))) == NULL) {
			fprintf(stderr, "Failed to allocate buffer for device path\n");
			return 1;
		}
		printf("Enter target device name: ");
		if ((fgets(dev_path, PATH_MAX + 1, stdin)) == NULL) {
			fprintf(stderr, "Failed to read target device\n");
			return 1;
		}
		for (c = dev_path; *c != '\n' && *c != '\0'; c++) {
			dev_path_len++;
		}
		*c = '\0';
		dev_path = realloc(dev_path, sizeof(char) * (dev_path_len + 1));
		if ((fd = open(dev_path, O_RDWR | O_CREAT)) == -1) {
			fprintf(stderr, "Failed to open device file for modification\n");
			return 1;
		}
	}
	
	format(fd);
	
	close(fd);

	return 0;
}

int configure(int argc, char **argv)
{
	int c;
	while ((c = getopt(argc, argv, "hd:p:a:")) != -1) {
		switch (c) {
		case 'd':
			fd = open(optarg, O_RDWR | O_CREAT);
			break;
		case 'p':
			
			break;
		case 'h':
		case '?':
		default:
			fprintf(stderr, "Usage: %s [-h] [-d DEVICE] [-p PATH] [-a ARCH]\n",
				argv[0]);
			return 0;
		}
	}
	return 1;
}

