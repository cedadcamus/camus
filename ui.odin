package camus

import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"
import "core:log"
import "base:runtime"

UIText :: struct {
    text: cstring,
    color: sdl.Color,
    texture: ^sdl.Texture,
    rect: sdl.FRect,
    font: ^ttf.Font,
    font_name: string,
    font_size: f32,
}

UIButton :: struct {
    text: UIText
}

UIFont :: struct {
    file: cstring,
	sizes: map[f32]^ttf.Font,
}

ui_fonts: map[string]^UIFont
ui_texts: [dynamic]^UIText


ui_init :: proc() {
    for ui_text in ui_texts {
        ui_init_text(ui_text)
    }
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

ui_create_text :: proc() -> ^UIText{
    ui_text := new(UIText)
    append(&ui_texts, ui_text)
    return ui_text
}

ui_engine_tick :: proc(delta_time: f64) {
    for text in ui_texts {
        sdl.RenderTexture(renderer, text.texture, nil, &text.rect)
    }
}

/*
Solid

    transparency by colorkey (0 pixel)
    very fast but low quality
    8-bit palettized RGB surface
    Functions
        TTF_RenderText_Solid(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color): PSDL_Surface
        TTF_RenderText_Solid_Wrapped(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color; wrapLength: cint): PSDL_Surface
        TTF_RenderGlyph_Solid(font: PTTF_Font; ch: cuint32; fg: TSDL_Color): PSDL_Surface

Shaded

    antialiasing
    slower than solid rendering, but high quality
    8-bit palettized RGB surface
    Functions
        TTF_RenderText_Shaded(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color; bg: TSDL_Color): PSDL_Surface
        TTF_RenderText_Shaded_Wrapped(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color; bg: TSDL_Color; wrap_width: cint): PSDL_Surface
        TTF_RenderGlyph_Shaded(font: PTTF_Font; ch: cuint32; fg: TSDL_Color; bg: TSDL_Color): PSDL_Surface

Blended

    transparency (alpha channel)
    antialiasing
    slow but very high quality
    32-bit unpalettized (RGBA) surface
    Functions
        TTF_RenderText_Blended(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color): PSDL_Surface
        TTF_RenderText_Blended_Wrapped(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color; wrap_width: cint): PSDL_Surface
        TTF_RenderGlyph_Blended(font: PTTF_Font; ch: cuint32; fg: TSDL_Color): PSDL_Surface

LCD

    sub-pixel rendering
    slow but very high quality
    32-bit unpalettized (RGBA) surface
    Functions
        TTF_RenderText_LCD(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color; bg: TSDL_Color): PSDL_Surface
        TTF_RenderText_LCD_Wrapped(font: PTTF_Font; text: PAnsiChar; length: csize_t; fg: TSDL_Color; bg: TSDL_Color; wrap_width: cint): PSDL_Surface
        TTF_RenderGlyph_LCD(font: PTTF_Font; ch: cuint32; fg: TSDL_Color; bg: TSDL_Color): PSDL_Surface


*/
ui_init_text :: proc(text: ^UIText) {
    ui_font := ui_fonts[text.font_name]
    ttf_font, ok := ui_font.sizes[text.font_size]
    if !ok {
        ui_add_font(text.font_name, ui_font.file, text.font_size)
    }
    text.font = ui_font.sizes[text.font_size]
    surface := ttf.RenderText_Blended(text.font, text.text, 0, text.color)
    text.texture = sdl.CreateTextureFromSurface(renderer, surface)
    sdl.DestroySurface(surface)
    sdl.GetTextureSize(text.texture, &text.rect.w, &text.rect.h)
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