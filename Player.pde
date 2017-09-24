class Player {
  float HP;
  PVector location, velocity, pVelocity; // 좌표, 그리고 이동에 관련된 벡터들
  float newMouseX, newMouseY;
  float moveSpeed; // 플레이어의 이동 속도, movSpeed=x은 플레이어가 x pixels per frame 의 속도로 이동함을 뜻함
  float fireSpeed; // 플레이어의 발사 속도. 나중에 공격 속도를 올릴 때는 이 변수를 바꾸면 된다.
  float radius; // 플레이어 개체의 크기
  float distanceLeft; // 이동 시에 사용되는 변수. 이동이 얼마나 남았는지.
  int[] CCStatus=new int[6]; // 우선 최대 6개까지 동시에 CC기가 걸릴 수 있다고 가정. 각각의 값은 CC번호를 가진다.
  int[] CCFrameCount = new int[6]; // CC가 얼마나 지속되는지, =0 일 때 CC 끝
  ArrayList<Projectile> projectileList = new ArrayList<Projectile>(); // 각 projectile 은 플레이어가 관리한다.
  //ArrayList<CollisionShape> playerCollisionList = new ArrayList<CollisionShape>();
  ArrayList<CollisionShape> projectileCollisionList = new ArrayList<CollisionShape>();
  PVector projectileLocation, projectileVelocity, skillDirection; // 플레이어가 지정한 공격 위치, 총알이 나가는 방향
  float weaponCooltime; // 다시 발사 가능할때까지 걸리는 시간
  CollisionShape collisionShape;
  //Table CCtable = loadTable("CCtable.csv"); // ※아직 구현 안됨※ 미리 정해진 CC 테이블 [CC상태][이동 속도][지속시간(ccframecount)] ex) [0][0] [0][1] [0][2] 순서대로
  //Table WPtable = loadTable("WPtable.csv"); // ※아직 구현 안됨※ [무기 타입] [총알 속도] [무기 쿨타임] [무기 데미지]
  boolean hitEvent;
  boolean isAbleToMove, isAbleToFire, isAbleToSkill;
  boolean disableMove, disableFire, disableSkill;
  

  Player(float x, float y) {
    HP = 100;
    moveSpeed = DEFAULT_MOVESPEED;
    fireSpeed = DEFAULT_FIRESPEED;
    radius = 45;
    location = new PVector(x, y);
    velocity = new PVector(1, 1);
    pVelocity = new PVector(0, 0);
    skillDirection = new PVector(0, 0);
    weaponCooltime = 0;
    isAbleToMove = true;
    isAbleToFire = true;
    isAbleToSkill = true;
    collisionShape = new CollisionShape('R', location, velocity, radius, radius);  // 플레이어의 모양인 네모,
    hitEvent = false;
    for(int i=0; i < 6; i++) CCFrameCount[i] = 0; 
  }

  void run() {
    display();
    update();
    updateCount();
    manageProjectiles();
  }
  
  void display() {
    noStroke();
    fill(0);
    pushMatrix();
    translate(location.x, location.y);
    //rotate(velocity.heading());
    //rect(0, 0, radius, radius);
    shape(p1Shape, 0, 0);
    popMatrix();
    if (distanceLeft > 0.1) {
      strokeWeight(2);
      stroke(30, 100, 255, 80);
      if(!isAbleToMove) {
        stroke(225, 155, 0, 80);
      }
      line(location.x, location.y, pVelocity.x, pVelocity.y);
    }
    for(Skill temp : skillList) {
      if(temp.isActiveOnReady) {
        skillDirection.set(worldCamera.pos.x + mouseX - location.x, worldCamera.pos.y + mouseY - location.y);
        pushMatrix();
        translate(location.x, location.y);
        rotate(skillDirection.heading());
        shape(temp.shapeOnReady, 0, 0);
        popMatrix();
      }
    }
  }

  void move(float destinationX,float destinationY) { 
    velocity = new PVector(destinationX, destinationY);
    pVelocity.set(velocity);            // b.set(a): b 벡터를 a 벡터와 같은 내용으로 초기화
    velocity.sub(location);            // sub(): 벡터의 빼기 연산. 원래의 velocity 벡터는 단순히 mouseX,mouseY 만을 가지므로, 처음 위치에서 빼줄 필요가 있음
    distanceLeft = velocity.mag();      // mag(): 벡터의 크기를 구하는 연산(즉 총 이동 거리를 구함)
    velocity.normalize();               // normalize 는 해당 벡터의 크기를 1로 만드는 효과임. 즉 (cosθ,sinθ)가 되어 자동으로 방향을 나타내게 됨
  }
  void move(float directionX, float directionY, float distance) { // 비자발적 움직임의 경우
    if(!isAbleToMove) return;
    location.add(directionX * distance, directionY * distance);
  }
  
  void fireEvent() { // 기본 공격 발사. 자동으로 마우스 포지션을 지정하게 됨. //<>// //<>//
    if(!isAbleToFire) return;
    projectileLocation=new PVector(location.x, location.y);
    projectileVelocity=new PVector(newMouseX - location.x, newMouseY - location.y);   
    Projectile temp = new Projectile(projectileLocation, projectileVelocity, p1Attack, 60, 16, 35);
    projectileList.add(temp);
    projectileCollisionList.add(new CollisionShape('R', projectileLocation, projectileVelocity, temp.projectileWidth, temp.projectileHeight));
    weaponCooltime = 70;  //  무기 쿨타임
  }
  void fireEvent(float destinationX, float destinationY) {
    projectileLocation=new PVector(location.x, location.y); //<>// //<>//
    projectileVelocity=new PVector(destinationX - location.x, destinationY - location.y);   
    Projectile temp = new Projectile(projectileLocation, projectileVelocity, p1Attack, 60, 16, 35);
    projectileList.add(temp);
    projectileCollisionList.add(new CollisionShape('R', projectileLocation, projectileVelocity, temp.projectileWidth, temp.projectileHeight));    
  }
  
  void update() {                               //플레이어의 다양한 정보 업데이트. 체력 상태, CC상태 등등
    isAbleToMove = true;                        // 앞에서 우선 enable 해놓고 조건 검사해서 false 로 만들기!!
    isAbleToFire = true;
    isAbleToSkill = true;
    
    if (weaponCooltime > 0) { 
      isAbleToFire = false;
    }
    for(int temp : CCStatus) {
      if(temp >= 10) {
        isAbleToMove = false;
        isAbleToFire = false;
        isAbleToSkill = false;
      }
    } 
    
    if(disableFire) isAbleToFire = false;
    if(disableSkill) isAbleToSkill = false;    
    if (isAbleToMove == true && distanceLeft > 0.1) location.add(velocity.x*moveSpeed, velocity.y*moveSpeed);
    
    newMouseX = worldCamera.pos.x + mouseX;
    newMouseY = worldCamera.pos.y + mouseY;
    
    for(Skill temp : skillList) {
      if(temp.isActiveOnUse) temp.update();
    }    
  }

  void updateCount() { // 무기 쿨타임, 스킬 쿨타임 등을 집중적으로 관리하는 함수
    if (weaponCooltime > 0) {
      weaponCooltime -= fireSpeed;
    }
    if (isAbleToMove && distanceLeft > 0.1) {
      distanceLeft -= moveSpeed;
    }
    for(int i=0; i < 6; i++) {
      if (CCFrameCount[i] > 0) CCFrameCount[i]--;  
      else {
        CCStatus[i] = 0;
        CCFrameCount[i] = 0;      
      }
    }
    //skill_cooltime[] -= ?  나중에 스킬 관련 쿨타임 감소도 구현하기
  }

  void manageProjectiles() {  // CollisionShape 업데이트
    for(int i=0; i<projectileList.size(); i++) {
      projectileCollisionList.get(i).update(projectileList.get(i).location, projectileList.get(i).velocity);
    }
    for(int i=0; i<projectileList.size(); i++) {  // 총알 삭제 파트
      if(!projectileList.get(i).isActive) {
        projectileList.remove(i);
        projectileCollisionList.remove(i);
      }
    }
  }
  
  void setHitEvent(boolean hitEvent) {
    this.hitEvent = hitEvent;
    for(int i = 0; i < 6; i++) {
      if(CCStatus[i] == 0) {
        CCStatus[i] = 10;
        CCFrameCount[i] = 50;
        break;
      }
    }
  }

  void setStatus(char type) { // disable 상태를 바꾼다. 예를 들어 disableMove 가 T 일때 F 로 바꿔줌.
    switch(type) {
    case 'm':  // 이동 제한 여부를 바꿈.
      if(disableMove) disableMove = false;
      else disableMove = true;
    case 'f':  // 발사 제한 여부를 바꿈
      if(disableFire) disableFire = false;
      else disableFire = true;
      break;
    case 's':
      if(disableSkill) disableSkill = false;
      else disableSkill = true;
      break;
    }
  }
  
  void setMoveSpeed(float xtimes) {
    this.moveSpeed *= xtimes;
  }
  void setMoveSpeed() {
    this.moveSpeed = DEFAULT_MOVESPEED;
  }
  void setFireSpeed(float xtimes) {
    this.fireSpeed *= xtimes;
  }
  void setFireSpeed() {
    this.moveSpeed = DEFAULT_FIRESPEED;
  }
  
}


//  ※구현되지 않은 것들※ 
//   [완료] 중간에 movSpeed 가 바뀌는 경우에 어떻게 대처할 것인가? 어짜피 거리는 일정하니까 속도 x 시간 으로 계산하는건 어떨까?
//   ※ 플레이어의 에임을 돕기 위해 일정 범위 안에 들어온 대상은 에임보조선 표시.
//   ※ CC스테이터스만 바꿔주는 함수 만들기. CCframecount로 얼마나 지속시간이 남았는지를 계산하고 그게 끝나면 다시 정상으로! 정상으로 돌릴 때 앞으로 정렬하기.
//   ※ 만약 CC기가 여러개가 걸린다면???? 어떻게 하지 이때는? 배열 선언으로 해야할듯..
//   ※ CC기 판정 시에 CCstatus에 해당 CC기 번호를 넣고, 그 번호에 framecount[] 도 할당하고, playerStatus[1] 에 1증가.
//   [완료] 플레이어의 총알이 화면 밖으로 나가거나 피격 판정 등으로 isActive == false 가 되면 메모리에서 제거. println 으로 확인가능