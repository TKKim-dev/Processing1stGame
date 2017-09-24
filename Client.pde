class Client { // 클라이언트 클래스가 하는 일: 데이터 전송, 데이터 받고 적절하게 분석 & 자르기
  DatagramSocket ds;
  InetAddress ia;
  int portNum; // 상대에게 전송할 포트 번호 0~ 65508(?)
  
  Client(InetAddress ia, int portNum) throws Exception{ // 전송할 InetAddress에 대한 정보, ia 는 전송할 
    this.ia = ia; 
    this.portNum = portNum;
    ds = new DatagramSocket(portNum);
  }
  
  void update() {
  }
  
  void setPacket() { //패킷을 가공함
  }
  
  void sendPacket(byte[] buffer) { // 서버에게 패킷을 전송함
    DatagramPacket dps = new DatagramPacket(buffer, buffer.length, ia, portNum);
  }
}