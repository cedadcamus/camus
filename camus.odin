package camus

import "base:runtime"
import "core:log"
import sdl "vendor:sdl3"
import "vector2"
import "core:time"

// show
debug := false

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


// settings
background_color: Color
window_size := []i32 {640, 480}

// generated variables
window: ^sdl.Window
renderer: ^sdl.Renderer

Color :: struct {
	r: u8,
	g: u8,
	b: u8,
	a: u8,
}

run :: proc() {
	old_time : time.Time = time.now()
	current_time: time.Time
	delta_time: f64
	context.logger = log.create_console_logger()

	is_running = true
	if debug {
		log.logf(runtime.Logger_Level.Info, "game started")
	}
	sdl_init := sdl.Init(sdl.INIT_VIDEO)
	if !sdl_init {
		log.panic(sdl.GetError())
	}
	window = sdl.CreateWindow("Camus", window_size[0], window_size[1], sdl.WINDOW_OPENGL)
	if window == nil {
		log.panic(sdl.GetError())
	}
	renderer = sdl.CreateRenderer(window, nil)
	if renderer == nil {
		log.panic(sdl.GetError())
	}

	init()
	
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
		
		sdl.RenderPresent(renderer)
	}

	sdl.DestroyWindow(window)
	if debug {
		log.logf(runtime.Logger_Level.Info, "game ended")
	}
}


draw_line :: proc(color: Color, start: [2]f32, end: [2]f32) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderLine(renderer, start[0], start[1], end[0], end[1])
}


draw_rect :: proc(color: Color, rect: ^sdl.FRect) {
	sdl.SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
	sdl.RenderRect(renderer, rect)
}

draw_circle :: proc(color: Color, center: [2]i32, radius: i32) {
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