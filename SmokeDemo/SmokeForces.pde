class SmokeForces{
  FluidSolver parent;
  static final double alpha = 0.00001;
  static final double beta = 0.0001;
  
  SmokeForces(FluidSolver p){
    parent = p;
  }
 
  void addSmokeForces() {
    for(int i = 0; i < N; i++) {
      for(int j = 0; j < N; j++) {
        if(parent.theGrid[i][j].density[parent.newVals] > densityTolerance) {
          this.applyGravity(i,j);
          this.applyBouyancy(i,j);
          //this.setOmega(i,j);
          //this.applyVorticity(i,j);
        }
      }
    }
  }
  
  private void applyGravity(int i, int j) {
    PVector gravity = new PVector(0.0, .001);
    parent.theGrid[i][j].vx[parent.newVals] += gravity.x;
    parent.theGrid[i][j].vy[parent.newVals] += gravity.y;
  }
  
  private void applyBouyancy(int i, int j) {
    PVector bouyancy = new PVector(0.0, (float)(alpha * parent.theGrid[i][j].density[parent.newVals]
      + -beta * (parent.theGrid[i][j].temperature[parent.newVals] - FluidCell.AMBIENT_TEMP)));
    parent.theGrid[i][j].vx[parent.newVals] += bouyancy.x;
    parent.theGrid[i][j].vy[parent.newVals] += bouyancy.y;
  }
  
  /*
  private void setOmega(int i, int j) {
    double vel1 = (i+1 < N) ? theGrid[i+1][j].velocity.y : theGrid[i][j].velocity.y;
    double vel2 = (i-1 >= 0) ? theGrid[i-1][j].velocity.y : theGrid[i][j].velocity.y;
    double vel3 = (j+1 < N) ? theGrid[i][j+1].velocity.x : theGrid[i][j].velocity.x;
    double vel4 = (j-1 >= 0) ? theGrid[i][j-1].velocity.x : theGrid[i][j].velocity.x;
    double omega = (vel1 - vel2)/(2*h) - (vel3 - vel4)/(2*h);
    theGrid[i][j].omega = omega;
  }
  
  private void applyVorticity(int i, int j) {
    double omega1 = (i+1 < N) ? theGrid[i+1][j].omega : theGrid[i][j].omega;
    double omega2 = (i-1 >= 0) ? theGrid[i-1][j].omega : theGrid[i][j].omega;
    double omega3 = (j+1 < N) ? theGrid[i][j+1].omega : theGrid[i][j].omega;
    double omega4 = (j-1 >= 0) ? theGrid[i][j-1].omega : theGrid[i][j].omega;
    double omegaDivX = (omega1 - omega2)/(2*h);
    double omegaDivY = (omega3 - omega4)/(2*h);
    PVector omegaDiv = new PVector((float)omegaDivX, (float)omegaDivY);
    PVector N = new PVector((float)(omegaDiv.x / (omegaDiv.mag() + epsilon)),
      (float)(omegaDiv.y / (omegaDiv.mag() + epsilon)));
    // We flip the y because of the grid
    double confX = (-theGrid[i][j].omega * N.y) * h * zeta;
    double confY = (theGrid[i][j].omega * N.x) * h * zeta;
    theGrid[i][j].velocity.x += confX;
    theGrid[i][j].velocity.y += confY;
  }
  */
  
}