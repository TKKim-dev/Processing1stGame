class Button {
  PVector location = new PVector(0, 0);
  float pressedLoc, releasedLoc;
  float bWidth, bHeight;
  boolean isPushed;
  PShape bShape;
  
  Button(float locationX, float locationY, float bWidth, float bHeight, PShape shape) {
    location.set(locationX, locationY);
    this.bWidth = bWidth;
    this.bHeight = bHeight;
    isPushed = false;
    bShape = shape;
  }
  
  void display() {
    shape(bShape, location.x, location.y);
  }
  
  void mousePressed() {
    if(worldCamera.pos.x + mouseX > location.x - bWidth / 2 && worldCamera.pos.x + mouseX < location.x + bWidth / 2 && worldCamera.pos.y + mouseY > location.y - bHeight / 2 && worldCamera.pos.y + mouseY < location.y + bHeight / 2) isPushed = true;  //<>// //<>//
  }
}