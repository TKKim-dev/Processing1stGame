class Bullet {
  PVector bLoc,bVel;
  int radius;
  int type_weapon;
  int type_bullet;           // 어느 플레이어의 총알인지
  color b_color;            // 총알 색상
  boolean isActive;
    
  Bullet(PVector Loc, PVector Vel, int Btype,int Wtype){  // 총알 생성 위치, 총알 방향 속도, 누가쏘는건지, 무기 타입
    this.bLoc=new PVector(Loc.x, Loc.y);
    this.bVel=new PVector(Vel.x, Vel.y); 
    bVel.normalize(); 
    bVel.mult(25); // 이 부분에서 총알 속도 조절
    this.type_weapon = Wtype;
    this.type_bullet = Btype;
    this.isActive = true;
    b_color=color(0,0,200); // 나중에 수정! 색은 나중에 다시 변경
    radius=5; // 나중에 반지름은 웨폰 타입 맞춰서 다시 설정~!
  }
  
  void display() {
    if(isActive == true) {
      fill(b_color);
      pushMatrix();
      translate(bLoc.x, bLoc.y);
      rotate(bVel.heading());
      ellipse(0, 0, radius*12, radius);
      popMatrix();
      
    }
  }
  
  void update() {
    if(isActive == true) {
      bLoc.add(bVel);                  // 총알의 움직임을 담당하는 부분
    }    
  }
  
  void deactivate() {
    this.isActive = false;
  }
}