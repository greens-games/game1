#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 t;

void main()
{
	gl_Position =  t * vec4(aPos, 1.0);
	TexCoord = aTexCoord;
}
