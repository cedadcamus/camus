package camus

import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"

UIText :: struct {
	text:      cstring,
	color:     sdl.Color,
	texture:   ^sdl.Texture,
	rect:      sdl.FRect,
	font:      ^ttf.Font,
	font_name: string,
	font_size: f32,
	visible:   bool,
}

ui_create_text :: proc(scene: ^Scene) -> ^UIText {
	text := new(UIText)
	append(&scene.ui_texts, text)
	return text
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

ui_set_text_color :: proc(text: ^UIText, r: u8, g: u8, b: u8, a: u8) {
	text.color.r = r
	text.color.g = g
	text.color.b = b
	text.color.a = a
	sdl.DestroyTexture(text.texture)
	surface := ttf.RenderText_Blended(text.font, text.text, 0, text.color)
	text.texture = sdl.CreateTextureFromSurface(renderer, surface)
	sdl.DestroySurface(surface)
}

ui_set_text_pos :: proc(text: ^UIText, x: f32, y: f32) {
	text.rect.x = x
	text.rect.y = y
}

ui_render_text :: proc(text: ^UIText) {
	sdl.RenderTexture(renderer, text.texture, nil, &text.rect)
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
