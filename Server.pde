class Server { // 서버로 선택된 경우 화이트보드 데이터를 지속적으로 받고, 업데이트 하여 전송해주는 역할
  DatagramSocket ds;
  int serverPortNum; // 서버의 포트 주소
  ArrayList<InetAddress> addressList = new ArrayList<InetAddress>(); // 플레이어들의 주소를 각각 관리
  ArrayList<Integer> portList = new ArrayList<Integer>(); // 플레이어들의 포트
  int connectionStandbyTime;
  boolean shouldWaitConnection;
  ArrayList<Integer> playerX = new ArrayList<Integer>();
  ArrayList<Integer> playerY = new ArrayList<Integer>();
  
  Server(int serverPortNum) throws Exception { // 생성자: 데이터를 수신할 포트 주소
    this.serverPortNum = serverPortNum;
    shouldWaitConnection = true;
    ds = new DatagramSocket(serverPortNum);
    ds.setSoTimeout(10);
  }
  void update() throws Exception {
    if(shouldWaitConnection) {
      initialConnection(); 
      return;
    }
    receivePacket();
    sendPacket();
  } //update()
  
  void receivePacket() throws Exception{
    DatagramPacket dpr = new DatagramPacket(new byte[1024], 1024);
    ds.receive(dpr);
  } //receivePacket  
  void sendPacket() throws Exception{
    for(int i = 0; i < addressList.size(); i++) {
      //DatagramPacket dps = new DatagramPacket(화이트보드 데이터, 데이터길이, addressList.get(i), portList.get(i));
      //ds.send(dps);
    }    
  } //sendPacket
  void sendInitialPacket() throws Exception{ // 처음에 Connection Establish 할 때 연결된 모든 클라이언트에게 패킷 전송하는 메서드
    if(!addressList.isEmpty()) {
      for(int i = 0; i < addressList.size(); i++) {
        DatagramPacket dps = new DatagramPacket(new byte[1], 1, addressList.get(i), portList.get(i));
        ds.send(dps);
      }
    }
  }

  void initialConnection() throws Exception {
    if(millis() - connectionStandbyTime < serverConnectionTime) {    
      println(millis() - connectionStandbyTime);
      DatagramPacket dpr = new DatagramPacket(new byte[1024], 1024);
      ds.receive(dpr);
      if(dpr.getPort() != -1 && !addressList.contains(dpr.getAddress())) {
        println("Connection Established with - " + dpr.getAddress().getHostAddress() + ": " + dpr.getPort());
        addressList.add(dpr.getAddress());
        portList.add(dpr.getPort());
      } //if(dpr~
      sendInitialPacket();
    } else if(millis() - connectionStandbyTime > serverConnectionTime && !addressList.isEmpty()) { //if(millis~
      println("-----------Connection List-----------");
      for(int i = 0; i < addressList.size(); i++) println(i + 1 + "번째 플레이어: " + addressList.get(i).getHostAddress() + ": " + portList.get(i));    
      shouldWaitConnection = false; // 더이상 연결을 기다리지 않음. initialConnection 으로 분기되지 않음.
      runState += 2; // runState 를 1(호스트) 에서 3(네트워크 플레이)로!
    } else { //else if
      runState = 0; // 
    }
  } //initialConnection()  
} //class