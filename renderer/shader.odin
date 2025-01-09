package renderer 

import "core:fmt"
import "core:os"
import "core:strings"
import gl "vendor:OpenGL"
import "vendor:glfw"

load_shader :: proc(name: string) -> cstring {
	file_name := strings.concatenate({"res/", name})
	defer delete(file_name)
	data, ok := os.read_entire_file_from_filename(file_name)
	defer delete(data)

	if !ok {
		fmt.println("failed to load file")
		return ""
	}
	return strings.clone_to_cstring(string(data))
}

shader_logic :: proc() -> u32 {

	//SHADER STUFF
	v_shader := gl.CreateShader(gl.VERTEX_SHADER)
	v_shader_source := load_shader("vert.glsl")
	defer delete(v_shader_source)
	gl.ShaderSource(v_shader, 1, &v_shader_source, nil)
	gl.CompileShader(v_shader)
	success: i32
	infoLog: u8
	gl.GetShaderiv(v_shader, gl.COMPILE_STATUS, &success)
	if success == 0 {
		gl.GetShaderInfoLog(v_shader, 512, nil, &infoLog)
		fmt.println(infoLog)
	}

	f_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
	f_shader_source := load_shader("frag.glsl")
	defer delete(f_shader_source)
	gl.ShaderSource(f_shader, 1, &f_shader_source, nil)
	gl.CompileShader(f_shader)

	gl.GetShaderiv(f_shader, gl.COMPILE_STATUS, &success)
	if success == 0 {
		gl.GetShaderInfoLog(f_shader, 512, nil, &infoLog)
		fmt.println(infoLog)
	}
	shader_program := gl.CreateProgram()
	gl.AttachShader(shader_program, v_shader)
	gl.AttachShader(shader_program, f_shader)
	gl.LinkProgram(shader_program)
	gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success)
	if success == 0 {
		gl.GetProgramInfoLog(shader_program, 512, nil, &infoLog)
		fmt.println("SHADER ERROR")
	}
	gl.DeleteShader(v_shader)
	gl.DeleteShader(f_shader)
	return shader_program
}
