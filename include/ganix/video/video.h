#ifndef __VIDEO_H
#define __VIDEO_H

#include <stdint.h>

struct display_device {
    void (* plot) (unsigned int x, unsigned int y, uint8_t colour);
};

int init_display_device(struct display_device *dev);

#endif
