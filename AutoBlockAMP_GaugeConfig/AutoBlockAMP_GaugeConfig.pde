/**
 * ABamp configuration sketch
 */
// to do:

// add mode indicator i.e. run and config
// improve loading function with time-out, etc

import controlP5.*;
import processing.serial.*;
SerialReader serialReader;
RCIPacket packet;

byte[] byteBuffer = new byte[20];

boolean Loaded = false;

PImage img;  // Declare variable "a" of type PImage

Serial serialPort;  // Create object from Serial class
int val;        // Data received from the serial port

ControlP5 controlP5;

int myColorBackground = color(0, 0, 0);

float LLvalue = 20;
float TempFGH = 1024;

int DCmsb;
int DClsb;

float SOCvalue = 1200;
float previousSOCvalue;

final int SlipEnd = int(0xC0);

int  LLX = 100, LLY = 101, LLW = 300, LLH = 20;    //LLY=71

int SOCX = 100, SOCY = LLY +28, SOCW = 300, SOCH = 40;
int SOC2 = SOCY + 47;  // full slider
int SOC3 = SOC2 + 27;  // empty slider
int CAPX = 100, CAPY = SOCY+102, CAPW = 300, CAPH = 20;

float CAPvalue = 200;
int TACHX = 40, TACHY = CAPY+104;  //84
int AMPX = 250, AMPY = TACHY-21;
int TACHmsb;
int TACHlsb;

float AMPvalue = 100;

int SerialX = 30, SerialY =    42;
int PGMX =    30, PGMY =       CAPY+150;
int CONX =   195, CONY =       17;
int LOADX =  100, LOADY =      CAPY+150;

float TempMin;
float TempMax;

boolean portselected = false;

int Out = 0;  //duty cycle output
int FGH, FGL;  //FGT is a temp variable for flipping
int tach; // this is the number of pulses/rev

int Slope;     //half range in FW
int Intercept;
int InterceptCalibrate;

float amperage;

int OUTPUTMODE = 0;

boolean CONNECTED = false;

Textlabel FULLLabel, EMPTYLabel, LevelLabel, LLLabel, SOClevellabel, LLlevellabel, CAPLabel, CAPlevelLabel, 
ButtonLabel, TachLabel, ZEROLabel, CONLabel, AMPLabel, UPDATELabel, PPRlabel, FGLabel, TALabel, FGHIGHLabel, FGLOWLabel;

DropdownList d2;
String DDListname;

Button PGRM, CON, LOAD, CONFIG, RUN, FDOWN, FUP, EDOWN, EUP;

String textValue = "";
Textfield myTextfield;

String portName;

Toggle T;
Range r1;

//public void init() {
//  /// to make a frame not displayable, you can 
//  // use frame.removeNotify() 
//  frame.removeNotify(); 
// 
//  frame.setUndecorated(true); 
// 
//  // addNotify, here i am not sure if you have  
//  // to add notify again.   
//  frame.addNotify(); 
//  super.init();
//}

PFont p2;
PFont p1;
ControlFont labelFont;
ControlFont labelFont1;


void setup() {
  size(500, 500);

  // smooth();
  // frameRate(10);

  controlP5 = new ControlP5(this);

  // myTextfield = controlP5.addTextfield("CALIBRATE", 414, 309, 50, 25
  // myTextfield.setFocus(true
  //  myTextfield.keepFocus(true);
  // p2 = loadFont("ArialNarrow-18.vlw");

  p2 = createFont("Arial", 16);
  labelFont = new ControlFont(p2);

  p1 = createFont("Arial", 14);
  labelFont1 = new ControlFont(p1);

  textSize(30);

  controlP5.setColorBackground(0xFF00C90D);
  controlP5.setColorForeground(0xFF39E444);
  controlP5.setColorActive(0xFF67E46F);

  createSliders();
  createlabels();
  createButtons();

  d2 = controlP5.addDropdownList("SerialList", SerialX, SerialY, 150, 200);
  customize2(d2);

  img = loadImage("ABSWtitle.png");  // Load the image into the program
}

