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
    color: sdl.Color,
    highlight_color: sdl.Color,
    shadow_color: sdl.Color,
    padding: [4]f32,
    rect: sdl.FRect,
    text: UIText,
}

UIFont :: struct {
    file: cstring,
	sizes: map[f32]^ttf.Font,
}

ui_fonts: map[string]^UIFont
ui_texts: [dynamic]^UIText
ui_buttons: [dynamic] ^UIButton

ui_init :: proc() {
    for text in ui_texts {
        ui_init_text(text)
    }
    for button in ui_buttons {
        ui_init_button(button)
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

ui_create_text :: proc() -> ^UIText {
    text := new(UIText)
    append(&ui_texts, text)
    return text
}

ui_create_button :: proc() -> ^UIButton {
    button := new(UIButton)
    append(&ui_buttons, button)
    return button
}

ui_engine_tick :: proc(delta_time: f64) {
    for text in ui_texts {
        sdl.RenderTexture(renderer, text.texture, nil, &text.rect)
    }
    for button in ui_buttons{
        draw_fill_rect(button.color, &button.rect)
        sdl.RenderTexture(renderer, button.text.texture, nil, &button.text.rect)
    }
}

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

ui_set_text_pos :: proc(text: ^UIText, x: f32, y: f32) {
    text.rect.x = x
    text.rect.y = y
}

ui_init_button :: proc(button: ^UIButton) {
    ui_init_text(&button.text)
    color_lighter_sample(&button.highlight_color, button.color)
    color_darker_sample(&button.shadow_color, button.color)
    button.rect.x = button.text.rect.x - button.padding[0]
    button.rect.y = button.text.rect.y - button.padding[1]
    button.rect.w = button.text.rect.w + (button.padding[2] * 2)
    button.rect.h = button.text.rect.h + (button.padding[3] * 2)
}

ui_set_button_pos :: proc(button: ^UIButton, x: f32, y: f32) {
    button.rect.x = x
    button.rect.y = y
    button.text.rect.x = x + button.padding[0]
    button.text.rect.y = y + button.padding[1]
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