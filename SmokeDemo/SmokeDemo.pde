import Jama.*;

Grid grid;
PrintWriter output;

PImage img;

int N = 120; // dimension of grid
double h; // size of each voxel
double diff = 2.0; // diffusion rate
double visc = 20000.0; // viscosity

long lastTime = 0;
float delta = 0.0;

double smokeWeight = 1;
double densityTolerance = 0.001;
double pressureTolerance = 0.001;

final double ambientTemp = 23;
final double alpha = .0005;
final double beta = 500;
final double epsilon = 1.0e-20;
final double zeta = .25;

boolean DRAW_VELOCITY_FIELD = false;

void setup() {
  size(640, 640, P3D);
  
  grid = new Grid();
  
  img = loadImage("smokealpha.png");
  img.resize(50, 0);
  //ps = new ParticleSystem(0, new PVector(width/2, height-60), img);
  //output = createWriter("debug.txt");

  h = (double)width / (double)N;
  
}

void draw() {
  //// 3D camera
  ////camera(mouseX, height/2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  //delta = (millis() - lastTime)/10.0;
  delta = 0.5;
  if(delta < epsilon) return;
  background(0);
  
  if (DRAW_VELOCITY_FIELD){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        if (grid.getCell(i,j).isASource()){
          stroke(255, 0, 0);
        }
        else {
          //stroke((int)grid.getCell(i,j).pressure, 0, 0);
          stroke(255, 255, 255);

        }
        drawVector((new PVector(grid.getCell(i,j).velocity.x, grid.getCell(i,j).velocity.y)).normalize(), new PVector((float)((i+0.5)*h),(float)((j+0.5)*h)), 0.1);
      }
    }
  }

  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      drawSmokeAt(img, i, j, 255*grid.getCell(i,j).density);
    }
  }
  
  grid.advect();
  grid.applyBodyForces();
  grid.project();
  //output.flush();
  
  lastTime = millis();
  //println(delta);
}

/* This method draws a smoke image in the 
* box specified at (i,j) in the NxN grid
*/
void drawSmokeAt(PImage image, int i, int j, double density){
  tint(255, (float)density);
  imageMode(CENTER);
  image(image, (float)h*i, (float)h*j);
}

// Renders a vector object 'v' as an arrow and a position 'loc'
void drawVector(PVector v, PVector loc, float scayl) {
  pushMatrix();
  float arrowsize = 4;
  // Translate to position to render vector
  translate(loc.x, loc.y);
  //stroke(255);
  // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
  rotate(v.heading());
  // Calculate length of vector & scale it to be bigger or smaller if necessary
  float len = v.mag()*scayl;
  // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
  line(0, 0, len, 0);
  line(len, 0, len-arrowsize, +arrowsize/2);
  line(len, 0, len-arrowsize, -arrowsize/2);
  popMatrix();
}