package camus

import "base:runtime"
import "core:log"
import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"

ui_init :: proc(scene: ^Scene) {
	for text in scene.ui_texts {
		ui_init_text(text)
	}
	for button in scene.ui_buttons {
		ui_init_button(button)
	}
}

ui_engine_tick :: proc(delta_time: f64, scene: ^Scene) {
	for text in scene.ui_texts {
		ui_render_text(text)
	}
	for button in scene.ui_buttons {
		ui_button_render(button)
	}
}

ui_destroy :: proc(scene: ^Scene) {
	for text in scene.ui_texts {
		sdl.DestroyTexture(text.texture)
	}
}

internal_ui_destroy :: proc() {
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


ui_mouse_motion_event :: proc(event: sdl.MouseMotionEvent, scene: ^Scene) {
	for text in scene.ui_texts {
	}
	for button in scene.ui_buttons {
		mouse_pos: sdl.FPoint = {event.x, event.y}
		if !button.hover && sdl.PointInRectFloat(mouse_pos, button.rect) {
			ui_button_mouse_enter(button)
		} else if button.hover && !sdl.PointInRectFloat(mouse_pos, button.rect) {
			ui_button_mouse_exit(button)
		}
	}
}

ui_mouse_button_event :: proc(event: sdl.MouseButtonEvent, scene: ^Scene) {
	for text in scene.ui_texts {
	}
	for button in scene.ui_buttons {
		mouse_pos: sdl.FPoint = {event.x, event.y}
		if button.hover {
			ui_button_mouse_button_event(button, event)
		}
	}
}
