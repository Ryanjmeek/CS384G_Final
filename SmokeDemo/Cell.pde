class Cell {
  double[] pressure;
  PVector[] velocity;
  double[] temperature;
  double[] density;
  double[] omega;
  
  boolean isSource;
  
  Cell(double press, PVector vel, double temp, double dens, boolean isSource){
    this.pressure = new double[2];
    this.velocity = new PVector[2];
    this.temperature = new double[2];
    this.density = new double[2];
    this.omega = new double[2];
    
    this.pressure[0] = press;
    this.pressure[1] = press;
    this.velocity[0] = vel;
    this.velocity[1] = vel;
    this.temperature[0] = temp;
    this.temperature[1] = temp;
    this.density[0] = dens;
    this.density[1] = dens;
    this.isSource = isSource;
  }
  
  boolean isASource(){
    return isSource;
  }

}