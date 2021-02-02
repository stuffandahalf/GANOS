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

#ifndef ALIX_INSTALL_PARTMAN_H
#define ALIX_INSTALL_PARTMAN_H	1

#define FORMAT_TYPE_X86_FLOPPY
#define FORMAT_TYPE_X86_MBR
#define FORMAT_TYPE_X86_GPT

void format_i(int fd);

void format_x86(int fd, int type);

#endif /* ALIX_INSTALL_PARTMAN_H */
