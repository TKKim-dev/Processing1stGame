class Skill {  // 플레이어의 skillList에 들어갈 것들. 얘들은 skillOnReady 랑 쿨타임 등등만 관리. 실제로 스킬 사용은 ActiveOnUse() 로 메시지 전달. display 는 player 에서(shapeOnReady), + 전역 관리
  int skillNum;  // 스킬 번호. 내가 나중에 추가할 것들. 예를 들어 1번 스킬은 앞쪽 빠른 대쉬
  PVector playerLocation, direction; // 스킬 시전자의 위치와 시전하려는 위치 방향 벡터
  PVector locationOnUse, velocityOnUse; // 발사된 스킬의 위치와 속도 벡터
  PShape shapeOnReady; //
  float cooltime;
  boolean isActiveOnReady, isActiveOnUse; // 각각이 의미하는 것들: 준비 Mode 가 activate 되어있는지, 스킬 사용이 activate 되어있는지. 스킬 사용 activate 되어있을 때 해당 스킬이 투사체 생성 스킬인지 따로 검사 
  
  Skill(int skillNum, PShape shapeOnReady) { // 이동 속도 증가나 공격 속도 증가. 혹은 특정 범위 내의 적 지속 시간 동안 자동 조준, 다음 공격 강화. 그래도 범위 선을 표현하기 위한 PShape는 필요함!
    this.skillNum = skillNum;
    this.shapeOnReady = shapeOnReady;
  }
  
  void setActiveOnReady(boolean bool) {
    isActiveOnReady = bool;
  }
  void activate(int skillNum) {
    //isActiveOnUse();
    //쿨타임 시작!
  }
  void lowerSkillCooltime(float amountTime) {   // 얼마만큼 해당 스킬 쿨타임을 감소시키는 method
    cooltime -= amountTime;
  } 
}

//   ※ 구현해야 할 것 ※
// ※ skillEffectBeforeUse -> 스킬을 사용하기 전에 ( ex) Q를 누르고 조준 ) 스킬 이펙트를 표시하는 것! 스킬을 준비시키는 과정. 따라서 CC상태에 따라 판단해야함.  
// ※ 스킬이 사용되는 방식은 = Q 를 누르면 p1.skillQ.skillRun() -> 그 뒤에 마우스가 클릭되거나 해서 skillEffectAfterUse 로 스킬 이펙트를 표시하고 update() 로 스킬 좌표, 상호작용 등 하도록!  
// ※ 우선 Q 를 누르면 짧은 마우스 방향 스킬 준비 그림, 거기서 왼쪽 클릭 혹은 다시 한번 Q키 누르면 취소!!!
// ※ W 누르면 특정 투사체 발사. 쿨타임
// ※
// ※