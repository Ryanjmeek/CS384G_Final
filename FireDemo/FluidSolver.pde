class FluidSolver {
  FluidCell[][] theGrid = new FluidCell[N][N];
  SmokeForces smoke;
  int newPressure;
  int oldPressure;
  int newVals;
  int curVals;
  float lastMouseX;
  float lastMouseY;
  static final float TIME_STEP = 1.0;
  static final int SMOKE_START_X = ((N/2) - 20);
  static final int SMOKE_END_X = ((N/2) + 20);
  static final int SMOKE_START_Y = (N - 6);
  static final int SMOKE_END_Y = (N - 1);

  FluidSolver(){
    newPressure = 1;
    oldPressure = 0;
    newVals = 0;
    curVals = 1;
    smoke = new SmokeForces(this); 
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){        
          //theGrid[i][j] = new FluidCell(random(-5.0,5.0),random(-5.0,5.0), 1);
          theGrid[i][j] = new FluidCell(random(-5.0,5.0),random(-5.0,5.0));
          //theGrid[i][j] = new FluidCell(0,-0.05);
      }
    }
    
  }
  
  boolean isSmoke(int i, int j){
    if(i > SMOKE_START_X && i < SMOKE_END_X && j > SMOKE_START_Y && j < SMOKE_END_Y){
      return true;
    }
    return false;
    
  }
  
  void injectSmoke(){
    for(int i = SMOKE_START_X; i < SMOKE_END_X; i++){
      for(int j = SMOKE_START_Y; j < SMOKE_END_Y; j++){
        theGrid[i][j] = new FluidCell(random(-10.0,10.0),random(-10.0,0), 1);
        //theGrid[i][j] = new FluidCell(0,-0.05, 1);
      }  
    }
  }
  
  void simulate(){
    injectSmoke();
    velocityBoundary();
    advect();
    smoke.addSmokeForces();
    project();
    int swap = newVals;
    newVals = curVals;
    curVals = swap;
  }
  
  
  void velocityBoundary(){
    for(int x = 0; x < N; x++) {        
        theGrid[x][0].velocity[curVals].x = -theGrid[x][1].velocity[curVals].x;
        theGrid[x][0].velocity[curVals].y = -theGrid[x][1].velocity[curVals].y;
        
        theGrid[x][N-1].velocity[curVals].x = -theGrid[x][N-2].velocity[curVals].x;
        theGrid[x][N-1].velocity[curVals].y = -theGrid[x][N-2].velocity[curVals].y;
    }
    for(int y = 0; y < N; y++) {
        theGrid[0][y].velocity[curVals].x = -theGrid[1][y].velocity[curVals].x;
        theGrid[0][y].velocity[curVals].y = -theGrid[1][y].velocity[curVals].y;

        theGrid[N-1][y].velocity[curVals].x = -theGrid[N-2][y].velocity[curVals].x;
        theGrid[N-1][y].velocity[curVals].y = -theGrid[N-2][y].velocity[curVals].y;
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
  
  FluidCell getCell(int x, int y){
    x = (x < 0 ? 0 : (x > N-1 ? N-1 : x));
    y = (y < 0 ? 0 : (y > N-1 ? N-1 : y));
    
    //if(debug) output.println("This is i: " + i + " and j: " + j);
    return theGrid[x][y];
  }
  
  private void advectTemp(int i, int j){
        //if (theGrid[i][j].isASource()){return;}
        float x_prev = i - theGrid[i][j].velocity[curVals].x*delta;
        float y_prev = j - theGrid[i][j].velocity[curVals].y*delta;
        
        
        double v_bl = getCell(floor(x_prev),floor(y_prev)).temperature[curVals];
        double v_tl = getCell(floor(x_prev),ceil(y_prev)).temperature[curVals];
        double v_br = getCell(ceil(x_prev),floor(y_prev)).temperature[curVals];
        double v_tr = getCell(ceil(x_prev),ceil(y_prev)).temperature[curVals];
        
        //PVector v_ml = new PVector( lerp((float)v_bl, (float)v_tl.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_bl.y, (float)v_tl.y, (float)((y_prev-floor(y_prev))/h)) );
        //PVector v_mr = new PVector( lerp((float)v_br.x, (float)v_tr.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_br.y, (float)v_tr.y, (float)((y_prev-floor(y_prev))/h)) );
        
        double v_ml =  lerp((float)v_bl, (float)v_tl, (float)((y_prev-floor(y_prev))/h));
        double v_mr = lerp((float)v_br, (float)v_tr, (float)((y_prev-floor(y_prev))/h)); 
        
        //PVector v_mid = new PVector( lerp((float)v_ml.x, (float)v_mr.x, (float)((x_prev-floor(x_prev))/h)) , lerp((float)v_ml.y, (float)v_mr.y, (float)((x_prev-floor(x_prev))/h)) );
        double v_mid = lerp((float)v_ml, (float)v_mr, (float)((x_prev-floor(x_prev))/h)); 
        
        theGrid[i][j].temperature[newVals] = (float)v_mid;
  }
  
  private void advectDensity(int i, int j){
        //if (theGrid[i][j].isASource()){return;}
        float x_prev = i - theGrid[i][j].velocity[curVals].x*delta;
        float y_prev = j - theGrid[i][j].velocity[curVals].y*delta;
        
        
        double v_bl = getCell(floor(x_prev),floor(y_prev)).density[curVals];
        double v_tl = getCell(floor(x_prev),ceil(y_prev)).density[curVals];
        double v_br = getCell(ceil(x_prev),floor(y_prev)).density[curVals];
        double v_tr = getCell(ceil(x_prev),ceil(y_prev)).density[curVals];
        
        //PVector v_ml = new PVector( lerp((float)v_bl, (float)v_tl.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_bl.y, (float)v_tl.y, (float)((y_prev-floor(y_prev))/h)) );
        //PVector v_mr = new PVector( lerp((float)v_br.x, (float)v_tr.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_br.y, (float)v_tr.y, (float)((y_prev-floor(y_prev))/h)) );
        
        double v_ml =  lerp((float)v_bl, (float)v_tl, (float)((y_prev-floor(y_prev))/h));
        double v_mr = lerp((float)v_br, (float)v_tr, (float)((y_prev-floor(y_prev))/h)); 
        
        //PVector v_mid = new PVector( lerp((float)v_ml.x, (float)v_mr.x, (float)((x_prev-floor(x_prev))/h)) , lerp((float)v_ml.y, (float)v_mr.y, (float)((x_prev-floor(x_prev))/h)) );
        double v_mid = lerp((float)v_ml, (float)v_mr, (float)((x_prev-floor(x_prev))/h)); 
        
        theGrid[i][j].density[newVals] = (float)v_mid;
  }  

  private void advectVelocity(int i, int j){
        //if (theGrid[i][j].isASource()){return;}
        float x_prev = i - theGrid[i][j].velocity[curVals].x*delta;
        float y_prev = j - theGrid[i][j].velocity[curVals].y*delta;
        
        
        PVector v_bl = getCell(floor(x_prev),floor(y_prev)).velocity[curVals];
        PVector v_tl = getCell(floor(x_prev),ceil(y_prev)).velocity[curVals];
        PVector v_br = getCell(ceil(x_prev),floor(y_prev)).velocity[curVals];
        PVector v_tr = getCell(ceil(x_prev),ceil(y_prev)).velocity[curVals];
        
        PVector v_ml = new PVector( lerp((float)v_bl.x, (float)v_tl.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_bl.y, (float)v_tl.y, (float)((y_prev-floor(y_prev))/h)) );
        PVector v_mr = new PVector( lerp((float)v_br.x, (float)v_tr.x, (float)((y_prev-floor(y_prev))/h)) , lerp((float)v_br.y, (float)v_tr.y, (float)((y_prev-floor(y_prev))/h)) );
        
        PVector v_mid = new PVector( lerp((float)v_ml.x, (float)v_mr.x, (float)((x_prev-floor(x_prev))/h)) , lerp((float)v_ml.y, (float)v_mr.y, (float)((x_prev-floor(x_prev))/h)) );
        
        theGrid[i][j].velocity[newVals] = v_mid;
  }

  void advect(){
    for(int y = 1; y < N-1; y++) {
        for(int x = 1; x < N-1; x++) {
            FluidCell myCell = getCell(x,y);
            if(myCell.solid || myCell.boundary) continue;
            
            advectVelocity(x,y);
            advectDensity(x,y);
            advectTemp(x,y);
        }
    }
  }
  
  float clamp(float a, float min, float max){
    return Math.max(Math.min(a, max), min);

  }
  
  boolean debugDivergence = false;
  void computeDivergence(double[][] divergence){
    double C = (-2*h*smokeWeight/delta);
    //double C = (-2*h*smokeWeight/2);
    //C = C*0.05;
    if(debugDivergence) output.println("in computeDivergence this is delta: " + delta);
    for(int i=0; i < N; i++){
      for(int j=0; j < N; j++){
        PVector u = getCell(i, j).velocity[newVals];
        //for edge conditions, values will remain as velocity of current cell
        double u_left = getCell(i - 1, j).velocity[newVals].x;;
        double u_right =  getCell(i + 1, j).velocity[newVals].x; 
        double u_top = getCell(i, j - 1).velocity[newVals].y;
        double u_bot = getCell(i, j + 1).velocity[newVals].y;
        if(debugDivergence) output.println("C: " + C + ", u_right: " + u_right + ", u_left: " + u_left + ", u_bot: " + u_bot + ", u_top: " + u_top);
        divergence[i][j] = -0.5*(u_right - u_left +  u_bot - u_top);
        if(debugDivergence) output.println("in computeDivergence and Cell i: " + i + ", j: " + j + " divergence: " + divergence[i][j] );
      }
    }
  }
  
  boolean debugVelocity = false;
  void updateVelocities(){
    for(int i = 0; i < N-1; i++){
      for(int j = 0; j < N-1; j++){
        FluidCell myCell = getCell(i,j);
        //if (myCell.isASource()){continue;}
        FluidCell left = getCell(i - 1, j);
        FluidCell right = getCell(i + 1, j);
        FluidCell top = getCell(i, j - 1);
        FluidCell bot = getCell(i, j + 1);
        double myPressure = myCell.pressure[newPressure];
        double pressureLeft = i == 0 ? 0 : left.pressure[newPressure];
        double pressureRight = i == N - 1 ? 0 : right.pressure[newPressure];
        double pressureTop = j == 0 ? 0 : top.pressure[newPressure];
        double pressureBot = j == N - 1 ? 0 : bot.pressure[newPressure];
        //double oldVelocityX = myCell.velocity[newVelocity].x;
        //double oldVelocityY = myCell.velocity[newVelocity].y;
       
        myCell.velocity[newVals].x = myCell.velocity[newVals].x - ((float)pressureRight - (float)pressureLeft)*0.5;
        myCell.velocity[newVals].y = myCell.velocity[newVals].y - ((float)pressureBot - (float)pressureTop)*0.5;
        
      }
    }
  }
  
  boolean debugIteration = false;
  double doIteration(double[][] divergence, double[][][] coeffs, int iter){
    double maxDiff = 0;
    for(int i = 0; i < N-1; i++){
      for(int j = 0; j < N-1; j++){
        FluidCell myCell = getCell(i,j);
        //fif (myCell.isASource()){continue;}
        /*if(myCell.density[newVelocity] < densityTolerance){
          myCell.pressure[newPressure] = 0;
          continue;
        }*/
        FluidCell left = getCell(i - 1, j);
        FluidCell right = getCell(i + 1, j);
        FluidCell top = getCell(i, j - 1);
        FluidCell bot = getCell(i, j + 1);
        double pressureOld = iter == 0 ? 0.0 : myCell.pressure[oldPressure];
        double pressureLeft = iter == 0 ? 0.0 : left.pressure[oldPressure];
        double pressureRight = iter == 0 ? 0.0 : right.pressure[oldPressure];
        double pressureTop = iter == 0 ? 0.0 : top.pressure[oldPressure];
        double pressureBot = iter == 0 ? 0.0 : bot.pressure[oldPressure];
        double pressureNew = 0.25*(divergence[i][j] + pressureLeft + pressureRight
                                                                        + pressureTop + pressureBot);
        double diff = (double) abs((float) (pressureNew - pressureOld));
        myCell.pressure[newPressure] = (float) pressureNew;
        if(debugIteration) output.println("in doIteration and this is i: " + i + ", j: " + j + ", pressureNew: " + pressureNew + ", pressureOld: " + pressureOld);
        if(diff > maxDiff) maxDiff = diff;                        
      }
    }
    return maxDiff;
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
    pressureBoundary();
    updateVelocities();
  }

}