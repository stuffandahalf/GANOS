#ifndef VIDEO_H
#define VIDEO_H

enum colour {
    COLOUR_BLACK,
    COLOUR_BLUE,
    COLOUR_GREEN,
    COLOUR_CYAN,
    COLOUR_RED,
    COLOUR_PURPLE,
    COLOUR_BROWN,
    COLOUR_GREY,
    COLOUR_DARK_GREY,
    COLOUR_LIGHT_BLUE,
    COLOUR_LIGHT_GREEN,
    COLOUR_LIGHT_CYAN,
    COLOUR_LIGHT_RED,
    COLOUR_LIGHT_PURPLE,
    COLOUR_YELLOW,
    COLOUR_WHITE
};

#define CHAR_COLOUR(bg, fg) ((FLAG(bg) << 4) | FLAG(fg))

struct video_mode {
    uint8_t mode;
    uint8_t columns;
    uint8_t active_page;
} __attribute__((packed));

struct display {
    volatile uint8_t *buffer;
    uint16_t index;
    uint16_t width;
    uint16_t height;
} __attribute__((packed));

#endif
