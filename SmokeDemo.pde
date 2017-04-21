ParticleSystem ps;

PImage img;

int N = 100; // dimension of grid
double diff = 2.0; // diffusion rate
int size = (N+2)*(N+2);
double h; // size of each voxel
double u[] = new double[size];
double v[] = new double[size];
double u_prev[] = new double[size];
double v_prev[] = new double[size];
double dens[] = new double[size];
double dens_prev[] = new double[size];

long lastTime = 0;
long delta = 0;

int IX(int i, int j){
  return ((i)+(N+2)*j);
}

/* This method draws a smoke image in the 
* box specified at (i,j) in the NxN grid
*/
void drawSmokeAt(PImage image, int i, int j){
  image(image, (float)h*i, (float)h*j);
}

void add_source(int n, double[] x, double[] s, double dt){
  for (int i = 0; i < size; i++){
    if (i == 50){ x[i] += dt*1.0; } // temporarily insert source @50, always
  }
}

void diffuse(int n, int b, double[] x, double[] x0, double diff, double dt){
  double a = dt*diff*n*n;
  
  for (int k = 0; k < 20; k++){
    for (int i = 1; i <= n; i++){
      for (int j = 1; j <= n; j++){
        x[IX(i,j)] = (x0[IX(i,j)] + a*(x[IX(i-1,j)] + x[IX(i+1,j)] + x[IX(i,j-1)] + x[IX(i,j+1)]))/(1+4*a);
      }
    }
    //set_bnd(n, b, x); // TODO
  }
}

void dens_step(int n, double[] x, double[] x0, double[] u, double[] v, double diff, double dt){
  add_source(n, x, x0, dt);
  diffuse(n, 0, x0, x, diff, dt);
  //advect(n, 0, x, x0, u, v, dt);
}

void setup() {
  size(640, 640, P3D);
  img = loadImage("smokealpha.png");
  img.resize(25, 0);
  //ps = new ParticleSystem(0, new PVector(width/2, height-60), img);

  h = (double)width / (double)N;

}

void draw() {
  background(0);
  //// 3D camera
  ////camera(mouseX, height/2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  delta = millis() - lastTime;
  drawSmokeAt(img, 10, 5);
  drawSmokeAt(img, 30, 6);
  drawSmokeAt(img, 50, 50);
  drawSmokeAt(img, 51, 50);

  dens_step(N, dens, dens_prev, u, v, diff, delta);
  
  lastTime = millis();
}

// Renders a vector object 'v' as an arrow and a position 'loc'
void drawVector(PVector v, PVector loc, float scayl) {
  pushMatrix();
  float arrowsize = 4;
  // Translate to position to render vector
  translate(loc.x, loc.y);
  stroke(255);
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