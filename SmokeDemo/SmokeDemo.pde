import Jama.*;

FluidSolver grid;
PrintWriter output;

PImage img;

boolean debug = false;
boolean printVelocities = false;

int N = 640; // dimension of grid
double h; // size of each voxel
double diff = 2.0; // diffusion rate
double visc = 20000.0; // viscosity

long lastTime = 0;

float delta = 0.01;

double smokeWeight = 1;
double densityTolerance = 0.001;
double pressureTolerance = 0.001;

final double ambientTemp = 23;
final double alpha = 0.05;
final double beta = 50;
final double epsilon = 1.0e-20;

boolean DRAW_VELOCITY_FIELD = false;

void setup() {
  size(640, 640, P3D);
  
  output = createWriter("debug.txt");
  grid = new FluidSolver();
  
  img = loadImage("smokealpha.png");
  img.resize(50, 0);
  //ps = new ParticleSystem(0, new PVector(width/2, height-60), img);

  h = (double)width / (double)N;
  output.println("This is h: " + h);
  
}

void draw() {
  background(0);
  grid.simulate();
  loadPixels();
  for(int y = 0; y < N; y++) {
    for(int x = 0; x < N; x++) {
      int loc = y*N + x;
      FluidCell myCell = grid.getCell(x,y);
      pixels[loc] = color(myCell.pressure[grid.newPressure]*555, myCell.vx[grid.newVals]*128+128, myCell.vy[grid.newVals]*128+128);
      //pixels[loc] = color(myCell.pressure[grid.newPressure]*555, 0, 0);
    }
  }
  updatePixels();
    
}