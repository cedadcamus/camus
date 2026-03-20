package camus

import "base:runtime"
import "core:log"
import "core:time"
import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"

debug := false
debug_fps := false

is_running := false

// callbacks
InitCallback :: proc()
init: InitCallback = proc() {}
ReadyCallback :: proc()
ready: ReadyCallback = proc() {}
TickCallback :: proc(delta_time: f64)
tick: TickCallback = proc(delta_time: f64) {}
FixedTickCallback :: proc()
fixed_tick: FixedTickCallback = proc() {}
DestroyCallback :: proc()
destroy: DestroyCallback = proc() {}

KeyboardEventCallback :: proc(event: sdl.KeyboardEvent)
keyboard_event: KeyboardEventCallback = proc(event: sdl.KeyboardEvent) {}
MouseMotionEventCallback :: proc(event: sdl.MouseMotionEvent)
mouse_motion_event: MouseMotionEventCallback = proc(event: sdl.MouseMotionEvent) {}
MouseButtonEventCallback :: proc(event: sdl.MouseButtonEvent)
mouse_button_event: MouseButtonEventCallback = proc(event: sdl.MouseButtonEvent) {}
WindowSizeEventCallback :: proc(event: sdl.WindowEvent)
window_size_event: WindowSizeEventCallback = proc(event: sdl.WindowEvent) {}


// settings
background_color: sdl.Color
debug_color: sdl.Color

// generated variables
window: ^sdl.Window
renderer: ^sdl.Renderer
current_scene: ^Scene

run :: proc() {
	old_time: time.Time = time.now()
	current_time: time.Time
	delta_time: f64
	last_fps: i32 = 0
	fps: i32 = 0
	fps_accumulator: f64 = 0
	context.logger = log.create_console_logger()

	is_running = true
	if debug {
		log.log(runtime.Logger_Level.Info, "game started")
	}
	sdl_init := sdl.Init(sdl.INIT_VIDEO)
	if !sdl_init {
		is_running = false
		log.log(runtime.Logger_Level.Error, sdl.GetError())
	}
	window = sdl.CreateWindow("Camus", window_size[0], window_size[1], sdl.WINDOW_OPENGL)
	if window == nil {
		is_running = false
		log.log(runtime.Logger_Level.Error, sdl.GetError())
	}
	renderer = sdl.CreateRenderer(window, nil)
	if renderer == nil {
		is_running = false
		log.log(runtime.Logger_Level.Error, sdl.GetError())
	}
	if !ttf.Init() {
		is_running = false
		log.log(runtime.Logger_Level.Error, sdl.GetError())
	}

	debug_color.a = 255
	color_negative_sample(&debug_color, background_color)
	init()
	ui_init(current_scene)
	ready()

	for is_running {
		event: sdl.Event
		for sdl.PollEvent(&event) {
			#partial switch event.type {
			case sdl.EventType.QUIT:
				is_running = false
			case sdl.EventType.KEY_UP, sdl.EventType.KEY_DOWN:
				keyboard_event(event.key)
			case sdl.EventType.MOUSE_MOTION:
				ui_mouse_motion_event(event.motion, current_scene)
				mouse_motion_event(event.motion)
			case sdl.EventType.MOUSE_BUTTON_DOWN, sdl.EventType.MOUSE_BUTTON_UP:
				mouse_button_event(event.button)
				ui_mouse_button_event(event.button, current_scene)
			case sdl.EventType.WINDOW_RESIZED,
			     sdl.EventType.WINDOW_MAXIMIZED,
			     sdl.EventType.WINDOW_RESTORED:
				window_size_changed()
				window_size_event(event.window)
			}
		}

		sdl.SetRenderDrawColor(
			renderer,
			background_color.r,
			background_color.g,
			background_color.b,
			background_color.a,
		)
		sdl.RenderClear(renderer)

		current_time = time.now()
		delta_time = time.duration_milliseconds(time.diff(old_time, current_time))
		old_time = current_time

		// TODO update when physics
		tick(delta_time)
		ui_engine_tick(delta_time, current_scene)

		if debug_fps {
			fps += 1
			sdl.SetRenderDrawColor(
				renderer,
				debug_color.r,
				debug_color.g,
				debug_color.b,
				debug_color.a,
			)
			sdl.RenderDebugTextFormat(renderer, 16, 16, "%i", last_fps)
			fps_accumulator += delta_time
			if fps_accumulator > 1000 {
				fps_accumulator -= 1000
				last_fps = fps
				fps = 0
			}
		}

		sdl.RenderPresent(renderer)
	}

	destroy()
	ui_destroy(current_scene)
	ttf.Quit()
	sdl.DestroyRenderer(renderer)
	sdl.DestroyWindow(window)
	if debug {
		log.logf(runtime.Logger_Level.Info, "game ended")
	}
}


set_color :: proc(color: sdl.Color) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
}

draw_line :: proc(start_x: f32, start_y: f32, end_x: f32, end_y: f32) {
	sdl.RenderLine(renderer, start_x, start_y, end_x, end_y)
}

draw_line_color :: proc(color: sdl.Color, start_x: f32, start_y: f32, end_x: f32, end_y: f32) {
	set_color(color)
	draw_line(start_x, start_y, end_x, end_y)
}


draw_rect :: proc(color: sdl.Color, rect: ^sdl.FRect) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderRect(renderer, rect)
}

draw_fill_rect :: proc(color: sdl.Color, rect: ^sdl.FRect) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderFillRect(renderer, rect)
}

draw_circle :: proc(center_x: i32, center_y: i32, radius: i32) {
	x: i32 = radius - 1
	y: i32 = 0
	dx: i32 = 1
	dy: i32 = 1
	err: i32 = dx - (radius << 1)

	for x >= y {
		sdl.RenderPoint(renderer, f32(center_x + x), f32(center_y + y))
		sdl.RenderPoint(renderer, f32(center_x + y), f32(center_y + x))
		sdl.RenderPoint(renderer, f32(center_x - y), f32(center_y + x))
		sdl.RenderPoint(renderer, f32(center_x - x), f32(center_y + y))
		sdl.RenderPoint(renderer, f32(center_x - x), f32(center_y - y))
		sdl.RenderPoint(renderer, f32(center_x - y), f32(center_y - x))
		sdl.RenderPoint(renderer, f32(center_x + y), f32(center_y - x))
		sdl.RenderPoint(renderer, f32(center_x + x), f32(center_y - y))

		if (err <= 0) {
			y += 1
			err += dy
			dy += 2
		}

		if (err > 0) {
			x -= 1
			dx += 2
			err += dx - (radius << 1)
		}
	}
}

draw_circle_color :: proc(color: sdl.Color, center_x: i32, center_y: i32, radius: i32) {
	set_color(color)
	draw_circle(center_x, center_y, radius)
}
