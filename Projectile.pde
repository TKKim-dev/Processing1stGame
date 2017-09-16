class Projectile { // 이건 총알 뿐만이 아니라 각종 투사체를 모두 관리하는 클래스. //<>// //<>//
  PVector location, velocity;
  float projectileWidth;
  float projectileHeight;
  color projectileColor;
  boolean isActive;
  CollisionShape projectileCollisionShape;

  Projectile(PVector location, PVector velocity, color pColor, float projectileWidth, float projectileHeight, float projectileSpeed) {  // 총알 생성 위치, 총알 방향 속도, 누가쏘는건지, 무기 타입
    this.location = /*location;*/new PVector(location.x, location.y);   
    this.velocity = /*velocity;*/new PVector(velocity.x, velocity.y);
    this.velocity.normalize(); 
    this.velocity.mult(projectileSpeed); // 이 부분에서 총알 속도 조절
    this.projectileWidth = projectileWidth;
    this.projectileHeight = projectileHeight;
    this.isActive = true;
    this.projectileCollisionShape = new CollisionShape('C', location, velocity, projectileWidth, projectileHeight);
    this.projectileColor = pColor; // 나중에 수정! 색은 나중에 다시 변경
  }

  void display() {
    if (isActive == true) {
      fill(projectileColor);
      pushMatrix();
      translate(location.x, location.y);
      rotate(velocity.heading());
      ellipse(0, 0, projectileWidth, projectileHeight);
      popMatrix();
    }
  }

  void update() {
    if (isActive) {
      location.add(velocity);                  // 총알의 움직임을 담당하는 부분
      projectileCollisionShape.update(location, velocity);
    }
    if (location.x < 0 || location.x > width || location.y < 0 || location.y > height) {
      deactivate();
    }
  }
  
  void deactivate() {
    isActive = false;
  }
}