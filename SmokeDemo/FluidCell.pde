class FluidCell {
  float vx;
  float vy;
  float divergence;
  float[] pressure;
  
  FluidCell(float vx, float vy){
    this.pressure = new float[2];
    this.pressureOld = 0;
    this.divergence = 0;
    this.vx = vx;
    this.vy = vy;
  }

}