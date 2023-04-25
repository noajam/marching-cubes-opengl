#version 330 core

//  Vertex attributes (input)
in vec4 Vertex;

void main()
{
   gl_Position = Vertex;
}
