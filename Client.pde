class Client { // 클라이언트 클래스가 하는 일: 데이터 전송, 데이터 받고 적절하게 분석 & 자르기
  DatagramSocket ds;
  InetAddress ia;
  int portNum; // 상대에게 전송할 포트 번호 0~ 65508(?)
  byte[] test = "25.13.32.222".getBytes();
  boolean isActive;
  
  Client(InetAddress ia, int portNum) throws Exception { // 전송할 InetAddress에 대한 정보, ia 는 전송할 
    this.ia = ia; 
    this.portNum = portNum;
    ds = new DatagramSocket(portNum + int(random(0, 100)));
    ds.setSoTimeout(10);
    isActive = true;    
  }
  /*Client() throws Exception {
    this.ia = InetAddress.getLocalHost();
    this.portNum = server.serverPortNum;
    ds = new DatagramSocket(portNum + int(random(0, 100)));
    ds.setSoTimeout(10);
    isActive = true;
  }*/
  void update() throws Exception {
    sendPacket(test);
    receivePacket();
  }
  
  void setPacket() { //패킷을 가공함
  }
  void receivePacket() throws Exception {
    DatagramPacket dpr = new DatagramPacket(new byte[1024], 1024);
    ds.receive(dpr);
    if(dpr.getPort() != -1) println(dpr.getData()); //<>//
  }
  void sendPacket(byte[] buffer) { // 서버에게 패킷을 전송함
    DatagramPacket dps = new DatagramPacket(buffer, buffer.length, ia, portNum);
    try {
      ds.send(dps);
    } catch(IOException ie) {
      ie.printStackTrace();
    }
  }
}

// byte[] data=sendMsg.getBytes();