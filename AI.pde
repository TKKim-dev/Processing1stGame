class AI {
  float HP; // AI의 체력
  float movSpeed; // 플레이어의 이동 속도, movSpeed=x은 플레이어가 x pixels per frame 의 속도로 이동함을 뜻함
  float fireSpeed; // 플레이어의 발사 속도. 나중에 공격 속도를 올릴 때는 이 변수를 바꾸면 된다.
  float radius; // 플레이어 개체의 크기
  float movDistance; // 이동 시에 사용되는 변수. 이동이 얼마나 남았는지.
  float randTimer;
  float randProjectileTimer;
  ArrayList<CollisionShape> collisionList = new ArrayList<CollisionShape>();
  PVector location = new PVector(random(0, width), random(0, height));
  PVector velocity = new PVector(3, 3);
  PVector pvelocity = new PVector(0, 0);
  ArrayList<Projectile> projectileList = new ArrayList<Projectile>();
  ArrayList<CollisionShape> projectileCollisionList = new ArrayList<CollisionShape>();  // AI의 총알 충돌 영역
  PVector projectileLocation, projectileVelocity; // AI가 플레이어에게 총알을 발사함
  CollisionShape collisionShape;
  boolean hitEvent;
  boolean isActive;
  
  AI() {
    HP = 100;
    location.set(random(mapWidth - 200, mapWidth), random(mapHeight - 200, mapHeight));
    movSpeed = 2;
    radius = 45;
    randTimer = 0;
    randProjectileTimer = 0;
    collisionShape = new CollisionShape('R', location, velocity, radius, radius);
    collisionList.add(collisionShape);
    isActive = true;
  }

  void display() {
    noStroke();
    fill(0);
    if(hitEvent) {
      fill(255,0,0);
      setHitEvent(false);
    }
    pushMatrix();
    translate(location.x, location.y);
    //rotate(velocity.heading());
    //rect(0, 0, radius, radius);
    shape(AIShape,0,0);
    popMatrix();
    stroke(225, 111, 0, 100);
    line(location.x, location.y, pvelocity.x, pvelocity.y);
    text(int(HP), location.x - 10, location.y - 30);
  }
  
  void randomize() {
    if (randTimer == 0) {
      velocity=new PVector(random(0, mapWidth), random(0, mapHeight));
      pvelocity.set(velocity);            // b.set(a): b 벡터를 a 벡터와 같은 내용으로 초기화
      velocity.sub(location);            // sub(): 벡터의 빼기 연산. 원래의 velocity 벡터는 단순히 mouseX,mouseY 만을 가지므로, 처음 위치에서 빼줄 필요가 있음
      movDistance = velocity.mag();      // mag(): 벡터의 크기를 구하는 연산(즉 총 이동 거리를 구함)
      velocity.normalize();               // normalize 는 해당 벡터의 크기를 1로 만드는 효과임. 즉 (cosθ,sinθ)가 되어 자동으로 방향을 나타내게 됨
      randTimer = 240;
    }
  }

  void update() { 
    if (movDistance > 0.2) {
      location.add(velocity.x*movSpeed, velocity.y*movSpeed);
      for(CollisionShape temp : collisionList) {
        temp.update(location, velocity);
      }
      movDistance -= movSpeed;
    }
    if(randProjectileTimer < 0) {
      projectileLocation = new PVector(location.x, location.y);
      projectileVelocity = new PVector(p1.location.x - location.x, p1.location.y - location.y);
      Projectile temp = new Projectile(projectileLocation, projectileVelocity, AIAttack, 40, 40, 5);
      projectileList.add(temp);
      projectileCollisionList.add(new CollisionShape('C', projectileLocation, projectileVelocity, temp.projectileWidth, temp.projectileHeight));
      randProjectileTimer=150;
    }
    randTimer--;
    randProjectileTimer--;

    for(int i=0; i<projectileList.size(); i++) {  // 총알 삭제 파트
      if(!projectileList.get(i).isActive) {
        projectileList.remove(i);
        projectileCollisionList.remove(i);
      }
    }
    if(HP <= 0) {
      isActive = false;
    }
  }

  void run() {
    display();
    randomize();
    update();
  }
  
  void setHitEvent(boolean hitEvent) {
    this.hitEvent = hitEvent;
    HP -= 7.5;
  }
}