void draw() {

  background(0);

  fill(color(255));

  image(img, 315, 385);   //15

    fill(color(35));    // big box  //40
  quad(29, 91, //60
  465, 91, 
  465, 262, //232
  29, 262); 

  fill(color(35));    // small box
  quad(29, 308, //248
  465, 308, 
  465, 357, //297
  29, 357); 

  fill(color(70));    // FG box
  quad(29, 65, //60
  190, 65, 
  190, 91, //232
  29, 91); 

  fill(color(70));    // TA box
  quad(29, 282, //60
  165, 282, 
  165, 308, //232
  29, 308); 

  fill(0xFF39E444);

  SOClevellabel.setValue(round(SOCvalue)+"%");
  SOClevellabel.setControlFont(labelFont);
  SOClevellabel.draw(this);

  LLlevellabel.setValue(round(LLvalue)+"%");
  LLlevellabel.setControlFont(labelFont);
  LLlevellabel.draw(this);

  AMPLabel.setValue(round(AMPvalue)+"A");
  AMPLabel.setControlFont(labelFont);
  AMPLabel.draw(this);

  PPRlabel.setValue(round(tach)+" PPR");
  PPRlabel.setControlFont(labelFont);
  PPRlabel.draw(this);

  FGHIGHLabel.setValue(round(TempMax)+"");
  FGHIGHLabel.setControlFont(labelFont);
  FGHIGHLabel.draw(this);

  FGLOWLabel.setValue(round(TempMin)+"");
  FGLOWLabel.setControlFont(labelFont);
  FGLOWLabel.draw(this);

  CAPlevelLabel.setValue(round(CAPvalue)+"Ah");
  CAPlevelLabel.setControlFont(labelFont);
  CAPlevelLabel.draw(this);

  if (SOCvalue < LLvalue) {      
    SOClevellabel.setColorValue(0xFFDE1616);
  }
  else
  {
    SOClevellabel.setColorValue(0xFFFFFFFF);
  }


  if (!(controlP5.window().isMouseOver(d2)) && mousePressed) {
    d2.close();
  }

  if ((controlP5.window().isMouseOver(d2))  && mousePressed && !d2.isOpen()  ) {   //repopulates drop-down menu when caption is pressed
    d2.clear();
    for (int i=0;i<(Serial.list().length);i++) {
      d2.addItem(Serial.list()[i], i);
    }
    d2.setHeight(((Serial.list().length)+1)*23);
  }
}

