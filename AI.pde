class AI{
  PVector location, velocity, pvelocity; // 좌표, 그리고 이동에 관련된 벡터들
  float movSpeed; // 플레이어의 이동 속도, movSpeed=x은 플레이어가 x pixels per frame 의 속도로 이동함을 뜻함
  float fireSpeed; // 플레이어의 발사 속도. 나중에 공격 속도를 올릴 때는 이 변수를 바꾸면 된다.
  float radius; // 플레이어 개체의 크기
  float movDistance; // 이동 시에 사용되는 변수. 이동이 얼마나 남았는지.
  float HP; // AI의 체력
  float rand_timer;
  //PVector bLoc, bVel; // 플레이어가 지정한 공격 위치, 총알이 나가는 방향
  
  
  AI(){
    this.movSpeed = 2;
    this.radius=30;
    this.location=new PVector(random(0,width),random(0,height));
    this.velocity=new PVector(0,0);
    this.pvelocity=new PVector(0,0);
    this.rand_timer=0;
  }
  
  void display() {
    noStroke();
    fill(0);
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading());
    rect(0,0,radius,radius);
    popMatrix();
    stroke(225,111,0,80);
    line(location.x , location.y , pvelocity.x , pvelocity.y);  
  }
  void randomize() {
    if(rand_timer == 0) {
      velocity=new PVector(random(0,width),random(0,height));
      pvelocity.set(velocity);            // b.set(a): b 벡터를 a 벡터와 같은 내용으로 초기화
      velocity.sub(location);            // sub(): 벡터의 빼기 연산. 원래의 velocity 벡터는 단순히 mouseX,mouseY 만을 가지므로, 처음 위치에서 빼줄 필요가 있음
      movDistance = velocity.mag();      // mag(): 벡터의 크기를 구하는 연산(즉 총 이동 거리를 구함)
      velocity.normalize();               // normalize 는 해당 벡터의 크기를 1로 만드는 효과임. 즉 (cosθ,sinθ)가 되어 자동으로 방향을 나타내게 됨
      rand_timer = 240;
    }
  }
  
  void update_AI() {                               // AI의 
    if(movDistance > 0.2) {
      location.add(velocity.x*movSpeed, velocity.y*movSpeed);
      movDistance -= movSpeed;
    }
    rand_timer--;
  }
  
  void run() {
        display();
        randomize();
        update_AI();
  }
}