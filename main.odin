package main

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:math"
import glm "core:math/linalg/glsl"
import "core:mem"
import gl "vendor:OpenGL"
import "vendor:glfw"

import "renderer"

WINDOW_WIDTH :: 960
WINDOW_HEIGHT :: 720
shader_program: u32

//CAMERA VARS
camera_pos := [?]f32{0.0,0.0,3.0}
camera_target := [?]f32{0.0,0.0,0.0}
camera_front := [?]f32{0.0,0.0,-1.0}
camera_dir := glm.normalize_vec3(camera_pos - camera_target)
up := [?]f32{0.0,1.0,0.0}
last_mouse_x := f64(WINDOW_WIDTH/2)
last_mouse_y := f64(WINDOW_HEIGHT/2)
yaw := -90.0
pitch := 50.0
first_mouse := true
fov:f32 = 45.0
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




	//SHADER STUFF
	/* shader_program = renderer.shader_logic() */
	ok := true
	shader_program, ok = gl.load_shaders_file("res/vert.glsl", "res/frag.glsl")
	if !ok {
		panic("SHADER STUFF BAD")
	}
	uniforms := gl.get_uniforms_from_program(shader_program)
	/* transform := gl.GetUniformLocation(shader_program, "transform")
	u_model := gl.GetUniformLocation(shader_program, "model")
	u_view := gl.GetUniformLocation(shader_program, "view")
	u_projection := gl.GetUniformLocation(shader_program, "projection") */
	gl.UseProgram(shader_program)

	//Render logic
	/* render_exercise() */
	renderer.render_setup()
	gl.Enable(gl.DEPTH_TEST)
	cube_positions := [?][3]f32{
		{ 1.0,  0.0,  0.0}, 
		{ 2.0,  5.0, -15.0}, 
		/* {-1.5, -2.2, -2.5},  
		{-3.8, -2.0, -12.3},  
		{ 2.4, -0.4, -3.5},  
		{-1.7,  3.0, -7.5},  
		{ 1.3, -2.0, -2.5},  
		{ 1.5,  2.0, -2.5}, 
		{ 1.5,  0.2, -1.5}, 
		{-1.3,  1.0, -1.5}   */
	}
	lastFrame := 0.0
	for !glfw.WindowShouldClose(window_handle) {
		time := glfw.GetTime()
		deltaTime := time - lastFrame
		lastFrame = time
		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		//Input
		process_input(window_handle, auto_cast deltaTime)

		//Update Game Logic

		//Render
		gl.UseProgram(shader_program)
		projection := glm.mat4Perspective(glm.radians_f32(fov), 960.0/720.0, 0.1, 100.0) 
		gl.UniformMatrix4fv(uniforms["projection"].location,1,false,&projection[0,0])
		radius := 10.0
		camX := math.sin(time) * radius
		camZ := math.cos(time) * radius
		/* orbit_camera(f32(camX), f32(camZ), u_view) */
		wasd_move_camera(uniforms["view"].location)
		for pos, i in cube_positions {
			t:= glm.mat4Translate(pos) 
			angle := f32(20.0 * i) 
			model := glm.mat4Rotate({1.0,0.3,0.5}, glm.radians_f32(angle)) 
			i :=  t *model 
			gl.UniformMatrix4fv(uniforms["model"].location,1,false,&i[0,0])
			renderer.draw_sprite_3d(uniforms["transforms"].location, 0., {math.sin_f32(f32(time)),0.5,0.5}, 0.1, {0.0,0.0}, {0.5,1.0})
		}

		/* renderer.draw_sprite_3d(transform, 0., {math.sin_f32(f32(time)),0.5,0.5}, 0.1, {0.0,0.0}, {0.5,1.0}) */
		/* renderer.draw_sprite_2d(transform, 0., {math.sin_f32(f32(time)),0.5,0.5}, 0.1, {0.0,0.0}, {0.5,1.0}) */
		//Check events and swap buffers
		glfw.PollEvents()
		glfw.SwapBuffers(window_handle)
	}
}

