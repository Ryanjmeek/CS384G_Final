import Jama.*;

ParticleSystem ps;

PImage img;

int N = 200; // dimension of grid
double diff = 2.0; // diffusion rate
double visc = 20000.0; // viscosity
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
void drawSmokeAt(PImage image, int i, int j, double density){
  tint(255, (float)density);
  image(image, (float)h*i, (float)h*j);
}

void add_dens_source(int n, double[] x, double[] s, double dt){
  for (int i = 0; i < size; i++){
    if (i == 10000){ x[i] += dt*1.0;} // temporarily insert source @50, always
  }
}

void add_vel_source(int n, double[] x, double[] s, double dt){
  for (int i = 0; i < size; i++){
    if (i == 10000){ x[i] += dt*1.0;} // temporarily insert source @50, always
  }
}

void set_bnd(int n, int b, double[] x){
  for (int i = 1; i <= N; i++){
    if (b == 1){
      x[IX(0,i)] = -x[IX(1,i)];
      x[IX(n+1,i)] = -x[IX(n,i)];
    }
    else {
      x[IX(0,i)] = x[IX(1,i)];
      x[IX(n+1,i)] = x[IX(n,i)];
    }
    
    if (b == 2){
      x[IX(i,0)] = -x[IX(i,1)];
      x[IX(i,n+1)] = -x[IX(i,n)];
    }
    else {
      x[IX(i,0)] = x[IX(i,1)];
      x[IX(i,n+1)] = x[IX(i,n)];   
    }
  }
  x[IX(0,0 )] = 0.5*(x[IX(1,0)]+x[IX(0,1)]);
  x[IX(0,n+1)] = 0.5*(x[IX(1,n+1)]+x[IX(0,n)]);
  x[IX(n+1,0)] = 0.5*(x[IX(n,0 )]+x[IX(n+1,1)]);
  x[IX(n+1,n+1)] = 0.5*(x[IX(n,n+1)]+x[IX(n+1,n)]);
}

void diffuse(int n, int b, double[] x, double[] x0, double diff, double dt){
  double a = dt*diff*n*n;
  
  for (int k = 0; k < 20; k++){
    for (int i = 1; i <= n; i++){
      for (int j = 1; j <= n; j++){
        x[IX(i,j)] = (x0[IX(i,j)] + a*(x[IX(i-1,j)] + x[IX(i+1,j)] + x[IX(i,j-1)] + x[IX(i,j+1)]))/(1+4*a);
      }
    }
    set_bnd(n, b, x); 
  }
}

void advect(int n, int b, double[] d, double[] d0, double[] u, double[] v, double dt){
  int i0;
  int j0;
  int i1;
  int j1;
  double x;
  double y;
  double s0;
  double t0;
  double s1;
  double t1;
  
  double dt0 = dt*n;
  for (int i = 1; i <= n; i++){
    for (int j = 1; j <= n; j++){
      x = i-dt0*u[IX(i,j)]; y = j-dt0*v[IX(i,j)];
      if (x<0.5) x=0.5; if (x>n+0.5) x=n+0.5; i0=(int)x; i1=i0+1;
      if (y<0.5) y=0.5; if (y>n+0.5) y=n+0.5; j0=(int)y; j1=j0+1;
      s1 = x-i0; s0 = 1-s1; t1 = y-j0; t0 = 1-t1;
      d[IX(i,j)] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+
       s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
    }
  }
  set_bnd(n, b, d);
}

