class FluidSolver {
  FluidCell[][] theGrid = new FluidCell[N][N];
  int newPressure;
  int oldPressure;
  
  FluidSolver(){
    //TODO
    newPressure = 1;
    oldPressure = 0;
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new FluidCell(random(-5.0,5.0),random(-5.0,5.0));
      }
    }
    
  }
  
  void addMouseForce(){
    var x = clamp(mouseX*sx, 1, WIDTH-2),
        y = clamp(mouseY*sy, 1, HEIGHT-2),
        dx = mouseX-lastMouseX,
        dy = mouseY-lastMouseY;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
    ux(x, y, ux(x, y)-dx*2);
    uy(x, y, uy(x, y)-dy*2);
  }
  
  void velocityBoundary(){
    for(int x = 0; x < N; x++) {        
        theGrid[x][0].vx = -theGrid[x][1].vx;
        theGrid[x][0].vy = -theGrid[x][1].vy;
        
        theGrid[x][N-1].vx = -theGrid[x][N-2].vx;
        theGrid[x][N-1].vy = -theGrid[x][N-2].vy;
    }
    for(int y = 0; y < N; y++) {
        theGrid[0][y].vx = -theGrid[1][y].vx;
        theGrid[0][y].vy = -theGrid[1][y].vy;

        theGrid[N-1][y].vx = -theGrid[N-2][y].vx;
        theGrid[N-1][y].vy = -theGrid[N-2][y].vy;
    }
  }
  
  void pressureBoundary(){
    
  }
  
  //TODO
  FluidCell getCell(int x, int y){
    x = (x < 0 ? 0 : (x > N-1 ? N-1 : x))|0;
    y = (y < 0 ? 0 : (y > N-1 ? N-1 : y))|0;
    //if(debug) output.println("This is i: " + i + " and j: " + j);
    return theGrid[x][y];
  }
  

  
  float lerp(float a, float b, float c){
    c = c < 0 ? 0 : (c > 1 ? 1 : c);
    //c = clamp(c, 0, 1);
    return a * (1 - c) + b * c;
  }
  
  float bilerpVelocityX(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).vx;
      float p01 = getCell(x0,y1).vx;
      float p10 = getCell(x1,y0).vx;
      float p11 = getCell(x1,y1).vx;
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  float bilerpVelocityY(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).vy;
      float p01 = getCell(x0,y1).vy;
      float p10 = getCell(x1,y0).vy;
      float p11 = getCell(x1,y1).vy;
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  void advectVelocity(float t){
    for(int y = 1; y < N-1; y++) {
        for(int x = 1; x < N-1; x++) {
            FluidCell myCell = getCell(x,y);
            float vx = myCell.vx*t;
            float vy = myCell.vy*t;
            
            dest(x, y, bilerp(src, x+vx, y+vy));
            //TODO this might need to be a x +vx instead of x-vx
            myCell.vx = bilerpVelocityX(x-vx,y-vy);
            myCell.vy = bilerpVelocityY(x-vx,y-vy);
        }
    }
  }
  
  float clamp(float a, float min, float max){
    return Math.max(Math.min(a, max), min);

  }
  
  void computeDivergence(){
    for(int y = 1; y < N-1; y++) {
        for(int x = 1; x < N-1; x++) {
            // compute divergence using central difference     
            float x0 = getCell(x-1,y).vx;
            float x1 = getCell(x+1,y).vx;
            float y0 = getCell(x,y-1).vy;
            float y1 = getCell(x,y+1).vy;
            getCell(x,y).divergence = (x1-x0 + y1-y0)*0.5;
        }
    }
  }
  
  void fastjacobi(float alpha, float beta, int iterations){
      //for(var i = 0; i < pressureField0.length; i++) {
          //pressureField0[i] = 0.5;
          //pressureField1[i] = pressureField0[i];
      //}
      for(int y = 0; y < N-1; y++) {
        for(int x = 0; x < N-1; x++) {
            theGrid[x][y].pressure[0] = 0;
            theGrid[x][y].pressure[1] = 0;
        }
      }
      
      for(int i = 0; i < iterations; i++) {
        int swap = newPressure;
        newPressure = oldPressure;
        oldPressure = swap;
        for(int y = 1; y < N-1; y++) {
            for(int x = 1; x < N-1; x++) {
                float x0 = getCell(x-1,y).pressure[oldPressure];
                float x1 = getCell(x+1,y).pressure[oldPressure];
                float y0 = getCell(x,y-1).pressure[oldPressure];
                float y1 = getCell(x,y+1).pressure[oldPressure];
                getCell(x-1).pressure[newPressure] = (x0 + x1 + y0 + y1 + alpha * b[pi]) * beta;
            }
        }
      }
  }
  
  void subtractPressureGradient(ux, uy, p){
    for(int y = 1; y < HEIGHT-1; y++) {
        for(int x = 1; x < WIDTH-1; x++) {
            float x0 = getCell(x-1,y).pressure[newPressure];
            float x1 = getCell(x+1,y).pressure[newPressure];
            float y0 = getCell(x,y-1).pressure[newPressure];
            float y1 = getCell(x,y+1).pressure[newPressure];
            float dx = (x1-x0)/2,
            float dy = (y1-y0)/2;
            FluidCell myCell = getCell(x,y);
            myCell.vx = myCell.vx - dx;
            myCell.vy = myCell.vy - dy;
        }
    }
  }

  

}