class CollisionShape {  // 하나의 Collision 영역만을 다루는 클래스. 해당 영역이 누구건지, 어떤 모양인지, 어딜 향하고 있는지만 다룬다.
  char shapeType;   // 어떤 모양인지 Ex) 'C' 이면 원, 'R' 이면 사각형.
  PVector location, direction, verticalVector;  // 히트박스의 위치 어디를 향하고 있는지
  float shapeWidth, shapeHeight;  // 히트박스
  
  CollisionShape(char shapeType, PVector location, PVector direction, float shapeWidth, float shapeHeight) {
    this.shapeType = shapeType;
    this.location = location;
    this.shapeWidth = shapeWidth;
    this.shapeHeight = shapeHeight;
    this.direction = new PVector(direction.x ,direction.y);
    this.direction.normalize();
    verticalVector = new PVector(this.direction.x ,this.direction.y);
    verticalVector.rotate(HALF_PI);
  }
  
  void update(PVector updatedLocation, PVector updatedDirection) {
    location.set(updatedLocation);
    direction.set(updatedDirection);
    direction.normalize();
    verticalVector.set(direction.x, direction.y);
    verticalVector.rotate(HALF_PI);
  }
}