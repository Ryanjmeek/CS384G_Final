class FluidCell {
  int x;
  int y;
  //float[] velocity[].x;
  //float[] velocity[].y;
  PVector[] velocity;
  float divergence;
  float[] pressure;
  float[] density;
  float[] temperature;
  boolean solid;
  boolean boundary;
  static final float AMBIENT_TEMP = 23.0;
  static final float SMOKE_TEMP = 150;
  static final float SMOKE_DENSITY = 4.0;
  
  FluidCell(float vx, float vy){
    this.pressure = new float[2];
    this.velocity = new PVector[2];
    //this.velocity[].y = new float[2];
    this.density = new float[2];
    this.temperature = new float[2];
    this.divergence = 0;
    this.velocity[0]= new PVector();
    this.velocity[1]= new PVector();
    this.velocity[0].x = vx;
    this.velocity[1].x = vx;
    this.velocity[0].y = vy;
    this.velocity[1].y = vy;
    this.density[0] = 0;
    this.density[1] = 0;
    this.temperature[0] = AMBIENT_TEMP;
    this.temperature[1] = AMBIENT_TEMP;
    this.solid = false;
    this.boundary = false;
  }
  FluidCell(float vx, float vy, int not_used){
    this.pressure = new float[2];
    this.velocity = new PVector[2];
    this.density = new float[2];
    this.temperature = new float[2];
    this.divergence = 0;
    this.velocity[0]= new PVector();
    this.velocity[1]= new PVector();
    this.velocity[0].x = vx;
    this.velocity[1].x = vx;
    this.velocity[0].y = vy;
    this.velocity[1].y = vy;
    this.density[0] = random(SMOKE_DENSITY/2, SMOKE_DENSITY);
    this.density[1] = random(SMOKE_DENSITY/2, SMOKE_DENSITY);
    this.temperature[0] = SMOKE_TEMP;
    this.temperature[1] = SMOKE_TEMP;
    this.solid = false;
    this.boundary = false;
  }
  
  FluidCell(float vx, float vy, float hack){
    this.pressure = new float[2];
    this.velocity = new PVector[2];
    this.density = new float[2];
    this.temperature = new float[2];
    this.divergence = 0;
    this.velocity[0]= new PVector();
    this.velocity[1]= new PVector();
    this.velocity[0].x = vx;
    this.velocity[1].x = vx;
    this.velocity[0].y = vy;
    this.velocity[1].y = vy;
    this.density[0] = 0;
    this.density[1] = 0;
    this.temperature[0] = 0;
    this.temperature[1] = 0;
    this.solid = true;
    this.boundary = false;
  }
  
}