package camus

import "base:runtime"
import "core:log"
import sdl "vendor:sdl3"

UIButtonClickCallback :: proc(button: ^UIButton)

UIButton :: struct {
	color:                  sdl.Color,
	highlight_color:        sdl.FColor,
	shadow_color:           sdl.FColor,
	hover_color:            sdl.Color,
	hover_highlight_color:  sdl.FColor,
	hover_shadow_color:     sdl.FColor,
	press_color:            sdl.Color,
	press_hover_color:      sdl.Color,
	padding:                [4]f32,
	border_width:           [4]f32,
	rect:                   sdl.FRect,
	inner_rect:             sdl.FRect,
	texture:                sdl.Texture,
	text:                   UIText,
	hover:                  bool,
	pressed:                bool,
	waiting_for_click:      bool,
	click:                  UIButtonClickCallback,

	// border stuff
	indices:                [6]i32,
	indices_pointer:        [^]i32,
	up_vertices:            [4]sdl.Vertex,
	up_vertices_pointer:    [^]sdl.Vertex,
	left_vertices:          [4]sdl.Vertex,
	left_vertices_pointer:  [^]sdl.Vertex,
	down_vertices:          [4]sdl.Vertex,
	down_vertices_pointer:  [^]sdl.Vertex,
	right_vertices:         [4]sdl.Vertex,
	right_vertices_pointer: [^]sdl.Vertex,

	// events
	mouse_enter:            MouseMotionEventCallback,
	mouse_leave:            MouseMotionEventCallback,
}

ui_create_button :: proc(scene: ^Scene) -> ^UIButton {
	button := new(UIButton)
	append(&scene.ui_buttons, button)
	return button
}

ui_init_button :: proc(button: ^UIButton) {
	ui_init_text(&button.text)

	color_lighter_sample_tof(&button.highlight_color, button.color)
	color_darker_sample_tof(&button.shadow_color, button.color)

	color_lighter_sample(&button.hover_color, button.color, 10)
	color_lighter_sample_f(
		&button.hover_highlight_color,
		button.highlight_color,
		(1.0 / 255.0) * 10.0,
	)
	color_lighter_sample_f(&button.hover_shadow_color, button.shadow_color, (1.0 / 255.0) * 10.0)

	color_darker_sample(&button.press_color, button.color, 20)
	color_darker_sample(&button.press_hover_color, button.color, 10)

	button.rect.x = button.text.rect.x - button.padding[0]
	button.rect.y = button.text.rect.y - button.padding[1]
	button.rect.w = button.text.rect.w + (button.padding[2] * 2)
	button.rect.h = button.text.rect.h + (button.padding[3] * 2)
	button.inner_rect = button.rect
	button.rect.x -= button.border_width[0]
	button.rect.y -= button.border_width[1]
	button.rect.w += button.border_width[2] * 2
	button.rect.h += button.border_width[3] * 2

	ui_button_refresh_border(button)

	button.indices[0] = 0
	button.indices[1] = 1
	button.indices[2] = 2
	button.indices[3] = 2
	button.indices[4] = 3
	button.indices[5] = 0

	button.up_vertices_pointer = raw_data(button.up_vertices[:])
	button.left_vertices_pointer = raw_data(button.left_vertices[:])
	button.down_vertices_pointer = raw_data(button.down_vertices[:])
	button.right_vertices_pointer = raw_data(button.right_vertices[:])
	button.indices_pointer = raw_data(button.indices[:])
}

ui_set_button_pos :: proc(button: ^UIButton, x: f32, y: f32) {
	button.rect.x = x - button.border_width[0]
	button.rect.y = y - button.border_width[1]
	button.inner_rect.x = x
	button.inner_rect.y = y
	button.text.rect.x = x + button.padding[0]
	button.text.rect.y = y + button.padding[1]

	ui_button_refresh_border(button)
}

