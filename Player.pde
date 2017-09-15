class Player {
  int playerNum; // 몇번째 플레이어 인지!
  PVector location, velocity, pVelocity; // 좌표, 그리고 이동에 관련된 벡터들
  float moveSpeed; // 플레이어의 이동 속도, movSpeed=x은 플레이어가 x pixels per frame 의 속도로 이동함을 뜻함
  float fireSpeed; // 플레이어의 발사 속도. 나중에 공격 속도를 올릴 때는 이 변수를 바꾸면 된다.
  float radius; // 플레이어 개체의 크기
  float distanceLeft; // 이동 시에 사용되는 변수. 이동이 얼마나 남았는지.
  float CCFrameCount; // CC가 얼마나 지속되는지, =0 일 때 CC 끝
  //int[] playerStatus=new int[2]; // [플레이어의 체력] [걸린 CC기 개수] [?] [?]
  int[] CCStatus=new int[6]; // 우선 최대 6개까지 동시에 CC기가 걸릴 수 있다고 가정. 각각의 값은 CC번호를 가진다.
  ArrayList<Bullet> bulletList = new ArrayList<Bullet>(); // 각 bullet 은 플레이어가 관리한다.
  ArrayList<CollisionShape> playerCollisionList = new ArrayList<CollisionShape>();
  ArrayList<CollisionShape> bulletCollisionList = new ArrayList<CollisionShape>();
  PVector bulletLocation, bulletVelocity; // 플레이어가 지정한 공격 위치, 총알이 나가는 방향
  float weaponCooltime; // 다시 발사 가능할때까지 걸리는 시간
  int weaponType;
  CollisionShape collisionShape;
  Table CCtable = loadTable("CCtable.csv"); // ※아직 구현 안됨※ 미리 정해진 CC 테이블 [CC상태][이동 속도][지속시간(ccframecount)] ex) [0][0] [0][1] [0][2] 순서대로
  Table WPtable = loadTable("WPtable.csv"); // ※아직 구현 안됨※ [무기 타입] [총알 속도] [무기 쿨타임] [무기 데미지] 

  Player(int playerNum, float x, float y) {
    this.playerNum=playerNum; // 몇번째 플레이어인지 미리 input
    moveSpeed=2;
    fireSpeed=2;
    radius=30;
    location=new PVector(x, y);
    velocity=new PVector(3, 3);
    pVelocity=new PVector(0, 0);
    CCFrameCount=0;
    weaponCooltime=0;
    /*playerCollisionList.add(*/collisionShape = new CollisionShape('R', location, velocity, radius, radius)/*)*/;  // 플레이어의 모양인 네모,
  }

  void run() {
    mouseEvent();
    display();
    move();
    updateCount();
    manageBullets();
  }
  
  void mouseEvent() { // 마우스 이벤트는 메시지 전달만. CC 체크는 X
    if (mousePressed) {  
      if (mouseButton == RIGHT) {
        velocity=new PVector(mouseX, mouseY);
        pVelocity.set(velocity);            // b.set(a): b 벡터를 a 벡터와 같은 내용으로 초기화
        velocity.sub(location);            // sub(): 벡터의 빼기 연산. 원래의 velocity 벡터는 단순히 mouseX,mouseY 만을 가지므로, 처음 위치에서 빼줄 필요가 있음
        distanceLeft = velocity.mag();      // mag(): 벡터의 크기를 구하는 연산(즉 총 이동 거리를 구함)
        velocity.normalize();               // normalize 는 해당 벡터의 크기를 1로 만드는 효과임. 즉 (cosθ,sinθ)가 되어 자동으로 방향을 나타내게 됨
      }
      if (mouseButton == LEFT) {
        if (isAbleTo('f') == true) {
          bulletLocation=new PVector(location.x, location.y);
          bulletVelocity=new PVector(mouseX-location.x, mouseY-location.y);
          fireEvent(1); // 일반적인 공격(공격 가능 상태에서 클릭을 통해 공격), 0 일때 공격제한, 혹은 여러 갈래로 발사하거나, 난사 스킬처럼 쏘는 경우 또 다른 숫자 넣어두기.
        }
      }
    }
  }
  
  void fireEvent(int type) { // 파이어 이벤트는 발사 방향 & 플레이어 타입, 웨폰타입 전달
    switch(type) {
    case 0:
      break;
    case 1:
      Bullet temp = new Bullet(bulletLocation, bulletVelocity, weaponType, color(0,0,255));
      bulletList.add(temp);
      bulletCollisionList.add(new CollisionShape('R', bulletLocation, bulletVelocity, temp.bulletWidth, temp.bulletHeight));
      weaponCooltime = 20;  //  무기 쿨타임
      break;
    }
  }
  
  void display() {
    noStroke();
    fill(0);
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading());
    rect(0, 0, radius, radius);
    popMatrix();
    if (isMoving()) {
      strokeWeight(2);
      stroke(30, 100, 255, 80);
      line(location.x, location.y, pVelocity.x, pVelocity.y);
    }
  }

  void move() {                               //플레이어의 다양한 정보 업데이트. 체력 상태, CC상태 등등
    if (isAbleTo('m')==true && distanceLeft>0) {
      location.add(velocity.x*moveSpeed, velocity.y*moveSpeed);
    }
  }

  void updateCount() { // 무기 쿨타임, 스킬 쿨타임 등을 집중적으로 관리하는 함수
    if (weaponCooltime > 0) { // 얘는 발사 가능 여부랑 상관없이 줄어들어야 함!
      weaponCooltime -= fireSpeed;
    }
    if (isMoving()) {
      distanceLeft -= moveSpeed;
    }
    //skill_cooltime[] -= ?  나중에 스킬 관련 쿨타임 감소도 구현하기
  }

  void manageBullets() {  // CollisionShape 업데이트
    for(int i=0; i<bulletList.size(); i++) {
      bulletCollisionList.get(i).update(bulletList.get(i).location, bulletList.get(i).velocity);
    }
    for(int i=0; i<bulletList.size(); i++) {  // 총알 삭제 파트
      if(!bulletList.get(i).isActive) {
        bulletList.remove(i);
        bulletCollisionList.remove(i);
      }
    }
  }

  boolean isAbleTo(char type) { // 어떤 행동이 가능한지를 검사하는 함수: m(ove) f(ire) s(kill) true 리턴시에 가능, false 일 경우 행동 제한
    switch(type) {
    case 'm':  // 이동 가능 여부 판단해주는 파트
      for (int num : CCStatus) {  // CC상태를 검사해서 10 이상인 것이 하나라도 있다면 '이동 못함: false' 리턴
        if (num >= 10) {
          return false;
        }
      }
      return true;
    case 'f':  // 발사 가능 여부 판단해주는 파트
      for (int num : CCStatus) {  // CC상태를 검사해서 10 이상인 것이 하나라도 있다면 '공격 못함: false' 리턴
        if (num >= 10) {
          return false;
        }
      }
      if (weaponCooltime <= 0 && isSkillActive()==false) {
        return true;
      }
      break;
    case 's':
      break;
    }
    return false;
  }

  boolean isMoving() {
    if (isAbleTo('m') && distanceLeft>0.2) { // 움직일 수 있고 움직일 거리가 남았다면 움직이는 것으로 가정. 나중에 프레임 카운트 대신 거리 개념으로~!
      return true;
    }
    distanceLeft=0;
    return false;
  }

  boolean isSkillActive() { // 액티브 스킬 사용 시, 혹은 사용 중에 클릭으로 기본 공격이 나가면 안되니까~~
    if (true) {
      return false;
    }
    return true; // 스킬 사용 시에 여기에 조건 추가하기.
  }
}


//  ※구현되지 않은 것들※ 
//   [완료] 중간에 movSpeed 가 바뀌는 경우에 어떻게 대처할 것인가? 어짜피 거리는 일정하니까 속도 x 시간 으로 계산하는건 어떨까?
//   ※ 플레이어의 에임을 돕기 위해 일정 범위 안에 들어온 대상은 에임보조선 표시.
//   ※ CC스테이터스만 바꿔주는 함수 만들기. CCframecount로 얼마나 지속시간이 남았는지를 계산하고 그게 끝나면 다시 정상으로! 정상으로 돌릴 때 앞으로 정렬하기.
//   ※ 만약 CC기가 여러개가 걸린다면???? 어떻게 하지 이때는? 배열 선언으로 해야할듯..
//   ※ CC기 판정 시에 CCstatus에 해당 CC기 번호를 넣고, 그 번호에 framecount[] 도 할당하고, playerStatus[1] 에 1증가.
//   [완료] 플레이어의 총알이 화면 밖으로 나가거나 피격 판정 등으로 isActive == false 가 되면 메모리에서 제거. println 으로 확인가능