void controlEvent(ControlEvent theControlEvent) {

  if (theControlEvent.isGroup()) {

    if (theControlEvent.group().name().equals("SerialList")) {
      portselected = true;
      CON.setColorActive(0xFF00C90D);
      CON.setColorForeground(0xFF39E444);
      println(round(theControlEvent.group().value())); 
      d2.captionLabel().style().marginTop = 8;
      println(Serial.list().length);
      portName = Serial.list()[(round(theControlEvent.group().value()))];
      d2.clear();
      for (int i=0;i<(Serial.list().length);i++) {
        d2.addItem(Serial.list()[i], i);
      }
    }
  }

  else {

    if ((theControlEvent.controller().name().equals("FULL")) || 
      (theControlEvent.controller().name().equals("EMPTY")) ||
      (theControlEvent.controller().name().equals("FDOWN")) ||
      (theControlEvent.controller().name().equals("FUP")) ||
      (theControlEvent.controller().name().equals("EDOWN")) ||
      (theControlEvent.controller().name().equals("EUP"))

    ) {   // if range sliders are moved, or buttons are pressed.

      if (theControlEvent.controller().name().equals("FULL")) {
        TempMax = theControlEvent.controller().value();
        controlP5.controller("SOC").setValue(100);
      }

      if (theControlEvent.controller().name().equals("EMPTY")) {
        TempMin = theControlEvent.controller().value();
        controlP5.controller("SOC").setValue(0);
      }


      if (theControlEvent.controller().name().equals("FDOWN")) {
        TempMax = TempMax-1;
        controlP5.controller("SOC").setValue(100);    
        controlP5.controller("FULL").setValue(TempMax);
      }  


      if (theControlEvent.controller().name().equals("FUP")) {
        TempMax = TempMax+1;
        controlP5.controller("SOC").setValue(100);    
        controlP5.controller("FULL").setValue(TempMax);
      }  


      if (theControlEvent.controller().name().equals("EDOWN")) {
        TempMin = TempMin-1;
        controlP5.controller("SOC").setValue(0);    
        controlP5.controller("EMPTY").setValue(TempMin);
      }


      if (theControlEvent.controller().name().equals("EUP")) {
        TempMin = TempMin+1;
        controlP5.controller("SOC").setValue(0);    
        controlP5.controller("EMPTY").setValue(TempMin);
      }

      int Range = abs(int(TempMax)-int(TempMin));

      if (TempMax > TempMin) { 

        Out = int(((SOCvalue/100))*Range)+int(TempMin);
        //  println(Out);
        FGH = int(TempMax);   // just changed these...
        FGL = int(TempMin);
      }

      else if (TempMax < TempMin) { 

        Out = int(TempMin)-int(((SOCvalue/100))*Range);
        //   println(Out);
        //    FGH = int(TempMin);
        //    FGL = int(TempMax);
        FGH = int(TempMax);   // just changed these...
        FGL = int(TempMin);
      }

      if (CONNECTED == true) {

        slipStart();    //Version, Payload Size MSB, Payload Size LSB, Packet Type, Duty Cycle MSB, Duty Cycle LSB, Checksum

        slipSend(0x00);    //version
        slipSend(0x00);    //Payload Size MSB
        slipSend(0x05);    //Payload Size LSB
        slipSend(0x14);    //Packet type

        DCmsb = (Out >> 8) & 0x03;
        DClsb = (Out & 0xff);

        slipSend(DCmsb);    //Duty Cycle MSB
        slipSend(DClsb);    //Duty Cycle LSB  

        slipSend(tach);

        TACHmsb = (round(AMPvalue) >> 8) & 0x03;
        TACHlsb = (round(AMPvalue) & 0xff);

        slipSend(TACHmsb);    //Duty Cycle MSB
        slipSend(TACHlsb);    //Duty Cycle LSB

        slipSend(0x00);     // checksum
        slipEnd();

        //delay(200);
      }
    }

    if (theControlEvent.controller().name().equals("SOC")) {

      SOCvalue = theControlEvent.controller().value();

      if (SOCvalue != previousSOCvalue) {


        int Range = abs(int(TempMax)-int(TempMin));

        if (TempMax > TempMin) { 

          Out = int(((SOCvalue/100))*Range)+int(TempMin);     
          println(Out);
        }

        else if (TempMax < TempMin) { 

          Out = int(TempMin)-int(((SOCvalue/100))*Range);
          println(Out);
        }

        if (CONNECTED == true) {

          slipStart();
          //Version, Payload Size MSB, Payload Size LSB, Packet Type, Duty Cycle MSB, Duty Cycle LSB, Checksum

          slipSend(0x00);    //version
          slipSend(0x00);    //Payload Size MSB
          slipSend(0x05);    //Payload Size LSB
          slipSend(0x14);    //Packet type

          DCmsb = (Out >> 8) & 0x03;
          DClsb = (Out & 0xff);

          slipSend(DCmsb);    //Duty Cycle MSB
          slipSend(DClsb);    //Duty Cycle LSB  

          slipSend(tach);

          TACHmsb = (round(AMPvalue) >> 8) & 0x03;
          TACHlsb = (round(AMPvalue) & 0xff);

          slipSend(TACHmsb);    //Duty Cycle MSB
          slipSend(TACHlsb);    //Duty Cycle LSB

          slipSend(0x00);     // checksum
          slipEnd();

          //delay(200);
        }
      }
      previousSOCvalue = SOCvalue;
    }

    if (theControlEvent.controller().name().equals("LL")) {
      LLvalue = int(theControlEvent.controller().value());
      //  println("LL is "+round(LLvalue));
    }

    if (theControlEvent.controller().name().equals("AMP")) {
      AMPvalue = theControlEvent.controller().value();

      if (CONNECTED == true) {

        slipStart();
        slipSend(0x00);    //version
        slipSend(0x00);    //Payload Size MSB
        slipSend(0x05);    //Payload Size LSB
        slipSend(0x14);    //Packet type

        slipSend(DCmsb);    //Duty Cycle MSB
        slipSend(DClsb);    //Duty Cycle LSB  

        slipSend(tach);

        TACHmsb = (round(AMPvalue) >> 8) & 0x03;
        TACHlsb = (round(AMPvalue) & 0xff);

        slipSend(TACHmsb);    //Duty Cycle MSB
        slipSend(TACHlsb);    //Duty Cycle LSB 

        slipSend(0x00);     // checksum
        slipEnd();
      }
    }

    if (theControlEvent.controller().name().equals("PPR")) {
      tach = round(theControlEvent.controller().value());
    }

    if (theControlEvent.controller().name().equals("CAP")) {
      CAPvalue = theControlEvent.controller().value();
    }

    if (theControlEvent.controller().name().equals("PGRM")) {


      if (CONNECTED == true) {

        slipStart();
        slipSend(0x00);    //version
        slipSend(0x00);    //Payload Size MSB
        slipSend(0x13);    //Payload Size LSB
        slipSend(0x15);    //Packet type

        slipSend((FGH >> 8) & 0x03);  
        slipSend(FGH & 0xff);          

        slipSend((FGL >> 8) & 0x03);   
        slipSend(FGL & 0xff);          

        slipSend((int(LLvalue) >> 8) & 0x03);    //LL MSB
        slipSend(int(LLvalue) & 0xff);    //LL LSB  

        slipSend((round(CAPvalue) >> 8) & 0x03);    
        slipSend(round(CAPvalue) & 0xff);    

        slipSend(tach);     

        slipSend((Slope >> 8) & 0x03);   
        slipSend(Slope & 0xff);  

        slipSend(byte((Intercept&0x0000FF00)>>8));
        slipSend(byte((Intercept&0x000000FF)));

        slipSend(OUTPUTMODE); 

        slipSend(0x00);     // checksum
        slipEnd();

        print("FGH is: "+FGH);
        println(", FGL is: "+FGL);
        println("LL is: "+LLvalue); 
        println("CAP is: "+CAPvalue);          
        println("tach is: "+tach); 
        println("Slope is: "+Slope); 
        println("Intercept is: "+Intercept);
      }
    }


    if (theControlEvent.controller().name().equals("LOAD")) {   //this updates range values

        // updateSOC();

      LoadfromAB();
    }


    if (theControlEvent.controller().name().equals("CON")) { 

      if (CONNECTED == false && portselected == true) {

        CONNECTED = true; 
        println("connected");
        controlP5.getController("CON").setCaptionLabel("CONNECTED");
        CON.setWidth(112);
        CON.setColorForeground(0xFF39E444);
        CON.setColorBackground(0xFF00C90D);

        PGRM.setColorBackground(0xFF00C90D);
        PGRM.setColorForeground(0xFF39E444);
        PGRM.setColorActive(0xFF67E46F);

        LOAD.setColorBackground(0xFF00C90D);
        LOAD.setColorForeground(0xFF39E444);
        LOAD.setColorActive(0xFF67E46F);

        openPortAndGo();

        // LoadfromAB();
      }

      else if (CONNECTED == true && portselected == true) {

        CONNECTED = false;

        controlP5.getController("CON").setCaptionLabel("CONNECT");
        CON.setWidth(89);
        CON.setColorBackground(color(60));
        CON.setColorForeground(0xFF00C90D);

        PGRM.setColorBackground(color(60));
        PGRM.setColorForeground(color(60));
        PGRM.setColorActive(color(60));

        LOAD.setColorBackground(color(60));
        LOAD.setColorForeground(color(60));
        LOAD.setColorActive(color(60));


        serialPort.clear();

        delay(100);
        LoadfromAB();
        serialPort.stop();
      }
    }
  }
}

