class Grid {
  Cell[][] theGrid = new Cell[N][N];
  Cell theSource;
  int newVelocity;
  int oldVelocity;
  int newPressure;
  int oldPressure;
  float lastMouseX;
  float lastMouseY;
  
  Grid(){
    
    //theGrid[0][0] = new Cell(1.0, new PVector(0,1), 585.0, 1.0, true);
    //this.applyGravity(0,0);
    //this.applyBouyancy(0,0);
    //theSource = new Cell(1.0, new PVector(0,-1), 585.0, 1.0, true);
    //theSource = new Cell(1.0, new PVector(0,-1), 585.0, 1.0, false);
    //this.apply(0,0);
    newVelocity = 0;
    oldVelocity = 1;
    newPressure = 0;
    oldPressure = 1;
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new Cell(0.0, new PVector(random(-5.0,5.0),random(-5.0,5.0)), 23.0, 0.0, false);
        //theGrid[i][j] = new Cell(0.0, new PVector(0,-1), 23.0, 0.0, false);
      }
    }
    
    //theGrid[N/2][N/2] = new Cell(1.0, new PVector(0,1), 585.0, 1.0, false); // source, temperature of source is 585 (fire)
    
  }
  float clamp(float a, float min, float max){
    return Math.max(Math.min(a, max), min);

  }
  
  void addMouseForce(){
    if(!doExplosion) return;
    int x = (int) clamp(mouseX, 1, N-2);
    int y = (int )clamp(mouseY, 1, N-2);
    float dx = mouseX-lastMouseX;
    float dy = mouseY-lastMouseY;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
    Cell leftCell = getCell(x-1,y);
    Cell rightCell = getCell(x+1,y);
    Cell topCell = getCell(x,y-1);
    Cell botCell = getCell(x,y+1);
    Cell topRightCell = getCell(x+1,y-1);
    Cell botRightCell = getCell(x+1,y+1);
    Cell topLeftCell = getCell(x-1,y-1);
    Cell botLeftCell = getCell(x-1,y+1);
    
    leftCell.velocity[newVelocity].y = 0.0;
    leftCell.velocity[newVelocity].x = -100.0;
    
    topCell.velocity[newVelocity].y = -100.0;
    topCell.velocity[newVelocity].x = 0;
    
    rightCell.velocity[newVelocity].y = 0.0;
    rightCell.velocity[newVelocity].x = 100.0;
    
    botCell.velocity[newVelocity].y = 100.0;
    botCell.velocity[newVelocity].x = 0.0;
    
    topRightCell.velocity[newVelocity].y = -70.0;
    topRightCell.velocity[newVelocity].x = 70.0;  
    
    botRightCell.velocity[newVelocity].y = 70.0;
    botRightCell.velocity[newVelocity].x = 70.0;  
    
    topLeftCell.velocity[newVelocity].y = -70.0;
    topLeftCell.velocity[newVelocity].x = -70.0;
    
    botLeftCell.velocity[newVelocity].y = 70.0;
    botLeftCell.velocity[newVelocity].x = -70.0;
    
    doExplosion = false;
  }
  Cell getCell(int i, int j){
    i = (i < 0) ? 0 : (i > N-1) ? N-1 : i;
    j = (j < 0) ? 0 : (j > N-1) ? N-1 : j;
    //if(debug) output.println("This is i: " + i + " and j: " + j);
    return theGrid[i][j];
  }
  
  void velocityBoundary(){
    for(int x = 0; x < N; x++) {        
        theGrid[x][0].velocity[oldVelocity].x = -theGrid[x][1].velocity[oldVelocity].x;
        theGrid[x][0].velocity[oldVelocity].y = -theGrid[x][1].velocity[oldVelocity].y;
        
        theGrid[x][N-1].velocity[oldVelocity].x = -theGrid[x][N-2].velocity[oldVelocity].x;
        theGrid[x][N-1].velocity[oldVelocity].y = -theGrid[x][N-2].velocity[oldVelocity].y;
    }
    for(int y = 0; y < N; y++) {
        theGrid[0][y].velocity[oldVelocity].x = -theGrid[1][y].velocity[oldVelocity].x;
        theGrid[0][y].velocity[oldVelocity].y = -theGrid[1][y].velocity[oldVelocity].y;
        
        theGrid[N-1][y].velocity[oldVelocity].x = -theGrid[N-2][y].velocity[oldVelocity].x;
        theGrid[N-1][y].velocity[oldVelocity].y = -theGrid[N-2][y].velocity[oldVelocity].y;
    }
    
  }
  
  void pressureBoundary(){
    for(int x = 0; x < N; x++) {        
        theGrid[x][0].pressure[newPressure] = theGrid[x][1].pressure[newPressure];        
        theGrid[x][N-1].pressure[newPressure] = theGrid[x][N-2].pressure[newPressure];
    }
    for(int y = 0; y < N; y++) {
        theGrid[0][y].pressure[newPressure] = theGrid[1][y].pressure[newPressure];
        theGrid[N-1][y].pressure[newPressure] = theGrid[N-2][y].pressure[newPressure];
    }
  }
  
  void advect(){
    //theGrid[N/2][N/2] = new Cell(1.0, new PVector(0,-1), 585.0, 1.0, false); // source
    for (int i = 1; i < N-1; i++){
      for (int j = 1; j < N-1; j++){
        //this.advectDensity(i,j);
        //this.advectTemperature(i,j);
        this.advectVelocity(i,j);
      }
    }
  }
  
  float bilerpVelocityY(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).velocity[oldVelocity].y;
      float p01 = getCell(x0,y1).velocity[oldVelocity].y;
      float p10 = getCell(x1,y0).velocity[oldVelocity].y;
      float p11 = getCell(x1,y1).velocity[oldVelocity].y;
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  float bilerpVelocityX(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).velocity[oldVelocity].x;
      float p01 = getCell(x0,y1).velocity[oldVelocity].x;
      float p10 = getCell(x1,y0).velocity[oldVelocity].x;
      float p11 = getCell(x1,y1).velocity[oldVelocity].x;
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  private void advectVelocity(int i, int j){
        //if (theGrid[i][j].isASource()){return;}
        float x_prev = i - theGrid[i][j].velocity[oldVelocity].x*delta;
        float y_prev = j - theGrid[i][j].velocity[oldVelocity].y*delta;
        /*if(checkSource(x_prev,y_prev)){
          theGrid[i][j].velocity[newVelocity] = getSourceVelocity();
          return;
        }*/
        //x_prev = x_prev/((float)h);
        //y_prev = y_prev/((float)h);
        if (x_prev < 0) {x_prev = N - 1;}
        if (x_prev >= N-1) {x_prev = 0;}
        if (y_prev < 0) {y_prev = N - 1;}
        if (y_prev >= N-1) {y_prev = 0;}
        
        //println("x_prev = " + x_prev + ", y_prev = " + y_prev);
        
        PVector v_bl = theGrid[floor(x_prev)][floor(y_prev)].velocity[oldVelocity];
        PVector v_tl = theGrid[floor(x_prev)][ceil(y_prev)].velocity[oldVelocity];
        PVector v_br = theGrid[ceil(x_prev)][floor(y_prev)].velocity[oldVelocity];
        PVector v_tr = theGrid[ceil(x_prev)][ceil(y_prev)].velocity[oldVelocity];
        
        PVector v_ml = new PVector( lerp((float)v_bl.x, (float)v_tl.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_bl.y, (float)v_tl.y, (float)((y_prev-floor(y_prev))/h)) );
        PVector v_mr = new PVector( lerp((float)v_br.x, (float)v_tr.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_br.y, (float)v_tr.y, (float)((y_prev-floor(y_prev))/h)) );
        
        PVector v_mid = new PVector( lerp((float)v_ml.x, (float)v_mr.x, (float)((x_prev-floor(x_prev))/h)) , lerp((float)v_ml.y, (float)v_mr.y, (float)((x_prev-floor(x_prev))/h)) );
        
        theGrid[i][j].velocity[newVelocity] = v_mid;
  }
  
  boolean debugDivergence = false;
  void computeDivergence(double[][] divergence){
    double C = (-2*h*smokeWeight/delta);
    //double C = (-2*h*smokeWeight/2);
    //C = C*0.05;
    if(debugDivergence) output.println("in computeDivergence this is delta: " + delta);
    for(int i=0; i < N; i++){
      for(int j=0; j < N; j++){
        PVector u = getCell(i, j).velocity[newVelocity];
        //for edge conditions, values will remain as velocity of current cell
        double u_left = getCell(i - 1, j).velocity[newVelocity].x;;
        double u_right =  getCell(i + 1, j).velocity[newVelocity].x; 
        double u_top = getCell(i, j - 1).velocity[newVelocity].y;
        double u_bot = getCell(i, j + 1).velocity[newVelocity].y;
        if(debugDivergence) output.println("C: " + C + ", u_right: " + u_right + ", u_left: " + u_left + ", u_bot: " + u_bot + ", u_top: " + u_top);
        divergence[i][j] = -0.5*(u_right - u_left +  u_bot - u_top);
        if(debugDivergence) output.println("in computeDivergence and Cell i: " + i + ", j: " + j + " divergence: " + divergence[i][j] );
      }
    }
  }
   
  boolean debugIteration = false;
  double doIteration(double[][] divergence, double[][][] coeffs, int iter){
    double maxDiff = 0;
    for(int i = 0; i < N-1; i++){
      for(int j = 0; j < N-1; j++){
        Cell myCell = getCell(i,j);
        //fif (myCell.isASource()){continue;}
        /*if(myCell.density[newVelocity] < densityTolerance){
          myCell.pressure[newPressure] = 0;
          continue;
        }*/
        Cell left = getCell(i - 1, j);
        Cell right = getCell(i + 1, j);
        Cell top = getCell(i, j - 1);
        Cell bot = getCell(i, j + 1);
        double pressureOld = iter == 0 ? 0.0 : myCell.pressure[oldPressure];
        double pressureLeft = iter == 0 ? 0.0 : left.pressure[oldPressure];
        double pressureRight = iter == 0 ? 0.0 : right.pressure[oldPressure];
        double pressureTop = iter == 0 ? 0.0 : top.pressure[oldPressure];
        double pressureBot = iter == 0 ? 0.0 : bot.pressure[oldPressure];
        double pressureNew = 0.25*(divergence[i][j] + pressureLeft + pressureRight
                                                                        + pressureTop + pressureBot);
        double diff = (double) abs((float) (pressureNew - pressureOld));
        myCell.pressure[newPressure] = pressureNew;
        if(debugIteration) output.println("in doIteration and this is i: " + i + ", j: " + j + ", pressureNew: " + pressureNew + ", pressureOld: " + pressureOld);
        if(diff > maxDiff) maxDiff = diff;                        
      }
    }
    return maxDiff;
  }
  
  boolean debugVelocity = false;
  void updateVelocities(){
    for(int i = 0; i < N-1; i++){
      for(int j = 0; j < N-1; j++){
        Cell myCell = getCell(i,j);
        //if (myCell.isASource()){continue;}
        Cell left = getCell(i - 1, j);
        Cell right = getCell(i + 1, j);
        Cell top = getCell(i, j - 1);
        Cell bot = getCell(i, j + 1);
        double myPressure = myCell.pressure[newPressure];
        double pressureLeft = i == 0 ? 0 : left.pressure[newPressure];
        double pressureRight = i == N - 1 ? 0 : right.pressure[newPressure];
        double pressureTop = j == 0 ? 0 : top.pressure[newPressure];
        double pressureBot = j == N - 1 ? 0 : bot.pressure[newPressure];
        double oldVelocityX = myCell.velocity[newVelocity].x;
        double oldVelocityY = myCell.velocity[newVelocity].y;
       
        myCell.velocity[newVelocity].x = myCell.velocity[newVelocity].x - ((float)pressureRight - (float)pressureLeft)*0.5;
        myCell.velocity[newVelocity].y = myCell.velocity[newVelocity].y - ((float)pressureBot - (float)pressureTop)*0.5;
        
      }
    }
    
  
  }
  boolean debugProject = false;
  void debugProject(double[][] divergence, double[][][] coeffs){
    for(int i = 0; i < N; i++){
      for(int j = 0; j < N; j++){
        Cell myCell = getCell(i,j);
        if(myCell.density[newVelocity] < densityTolerance){
          continue;
        }
        Cell left = getCell(i - 2, j);
        Cell right = getCell(i + 2, j);
        Cell top = getCell(i, j - 2);
        Cell bot = getCell(i, j + 2);
        double myPressure = myCell.pressure[newVelocity];
        double pressureLeft = i == 0 ? 0 : left.pressure[newVelocity];
        double pressureRight = i == N - 1 ? 0 : right.pressure[newVelocity];
        double pressureTop = j == 0 ? 0 : top.pressure[newVelocity];
        double pressureBot = j == N - 1 ? 0 : bot.pressure[newVelocity];
        double difference = (4*(4*coeffs[i][j][0]*myPressure - coeffs[i][j][1]*pressureLeft - coeffs[i][j][2]*pressureRight
                                                              - coeffs[i][j][3]*pressureTop - coeffs[i][j][4]*pressureBot)) - divergence[i][j];
        if(debugProject) output.println("in debugProject and this is i: " + i + ", j: " + j + ", difference: " + difference);
        if(debugProject) output.println("in debugProject and this is myPressure " + myPressure + ", divergence: " + divergence[i][j]);
      }
    }
  }
  
  
  void project(){
    double[][] divergence = new double[N][N];
    double[][][] coeffs = new double [N][N][5];
    double diff = 999999.0; //a big number
    int iter = 0;
    computeDivergence(divergence);
    //computeCoeffs(coeffs);
    //while(diff > pressureTolerance){
    while(iter < 8){
      int swap = oldPressure;
      oldPressure = newPressure;
      newPressure = swap;
      diff = doIteration(divergence, coeffs, iter);
      //debugProject(divergence, coeffs);
      if(debug) output.println("in project and this is iter: " + iter + ", maxDiff: " + diff);
      iter++;
    }
    //update the velocity field with pressure info now
    updateVelocities();
  }
}