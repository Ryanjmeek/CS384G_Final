class Grid {
  Cell[][] theGrid = new Cell[N][N];
  
  Grid(){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new Cell(0.0, new PVector(random(-1.5,1.5),-1), 23.0, 0.0, false);
      }
    }
    
    theGrid[N/2][N/2] = new Cell(0.0, new PVector(0,-1), 23.0, 1.0, true); // source
    
  }
  
  Cell getCell(int i, int j){
    if(i < 0 || i > N - 1 || j < 0 || i > N - 1){
      return new Cell(0, new PVector(0,0,0), 23, 0, false);
    }
    return theGrid[i][j];
  }
  
  void advect(){
    theGrid[N/2][N/2] = new Cell(0.0, new PVector(0,-1), 23.0, 1.0, true); // source
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        this.advectDensity(i,j);
        this.advectVelocity(i,j);
      }
    }
  }
  
  private void advectDensity(int i, int j){
      if (theGrid[i][j].isASource()){return;}
      float x_prev = i - theGrid[i][j].velocity.x*delta;
      float y_prev = j - theGrid[i][j].velocity.y*delta;
      
      if (x_prev < 0) {x_prev = 0;}
      if (x_prev >= N-1) {x_prev = N-1;}
      if (y_prev < 0) {y_prev = 0;}
      if (y_prev >= N-1) {y_prev = N-1;}
      
      //println("x_prev = " + x_prev + ", y_prev = " + y_prev);
      
      double d_bl = theGrid[floor(x_prev)][floor(y_prev)].density;
      double d_tl = theGrid[floor(x_prev)][ceil(y_prev)].density;
      double d_br = theGrid[ceil(x_prev)][floor(y_prev)].density;
      double d_tr = theGrid[ceil(x_prev)][ceil(y_prev)].density;
      
      double d_ml = lerp((float)d_bl, (float)d_tl, (float)((y_prev-floor(y_prev))/h));
      double d_mr = lerp((float)d_br, (float)d_tr, (float)((y_prev-floor(y_prev))/h));
      
      double d_mid = lerp((float)d_ml, (float)d_mr, (float)((x_prev-floor(x_prev))/h));
      
      theGrid[i][j].density = d_mid;
  }
  
  private void advectVelocity(int i, int j){
        if (theGrid[i][j].isASource()){return;}
        float x_prev = i - theGrid[i][j].velocity.x*delta;
        float y_prev = j - theGrid[i][j].velocity.y*delta;
        
        if (x_prev < 0) {x_prev = 0;}
        if (x_prev >= N-1) {x_prev = N-1;}
        if (y_prev < 0) {y_prev = 0;}
        if (y_prev >= N-1) {y_prev = N-1;}
        
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
  
    void computeDivergence(double[][] divergence){
    double C = (-2*h*smokeWeight/delta);
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
        //this line is doing C*(u_right - u_left + u_bot - u_top)
        divergence[i][j] = C*(u_right - u_left + u_bot - u_top);
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
        double cdiv = (cleft + cright + ctop + cbot);
        coeffs[i][j][0] = cdiv/cdiv;
        coeffs[i][j][1] = cleft/cdiv;
        coeffs[i][j][2] = cright/cdiv;
        coeffs[i][j][3] = ctop/cdiv;
        coeffs[i][j][4] = cbot/cdiv;
      }
    }
  }
  
  double doIteration(double[][] divergence, double[][][] coeffs, int iter){
    double maxDiff = 0;
    for(int i = 0; i < N; i++){
      for(int j = 0; j < N; j++){
        Cell myCell = getCell(i,j);
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
        myCell.pressure = pressureNew;
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
    computeCoeffs(coeffs);
    while(diff > pressureTolerance){
      doIteration(divergence, coeffs, iter);
      iter++;
    } 
  }
}