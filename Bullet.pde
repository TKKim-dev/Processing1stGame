class Bullet {
  PVector location, velocity;
  int radius;
  int weaponType;
  int bulletType;           // 어느 플레이어의 총알인지
  color bColor;            // 총알 색상
  boolean isActive;

  Bullet(PVector loc, PVector vel, int bType, int wType) {  // 총알 생성 위치, 총알 방향 속도, 누가쏘는건지, 무기 타입
    this.location=new PVector(loc.x, loc.y);
    this.velocity=new PVector(vel.x, vel.y); 
    velocity.normalize(); 
    velocity.mult(25); // 이 부분에서 총알 속도 조절
    this.weaponType = wType;
    this.bulletType = bType;
    this.isActive = true;
    bColor=color(0, 0, 200); // 나중에 수정! 색은 나중에 다시 변경
    radius=5; // 나중에 반지름은 웨폰 타입 맞춰서 다시 설정~!
  }

  void display() {
    if (isActive == true) {
      fill(bColor);
      pushMatrix();
      translate(location.x, location.y);
      rotate(velocity.heading());
      ellipse(0, 0, radius*12, radius);
      popMatrix();
    }
  }

  void update() {
    if (isActive) {
      location.add(velocity);                  // 총알의 움직임을 담당하는 부분
    }
  }

  void deactivate() {
    this.isActive = false;
  }
}