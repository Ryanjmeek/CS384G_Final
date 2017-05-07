class Grid {
  Cell[][] theGrid = new Cell[N][N];
  
  Grid(){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        theGrid[i][j] = new Cell(0.0, new PVector(0,-1), 23.0, 0.0, false);
      }
    }
    
    theGrid[N/2][N/2] = new Cell(0.0, new PVector(0,-1), 23.0, 1.0, true);
    
  }
  
  Cell getCell(int i, int j){
    return theGrid[i][j];
  }
  
  void advect(){
    for (int i = 0; i < N; i++){
      for (int j = 0; j < N; j++){
        
      }
    }
  }
}