ui_button_refresh_border :: proc(button: ^UIButton) {
	//up
	if button.pressed {
		if button.hover {
			button.up_vertices[0].color = button.hover_shadow_color
			button.up_vertices[1].color = button.hover_shadow_color
			button.up_vertices[2].color = button.hover_shadow_color
			button.up_vertices[3].color = button.hover_shadow_color
		} else {
			button.up_vertices[0].color = button.shadow_color
			button.up_vertices[1].color = button.shadow_color
			button.up_vertices[2].color = button.shadow_color
			button.up_vertices[3].color = button.shadow_color
		}
	} else {
		if button.hover {
			button.up_vertices[0].color = button.hover_highlight_color
			button.up_vertices[1].color = button.hover_highlight_color
			button.up_vertices[2].color = button.hover_highlight_color
			button.up_vertices[3].color = button.hover_highlight_color
		} else {
			button.up_vertices[0].color = button.highlight_color
			button.up_vertices[1].color = button.highlight_color
			button.up_vertices[2].color = button.highlight_color
			button.up_vertices[3].color = button.highlight_color
		}
	}

	button.up_vertices[0].position[0] = button.rect.x
	button.up_vertices[0].position[1] = button.rect.y

	button.up_vertices[1].position[0] = button.inner_rect.x
	button.up_vertices[1].position[1] = button.inner_rect.y

	button.up_vertices[2].position[0] = button.inner_rect.x + button.inner_rect.w
	button.up_vertices[2].position[1] = button.inner_rect.y

	button.up_vertices[3].position[0] = button.rect.x + button.rect.w
	button.up_vertices[3].position[1] = button.rect.y

	//left
	if button.pressed {
		if button.hover {
			button.left_vertices[0].color = button.hover_shadow_color
			button.left_vertices[1].color = button.hover_shadow_color
			button.left_vertices[2].color = button.hover_shadow_color
			button.left_vertices[3].color = button.hover_shadow_color
		} else {
			button.left_vertices[0].color = button.shadow_color
			button.left_vertices[1].color = button.shadow_color
			button.left_vertices[2].color = button.shadow_color
			button.left_vertices[3].color = button.shadow_color
		}
	} else {
		if button.hover {
			button.left_vertices[0].color = button.hover_highlight_color
			button.left_vertices[1].color = button.hover_highlight_color
			button.left_vertices[2].color = button.hover_highlight_color
			button.left_vertices[3].color = button.hover_highlight_color
		} else {
			button.left_vertices[0].color = button.highlight_color
			button.left_vertices[1].color = button.highlight_color
			button.left_vertices[2].color = button.highlight_color
			button.left_vertices[3].color = button.highlight_color
		}
	}

	button.left_vertices[0].position[0] = button.rect.x
	button.left_vertices[0].position[1] = button.rect.y

	button.left_vertices[1].position[0] = button.rect.x
	button.left_vertices[1].position[1] = button.rect.y + button.rect.h

	button.left_vertices[2].position[0] = button.inner_rect.x
	button.left_vertices[2].position[1] = button.inner_rect.y + button.inner_rect.h

	button.left_vertices[3].position[0] = button.inner_rect.x
	button.left_vertices[3].position[1] = button.inner_rect.y

	//down
	if button.pressed {
		if button.hover {
			button.down_vertices[0].color = button.hover_highlight_color
			button.down_vertices[1].color = button.hover_highlight_color
			button.down_vertices[2].color = button.hover_highlight_color
			button.down_vertices[3].color = button.hover_highlight_color
		} else {
			button.down_vertices[0].color = button.highlight_color
			button.down_vertices[1].color = button.highlight_color
			button.down_vertices[2].color = button.highlight_color
			button.down_vertices[3].color = button.highlight_color
		}
	} else {
		if button.hover {
			button.down_vertices[0].color = button.hover_shadow_color
			button.down_vertices[1].color = button.hover_shadow_color
			button.down_vertices[2].color = button.hover_shadow_color
			button.down_vertices[3].color = button.hover_shadow_color
		} else {
			button.down_vertices[0].color = button.shadow_color
			button.down_vertices[1].color = button.shadow_color
			button.down_vertices[2].color = button.shadow_color
			button.down_vertices[3].color = button.shadow_color
		}
	}

	button.down_vertices[0].position[0] = button.inner_rect.x
	button.down_vertices[0].position[1] = button.inner_rect.y + button.inner_rect.h

	button.down_vertices[1].position[0] = button.rect.x
	button.down_vertices[1].position[1] = button.rect.y + button.rect.h

	button.down_vertices[2].position[0] = button.rect.x + button.rect.w
	button.down_vertices[2].position[1] = button.rect.y + button.rect.h

	button.down_vertices[3].position[0] = button.inner_rect.x + button.inner_rect.w
	button.down_vertices[3].position[1] = button.inner_rect.y + button.inner_rect.h

	//right
	if button.pressed {
		if button.hover {
			button.right_vertices[0].color = button.hover_highlight_color
			button.right_vertices[1].color = button.hover_highlight_color
			button.right_vertices[2].color = button.hover_highlight_color
			button.right_vertices[3].color = button.hover_highlight_color
		} else {
			button.right_vertices[0].color = button.highlight_color
			button.right_vertices[1].color = button.highlight_color
			button.right_vertices[2].color = button.highlight_color
			button.right_vertices[3].color = button.highlight_color
		}
	} else {
		if button.hover {
			button.right_vertices[0].color = button.hover_shadow_color
			button.right_vertices[1].color = button.hover_shadow_color
			button.right_vertices[2].color = button.hover_shadow_color
			button.right_vertices[3].color = button.hover_shadow_color
		} else {
			button.right_vertices[0].color = button.shadow_color
			button.right_vertices[1].color = button.shadow_color
			button.right_vertices[2].color = button.shadow_color
			button.right_vertices[3].color = button.shadow_color
		}
	}

	button.right_vertices[0].position[0] = button.rect.x + button.rect.w
	button.right_vertices[0].position[1] = button.rect.y

	button.right_vertices[1].position[0] = button.inner_rect.x + button.inner_rect.w
	button.right_vertices[1].position[1] = button.inner_rect.y

	button.right_vertices[2].position[0] = button.inner_rect.x + button.inner_rect.w
	button.right_vertices[2].position[1] = button.inner_rect.y + button.inner_rect.h

	button.right_vertices[3].position[0] = button.rect.x + button.rect.w
	button.right_vertices[3].position[1] = button.rect.y + button.rect.h
}