void openPortAndGo() {
  serialPort = new Serial(this, portName, 9600);
  serialPort.clear();
  serialPort.bufferUntil(byte(SlipEnd));
  serialReader = new SerialReader(serialPort, "serial1", portName);
}

void slipStart() {
  serialPort.write(0xC0);
  // delay(10);
}

void slipEnd() {
  serialPort.write(0xC0);
  // println("");
}

void slipSend (int dataByte) { 

  if ((dataByte != 0xC0) && (dataByte != 0xDB)) {
    serialPort.write(dataByte);
  }
  else if (dataByte == 0xC0) {
    serialPort.write(0xDB); //SlipEsc
    serialPort.write(0xDC); //SlipEscEnd
  }
  else { //must be 0xDB / SlipEsc
    serialPort.write(0xDB);//SlipEsc
    serialPort.write(0xDD);//SlipEscEsc
  }

  //print(hex(dataByte, 2) +" ");
}

void customize2(DropdownList ddl2) {

  ddl2.setBackgroundColor(color(190));
  ddl2.setItemHeight(23);
  ddl2.setBarHeight(24);
  ddl2.captionLabel().set("SELECT SERIAL PORT");
  ddl2.captionLabel().style().marginTop = 8;
  ddl2.captionLabel().style().marginLeft = 3;  
  ddl2.valueLabel().style().marginTop = 0;

  for (int i=0;i<(Serial.list().length);i++) {
    ddl2.addItem(Serial.list()[i], i);
  }

  ddl2.setColorBackground(color(80));
  ddl2.setColorActive(color(255, 128));
  ddl2.setHeight(((Serial.list().length)+1)*23);
}

