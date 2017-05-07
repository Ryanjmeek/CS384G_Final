class Grid {
  Cell[][] theGrid = new Cell[N][N];
  
  Grid(){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new Cell(0.0, new PVector(0,1+random(-2,2)), 23.0, 0.0, false);
      }
    }
    
    theGrid[N/2][N/2] = new Cell(0.0, new PVector(0,-1), 23.0, 1.0, true); // source
    
  }
  
  Cell getCell(int i, int j){
    return theGrid[i][j];
  }
  
  void advect(){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
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
    }
  }
}