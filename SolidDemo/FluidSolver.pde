class FluidSolver {
  FluidCell[][] theGrid = new FluidCell[N][N];
  ArrayList<FluidCell> boundaryCells = new ArrayList<FluidCell>();
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
  static final int SOLID_START_X = ((N/2) - 100);
  static final int SOLID_END_X = ((N/2) - 50);
  static final int SOLID_START_Y = ((N/2) - 20);
  static final int SOLID_END_Y = ((N/2) + 1);

  FluidSolver(){
    newPressure = 1;
    oldPressure = 0;
    newVals = 0;
    curVals = 1;
    smoke = new SmokeForces(this); 
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){        
          //theGrid[i][j] = new FluidCell(random(-5.0,5.0),random(-5.0,5.0), 1);
          if(isSolid(i,j)){
            theGrid[i][j] = new FluidCell(0.0001,0.0001, 1.0);
          }
          else{
            theGrid[i][j] = new FluidCell(random(-5.0,5.0),random(-5.0,5.0));
          }
          //theGrid[i][j] = new FluidCell(0,-0.05);
      }
    }
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){        
          //theGrid[i][j] = new FluidCell(random(-5.0,5.0),random(-5.0,5.0), 1);
          if(isBoundary(i,j)){
            theGrid[i][j].boundary = true;
            theGrid[i][j].x = i;
            theGrid[i][j].y = j;
            boundaryCells.add(theGrid[i][j]);
          }
          //theGrid[i][j] = new FluidCell(0,-0.05);
      }
    }
    
  }
  
  boolean isBoundary(int i, int j){
    FluidCell myCell = getCell(i,j);
    if(myCell.solid){ 
      return false;
    }
    if(getCell(i-1,j).solid || getCell(i + 1, j).solid || getCell(i, j - 1).solid || getCell(i, j + 1).solid){
      return true;
    }
    return false;
  }
  
  boolean isSolid(int i, int j){
    if(i > SOLID_START_X && i < SOLID_END_X && j > SOLID_START_Y && j < SOLID_END_Y){
      return true;
    }
    return false;
    
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
    advect(TIME_STEP);
    //addMouseForce();
    smoke.addSmokeForces();
    computeDivergence();
    fastJacobi(-1, 0.25, 8);
    pressureBoundary();
    subtractPressureGradient();
    int swap = newVals;
    newVals = curVals;
    curVals = swap;
  }
  
  void addMouseForce(){
    int x = (int) clamp(mouseX, 1, N-2);
    int y = (int )clamp(mouseY, 1, N-2);
    float dx = mouseX-lastMouseX;
    float dy = mouseY-lastMouseY;
    lastMouseX = mouseX;
    lastMouseY = mouseY;
    FluidCell myCell = getCell(x,y);
    myCell.vx[newVals] = myCell.vx[newVals] + dx*2;
    myCell.vy[newVals] = myCell.vy[newVals] + dy*2;
  }
  
  
  void velocityBoundary(){
    for(int x = 0; x < N; x++) {        
        theGrid[x][0].vx[curVals] = -theGrid[x][1].vx[curVals];
        theGrid[x][0].vy[curVals] = -theGrid[x][1].vy[curVals];
        
        theGrid[x][N-1].vx[curVals] = -theGrid[x][N-2].vx[curVals];
        theGrid[x][N-1].vy[curVals] = -theGrid[x][N-2].vy[curVals];
    }
    for(int y = 0; y < N; y++) {
        theGrid[0][y].vx[curVals] = -theGrid[1][y].vx[curVals];
        theGrid[0][y].vy[curVals] = -theGrid[1][y].vy[curVals];

        theGrid[N-1][y].vx[curVals] = -theGrid[N-2][y].vx[curVals];
        theGrid[N-1][y].vy[curVals] = -theGrid[N-2][y].vy[curVals];
    }
    for(FluidCell cell: boundaryCells){
      int x = cell.x;
      int y = cell.y;
      if(!getCell(x-1,y).solid){
        cell.vx[curVals] = -getCell(x-1,y).vx[curVals];
      }
      if(!getCell(x+1,y).solid){
         cell.vx[curVals] = -getCell(x+1,y).vx[curVals];
      }
      if(!getCell(x,y-1).solid){
        cell.vx[curVals] = -getCell(x,y-1).vx[curVals];
      }
      if(!getCell(x,y+1).solid){
        cell.vx[curVals] = -getCell(x,y+1).vx[curVals];
      }
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
    for(FluidCell cell: boundaryCells){
      int x = cell.x;
      int y = cell.y;
      if(!getCell(x-1,y).solid){
        cell.pressure[newPressure] = getCell(x-1,y).pressure[newPressure];
      }
      if(!getCell(x+1,y).solid){
         cell.pressure[newPressure] = getCell(x+1,y).pressure[newPressure];
      }
      if(!getCell(x,y-1).solid){
        cell.pressure[newPressure] = getCell(x,y-1).pressure[newPressure];
      }
      if(!getCell(x,y+1).solid){
        cell.pressure[newPressure] = getCell(x,y+1).pressure[newPressure];
      }
    }
  }
  
  FluidCell getCell(int x, int y){
    x = (x < 0 ? 0 : (x > N-1 ? N-1 : x))|0;
    y = (y < 0 ? 0 : (y > N-1 ? N-1 : y))|0;
    //if(debug) output.println("This is i: " + i + " and j: " + j);
    return theGrid[x][y];
  }
  

  
  float lerp(float a, float b, float c){
    c = c < 0 ? 0 : (c > 1 ? 1 : c);
    return a * (1 - c) + b * c;
  }
  
  float bilerpVelocityX(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).vx[curVals];
      float p01 = getCell(x0,y1).vx[curVals];
      float p10 = getCell(x1,y0).vx[curVals];
      float p11 = getCell(x1,y1).vx[curVals];
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  float bilerpVelocityY(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).vy[curVals];
      float p01 = getCell(x0,y1).vy[curVals];
      float p10 = getCell(x1,y0).vy[curVals];
      float p11 = getCell(x1,y1).vy[curVals];
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  float bilerpDensity(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).density[curVals];
      float p01 = getCell(x0,y1).density[curVals];
      float p10 = getCell(x1,y0).density[curVals];
      float p11 = getCell(x1,y1).density[curVals];
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  float bilerpTemp(float x, float y) {
      int x0 = floor(x);
      int y0 = floor(y);
      int x1 = x0+1;
      int y1 = y0+1;
      float p00 = getCell(x0,y0).temperature[curVals];
      float p01 = getCell(x0,y1).temperature[curVals];
      float p10 = getCell(x1,y0).temperature[curVals];
      float p11 = getCell(x1,y1).temperature[curVals];
      return lerp(lerp(p00, p10, x-x0), lerp(p01, p11, x-x0), y-y0);
  }
  
  void advect(float t){
    for(int y = 1; y < N-1; y++) {
        for(int x = 1; x < N-1; x++) {
            FluidCell myCell = getCell(x,y);
            if(myCell.solid || myCell.boundary) continue;
            float vx = myCell.vx[curVals]*t;
            float vy = myCell.vy[curVals]*t;
            
            //this might need to be a x +vx instead of x-vx
            myCell.vx[newVals] = bilerpVelocityX(x-vx,y-vy);
            myCell.vy[newVals] = bilerpVelocityY(x-vx,y-vy);
            
            myCell.density[newVals] = bilerpDensity(x-vx,y-vy);
            myCell.temperature[newVals] = bilerpTemp(x-vx,y-vy);
        }
    }
  }
  
  float clamp(float a, float min, float max){
    return Math.max(Math.min(a, max), min);

  }
  
  void computeDivergence(){
    for(int y = 1; y < N-1; y++) {
        for(int x = 1; x < N-1; x++) {
            FluidCell myCell = getCell(x,y);
            if(myCell.solid || myCell.boundary) continue;    
            float x0 = getCell(x-1,y).vx[newVals];
            float x1 = getCell(x+1,y).vx[newVals];
            float y0 = getCell(x,y-1).vy[newVals];
            float y1 = getCell(x,y+1).vy[newVals];
            myCell.divergence = (x1-x0 + y1-y0)*0.5;
        }
    }
  }
  
  void fastJacobi(float alpha, float beta, int iterations){
      for(int y = 0; y < N; y++) {
        for(int x = 0; x < N; x++) {
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
                FluidCell myCell = getCell(x,y);
                if(myCell.solid || myCell.boundary) continue;
                float x0 = getCell(x-1,y).pressure[oldPressure];
                float x1 = getCell(x+1,y).pressure[oldPressure];
                float y0 = getCell(x,y-1).pressure[oldPressure];
                float y1 = getCell(x,y+1).pressure[oldPressure];
                myCell.pressure[newPressure] = (x0 + x1 + y0 + y1 + alpha * theGrid[x][y].divergence) * beta;
            }
        }
      }
  }
  
  void subtractPressureGradient(){
    for(int y = 1; y < N - 1; y++) {
        for(int x = 1; x < N - 1; x++) {
            FluidCell myCell = getCell(x,y);
            if(myCell.solid || myCell.boundary) continue;
            float x0 = getCell(x-1,y).pressure[newPressure];
            float x1 = getCell(x+1,y).pressure[newPressure];
            float y0 = getCell(x,y-1).pressure[newPressure];
            float y1 = getCell(x,y+1).pressure[newPressure];
            float dx = (x1-x0)/2;
            float dy = (y1-y0)/2;
            myCell.vx[newVals] = myCell.vx[newVals] - dx;
            myCell.vy[newVals] = myCell.vy[newVals] - dy;
        }
    }
  }

  

}