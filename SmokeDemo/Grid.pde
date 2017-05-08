class Grid {
  Cell[][] theGrid = new Cell[N][N];
  
  Grid(){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new Cell(0.0, new PVector(random(-1.5,1.5),-1), 23.0, 0.0, false);
      }
    }
    
    theGrid[N/2][N/2] = new Cell(0.0, new PVector(0,-1), 585.0, 1.0, true); // source, temperature of source is 585 (fire)
    
  }
  
  Cell getCell(int i, int j){
    return theGrid[i][j];
  }
  
  void advect(){
    theGrid[N/2][N/2] = new Cell(0.0, new PVector(0,-1), 23.0, 1.0, true); // source
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
        this.applyGravity(i,j);
        this.applyBouyancy(i,j);
        this.setOmega(i,j);
        this.applyVorticity(i,j);
      }
    }
  }
  
  private void applyGravity(int i, int j) {
    PVector gravity = new PVector(0.0, .001);
    theGrid[i][j].velocity.x += gravity.x;
    theGrid[i][j].velocity.y += gravity.y;
  }
  
  private void applyBouyancy(int i, int j) {
    PVector bouyancy = new PVector(0.0, (float)(-alpha * theGrid[i][j].density
      + beta * (theGrid[i][j].temperature - ambientTemp)));
    theGrid[i][j].velocity.x += bouyancy.x;
    theGrid[i][j].velocity.y += bouyancy.y;
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
  
    private void advectTemperature(int i, int j){
      if (theGrid[i][j].isASource()){return;}
      float x_prev = i - theGrid[i][j].velocity.x*delta;
      float y_prev = j - theGrid[i][j].velocity.y*delta;
      
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