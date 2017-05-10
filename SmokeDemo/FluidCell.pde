class FluidCell {
  float pressure;
  float vx;
  float vy;
  float divergence;
  
  FluidCell(float vx, float vy){
    this.pressure = 0;
    this.divergence = 0;
    this.vx = vx;
    this.vy = vy;
  }

}