ui_button_render :: proc(button: ^UIButton) {
	// draw borders
	sdl.RenderGeometry(renderer, nil, button.up_vertices_pointer, 4, button.indices_pointer, 6)
	sdl.RenderGeometry(renderer, nil, button.left_vertices_pointer, 4, button.indices_pointer, 6)
	sdl.RenderGeometry(renderer, nil, button.down_vertices_pointer, 4, button.indices_pointer, 6)
	sdl.RenderGeometry(renderer, nil, button.right_vertices_pointer, 4, button.indices_pointer, 6)

	if button.pressed {
		if button.hover {
			draw_fill_rect(button.press_hover_color, &button.inner_rect)
		} else {
			draw_fill_rect(button.press_color, &button.inner_rect)
		}
	} else {
		if button.hover {
			draw_fill_rect(button.hover_color, &button.inner_rect)
		} else {
			draw_fill_rect(button.color, &button.inner_rect)
		}

	}

	sdl.RenderTexture(renderer, button.text.texture, nil, &button.text.rect)
}

ui_button_mouse_enter :: proc(button: ^UIButton) {
	button.hover = true
	button.waiting_for_click = false
	button.pressed = false
	ui_button_refresh_border(button)
}

ui_button_mouse_exit :: proc(button: ^UIButton) {
	button.hover = false
	button.waiting_for_click = false
	button.pressed = false
	ui_button_refresh_border(button)
}

ui_button_mouse_button_event :: proc(button: ^UIButton, event: sdl.MouseButtonEvent) {
	if event.button == 1 {
		button.pressed = event.down
		if event.down {
			button.waiting_for_click = true
		} else {
			if button.waiting_for_click {
				if button.click != nil {
					button.click(button)
				}
			}
			button.waiting_for_click = false
		}
		ui_button_refresh_border(button)
	}
}
