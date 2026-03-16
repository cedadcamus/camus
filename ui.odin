package camus

import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"
import "core:log"
import "base:runtime"

ui_init :: proc() {
    for text in ui_texts {
        ui_init_text(text)
    }
    for button in ui_buttons {
        ui_init_button(button)
    }
}

ui_engine_tick :: proc(delta_time: f64) {
    for text in ui_texts {
        ui_render_text(text)
    }
    for button in ui_buttons{
        ui_render_button(button)
    }
}

ui_destroy :: proc() {
    for text in ui_texts {
        sdl.DestroyTexture(text.texture)
    }
    for name in ui_fonts {
        font := ui_fonts[name]
        for size in font.sizes {
            ttf.CloseFont(font.sizes[size])
        }
        clear_map(&font.sizes)
        free(font)
    }
    clear_map(&ui_fonts)
}
