class FluidCell {
  float[] vx;
  float[] vy;
  float divergence;
  float[] pressure;
  float[] density;
  float[] temperature;
  static final float AMBIENT_TEMP = 23.0;
  static final float SMOKE_TEMP = 500.0;
  static final float SMOKE_DENSITY = 10.0;
  
  FluidCell(float vx, float vy){
    this.pressure = new float[2];
    this.vx = new float[2];
    this.vy = new float[2];
    this.density = new float[2];
    this.temperature = new float[2];
    this.divergence = 0;
    this.vx[0] = vx;
    this.vx[1] = vx;
    this.vy[0] = vy;
    this.vy[1] = vy;
    this.density[0] = 0;
    this.density[1] = 0;
    this.temperature[0] = AMBIENT_TEMP;
    this.temperature[1] = AMBIENT_TEMP;
  }
  FluidCell(float vx, float vy, int not_used){
    this.pressure = new float[2];
    this.vx = new float[2];
    this.vy = new float[2];
    this.density = new float[2];
    this.temperature = new float[2];
    this.divergence = 0;
    this.vx[0] = vx;
    this.vx[1] = vx;
    this.vy[0] = vy;
    this.vy[1] = vy;
    this.density[0] = SMOKE_DENSITY;
    this.density[1] = SMOKE_DENSITY;
    this.temperature[0] = SMOKE_TEMP;
    this.temperature[1] = SMOKE_TEMP;
  }

}