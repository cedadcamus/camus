package camus

import "base:runtime"
import "core:log"
import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"
import "core:time"

debug := false
debug_fps := false

is_running := false

// callbacks
InitCallback :: proc()
init: InitCallback = proc() {}
TickCallback :: proc(delta_time: f64)
tick: TickCallback = proc(delta_time: f64) {}
FixedTickCallback :: proc()
fixed_tick: FixedTickCallback = proc() {}
KeyboardEventCallback :: proc(input: sdl.Event)
keyboard_event: KeyboardEventCallback = proc(input: sdl.Event) {}
DestroyCallback :: proc()
destroy: DestroyCallback = proc() {}
ReadyCallback :: proc()
ready: ReadyCallback = proc() {}


// settings
background_color: sdl.Color
debug_color: sdl.Color
window_size := []i32 {640, 480}

// generated variables
window: ^sdl.Window
renderer: ^sdl.Renderer

run :: proc() {
	old_time : time.Time = time.now()
	current_time: time.Time
	delta_time: f64
	last_fps: i32 = 0
	fps: i32 = 0
	fps_accumulator: f64 = 0
	context.logger = log.create_console_logger()
	
	is_running = true
	if debug {
		log.logf(runtime.Logger_Level.Info, "game started")
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
	ui_init()
	ready()
	
	for is_running {
		event:sdl.Event
		for sdl.PollEvent(&event) {
			#partial switch event.type {
				case sdl.EventType.QUIT:
					is_running = false
				case sdl.EventType.KEY_UP, sdl.EventType.KEY_DOWN:
					keyboard_event(event)
			}
			if event.type == sdl.EventType.QUIT {
				is_running = false
			}
		}
		
		sdl.SetRenderDrawColor(renderer, background_color.r, background_color.g, background_color.b, background_color.a)
		sdl.RenderClear(renderer)
		
		current_time = time.now()
		delta_time = time.duration_milliseconds(time.diff(old_time, current_time))
		old_time = current_time
		
		// TODO update when physics
		tick(delta_time)
		ui_engine_tick(delta_time)
		
		if debug_fps {
			fps += 1
			sdl.SetRenderDrawColor(renderer, debug_color.r, debug_color.g, debug_color.b, debug_color.a)
			sdl.RenderDebugTextFormat(renderer, 16, 16, "%i", last_fps)//(renderer, 16, 16, fmt.ctprintf("%f02", 1 / delta_time))
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
	ui_destroy()
	ttf.Quit()
	sdl.DestroyRenderer(renderer)
	sdl.DestroyWindow(window)
	if debug {
		log.logf(runtime.Logger_Level.Info, "game ended")
	}
}


draw_line :: proc(color: sdl.Color, start: [2]f32, end: [2]f32) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderLine(renderer, start[0], start[1], end[0], end[1])
}


draw_rect :: proc(color: sdl.Color, rect: ^sdl.FRect) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderRect(renderer, rect)
}

draw_fill_rect :: proc(color: sdl.Color, rect: ^sdl.FRect) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderFillRect(renderer, rect)
}

draw_circle :: proc(color: sdl.Color, center: [2]i32, radius: i32) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	
	x: i32 = radius - 1
	y: i32 = 0
	dx: i32 = 1
	dy: i32 = 1
	err: i32 = dx - (radius << 1)
	
	for x >= y {
		sdl.RenderPoint(renderer, f32(center[0] + x), f32(center[1] + y))
        sdl.RenderPoint(renderer, f32(center[0] + y), f32(center[1] + x))
        sdl.RenderPoint(renderer, f32(center[0] - y), f32(center[1] + x))
        sdl.RenderPoint(renderer, f32(center[0] - x), f32(center[1] + y))
        sdl.RenderPoint(renderer, f32(center[0] - x), f32(center[1] - y))
        sdl.RenderPoint(renderer, f32(center[0] - y), f32(center[1] - x))
        sdl.RenderPoint(renderer, f32(center[0] + y), f32(center[1] - x))
        sdl.RenderPoint(renderer, f32(center[0] + x), f32(center[1] - y))
		
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