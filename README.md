# CSCI4239/5239 Spring 2023
## Final Project: Marching Cubes for Terrain Generation
### By Noah James

![Marching cubes terrain generation example](images/terrain_demo.png)
---

This program can be run by using `make` with the given `makefile` and then running the resulting `final.exe`. The keybinds for various operations within the program are shown down below.

This program runs the marching cubes algorithm on a set 3D grid of cubes. Per the user's input, the grid resolution can be increased and decreased, and the space that holds the grid can be expanded and reduced. The 3D grid, which can be toggled on and off, is there to help visualize the benefits of increased resolution.

There are 3 different surfaces to view: the first is a polynomial, the second is a sphere, and the third is a terrain generated using Perlin noise. Make sure to increase/decrease the isovalue on all the examples; certain values work better than others. First person mode can also be entered to make up close viewing easier.

---

This project was definitely a challenge for me. For many of the homeworks over the semester, I attempted to incorporate an implementation of the marching cubes algorithm since I was so fascinated by it. However, all of my attempts would render a blank white screen, and so I would pivot to another idea last minute. It was only a couple days before the project review deadline that I managed to successfully render a scene with marching cubes. I honestly can't say what caused it to finally work! It was barebones at the time, but I've since modified the noise volume to output more like a hilly/mountainous terrain. I've also incorporated flat lighting by just using the normal of each triangle face, although I would've liked to use the finite difference method if I had more time. With the time I did have, I implemented a first person mode using the glm library following some tips from LearnOpenGL tutorials. This included passive mouse motion for viewing at various angles. Finally, I added an option to view the surface mesh with gradient colors based on height or with a mountain texture.

In the course of making this program, I learned from my own experiences as well as external sources that geometry shaders are not exactly the best if you're aiming for performance. I decided to use geometry shaders because they mesh well (no pun intended) with marching cubes, and I found them easy to use and debug. For the best performance as well as support for additional functionality, compute shaders would be the better option. Because geometry shaders cannot write back to the CPU, they make it difficult to do things like Gouraud shading, since each cube can only directly access information related to itself. Other ways to calculate surface normals were also made more complicated by the geometry shader, so I focused more of my time on the terrain generation itself, which was my focus from the get-go.

I kept the terrain generation rather simple so as to maintain decent performance, so in order to try different variations on the noise sampling, the geometry shader code must be edited directly. Currently, it uses the Perlin noise 3D texture and uses the values at different y-coordinates in the texture to determine the terrain contour. This means that changing the isovalue will raise or lower the terrain to visually show the y-coordinate of the texture cube being sampled. 

I will say that I think I squeezed every bit of performance that I could out of the geometry shader. I trimmed a lot of redundant function calls that were commonly used in other implmentations. Instead, I saved the function outputs, such as values at the corners of the cube, for later use. I also used as few conditional statements as I could. Once I did all this, I managed to double the framerate, even though it is still not the best. At the highest grid resolution I allow (50^3), the FPS can drop to below 20 depending on what is being rendered.

For this implementation, I referenced Paul Bourke's solution to the marching cubes algorithm. With regards to terrain generation, I referenced Chapter 1 of NVIDIA's GPU Gems 3. LearnOpenGL was also a useful resource for navigating glm and OpenGL 4.


---

Key bindings:
-  gG         Change grid resolution
-  hH         Change space that grid occupies
-  iI         Change the isovalue for computing the isosurface
-  m          Switch between 3 surface generators (Function, Sphere, Noise)
-  v          Toggle axes
-  k          Toggle the grid display
-  f          Toggle wireframe
-  xXyYzZ     Translate the displayed surface
-  cC         Scale the displayed surface
-  n          Switch between centered view and first person mode
-  L          Stop/start light movement
-  ;:         Slow down/speed up light movement
-  o          Switch between gradient and textured views
-  wasd       First person movement
-  spacebar   First person move in positive Y direction
-  left ctrl  First person move in negative Y direction
-  Mouse      Change view angle
-  arrows     Change view angle
-  PgDn/PgUp  Zoom in and out
-  0          Reset view angle
-  ESC        Exit
