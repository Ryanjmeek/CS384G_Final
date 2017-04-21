ParticleSystem ps;

PImage img;

int N = 100; // dimension of grid
int size = (N+2)*(N+2);
double h; // size of each voxel
double u[] = new double[size];
double v[] = new double[size];
double u_prev[] = new double[size];
double v_prev[] = new double[size];
double dens[] = new double[size];
double dens_prev[] = new double[size];

int IX(int i, int j){
  return ((i)+(N+2)*j);
}

/* This method draws a smoke image in the 
* box specified at (i,j) in the NxN grid
*/
void drawSmokeAt(PImage image, int i, int j){
  image(image, (float)h*i, (float)h*j);
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
  
  drawSmokeAt(img, 10, 5);
  drawSmokeAt(img, 30, 6);
  drawSmokeAt(img, 50, 50);
  drawSmokeAt(img, 51, 50);
  //// 3D camera
  ////camera(mouseX, height/2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);

  //// Calculate a "wind" force based on mouse horizontal position
  //float dx = map(mouseX, 0, width, -0.2, 0.2);
  //PVector wind = new PVector(dx, 0);
  //PVector test = new PVector(0, 0.01);
  //ps.applyForce(wind);
  //ps.applyForce(test);
  //ps.run();
  //for (int i = 0; i < 2; i++) {
  //  ps.addParticle();
  //}

  //// Draw an arrow representing the wind force
  //drawVector(wind, new PVector(width/2, 50, 0), 500);
  
  //// 3D box
  ////pushMatrix();
  ////translate(width/2, height/2, -100);
  ////stroke(255);
  ////noFill();
  ////box(200);
  ////popMatrix();
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