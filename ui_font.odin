package camus

import "base:runtime"
import "core:log"
import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"

ui_fonts: map[string]^UIFont

UIFont :: struct {
	file:  cstring,
	sizes: map[f32]^ttf.Font,
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

ui_get_font :: proc(name: string, size: f32) -> ^ttf.Font {
	font, ok := ui_fonts[name]
	if ok {
		size, ok := font.sizes[size]
		if ok {
			return size
		}
	}
	return nil
}
