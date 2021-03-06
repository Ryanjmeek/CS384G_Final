Realistic Smoke, Fire, and Explosion Simulations in Processing
======

A real-time fluid solver implemented in Processing for simulating realistic particle effects for smoke, fire, and explosions.

## Background

In order to model fluid behavior in graphics, it is critical to build a solver that simultaneously allows for visually interesting behavior and ensures high stability and computation speed. Jos Stam developed a novel system for simulating fluids in this way, and his design serves as the basis for this project. Here is the Navier-Stokes equation that is the basis for fluid solution systems: 

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/NavierStokes.png" >

Here is the top level psuedocode:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/TopPsuedo.png" width="500" height="180">

### Advect:

The advection step consists of the transfer of fluid properties from position to position at every time step. By using a velocity field such that there is a unique velocity vector at every point in the fluid, properties can transfer throughout the fluid by using the backwards Euler advection strategy, as given by this equation:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/EulerAdvection.png" >

The key principle here is to assume that a "particle" of fluid exists at the center of each cell in the system. We can calculate where that particle came from at each time step using the velocity field to effectively move properties throughout the fluid. Since the prior location of the particle may not have come from the center of a cell, bilinear interpolation of the 4 surrounding cells can be used to assign values to the next cell. 

### BodyForces:

In order to make our simulations look realistic, we add on three forces to each cell at each time step. The first of these forces is gravity, which is simply a constant downward force. The second force that we use is bouyancy. The bouyancy force pushes fluids up based on the density of the fluid in a cell and the temperature of the fluid in a cell.

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/fbouy.PNG" >

The final force used is a vorticity confinement force. This force is used to amplify circular velocity fields in the fluid, making the fluid look more dynamic. The methods that we use for advection does not perfectly model how fluids behave in real life. One side effect is that it tends to make vortices dissipate. The vorticity confinement force is added in to prevent that from happening as much.

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/fconf.PNG" >

### Project:
In the project step we are solving the pressure portion of the Navier-Stokes equation in order to assure our fluid reamins incompressible (constant volume). Here is the equation that needs to be satisfied to ensure incompressible flow:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/Pressure2.png" >

Below is the equation that is used in order to update the velocities in our grid after pressures have been computed:

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/Pressure1.png" >

### BoundaryConditions:
Our Boundary conditions are that we must assure that no fluid flows in our out of the outside box or the solid we created. In order to do this we create a thin layer of "boundary" cells just inside or outside of the boundary. We then need to make sure that the following equations are satisfied for the boundary cells. 

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/VelocityBoundary.png" >

<img src="https://github.com/Ryanjmeek/CS384G_Final/blob/master/images/PressureBoundary.png" >

## Implementation

The solution we created consists of a simulation method that repeats at each timestep. It contains the following steps, in order:

1. advect()
2. bodyForces()
3. project()

Using the equations and strategies given in the Background section of this document, we implemented our fluid solver with these details: 

- A fixed time step of 1
- A non-staggered grid with cell size of 1 (where 1 cell corresponds to a pixel) 
- Advection of temperature, velocity, and density fluid properties for each cell using bilinear interpolation
- Application of the body forces of Buoyancy, Gravity, and Vorticity 
- The Jacobi method with a constant number of iterations (8) to solve the pressure equation 
- Boundary conditions consisting of a thin line of cells along solids and the edge of the simulated area ("boundary cells") -- the pressures of the boundary cells are set to be equal to the pressure just inside it, and the velocities of the boundary cells are set to be the opposite of the velocity just inside it 

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

