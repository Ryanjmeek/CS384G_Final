class Grid {
  Cell[][] theGrid = new Cell[N][N];
  Cell theSource;
  double[][] newPressure = new double[N][N];
  
  Grid(){
    
    //theGrid[0][0] = new Cell(1.0, new PVector(0,1), 585.0, 1.0, true);
    //this.applyGravity(0,0);
    //this.applyBouyancy(0,0);
    theSource = new Cell(1.0, new PVector(0,-1), 585.0, 1.0, true);
    //theSource = new Cell(1.0, new PVector(0,-1), 585.0, 1.0, false);
    //this.apply(0,0);
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new Cell(0.0, new PVector(random(-0.5,0.5),-1), 23.0, 0.0, false);
        //theGrid[i][j] = new Cell(0.0, new PVector(0,-1), 23.0, 0.0, false);
      }
    }
    
    //theGrid[N/2][N/2] = new Cell(1.0, new PVector(0,1), 585.0, 1.0, false); // source, temperature of source is 585 (fire)
    
  }
  
  Cell getCell(int i, int j){
    if(i < 0 || i > N - 1 || j < 0 || j > N - 1){
      return new Cell(0, new PVector(0,0,0), 23, 0, false);
    }
    //if(debug) output.println("This is i: " + i + " and j: " + j);
    return theGrid[i][j];
  }
  
  //tell us if this is the source, if so return
  private boolean checkSource(float i, float j){
    if(debug) output.println("in checkSource and this is i: " + i + ", j: " + j);
    //if(j > 570 && i > 213 && i < 416){
    if(j > 610 && i > 213 && i < 416){
      if(debug) output.println("in checkSource and this was a source");
      return true;
    }
    return false;
      
  }
  
  private PVector getSourceVelocity(){
    //return new PVector(random(-0.5,0.5),-1);
    return new PVector(theSource.velocity.x,theSource.velocity.y);
  }
  
  private double getSourceDensity(){
    return theSource.density;
  }
  
  private double getSourceTemp(){
    return theSource.temperature;
  }
  
  void advect(){
    //theGrid[N/2][N/2] = new Cell(1.0, new PVector(0,-1), 585.0, 1.0, false); // source
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        this.advectDensity(i,j);
        this.advectTemperature(i,j);
        this.advectVelocity(i,j);
      }
    }
  }
  
  void applyBodyForces() {
    for(int i = 0; i < N; i++) {
      for(int j = 0; j < N; j++) {
        //if (theGrid[i][j].isASource()){continue;}
        if(theGrid[i][j].density < densityTolerance) continue;
        if(debug) output.println("in applyBodyForces i: " + i + ", j: " + j);
        if(debug) output.println("velocity before BodyForces x: " + theGrid[i][j].velocity.x + ", y: " + theGrid[i][j].velocity.y);
        if(debug && j < N - 4) output.println("velocity before BodyForces x: " + theGrid[i][j + 3].velocity.x + ", y: " + theGrid[i][j + 3].velocity.y);
        this.applyGravity(i,j);
        this.applyBouyancy(i,j);
        if(debug) output.println("velocity after BodyForces x: " + theGrid[i][j].velocity.x + ", y: " + theGrid[i][j].velocity.y);
        if(debug && j < N - 4) output.println("velocity after BodyForces x: " + theGrid[i][j + 3].velocity.x + ", y: " + theGrid[i][j + 3].velocity.y);
        //this.setOmega(i,j);
        //this.applyVorticity(i,j);
      }
    }
  }
  
  private void applyGravity(int i, int j) {
    PVector gravity = new PVector(0.0, .001);
    theGrid[i][j].velocity.x += gravity.x;
    theGrid[i][j].velocity.y += gravity.y;
  }
  
  private void applyBouyancy(int i, int j) {
    PVector bouyancy = new PVector(0.0, (float)(alpha * theGrid[i][j].density
      + -beta * (theGrid[i][j].temperature - ambientTemp)));
    theGrid[i][j].velocity.x += bouyancy.x;
    theGrid[i][j].velocity.y += bouyancy.y;
    if(debug) output.println("in applyBuoyancy and bouyancy.x: " + bouyancy.x + ", bouyancy.y: " + bouyancy.y);
  }
  
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
    PVector vorticity = new PVector((float)(omegaDiv.x / (omegaDiv.mag() + epsilon)),
      (float)(omegaDiv.y / (omegaDiv.mag() + epsilon)));
    theGrid[i][j].velocity.x += vorticity.x;
    theGrid[i][j].velocity.y += vorticity.y;
  }
  
  private void advectDensity(int i, int j){
      //if (theGrid[i][j].isASource()){return;}
      float x_prev = i*(float)h - theGrid[i][j].velocity.x*delta;
      float y_prev = j*(float)h - theGrid[i][j].velocity.y*delta;
      if(checkSource(x_prev,y_prev)){
        theGrid[i][j].density = getSourceDensity();
        return;
      }
      if(debug) output.println("in advectDensity and this is i: " + i + ", j: " + j);
      if(debug) output.println("x_prev before change = " + x_prev + ", y_prev = " + y_prev);
      x_prev = x_prev/((float)h);
      y_prev = y_prev/((float)h);
      if (x_prev < 0) {x_prev = 0;}
      if (x_prev >= N-1) {x_prev = N-1;}
      if (y_prev < 0) {y_prev = 0;}
      if (y_prev >= N-1) {y_prev = N-1;}
      
      if(debug) output.println("x_prev after change = " + x_prev + ", y_prev = " + y_prev);
      
      double d_bl = theGrid[floor(x_prev)][floor(y_prev)].density;
      double d_tl = theGrid[floor(x_prev)][ceil(y_prev)].density;
      double d_br = theGrid[ceil(x_prev)][floor(y_prev)].density;
      double d_tr = theGrid[ceil(x_prev)][ceil(y_prev)].density;
      
      double d_ml = lerp((float)d_bl, (float)d_tl, (float)((y_prev-floor(y_prev))/h));
      double d_mr = lerp((float)d_br, (float)d_tr, (float)((y_prev-floor(y_prev))/h));
      
      double d_mid = lerp((float)d_ml, (float)d_mr, (float)((x_prev-floor(x_prev))/h));
      
      theGrid[i][j].density = d_mid;
  }
  
    private void advectTemperature(int i, int j){
      //if (theGrid[i][j].isASource()){return;}
      float x_prev = i*(float)h - theGrid[i][j].velocity.x*delta;
      float y_prev = j*(float)h - theGrid[i][j].velocity.y*delta;
      if(checkSource(x_prev,y_prev)){
        theGrid[i][j].temperature = getSourceTemp();
        return;
      }
      x_prev = x_prev/((float)h);
      y_prev = y_prev/((float)h);
      
      if (x_prev < 0) {x_prev = 0;}
      if (x_prev >= N-1) {x_prev = N-1;}
      if (y_prev < 0) {y_prev = 0;}
      if (y_prev >= N-1) {y_prev = N-1;}
      
      //println("x_prev = " + x_prev + ", y_prev = " + y_prev);
      
      double t_bl = theGrid[floor(x_prev)][floor(y_prev)].temperature;
      double t_tl = theGrid[floor(x_prev)][ceil(y_prev)].temperature;
      double t_br = theGrid[ceil(x_prev)][floor(y_prev)].temperature;
      double t_tr = theGrid[ceil(x_prev)][ceil(y_prev)].temperature;
      
      double t_ml = lerp((float)t_bl, (float)t_tl, (float)((y_prev-floor(y_prev))/h));
      double t_mr = lerp((float)t_br, (float)t_tr, (float)((y_prev-floor(y_prev))/h));
      
      double t_mid = lerp((float)t_ml, (float)t_mr, (float)((x_prev-floor(x_prev))/h));
      
      theGrid[i][j].temperature = t_mid;
  }
  
  private void advectVelocity(int i, int j){
        //if (theGrid[i][j].isASource()){return;}
        float x_prev = i*(float)h - theGrid[i][j].velocity.x*delta;
        float y_prev = j*(float)h - theGrid[i][j].velocity.y*delta;
        if(checkSource(x_prev,y_prev)){
          theGrid[i][j].velocity = getSourceVelocity();
          return;
        }
        x_prev = x_prev/((float)h);
        y_prev = y_prev/((float)h);
        if (x_prev < 0) {x_prev = N - 1;}
        if (x_prev >= N-1) {x_prev = 0;}
        if (y_prev < 0) {y_prev = N - 1;}
        if (y_prev >= N-1) {y_prev = 0;}
        
        //println("x_prev = " + x_prev + ", y_prev = " + y_prev);
        
        PVector v_bl = theGrid[floor(x_prev)][floor(y_prev)].velocity;
        PVector v_tl = theGrid[floor(x_prev)][ceil(y_prev)].velocity;
        PVector v_br = theGrid[ceil(x_prev)][floor(y_prev)].velocity;
        PVector v_tr = theGrid[ceil(x_prev)][ceil(y_prev)].velocity;
        
        PVector v_ml = new PVector( lerp((float)v_bl.x, (float)v_tl.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_bl.y, (float)v_tl.y, (float)((y_prev-floor(y_prev))/h)) );
        PVector v_mr = new PVector( lerp((float)v_br.x, (float)v_tr.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_br.y, (float)v_tr.y, (float)((y_prev-floor(y_prev))/h)) );
        
        PVector v_mid = new PVector( lerp((float)v_ml.x, (float)v_mr.x, (float)((x_prev-floor(x_prev))/h)) , lerp((float)v_ml.y, (float)v_mr.y, (float)((x_prev-floor(x_prev))/h)) );
        
        theGrid[i][j].velocity = v_mid;
  }
  
  boolean debugDivergence = true;
  void computeDivergence(double[][] divergence){
    double C = (-2*h*smokeWeight/delta);
    //double C = (-2*h*smokeWeight/2);
    //C = C*0.05;
    if(debugDivergence) output.println("in computeDivergence this is delta: " + delta);
    for(int i=0; i < N; i++){
      for(int j=0; j < N; j++){
        PVector u = getCell(i, j).velocity;
        //for edge conditions, values will remain as velocity of current cell
        double u_left = u.x;
        double u_right = u.x; 
        double u_top = u.y;
        double u_bot = u.y;
        if(i != 0) u_left = getCell(i - 1, j).velocity.x;
        if(j != 0) u_top = getCell(i, j - 1).velocity.y;
        if(i != N - 1) u_right = getCell(i + 1, j).velocity.x;
        if(j != N - 1) u_bot = getCell(i, j + 1).velocity.y;
        if(debugDivergence) output.println("C: " + C + ", u_right: " + u_right + ", u_left: " + u_left + ", u_bot: " + u_bot + ", u_top: " + u_top);
        divergence[i][j] = C*(u_right - u_left + u_top - u_bot);
        if(debugDivergence) output.println("in computeDivergence and Cell i: " + i + ", j: " + j + " divergence: " + divergence[i][j] );
      }
    }
  }
  
  void computeCoeffs(double[][][] coeffs){
    for(int i=0; i < N; i++){
      for(int j=0; j < N; j++){
        //coefficients
        double cleft = 1, cright = 1, ctop = 1, cbot = 1;
        Cell left = getCell(i - 2, j);
        Cell right = getCell(i + 2, j);
        Cell top = getCell(i, j - 2);
        Cell bot = getCell(i, j + 2);
        if(left.density < densityTolerance) cleft = 0; 
        if(right.density < densityTolerance) cright = 0;
        if(top.density < densityTolerance) ctop = 0;
        if(bot.density < densityTolerance) cbot = 0;
        double cdiv = 4;
        coeffs[i][j][0] = 1/cdiv;
        coeffs[i][j][1] = cleft/cdiv;
        coeffs[i][j][2] = cright/cdiv;
        coeffs[i][j][3] = ctop/cdiv;
        coeffs[i][j][4] = cbot/cdiv;
        if(debug) output.println("in computeCoeffs and these are coeffs: " + coeffs[i][j][0] + ", " + coeffs[i][j][1] + ", " + coeffs[i][j][2] + ", " + coeffs[i][j][3] + ", " + coeffs[i][j][4]);
      }
    }
  }
  
  boolean debugIteration = false;
  double doIteration(double[][] divergence, double[][][] coeffs, int iter){
    double maxDiff = 0;
    for(int i = 0; i < N; i++){
      for(int j = 0; j < N; j++){
        Cell myCell = getCell(i,j);
        //fif (myCell.isASource()){continue;}
        if(myCell.density < densityTolerance){
          myCell.pressure = 0;
          continue;
        }
        Cell left = getCell(i - 2, j);
        Cell right = getCell(i + 2, j);
        Cell top = getCell(i, j - 2);
        Cell bot = getCell(i, j + 2);
        double pressureOld = iter == 0 ? 0.0 : myCell.pressure;
        double pressureLeft = iter == 0 ? 0.0 : left.pressure;
        double pressureRight = iter == 0 ? 0.0 : right.pressure;
        double pressureTop = iter == 0 ? 0.0 : top.pressure;
        double pressureBot = iter == 0 ? 0.0 : bot.pressure;
        double pressureNew = coeffs[i][j][0]*divergence[i][j] + coeffs[i][j][1]*pressureLeft + coeffs[i][j][2]*pressureRight
                                                                        + coeffs[i][j][3]*pressureTop + coeffs[i][j][4]*pressureBot;
        double diff = (double) abs((float) (pressureNew - pressureOld));
        newPressure[i][j] = pressureNew;
        if(debugIteration) output.println("in doIteration and this is i: " + i + ", j: " + j + ", pressureNew: " + pressureNew + ", pressureOld: " + pressureOld);
        if(diff > maxDiff) maxDiff = diff;                        
      }
    }
    return maxDiff;
  }
  
  boolean debugVelocity = false;
  void updateVelocities(){
    for(int i = 0; i < N; i++){
      for(int j = 0; j < N; j++){
        Cell myCell = getCell(i,j);
        //if (myCell.isASource()){continue;}
        Cell left = getCell(i - 1, j);
        Cell right = getCell(i + 1, j);
        Cell top = getCell(i, j - 1);
        Cell bot = getCell(i, j + 1);
        double myPressure = myCell.pressure;
        double pressureLeft = i == 0 ? 0 : left.pressure;
        double pressureRight = i == N - 1 ? 0 : right.pressure;
        double pressureTop = j == 0 ? 0 : top.pressure;
        double pressureBot = j == N - 1 ? 0 : bot.pressure;
        double oldVelocityX = myCell.velocity.x;
        double oldVelocityY = myCell.velocity.y;
        if(debugVelocity && myPressure > 0) output.println("in updateVelocities before update and Cell i: " + i + ", j: " + j + ", velocity.x " + myCell.velocity.x + ", velocity.y: " + myCell.velocity.y );
        myCell.velocity.x = myCell.velocity.x - delta*((float)pressureRight - (float)myPressure)/((float)h*(float)smokeWeight);
        myCell.velocity.y = myCell.velocity.y + delta*((float)pressureBot - (float)myPressure)/((float)h*(float)smokeWeight);
        if(debugVelocity && myPressure > 0) output.println("in updateVelocities after update and Cell i: " + i + ", j: " + j + ", velocity.x " + myCell.velocity.x + ", velocity.y: " + myCell.velocity.y );
        if(debugVelocity && myPressure > 0) output.println("in updateVelocities myPressure: " + myPressure + ", pressureRight: " + pressureRight + ", pressureLeft: " + pressureLeft);
        double diffX = oldVelocityX - myCell.velocity.x;
        double diffY = oldVelocityY - myCell.velocity.y;
        if(debugVelocity && myPressure > 0) output.println("in updateVelocities and diffX: " + diffX + ", diffY: " + diffY);
      }
    }
    
  
  }
  boolean debugProject = true;
  void debugProject(double[][] divergence, double[][][] coeffs){
    for(int i = 0; i < N; i++){
      for(int j = 0; j < N; j++){
        Cell myCell = getCell(i,j);
        if(myCell.density < densityTolerance){
          continue;
        }
        Cell left = getCell(i - 2, j);
        Cell right = getCell(i + 2, j);
        Cell top = getCell(i, j - 2);
        Cell bot = getCell(i, j + 2);
        double myPressure = myCell.pressure;
        double pressureLeft = i == 0 ? 0 : left.pressure;
        double pressureRight = i == N - 1 ? 0 : right.pressure;
        double pressureTop = j == 0 ? 0 : top.pressure;
        double pressureBot = j == N - 1 ? 0 : bot.pressure;
        double difference = (4*(4*coeffs[i][j][0]*myPressure - coeffs[i][j][1]*pressureLeft - coeffs[i][j][2]*pressureRight
                                                              - coeffs[i][j][3]*pressureTop - coeffs[i][j][4]*pressureBot)) - divergence[i][j];
        if(debugProject) output.println("in debugProject and this is i: " + i + ", j: " + j + ", difference: " + difference);
        if(debugProject) output.println("in debugProject and this is myPressure " + myPressure + ", divergence: " + divergence[i][j]);
      }
    }
  }
  void updatePressures(){
    for(int i=0; i < N; i++){
      for(int j=0; j< N; j++){
        getCell(i,j).pressure = newPressure[i][j];
      }
    }
  }
  
  void project(){
    double[][] divergence = new double[N][N];
    double[][][] coeffs = new double [N][N][5];
    double diff = 999999.0; //a big number
    int iter = 0;
    computeDivergence(divergence);
    computeCoeffs(coeffs);
    //while(diff > pressureTolerance){
    while(iter < 10){
      diff = doIteration(divergence, coeffs, iter);
      updatePressures();
      //debugProject(divergence, coeffs);
      if(debug) output.println("in project and this is iter: " + iter + ", maxDiff: " + diff);
      iter++;
    }
    //update the velocity field with pressure info now
    updateVelocities();
  }
}