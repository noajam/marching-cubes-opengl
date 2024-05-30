#version 400 core

// Basic texturing

in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

uniform sampler2D Tex;

void main()
{
    FragColor = color*texture(Tex, texCoord);
}