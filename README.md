Realistic Smoke, Fire, and Explosion Simulations in Processing
======

A real-time fluid solver implemented in Processing for simulating realistic particle effects for smoke, fire, and explosions.

## Background

In order to model fluid behavior in graphics, it is critical to build a solver that simultaneously allows for visually interesting behavior and ensures high stability and computation speed. Jos Stam developed a novel system for simulating fluids in this way, and his design serves as the basis for this project. 

Top Level Psuedocode:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/TopPsuedo.png" width="500" height="200">

### Advect:

### BodyForces:

### Project:

### BoundaryConditions:


## Implementation

The solution we created follows the method of:

1. advect()
2. bodyForces()
3. project()

We used a fixed time step of 1, a grid with cell size of 1 (where 1 cell corresponds to a pixel). Our grid is non-staggered. We use bilinear interpolation for our advection. We advect temperature, velocity, and density for each cell. We use body forces of Buoyancy, Gravity, and Vorticity. Our boundary conditions include a thin line of cells along solids and the edge of the simulated area that we call boundary cells. We set the pressure of the boundary cells to be equal to the pressure just inside it. We set the velocity of the boundary cells to be the opposite of the velocity just inside it. 

## Artifacts Produced

Using our general fluid solver, we developed a number of visually interesting artifacts, as seen below. We created 3 primary demos: smoke, fire, and explosions. Additionally, we developed boundary conditions so that our smoke could interact with simple solids in the environment. This is seen in our Solid Demo. We also created an interactive fluid simulation in which the user can click around in the screen to create miniature explosions which propagate outwards, as seen in the Interactive Fluid Demo.

### Smoke Demo:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/SmokeDemo.gif" width="320" height="300">

### Fire Demo:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/FireDemo.gif" width="320" height="300">

### Explosion Demo:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/SourceExplosionDemo.gif" width="320" height="300">

### Solid Demo:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/SolidDemo.gif" width="320" height="300">

### Interactive Fluid Demo:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/SmokeFluidDemo.gif" width="320" height="300">

## References
[1] 2007 Siggraph Fluids Notes
https://www.cs.ubc.ca/~rbridson/fluidsimulation/fluids_notes.pdf

[2] GPU Gems Chapter 38. Fast Fluid Dynamics Simulation on the GPU
https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch38.html

[3] Example Fluid Solver
https://29a.ch/sandbox/2012/fluidcanvas/
https://29a.ch/sandbox/2012/fluidcanvas/fluid.js

[4] Example Fluid Solver with Explanations
http://jamie-wong.com/2016/08/05/webgl-fluid-simulation/

[5] Jos Stam Stable Fluids
http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/ns.pdf

[6] Explosions Paper
http://silviojemma.com/public/papers/fire/animating%20suspended%20particle%20explosion.pdf

