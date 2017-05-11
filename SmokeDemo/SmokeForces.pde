class SmokeForces{
  FluidSolver parent;
  static final float alpha = 0.00001;
  static final float beta = 0.0001;
  static final float zeta = 1;
  float[][] omega;
  
  
  SmokeForces(FluidSolver p){
    parent = p;
    omega = new float[N][N];
  }
 
  void addSmokeForces() {
    for(int i = 0; i < N; i++) {
      for(int j = 0; j < N; j++) {
        if(parent.theGrid[i][j].density[parent.newVals] > densityTolerance) {
          this.applyGravity(i,j);
          this.applyBouyancy(i,j);
          this.setOmega(i,j);
          this.applyVorticity(i,j);
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
  
  
  private void setOmega(int i, int j) {
    float vel1 = (i+1 < N) ? parent.theGrid[i+1][j].vy[parent.newVals] : parent.theGrid[i][j].vy[parent.newVals];
    float vel2 = (i-1 >= 0) ? parent.theGrid[i-1][j].vy[parent.newVals] : parent.theGrid[i][j].vy[parent.newVals];
    float vel3 = (j+1 < N) ? parent.theGrid[i][j+1].vx[parent.newVals] : parent.theGrid[i][j].vx[parent.newVals];
    float vel4 = (j-1 >= 0) ? parent.theGrid[i][j-1].vx[parent.newVals] : parent.theGrid[i][j].vx[parent.newVals];
    float omegaVal = (vel1 - vel2)/(2*h) - (vel3 - vel4)/(2*h);
    omega[i][j] = omegaVal;
  }
  
  private void applyVorticity(int i, int j) {
    float omega1 = (i+1 < N) ? omega[i+1][j] : omega[i][j];
    float omega2 = (i-1 >= 0) ? omega[i-1][j] : omega[i][j];
    float omega3 = (j+1 < N) ? omega[i][j+1] : omega[i][j];
    float omega4 = (j-1 >= 0) ? omega[i][j-1] : omega[i][j];
    float omegaDivX = (omega1 - omega2)/(2*h);
    float omegaDivY = (omega3 - omega4)/(2*h);
    PVector omegaDiv = new PVector(omegaDivX, omegaDivY);
    PVector N1 = new PVector((float)(omegaDiv.x / (omegaDiv.mag() + epsilon)),
      (float)(omegaDiv.y / (omegaDiv.mag() + epsilon)));
    // We flip the y because of the grid
    float confX = (-omega[i][j] * N1.y) * h * zeta;
    float confY = (omega[i][j] * N1.x) * h * zeta;
    parent.theGrid[i][j].vx[parent.newVals] += confX;
    parent.theGrid[i][j].vy[parent.newVals] += confY;
  }
  
  
}