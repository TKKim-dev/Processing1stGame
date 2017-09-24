class Skill {  // 플레이어의 skillList에 들어갈 것들. 얘들은 skillOnReady 랑 쿨타임 등등만 관리. 실제로 스킬 사용은 ActiveOnUse() 로 메시지 전달. display 는 player 에서(shapeOnReady), + 전역 관리
  int skillNum;  // 스킬 번호. 내가 나중에 추가할 것들. 예를 들어 1번 스킬은 앞쪽 빠른 대쉬
  PVector playerLocation, direction; // 스킬 시전자의 위치와 시전하려는 위치 방향 벡터. skillOnReady display 시에 필요
  float cooltime, cooltimeLeft, skillTime; // 스킬 시전 시간도 추가!
  boolean isActiveOnReady, isActiveOnUse; // 각각이 의미하는 것들: 준비 Mode 가 activate 되어있는지, 스킬 사용이 activate 되어있는지. 스킬 사용 activate 되어있을 때 해당 스킬이 투사체 생성 스킬인지 따로 검사 
  boolean shouldLoadShape; // OnReady 상태에서 Shape 를 로드해야 하는 스킬인 경우
  PShape shapeOnReady;
  Skill(int skillNum, float cooltime) {
    this.skillNum = skillNum;
    this.cooltime = cooltime;
  }
  Skill(int skillNum, boolean shouldLoadShapeOnReady, float cooltime) { // 이동 속도 증가나 공격 속도 증가. 혹은 특정 범위 내의 적 지속 시간 동안 자동 조준, 다음 공격 강화. 그래도 범위 선을 표현하기 위한 PShape는 필요함!
    this.skillNum = skillNum;
    this.cooltime = cooltime;
    if(shouldLoadShapeOnReady) {
      shapeOnReady = loadShape(skillNum + "R" + ".svg");
    }
  }

  void activate() {
    isActiveOnReady = false;
    isActiveOnUse = true;
    setCooltime();
  }
  void deactivate() {
    isActiveOnUse = false;
    skillTime = 0;
  }
  void setActiveOnReady(boolean bool) {
    isActiveOnReady = bool;
  }  
  void setCooltime() {
    this.cooltimeLeft = cooltime;
  }
  void lowerSkillCooltime(float amountTime) {   // 얼마만큼 해당 스킬 쿨타임을 감소시키는 method
    cooltime -= amountTime;
  }
  void update() { // 만약 CC를 맞아도 취소되지 않는 패시브 스킬 같은 경우에는 이 super 을 추가하지 말 것!
    if(!isActiveOnUse || skillTime < 0) {
      skillTime = 0;
      deactivate();
      return;
    }
    skillTime--;
  }
}

class Skill1 extends Skill{
  PShape skill1R;
  Skill1() { // 여기 30 부분에서 각 스킬 쿨타임 변경 가능.
    super(1, true, 30); // 1st, Skill1R
  }
  
  void activate() {
    super.activate();
    direction = new PVector(worldCamera.pos.x + mouseX - p1.location.x, worldCamera.pos.y + mouseY - p1.location.y);
    direction.normalize();
    p1.setStatus('m');
    p1.setStatus('f');
    p1.setStatus('s');
    skillTime = 20;
  }
  
  void deactivate() {
    super.deactivate();
    p1.setStatus('m');
    p1.setStatus('f');
    p1.setStatus('s');
    p1.setMoveSpeed();
  }
  
  void update() {
    super.update();
    if(skillTime > 0) {
      p1.move(direction.x, direction.y, 16);
      skillTime--;
      return;
    }
    deactivate();
  }
}

class Skill2 extends Skill{
  PShape skill2R;
  float delayTime = 10;
  Skill2() {
    super(2, true, 50);
  }
  
  void activate() {
    super.activate(); //<>// //<>//
    direction = new PVector(p1.newMouseX, p1.newMouseY);
    p1.setMoveSpeed(0.5);
    p1.setStatus('f');
    p1.setStatus('s');
    skillTime = 32;
  }
  void deactivate() {
    super.deactivate();
    p1.setStatus('f');
    p1.setStatus('s');
    p1.setMoveSpeed();
  }
  void update() {
    super.update();
    if(skillTime % 10 == 0) p1.fireEvent(random(direction.x - 65, direction.x + 65), random(direction.y - 65, direction.y + 65)); 
    if(!p1.isAbleToMove) deactivate();
  }
}





















//   ※ 구현해야 할 것 ※
// ※ skillEffectBeforeUse -> 스킬을 사용하기 전에 ( ex) Q를 누르고 조준 ) 스킬 이펙트를 표시하는 것! 스킬을 준비시키는 과정. 따라서 CC상태에 따라 판단해야함.  
// ※ 스킬이 사용되는 방식은 = Q 를 누르면 p1.skillQ.skillRun() -> 그 뒤에 마우스가 클릭되거나 해서 skillEffectAfterUse 로 스킬 이펙트를 표시하고 update() 로 스킬 좌표, 상호작용 등 하도록!  
// ※ 우선 Q 를 누르면 짧은 마우스 방향 스킬 준비 그림, 거기서 왼쪽 클릭 혹은 다시 한번 Q키 누르면 취소!!!
// ※ W 누르면 특정 투사체 발사. 쿨타임
// ※
// ※