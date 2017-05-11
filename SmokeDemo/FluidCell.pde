class FluidCell {
  float[] vx;
  float[] vy;
  float divergence;
  float[] pressure;
  
  FluidCell(float vx, float vy){
    this.pressure = new float[2];
    this.vx = new float[2];
    this.vy = new float[2];
    this.divergence = 0;
    this.vx[0] = vx;
    this.vx[1] = vx;
    this.vy[0] = vy;
    this.vy[1] = vy;
  }

}