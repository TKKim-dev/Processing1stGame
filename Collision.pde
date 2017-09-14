class Collision { // 해당 개체(플레이어, 스킬, 기본 공격, 각종 아이템)의 전체 Collision 영역을 관리하는 클래스. 콜리젼 영역 할당, 제거, 실질적인 충돌 검사까지 모두.
  
  ArrayList<CollisionShape> collisions = new ArrayList<CollisionShape>();
  Collision() {
    CollisionShape temp = new CollisionShape();
    collisions.add(temp);
  }
}



class CollisionShape {  // 하나의 Collision 영역만을 다루는 클래스. 해당 영역이 누구건지, 어떤 모양인지, 어딜 향하고 있는지만 다룬다.
  int playerNum;  // 누구의 히트박스인지
  char ShapeNum;   // 어떤 모양인지 Ex) 'C' 이면 원, 'R' 이면 사각형.
  PVector Location, Direction;  // 히트박스가 어디를 향하고 있는지
  float Width, Height;  // 히트박스
  CollisionShape(int playerNum, char ShapeNum, PVector Location, PVector Direction, float Width, float Height) {
    this.playerNum = playerNum;
    this.ShapeNum = ShapeNum;
    this.Location = new PVector(Location.x, Location.y);
    this.Direction = new PVector(Direction.x, Direction.y);
    this.Width = Width;
    this.Height = Height;
  }
}