FluidSolver grid;
PrintWriter output;

PImage img;

boolean debug = false;
boolean printVelocities = false;

static final int N = 320; // dimension of grid
float h = 1; // size of each voxel

float delta = 1.0;

double smokeWeight = 1;
double densityTolerance = 0.001;
double pressureTolerance = 0.001;

final double ambientTemp = 23;
final double epsilon = 1.0e-20;

void setup() {
  size(320, 300, P3D);
  
  output = createWriter("debug.txt");
  grid = new FluidSolver();
  
}

void draw() {
  background(0);
  grid.simulate();
  loadPixels();
  for(int y = 0; y < N-20; y++) {
    for(int x = 0; x < N; x++) {
      int loc = y*N + x;
      FluidCell myCell = grid.getCell(x,y);
      //pixels[loc] = color(myCell.density[grid.newVals]*128, 
              //myCell.density[grid.newVals]*128, myCell.density[grid.newVals]*128);
      
      pixels[loc] = color(myCell.density[grid.newVals]*64, 
              myCell.density[grid.newVals]*64, myCell.density[grid.newVals]*64);
      //pixels[loc] = color(myCell.pressure[grid.newPressure]*555, myCell.velocity[grid.newVals].x*128+128, myCell.velocity[grid.newVals].y*128+128);
      //pixels[loc] = color(myCell.pressure[grid.newPressure]*128 + 128, 0, 0);
      //pixels[loc] = color(0, myCell.vx[grid.newVals]*128+128, 0);
      //pixels[loc] = color(0, 0, myCell.vy[grid.newVals]*128+128);
    }
  }
  updatePixels();
    
}