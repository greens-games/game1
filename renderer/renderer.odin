package renderer 

import "core:fmt"
import "core:time"
import gl "vendor:OpenGL"
import "vendor:glfw"
import glm "core:math/linalg/glsl"
import "vendor:stb/image"

Vertex :: [4]f32
Texutre_Coord :: [2]f32

Texture :: struct {
	data: [^]byte,
	width : i32,
	height: i32,
	channels: i32,
}

Sprite :: struct {
	//Define texture coords
	t_x: f32,
	t_y: f32,
}

//TODO: This is all bad practice MOVE WHEN DONE
indices := [?]u32{0, 1, 3, 1, 2, 3}
texture: u32
VBO: [^]u32 = raw_data([]u32{0,0})
textures: [dynamic]Texture

render_setup :: proc() {

	EBO: u32
	gl.GenBuffers(1, &EBO)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(u32), &indices, gl.STATIC_DRAW)

	VAO: u32
	gl.GenVertexArrays(1, &VAO)
	gl.BindVertexArray(VAO)
	gl.GenBuffers(2, VBO)

	gl.GenTextures(1, &texture)
	//Texture stuff
	gl.BindTexture(gl.TEXTURE_2D, texture)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	image.set_flip_vertically_on_load(1)
	/* data := image.load("res/player_unit.png", &height, &width, &channels, 0) */
	texture: Texture 
	texture.data = image.load("res/jam_char-Sheet.png", &texture.width, &texture.height, &texture.channels, 0)
	append(&textures, texture)

	//After generating and binding texture stuff we can free image
}

draw_sprite :: proc(uniform: i32, rotation: f32, pos: [3]f32, scale: f32, t_pos: [2]f32, t_size: [2]f32) {
	vertices := [?]f32 {
	//Vert1
	1.0,1.0,0.0,
	//Tex1
	t_pos.x + t_size.x,t_pos.y + t_size.y,
	//Vert2
	1.0,-1.0,0.0,
	//Tex2
	t_pos.x + t_size.x,t_pos.y,
	//Vert3
	-1.0,-1.0,0.0,
	//Tex3
	t_pos.x,t_pos.y,
	//Vert4
	-1.0,1.0,0.0,
	//Tex4
	t_pos.x ,t_pos.y + t_size.y,
	}

	i := glm.identity(glm.mat4)
	t := glm.mat4Translate(pos)
	s := glm.mat4Scale({scale,scale,scale})
	r := glm.mat4Rotate({0.0,0.0,1.0}, rotation)
	i = i * t * r * s
	gl.UniformMatrix4fv(uniform,1,false,&i[0,0])

	gl.ActiveTexture(gl.TEXTURE0)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, textures[0].width, textures[0].height, 0, gl.RGBA, gl.UNSIGNED_BYTE, textures[0].data)
	/* gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data) */
	gl.GenerateMipmap(gl.TEXTURE_2D)

	gl.BindBuffer(gl.ARRAY_BUFFER, VBO[0])
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)
	
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 5 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, false, 5 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)
	gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, &indices)
}

/*
	NOTE: 
	WHen dealing with Multiple VAOs and VBOs we do the following:
		Generate x number of VAO/VBO
			VAO: [^]u32 = raw_data([]u32{0.0, 0.0})
			gl.GenVertexArrays(2, VAO)
			VBO: [^]u32 = raw_data([]u32{0.0, 0.0})
			gl.GenBuffers(2, VBO)
		For each buff we are dealing with we need to bind to the VAO > Bind the VBO > Set the data and attribs
		Repeat for each one
*/

