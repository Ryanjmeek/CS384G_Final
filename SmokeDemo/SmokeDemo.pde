import Jama.*;

ParticleSystem ps;
Grid grid;

PImage img;

int N = 80; // dimension of grid
double h; // size of each voxel
double diff = 2.0; // diffusion rate
double visc = 20000.0; // viscosity

long lastTime = 0;
float delta = 0.0;

boolean DRAW_VELOCITY_FIELD = false;

void setup() {
  size(640, 640, P3D);
  
  grid = new Grid();
  
  img = loadImage("smokealpha.png");
  img.resize(50, 0);
  //ps = new ParticleSystem(0, new PVector(width/2, height-60), img);

  h = (double)width / (double)N;
  
}

void draw() {
  background(0);
  //// 3D camera
  ////camera(mouseX, height/2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  delta = (millis() - lastTime)/10.0;
  
  if (DRAW_VELOCITY_FIELD){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        if (grid.getCell(i,j).isASource()){
          stroke(255, 0, 0);
        }
        else {
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
  
  lastTime = millis();
  //println(delta);
}

/* This method draws a smoke image in the 
* box specified at (i,j) in the NxN grid
*/
void drawSmokeAt(PImage image, int i, int j, double density){
  tint(255, (float)density);
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


// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {

  ArrayList<Particle> particles;    // An arraylist for all the particles
  PVector origin;                   // An origin point for where particles are birthed
  PImage img;

  ParticleSystem(int num, PVector v, PImage img_) {
    particles = new ArrayList<Particle>();              // Initialize the arraylist
    origin = v.copy();                                   // Store the origin point
    img = img_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, img));         // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  // Method to add a force vector to all particles currently in the system
  void applyForce(PVector dir) {
    // Enhanced loop!!!
    for (Particle p : particles) {
      p.applyForce(dir);
    }
  }  

  void addParticle() {
    particles.add(new Particle(origin, img));
  }
}



// A simple Particle class, renders the particle as an image

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  PImage img;

  Particle(PVector l, PImage img_) {
    acc = new PVector(0, 0);
    float vx = 0;//randomGaussian()*0.3;
    float vy = randomGaussian()*0.3 - 1.0;
    vel = new PVector(vx, vy);
    loc = l.copy();
    lifespan = 100.0;
    img = img_;
  }

  void run() {
    update();
    render();
  }

  // Method to apply a force vector to the Particle object
  // Note we are ignoring "mass" here
  void applyForce(PVector f) {
    acc.add(f);
  }  

  // Method to update position
  void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= 1.0;
    acc.mult(0); // clear Acceleration
  }

  // Method to display
  void render() {
    imageMode(CENTER);
    tint(255, lifespan);
    image(img, loc.x, loc.y);
    // Drawing a circle instead
    // fill(255,lifespan);
    // noStroke();
    // ellipse(loc.x,loc.y,img.width,img.height);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}