void serialEvent(Serial p) {
  serialReader.checkSerial();
}

void LoadfromAB() {

  Loaded = false;

  if (CONNECTED == true) {

    while (Loaded == false) {

      slipStart();
      slipSend(0x00);    //version
      slipSend(0x00);    //Payload Size MSB
      slipSend(0x00);    //Payload Size LSB
      slipSend(0x17);    //Packet type
      slipSend(0x00);     // checksum
      slipEnd();

      if (serialReader.available()) {
        packet = serialReader.getPacket(); 

        if (packet.packetType == 18) { 

          int TempFGH =  (packet.ConfigBuffer[0] << 8) + packet.ConfigBuffer[1];
          int TempFGL =  (packet.ConfigBuffer[2] << 8) + packet.ConfigBuffer[3];
          int LLvalue =  (packet.ConfigBuffer[4] << 8) + packet.ConfigBuffer[5];  
          int CAPvalue =  (packet.ConfigBuffer[6] << 8) + packet.ConfigBuffer[7];  
          int tach = packet.ConfigBuffer[8];    
          Slope = (packet.ConfigBuffer[9] << 8) + packet.ConfigBuffer[10];
          Intercept = (packet.ConfigBuffer[11] << 8) + packet.ConfigBuffer[12];

          print("FGH is: "+TempFGH);
          println(", FGL is: "+TempFGL);
          println("LL is: "+LLvalue); 
          println("CAP is: "+CAPvalue);          
          println("tach is: "+tach); 
          println("Slope is: "+Slope); 
          println("Intercept is: "+Intercept);

          Loaded = true; 

          controlP5.controller("EMPTY").setValue(TempFGL);    
          controlP5.controller("FULL").setValue(TempFGH);         


          //          if (TempFGH > TempFGL) {
          //
          //            controlP5.controller("EMPTY").setValue(TempFGL);    
          //            controlP5.controller("FULL").setValue(TempFGH);        
          //
          //            FGH = TempFGL;
          //            FGL = TempFGH;
          //          }
          //
          //          else if (TempFGH < TempFGL) {
          //
          //            controlP5.controller("EMPTY").setValue(TempFGH);    
          //            controlP5.controller("FULL").setValue(TempFGL);    
          //
          FGH = TempFGH;
          FGL = TempFGL;
          //          }      

          controlP5.controller("LL").setValue(LLvalue);         
          controlP5.controller("CAP").setValue(CAPvalue);
          controlP5.controller("PPR").setValue(tach);
        }
      }
    }
  }
} 


void updateSOC()
{
  if (CONNECTED == true) {
    slipStart();
    //Version, Payload Size MSB, Payload Size LSB, Packet Type, Duty Cycle MSB, Duty Cycle LSB, Checksum

    slipSend(0x00);    //version
    slipSend(0x00);    //Payload Size MSB
    slipSend(0x05);    //Payload Size LSB
    slipSend(0x14);    //Packet type

    DCmsb = (Out >> 8) & 0x03;
    DClsb = (Out & 0xff);

    slipSend(DCmsb);    //Duty Cycle MSB
    slipSend(DClsb);    //Duty Cycle LSB  

    slipSend(tach);

    TACHmsb = (round(AMPvalue) >> 8) & 0x03;
    TACHlsb = (round(AMPvalue) & 0xff);

    slipSend(TACHmsb);    //Duty Cycle MSB
    slipSend(TACHlsb);    //Duty Cycle LSB

    slipSend(0x00);     // checksum
    slipEnd();

    Out= Out+1;

    // println(DCmsb);
    // println(DClsb);
    // println(Out);
  }
}

