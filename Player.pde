//  ※구현되지 않은 것들※ 
//   ※ 중간에 movSpeed 가 바뀌는 경우에 어떻게 대처할 것인가? 어짜피 거리는 일정하니까 속도 x 시간 으로 계산하는건 어떨까?
//   ※ 플레이어의 에임을 돕기 위해 일정 범위 안에 들어온 대상은 에임보조선 표시.


class Player {
  int playernum; // 몇번째 플레이어 인지!
  PVector location, velocity, pvelocity; // 좌표, 그리고 이동에 관련된 벡터들
  float movSpeed; // 플레이어의 이동 속도, movSpeed=x은 플레이어가 x pixels per frame 의 속도로 이동함을 뜻함
  float radius; // 플레이어 개체의 크기
  float movframecount; // 이동 시에 사용되는 변수. 이동이 얼마나 남았는지.
  float CCframecount; // CC가 얼마나 지속되는지, =0 일 때 CC 끝
  //boolean[] playerStatus=new boolean[3]; // 플레이어의 [이동 가능 여부]  [공격 가능 여부]  [스킬 사용 가능 여부] 
  PVector bLoc, bVel; // 플레이어가 지정한 공격 위치, 총알이 나가는 방향
  float weapon_cooltime; // 다시 발사 가능할때까지 걸리는 시간
  int weapon_type;
  Table CCtable = loadTable("CCtable.csv"); // ※아직 구현 안됨※ 미리 정해진 CC 테이블 [CC상태][이동 속도][지속시간(ccframecount)] ex) [0][0] [0][1] [0][2] 순서대로
  Table WPtable = loadTable("WPtable.csv"); // ※아직 구현 안됨※ [무기 타입] [총알 속도] [무기 쿨타임] [무기 데미지] 
  
  
  Player(int pNum,float x,float y){
    this.playernum=pNum; // 몇번째 플레이어인지 미리 input
    this.movSpeed=3;
    this.radius=30;
    this.location=new PVector(x,y);
    this.velocity=new PVector(0,0);
    this.pvelocity=new PVector(0,0);
    this.CCframecount=0;
    //this.isMovActivated=false;
    this.weapon_cooltime=0;
  }
  
  void display() {
    noStroke();
    fill(0);
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading());
    rect(0,0,radius,radius);
    popMatrix();
    
    stroke(30,144,255,80);
    line(location.x , location.y , pvelocity.x , pvelocity.y);  
  }
  
  void movPlayer() { // 무브 플레이어는 움직일 좌표만 찍어줌. 그래야 나중에 비정상 이동도 다룰 수 있음.  CC체크는? 
  // 여기서 CC 체크 해서 움직임 가능한지, 어떻게 움직일건지, 이동 속도는 어떤지 결정해야함
  }
  
  void update_player() { //플레이어의 다양한 정보 업데이트.
    if(isAbleTo('m')==true && movframecount>0) {
      location.add(velocity.x*movSpeed,velocity.y*movSpeed);
    }
  }
  
  void update_count() { // 무기 쿨타임, 스킬 쿨타임 등을 집중적으로 관리하는 함수
    if(weapon_cooltime > 0) {
      weapon_cooltime--;
    }
    if(isMoving() == true) {
      movframecount-=1;
    }
  }
    
  void run() {
        mouseEvent();
        //movPlayer();
        display();
        update_player();
        update_count();
  }
  
  void mouseEvent() { // 마우스 이벤트는 메시지 전달만. CC 체크는 X
    if (mousePressed == true) {  
      if(mouseButton == RIGHT) {
        velocity=new PVector(mouseX,mouseY);
        pvelocity.set(velocity);            // b.set(a): b 벡터를 a 벡터와 같은 내용으로 초기화
        velocity.sub(location);            // sub(): 벡터의 빼기 연산. 원래의 velocity 벡터는 단순히 mouseX,mouseY 만을 가지므로, 처음 위치에서 빼줄 필요가 있음
        movframecount=velocity.mag() / movSpeed;      // mag(): 벡터의 크기를 구하는 연산(즉 총 이동 거리를 구함)
        velocity.normalize();               // normalize 는 해당 벡터의 크기를 1로 만드는 효과임. 즉 (cosθ,sinθ)가 되어 자동으로 방향을 나타내게 됨
       }
      if(mouseButton == LEFT) {
        if(weapon_cooltime <= 0) {
          bLoc=new PVector(location.x, location.y);
          bVel=new PVector(mouseX-location.x, mouseY-location.y);
          fireEvent(1); // 일반적인 공격(공격 가능 상태에서 클릭을 통해 공격), 0 일때 공격제한, 혹은 여러 갈래로 발사하거나, 난사 스킬처럼 쏘는 경우 또 다른 숫자 넣어두기.
        }
      
      }
    }   
  }
  
  void fireEvent(int type) { // 파이어 이벤트는 발사 방향 & 플레이어 타입, 웨폰타입 전달
    switch(type){
      case 0:
        break;
      case 1:
        Bullet temp = new Bullet(bLoc, bVel, playernum, weapon_type);
        bullets.add(temp);
        weapon_cooltime = 30; // 나중에 웨폰 테이블에 다 저장해놓기. -> 공격속도 증가는 어떻게 구현하지?
        break;
    }
  }
  
  boolean isAbleTo(char type) { // 어떤 행동이 가능한지를 검사하는 함수: m(ove) f(ire) s(kill) true 리턴시에 가능, false 일 경우 행동 제한
    switch(type) {
      case 'm':
      if(CCframecount==0) {
        return true;
      }
      break;
    }
    return false;
  }
  
  boolean isMoving() {
    if(isAbleTo('m')==true && movframecount>0.2) { // 움직일 수 있고 움직일 거리가 남았다면 움직이는 것으로 가정. 나중에 프레임 카운트 대신 거리 개념으로~!
      return true;
    }
    movframecount=0;
    return false;
  }
}