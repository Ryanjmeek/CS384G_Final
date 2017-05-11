import Jama.*;

FluidSolver grid;
PrintWriter output;

PImage img;

boolean debug = false;
boolean printVelocities = false;

static final int N = 320; // dimension of grid
float h = 1; // size of each voxel
double diff = 2.0; // diffusion rate
double visc = 20000.0; // viscosity

long lastTime = 0;

float delta = 0.01;

double smokeWeight = 1;
double densityTolerance = 0.001;
double pressureTolerance = 0.001;

final double ambientTemp = 23;
final double epsilon = 1.0e-20;

boolean DRAW_VELOCITY_FIELD = false;

void setup() {
  size(320, 320, P3D);
  
  output = createWriter("debug.txt");
  grid = new FluidSolver();
  
}

void draw() {
  background(0);
  grid.simulate();
  loadPixels();
  for(int y = 0; y < N; y++) {
    for(int x = 0; x < N; x++) {
      int loc = y*N + x;
      FluidCell myCell = grid.getCell(x,y);
      /*if(myCell.density[grid.newVals] > densityTolerance){
        pixels[loc] = color(128,128,128);
      }*/
      //pixels[loc] = color(myCell.density[grid.newVals]*128, 
              //myCell.density[grid.newVals]*128, myCell.density[grid.newVals]*128);
      if (myCell.temperature[grid.newVals] < 150){
        pixels[loc] = color( myCell.density[grid.newVals]*8, 
                             myCell.density[grid.newVals]*8, 
                             myCell.density[grid.newVals]*8);
      }
      else if (myCell.temperature[grid.newVals] < 200) {
        pixels[loc] = color( random( (float) (255-(255*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) - 10 , (float) (255-(255*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) + 10 ) * myCell.density[grid.newVals], 
                            random( (float) (115-(115*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) - 10 , (float) (115-(115*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) + 10 ) * myCell.density[grid.newVals], 
                            10);
      }
      else if (myCell.temperature[grid.newVals] < 1000){
        pixels[loc] = color( random( 255 - 10 , 255 + 10 ) * myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP * myCell.density[grid.newVals], 
                            random( (float) ((10*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) - 10 , (float) ((10*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) + 10 ) * myCell.density[grid.newVals], 
                            0);
      }
      else {
        pixels[loc] = color( random( 255 - 10 , 255 + 10 ) * myCell.density[grid.newVals], 
                            random( (float) ((215*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) - 10 , (float) ((215*(myCell.temperature[grid.newVals]/FluidCell.SMOKE_TEMP))) + 10 ) * myCell.density[grid.newVals], 
                            0);
      }
      
      //pixels[loc] = color(myCell.pressure[grid.newPressure]*555, myCell.vx[grid.newVals]*128+128, myCell.vy[grid.newVals]*128+128);
      //pixels[loc] = color(myCell.pressure[grid.newPressure]*128 + 128, 0, 0);
      //pixels[loc] = color(0, myCell.vx[grid.newVals]*128+128, 0);
      //pixels[loc] = color(0, 0, myCell.vy[grid.newVals]*128+128);
    }
  }
  updatePixels();
    
}