view_stuff :: proc() {

		//VIEW TRANSFORMATIONS
		/* model := glm.mat4Rotate({1.0,0.0,0.0},f32(time) * glm.radians_f32(50.0)) 
		view := glm.mat4Translate({0.0,0.0,-3.0})
		projection := glm.mat4Perspective(glm.radians_f32(45.0), 960.0/720.0, 0.1, 100.0) */
		/* camera_view := glm.mat4LookAt(camera_pos, camera_dir, up) */
		/* gl.UniformMatrix4fv(u_model,1,false,&model[0,0])
		gl.UniformMatrix4fv(u_view,1,false,&view[0,0]) */

		/* gl.UniformMatrix4fv(u_view,1,false,&camera_view[0,0]) */
		/* gl.UniformMatrix4fv(u_projection,1,false,&projection[0,0]) */

		/* view := glm.mat4Translate({0.0,0.0,-3.0}) */
		/* projection := glm.mat4Perspective(glm.radians_f32(fov), 960.0/720.0, 0.1, 100.0)  */
		/* projection := glm.mat4Ortho3d(0.0,WINDOW_WIDTH,0.0,WINDOW_HEIGHT,0.1,100.0)  */
		/* gl.UniformMatrix4fv(u_view,1,false,&view[0,0]) */
}

orbit_camera :: proc(camX, camZ: f32, u_view: i32) {
	view := glm.mat4LookAt({camX, 0.0, camZ}, {0.0, 0.0, 0.0}, {0.0, 1.0, 0.0})
	gl.UniformMatrix4fv(u_view,1,false,&view[0,0])
}

wasd_move_camera :: proc( u_view: i32) {
	view := glm.mat4LookAt(camera_pos, camera_pos + camera_front, up)
	gl.UniformMatrix4fv(u_view,1,false,&view[0,0])
}

mouse_move_camera :: proc() {
	dir := [?]f32{0.0,0.0,0.0}
	dir.x = auto_cast math.cos(glm.radians(yaw)) * auto_cast math.cos(glm.radians(pitch))
	dir.y = auto_cast math.sin(glm.radians(pitch))
	dir.z = auto_cast math.sin(glm.radians(yaw)) * auto_cast math.cos(glm.radians(pitch))
	camera_front = glm.normalize(dir)
}

resize_callback :: proc "c" (window: glfw.WindowHandle, width: c.int, height: c.int) {
	gl.Viewport(0, 0, width, height)
}

error_callback :: proc "c" (error: c.int, description: cstring) {
	context = runtime.default_context()
	fmt.printfln("ERROR: %v; DESC: %v; VERSIONS: %v", error, description, glfw.GetVersionString())
}

process_input :: proc(window: glfw.WindowHandle, delta_time: f32) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}

	if glfw.GetKey(window, glfw.KEY_R) == glfw.PRESS {
		ok: bool
		shader_program, ok = gl.load_shaders_file("res/vert.glsl", "res/frag.glsl")
		if !ok {
			panic("SHADER STUFF BAD")
		}
	}
	camera_speed := f32(2.5) * delta_time // adjust accordingly
    if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {

        camera_pos += camera_speed * camera_front
	}
    if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {

        camera_pos -= camera_speed * camera_front
	}
    if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {

        camera_pos -= glm.normalize(glm.cross(camera_front, up)) * camera_speed
	}
    if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
        camera_pos += glm.normalize(glm.cross(camera_front, up)) * camera_speed

	}
}

//TODO: This currently snaps on screen on first move (not sure why yet)
mouse_callback :: proc "c" (window: glfw.WindowHandle, x_pos, y_pos: f64) {
	context = runtime.default_context()
    if first_mouse {
        last_mouse_x = x_pos
        last_mouse_y = y_pos
        first_mouse = false
    }
	x_offset := x_pos - last_mouse_x
	y_offset := last_mouse_y - y_pos 

	last_mouse_x = x_pos
	last_mouse_y = y_pos

	sense := 0.5
	x_offset *= sense
	y_offset *= sense

	yaw += x_offset
	pitch += y_offset

	if pitch > 89.0 {
	  pitch =  89.0
	}
	if pitch < -89.0 {
	  pitch = -89.0
	}

	mouse_move_camera()
}

//TODO: This is not very smooth on the zoomout
scroll_callback :: proc "c"(window:glfw.WindowHandle, x_offset, y_offset: f64) {
	fov -= f32(y_offset)
	if fov < 1.0 {
		fov = 1.0
	}

	if fov > 90.0 {
		fov = 90.0
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

	glfw.SetInputMode(window_handle, glfw.CURSOR, glfw.CURSOR_DISABLED)
	/* glfw.SetCursorPosCallback(window_handle, mouse_callback) */
	glfw.SetScrollCallback(window_handle, scroll_callback)

	//Enables alpha transparency
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	return window_handle
}

cleanup :: proc(window_handle: glfw.WindowHandle) {
	glfw.DestroyWindow(window_handle)
	glfw.Terminate()
}
