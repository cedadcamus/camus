package camus

import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"
import "core:log"
import "base:runtime"


UIText :: struct {
    color: sdl.Color,
    texture: ^sdl.Texture,
    rect: sdl.FRect,
    font: ^ttf.Font,
    font_name: string,
    font_size: f32,
}

UIFont :: struct {
    file: cstring,
	sizes: map[f32]^ttf.Font,
}

ui_fonts : map[string]^UIFont


ui_init :: proc() {
    ui_fonts = make(map[string]^UIFont)
}

ui_add_font :: proc(name: string, file: cstring, size: f32) {
    font, ok := ui_fonts[name]
    if ok {
        if size in font.sizes {
            return
        }
    }
    ttf_font := ttf.OpenFont(file, size)
    if ttf_font == nil {
        is_running = false
        log.log(runtime.Logger_Level.Error, sdl.GetError())
    } else {
        if !ok {
            font = new(UIFont)
            font.file = file
            font.sizes = make(map[f32]^ttf.Font)
            ui_fonts[name] = font
        }
        font.sizes[size] = ttf_font
    }
}

ui_get_font :: proc(name: string, size: f32) -> ^ttf.Font{
    font, ok := ui_fonts[name]
    if ok {
        size, ok := font.sizes[size]
        if ok {
            return size
        }
    }
    return nil
}

ui_init_text :: proc(ui_text: ^UIText, r: u8, g: u8, b: u8, a: u8, text: cstring, font: string, font_size: f32) {
    ui_text.color.r = r
    ui_text.color.g = g
    ui_text.color.b = b
    ui_text.color.a = a
    ui_text.font_name = font
    ui_text.font_size = font_size
    ui_font := ui_fonts[font]
    ttf_font, ok := ui_font.sizes[font_size]
    if !ok {
        ui_add_font(font, ui_font.file, font_size)
    }
    ui_text.font = ui_font.sizes[font_size]
    surface := ttf.RenderText_Blended(ui_text.font, text, 0, ui_text.color)
    ui_text.texture = sdl.CreateTextureFromSurface(renderer, surface)
    sdl.DestroySurface(surface)
    sdl.GetTextureSize(ui_text.texture, &ui_text.rect.w, &ui_text.rect.h)
}

ui_destroy :: proc() {
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