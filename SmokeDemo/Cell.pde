class Cell {
  double pressure;
  PVector velocity;
  double temperature;
  double density;
  double omega;
  
  boolean isSource;
  
  Cell(double press, PVector vel, double temp, double dens, boolean isSource){
    this.pressure = press;
    this.velocity = vel;
    this.temperature = temp;
    this.density = dens;
    this.isSource = isSource;
  }
  
  boolean isASource(){
    return isSource;
  }
  
}