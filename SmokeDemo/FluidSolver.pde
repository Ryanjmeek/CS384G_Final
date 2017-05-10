class FluidSolver {
  FluidCell[][] theGrid = new FluidCell[N][N];
  
  FluidSolver(){
    //TODO
    
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new FluidCell(random(-5.0,5.0),random(-5.0,5.0));
      }
    }
    
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
  
  function fastjacobi(p0, p1, b, alpha, beta, iterations){
      p0 = p0.a;
      p1 = p1.a;
      b = b.a;
      //for(var i = 0; i < pressureField0.length; i++) {
          //pressureField0[i] = 0.5;
          //pressureField1[i] = pressureField0[i];
      //}
  
      for(i = 0; i < iterations; i++) {
          for(var y = 1; y < N-1; y++) {
              for(var x = 1; x < N-1; x++) {
                  int pi = x+y*WIDTH,
                  float x0 = p0[pi-1],
                      x1 = p0[pi+1],
                      y0 = p0[pi-WIDTH],
                      y1 = p0[pi+WIDTH];
                  p1[pi] = (x0 + x1 + y0 + y1 + alpha * b[pi]) * beta;
              }
          }
          var aux = p0;
          p0 = p1;
          p1 = aux;
          //pressureboundary(p0);
      }
  }
  

}