void project(int n, double[] u, double[] v, double[] p, double[] div){
  for (int i=1; i<=n; i++) {
    for (int j=1; j<=n ; j++) {
      div[IX(i,j)] = -0.5*h*(u[IX(i+1,j)]-u[IX(i-1,j)]+
      v[IX(i,j+1)]-v[IX(i,j-1)]);
      p[IX(i,j)] = 0;
    }
  }
  set_bnd (n, 0, div); set_bnd (n, 0, p);
  for (int k=0; k<20; k++) {
    for (int i=1; i<=n; i++) {
      for (int j=1; j<=n; j++) {
        p[IX(i,j)] = (div[IX(i,j)]+p[IX(i-1,j)]+p[IX(i+1,j)]+
         p[IX(i,j-1)]+p[IX(i,j+1)])/4;
      }
    }
  set_bnd (n, 0, p);
  }
  for (int i=1; i<=n; i++) {
    for (int j=1; j<=n; j++) {
      u[IX(i,j)] -= 0.5*(p[IX(i+1,j)]-p[IX(i-1,j)])/h;
      v[IX(i,j)] -= 0.5*(p[IX(i,j+1)]-p[IX(i,j-1)])/h;
    }
  }
  set_bnd (n, 1, u); set_bnd (n, 2, v);
}

void dens_step(int n, double[] x, double[] x0, double[] u, double[] v, double diff, double dt){
  add_dens_source(n, x, x0, dt);
  for (int i=1; i<=N; i++) {
    for (int j=1; j<=N; j++) {
      x0[IX(i,j)] = x[IX(i,j)];
    }
  }
  diffuse(n, 0, x, x0, diff, dt);
  for (int i=1; i<=N; i++) {
    for (int j=1; j<=N; j++) {
      x0[IX(i,j)] = x[IX(i,j)];
    }
  }
  advect(n, 0, x, x0, u, v, dt);
}

void vel_step(int n, double[] u, double[] v, double[] u0, double[] v0, double visc, double dt){
  add_vel_source(n, u, u0, dt);
  add_vel_source(n, v, v0, dt);
  for (int i=1; i<=N; i++) {
    for (int j=1; j<=N; j++) {
      u0[IX(i,j)] = u[IX(i,j)];
    }
  }
  diffuse(n, 1, u, u0, visc, dt);
  for (int i=1; i<=N; i++) {
    for (int j=1; j<=N; j++) {
      v0[IX(i,j)] = v[IX(i,j)];
    }
  }
  diffuse(n, 2, v, v0, visc, dt);
 
  project(n, u, v, u0, v0);
  for (int i=1; i<=N; i++) {
    for (int j=1; j<=N; j++) {
      u0[IX(i,j)] = u[IX(i,j)];
      v0[IX(i,j)] = v[IX(i,j)];
    }
  }
  advect(n, 1, u, u0, u0, v0, dt);
  advect(n, 2, v, v0, u0, v0, dt);
  project(n, u, v, u0, v0);
}

void setup() {
  size(640, 640, P3D);
  img = loadImage("smokealpha.png");
  img.resize(18, 0);
  //ps = new ParticleSystem(0, new PVector(width/2, height-60), img);

  h = (double)width / (double)N;
  
  for (int i=1; i<=N; i++) {
    for (int j=1; j<=N; j++) {
      u_prev[IX(i,j)] = 1.0;
      v_prev[IX(i,j)] = 1.0;
    }
  }
  
}

void draw() {
  background(0);
  //// 3D camera
  ////camera(mouseX, height/2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  delta = millis() - lastTime;

  vel_step(N, u, v, u_prev, v_prev, visc, delta);
  println("u_prev[50]: " + u_prev[50] + ", v_prev[50]: " + v_prev[50] + " u[50]: " + u[50] + " v[50]: " + v[50]);
  dens_step(N, dens, dens_prev, u, v, diff, delta);
  //println("dens_prev[67]: " + dens_prev[67] + ", dens[67]: " + dens[67]);
  
  for (int i=1; i<=N; i++) {
    for (int j=1; j<=N; j++) {
      drawSmokeAt(img, i, j, 255*dens[IX(i,j)]);
      //dens_prev[IX(i,j)] = dens[IX(i,j)];
      //u_prev[IX(i,j)] = u[IX(i,j)];
      //v_prev[IX(i,j)] = v[IX(i,j)];
    }
  }
  
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