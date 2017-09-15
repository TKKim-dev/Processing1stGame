class Bullet {  // 누구 총알인지는 상관 없고 그냥 이동 & 그래픽으로 나타내는 역할만
  PVector location, velocity;
  float bulletWidth;
  float bulletHeight;
  int weaponType;
  color bulletColor;            // 총알 색상
  boolean isActive;
  CollisionShape bulletCollisionShape;

  Bullet(PVector location, PVector velocity, int wType, color bColor) {  // 총알 생성 위치, 총알 방향 속도, 누가쏘는건지, 무기 타입
    this.location = location;
    this.velocity = velocity; 
    velocity.normalize(); 
    velocity.mult(15); // 이 부분에서 총알 속도 조절
    bulletWidth = 60;
    bulletHeight = 5;
    this.weaponType = wType;
    this.isActive = true;
    this.bulletCollisionShape = new CollisionShape('R', location, velocity, bulletWidth, bulletHeight);
    this.bulletColor = bColor; // 나중에 수정! 색은 나중에 다시 변경
  }

  void display() {
    if (isActive == true) {
      fill(bulletColor);
      pushMatrix();
      translate(location.x, location.y);
      rotate(velocity.heading());
      ellipse(0, 0, bulletWidth, bulletHeight);
      popMatrix();
    }
  }

  void update() {
    if (isActive) {
      location.add(velocity);                  // 총알의 움직임을 담당하는 부분
      bulletCollisionShape.update(location, velocity); //<>//
    } //<>//
    if (location.x < 0 || location.x > width || location.y < 0 || location.y > height) {
      deactivateBullet();
    }
  }
  
  void deactivateBullet() {
    isActive = false;
  }
}