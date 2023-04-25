# CSCI4239/5239 Spring 2023
## Final Project: Marching Cubes for Terrain Generation
### By Noah James
---

This program can be run by using `make` with the given `makefile` and then running the resulting `final.exe`. The keybinds for various operations within the program are shown down below.

Currently, the program runs the marching cubes algorithm on a set 3D grid of cubes. Per the user's input, the grid resolution can be increased and decreased, and the space that holds the grid can be expanded and reduced. The 3D grid, which can be toggled on and off, is there to help visualize the benefits of increased resolution.

Currently, there is no lighting, but I plan to add that next. I colored from black to red based on height to give the surfaces some visual depth. Make sure to decrease the isovalue on all the examples; certain values work better than others. 

These are the remaining steps to complete the project:
1. Implement lighting
2. Implement a first person mode
3. Design a scalar field to render a rocky/mountainous terrain with the aid of noise
4. Texture the generated surface, either procedurally, naively, or with a cubemap

If these get finished relatively quickly, then here are some additional things I may add (non-exhaustive):
1. Wireframe mesh
2. Import scalar3D data (like MRIs)
3. Additional surfaces/scenes utilizing marching cubes

---

Key bindings:
-  gG         Change grid resolution
-  hH         Change space that grid occupies
-  iI         Change the isovalue for computing the isosurface
-  m          Switch between 3 surface generators (Weird Function, Sphere, Noise)
-  v          Toggle axes
-  k          Toggle the grid display
-  cC         Scale the displayed surface
-  arrows     Change view angle
-  PgDn/PgUp  Zoom in and out
-  0          Reset view angle
-  ESC        Exit
