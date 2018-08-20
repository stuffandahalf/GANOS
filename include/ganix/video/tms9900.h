#ifndef _TMS9900_H
#define _TMS9900_H

#include <ganix/video/video.h>

#define _TMS9900_COLOUR_TRANSPARENT 0x0
#define _TMS9900_COLOUR_BLACK       0x1
#define _TMS9900_COLOUR_MEDGREEN    0x2
#define _TMS9900_COLOUR_LTGREEN     0x3
#define _TMS9900_COLOUR_DRKBLUE     0x4
#define _TMS9900_COLOUR_LTBLUE      0x5
#define _TMS9900_COLOUR_DRKRED      0x6
#define _TMS9900_COLOUR_CYAN        0x7
#define _TMS9900_COLOUR_MEDRED      0x8
#define _TMS9900_COLOUR_LTRED       0x9
#define _TMS9900_COLOUR_DRKYELLOW   0xA
#define _TMS9900_COLOUR_LTYELLOW    0xB
#define _TMS9900_COLOUR_DRKGREEN    0xC
#define _TMS9900_COLOUR_MAGENTA     0xD
#define _TMS9900_COLOUR_GREY        0xE
#define _TMS9900_COLOUR_WHITE       0xF

int init_tms9900_video();
void tms9900_plot_pixel(unsigned int x, unsigned int y, uint8_t colour);

#endif
