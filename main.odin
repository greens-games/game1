package main

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:math"
import "core:mem"
import gl "vendor:OpenGL"
import "vendor:glfw"

import "renderer"

WINDOW_WIDTH :: 960
WINDOW_HEIGHT :: 720
shader_program: u32

mat4 :: matrix[4, 4]f32
i4 := mat4{
	1,0,0,0,
	0,1,0,0,
	0,0,1,0,
	0,0,0,1,
}
main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}


	window_handle := setup()

	shader_program = renderer.shader_logic()

	uniform := gl.GetUniformLocation(shader_program, "t")
	if uniform == -1 {
		fmt.println("","t")
		panic("could not find uniform")
	}

	gl.UseProgram(shader_program)

	//Render logic
	/* render_exercise() */
	renderer.render_setup()

	for !glfw.WindowShouldClose(window_handle) {
		time := glfw.GetTime()
		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		//Input
		process_input(window_handle)

		//Update Game Logic

		//Render
		gl.UseProgram(shader_program)
		renderer.draw_sprite(uniform, 0., {math.sin_f32(f32(time)),0.5,0.5}, 0.1, {0.0,0.0}, {0.5,1.0})
		//Check events and swap buffers
		glfw.PollEvents()
		glfw.SwapBuffers(window_handle)
	}
}

resize_callback :: proc "c" (window: glfw.WindowHandle, width: c.int, height: c.int) {
	gl.Viewport(0, 0, width, height)
}

error_callback :: proc "c" (error: c.int, description: cstring) {
	context = runtime.default_context()
	fmt.printfln("ERROR: %v; DESC: %v; VERSIONS: %v", error, description, glfw.GetVersionString())
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}

	if glfw.GetKey(window, glfw.KEY_R) == glfw.PRESS {
		shader_program = renderer.shader_logic()
	}
}


setup :: proc() -> glfw.WindowHandle {

	//SetUp stuff
	if glfw.Init() != true {
		fmt.println("Failed to init")
	}
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.SetErrorCallback(error_callback)
	window_handle := glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Game 1", nil, nil)
	if window_handle == nil {
		fmt.println("Failed to create window")
	}
	glfw.MakeContextCurrent(window_handle)
	glfw.SwapInterval(0)
	gl.load_up_to(4, 6, glfw.gl_set_proc_address) //required for proc address stuff
	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
	glfw.SetFramebufferSizeCallback(window_handle, resize_callback)

	//Enables alpha transparency
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	return window_handle
}

cleanup :: proc(window_handle: glfw.WindowHandle) {
	glfw.DestroyWindow(window_handle)
	glfw.Terminate()
}
