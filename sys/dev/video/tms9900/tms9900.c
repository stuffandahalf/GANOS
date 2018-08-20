#include <ganix/video/tms9900.h>

int init_tms9900_video() {
    struct display_device *tms9900 = malloc(sizeof(struct display_device));
    tms9900->address = 0xFC00;
    tms9900->plot = &(tms9900_plot_pixel);
    return init_video_device(tms9900);
}

void tms9900_plot_pixel(unsigned x, unsigned y, unsigned char colour) {

}
