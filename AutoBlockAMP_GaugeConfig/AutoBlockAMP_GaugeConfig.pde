/**
 * ABamp configuration sketch
 */

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

int LLX = 96;
int LLY = 75;
int LLW = 310;
int LLH = 17;

float LLvalue = 20;

int SOCX = 100;
int SOCY = LLY +25;
int SOCW = 300;
int SOCH = 30;

int DCmsb;
int DClsb;

float SOCvalue = 100;

final int SlipEnd = int(0xC0);

int RangeX = 100;
int RangeY = SOCY+60;
int RangeW = 300;
int RangeH = 20;
int RangeB = 75;
int RangeT = 575;

int CAPX = 100;
int CAPY = RangeY+35;
int CAPW = 300;
int CAPH = 20;

float CAPvalue = 200;

int TACHX = 40;
int TACHY = CAPY+84;

int AMPX = 250;
int AMPY = TACHY-21;

int TACHmsb;
int TACHlsb;

float AMPvalue = 100;

int SerialX = 30;
int SerialY = 42;

int PGMX = 30;
int PGMY = CAPY+114;

int CONX = 195;
int CONY = 17;

int ZEROX = 340;
int ZEROY = CAPY+114;

int BLX = 160;
int BLY = CAPY+114;

int LOADX = 100;
int LOADY = CAPY+114;

float TempMin = RangeB;
float TempMax = RangeT;

boolean portselected = false;

int Out = 0;  //duty cycle output

boolean Flipped = false;

int FGH, FGL, FGT;//FGT is a temp variable for flipping

int tach; // this is the number of pulses/rev

int Slope;     //half range in FW
int Intercept;
int InterceptCalibrate;

float amperage;

int OUTPUTMODE = 0;

boolean CONNECTED = false;

Textlabel RangeLabel;
Textlabel LevelLabel;
Textlabel LLLabel;
Textlabel SOClevellabel;
Textlabel LLlevellabel;
Textlabel CAPLabel;
Textlabel CAPlevelLabel;
Textlabel ButtonLabel; 
Textlabel TachLabel;
//Textlabel PGRMLabel;
Textlabel ZEROLabel;
Textlabel CONLabel;
Textlabel AMPLabel;
Textlabel UPDATELabel;
//Textlabel LOADLabel;
Textlabel PPRlabel;

//DropdownList d1;
DropdownList d2;
String DDListname;

Button PGRM;
Button ZERO;
Button CON;
Button UPDATE;
Button LOAD;

String textValue = "";
Textfield myTextfield;


//boolean FLIP = false;

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
ControlFont labelFont;

void setup() {
  size(500, 350);

  smooth();
  frameRate(10);

  controlP5 = new ControlP5(this);

  myTextfield = controlP5.addTextfield("CALIBRATE", 414, 309, 50, 25);
  myTextfield.setFocus(true);
  myTextfield.keepFocus(true);

 // p2 = loadFont("ArialNarrow-18.vlw");
  p2 = createFont("Arial", 16);
  labelFont = new ControlFont(p2);

  textSize(30);

  r1 = controlP5.addRange("Range", 0, 1023, RangeB, RangeT, RangeX, RangeY, RangeW, RangeH);

  controlP5.setColorBackground(0xFF00C90D);
  controlP5.setColorForeground(0xFF39E444);
  controlP5.setColorActive(0xFF67E46F);

  r1.setColorBackground(0xFF078600);
  r1.setColorForeground(0xFF39E444);
  r1.setColorActive(0xFF00C90D);

  r1.setMoveable(false);
  r1.valueLabel().setVisible(false);
  r1.setLabelVisible(false);
  r1.setCaptionLabel("");
  r1.setHandleSize(10) ;

  Slider s1 = controlP5.addSlider("SOC", 0, 100, 50, SOCX, SOCY, SOCW, SOCH);
  s1.setSliderMode(Slider.FLEXIBLE);
  s1.setMoveable(false);
  s1.valueLabel().setVisible(false);
  s1.setCaptionLabel("");
  s1.setHandleSize(5) ;

  Slider s2 = controlP5.addSlider("LL", 0, 100, 20, LLX, LLY, LLW, LLH);
  s2.setSliderMode(Slider.FLEXIBLE);
  s2.setMoveable(false);
  s2.valueLabel().setVisible(false);
  s2.setCaptionLabel("");
  s2.setNumberOfTickMarks(51);
  s2.setColorBackground(color(40));
  s2.setColorActive(0xFFD1526C);
  s2.setColorForeground(0xFF95001E);

  Slider s3 = controlP5.addSlider("CAP", 1, 400, 10, CAPX, CAPY, CAPW, CAPH);
  //s3.setSliderMode(Slider.FIX);
  s3.setMoveable(false);
  s3.valueLabel().setVisible(false);
  s3.setCaptionLabel("");
  //s3.setNumberOfTickMarks(40);

  Slider s4 = controlP5.addSlider("AMP", 0, 1000, 0, AMPX, AMPY, 150, 20);
  s4.setSliderMode(Slider.FLEXIBLE);
  s4.setMoveable(false);
  s4.valueLabel().setVisible(false);
  s4.setCaptionLabel("");

  Slider s5 = controlP5.addSlider("PPR", 0, 4, 0, TACHX+10, TACHY-21, 132, 20);
  s5.setSliderMode(Slider.FLEXIBLE);
  s5.setMoveable(false);
  s5.valueLabel().setVisible(false);
  s5.setCaptionLabel("");
  s5.setNumberOfTickMarks(5);

  RangeLabel = controlP5.addTextlabel("label", "GAUGE", RangeX-67, RangeY-1);
  RangeLabel.draw(this); 
  RangeLabel.setControlFont(labelFont);

  LevelLabel = controlP5.addTextlabel("label2", "LEVEL", SOCX-60, SOCY+4);
  LevelLabel.draw(this); 
  LevelLabel.setControlFont(labelFont);

  LLLabel = controlP5.addTextlabel("label3", "WARN", LLX-55, LLY-7);
  LLLabel.draw(this); 
  LLLabel.setControlFont(labelFont);

  SOClevellabel = controlP5.addTextlabel("label4", SOCvalue+" %", SOCX+SOCW+5, SOCY+5);    

  LLlevellabel = controlP5.addTextlabel("label5", LLvalue+" %", LLX+LLW+1, LLY-5);  

  PPRlabel = controlP5.addTextlabel("label15", tach +" PPR", TACHX+150, TACHY-22);

  AMPLabel = controlP5.addTextlabel("label12", AMPvalue+" %", AMPX+160, AMPY-1);

  CAPLabel = controlP5.addTextlabel("label6", "PACK", CAPX-55, CAPY-0);
  CAPLabel.draw(this); 
  CAPLabel.setControlFont(labelFont);

  CAPlevelLabel = controlP5.addTextlabel("label7", CAPvalue + "Ah", CAPX+CAPW+5, CAPY-1);
  CAPlevelLabel.draw(this);

  T = controlP5.addToggle("FLIP", true, RangeX+310, RangeY+1, 45, 20);
  controlP5.getController("FLIP")
    .getCaptionLabel()
      .setControlFont(labelFont);
  T.captionLabel().getStyle().marginTop = -24;
  T.captionLabel().getStyle().marginLeft = 4;


  //  T.setCaptionLabel("");  
  // ButtonLabel = controlP5.addTextlabel("label8", "FLIP", RangeX+313, RangeY+4);
  // ButtonLabel.setControlFont(new ControlFont(p2));
  //  ButtonLabel.draw(this); 
  T.setColorActive(color(70));

  ZERO = controlP5.addButton("ZERO", 0, ZEROX, ZEROY, 53, 25);

  controlP5.getController("ZERO")
    .getCaptionLabel()
      .setControlFont(labelFont);
  ZERO.captionLabel().getStyle().marginTop = 1;
  //ZERO.setCaptionLabel("");  
  //ZEROLabel = controlP5.addTextlabel("label10", "ZERO", ZEROX+1, ZEROY+5);
  //ZEROLabel.setControlFont(new ControlFont(p2));
  //ZEROLabel.draw(this); 

  PGRM = controlP5.addButton("PGRM", 0, PGMX, PGMY, 55, 25);
  controlP5.getController("PGRM")
    .getCaptionLabel()
      .setControlFont(labelFont);
  PGRM.captionLabel().getStyle().marginTop = 1;

  LOAD = controlP5.addButton("LOAD", 0, LOADX, LOADY, 52, 25);
  controlP5.getController("LOAD")
    .getCaptionLabel()
      .setControlFont(labelFont);
  LOAD.captionLabel().getStyle().marginTop = 1;

  CON= controlP5.addButton("CON", 0, CONX, CONY, 89, 24);

  controlP5.getController("CON")
    .setCaptionLabel("CONNECT");
  controlP5.getController("CON")
    .getCaptionLabel()
      .setControlFont(labelFont);
  CON.captionLabel().getStyle().marginTop = 0;

  CON.setColorBackground(color(70));
  CON.setColorActive(color(70));
  CON.setColorForeground(color(70));

  d2 = controlP5.addDropdownList("SerialList", SerialX, SerialY, 150, 200);
  customize2(d2);

  img = loadImage("ABSWtitle.png");  // Load the image into the program

  //  controlP5.getTooltip().setDelay(200);
  //  controlP5.getTooltip().register("Range","Adjust endpoints to match your gauge. \nUse LEVEL to test.");
  //
}

void draw() {

  background(0);

  fill(color(255));

  image(img, 315, 15);

  fill(color(40));
  quad(30, 60, //good to go
  465, 60, 
  465, 230, 
  30, 230); 

  fill(color(40));
  quad(30, 246, //good to go
  465, 246, 
  465, 290, 
  30, 290); 

  fill(0xFF39E444);

  if (Flipped == false) {

    quad(SOCX, SOCY+SOCH+2, //good to go
    SOCX+((TempMin/1023)*300), RangeY-2, 
    SOCX+((TempMax/1023)*300), RangeY-2, 
    SOCX+SOCW, SOCY+SOCH+2);   // good to go
  } 
  else {

    quad(SOCX, SOCY+SOCH+2, //good to go
    SOCX+((TempMax/1023)*300), RangeY-2, 
    SOCX+((TempMin/1023)*300), RangeY-2, 
    SOCX+SOCW, SOCY+SOCH+2);   // good to go
  }

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

  if (SOCvalue < LLvalue) {      
    SOClevellabel.setColorValue(0xFFDE1616);
  }
  else
  {
    SOClevellabel.setColorValue(0xFFFFFFFF);
  }

  CAPlevelLabel.setValue(round(CAPvalue)+"Ah");
  CAPlevelLabel.setControlFont(labelFont);
  CAPlevelLabel.draw(this);

  if (!(controlP5.window().isMouseOver(d2)) && mousePressed) {

    d2.close();
    // d1.close();
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
      //  d2.captionLabel().setFontSize(13);
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

    if (theControlEvent.controller().name().equals("Range")) {
      // min and max values are stored in an array.
      // access this array with controller().arrayValue().
      // min is at index 0, max is at index 1.

      TempMin = theControlEvent.controller().arrayValue()[0];
      TempMax = theControlEvent.controller().arrayValue()[1];

      if (Flipped == false) {    

        FGH = int(TempMax);
        FGL = int(TempMin);
      }

      else {

        Flipped = true;
        FGH = int(TempMin);
        FGL = int(TempMax);
      }

      int Range = abs(FGH-FGL);

      if (Flipped==false) {

        Out = int(((SOCvalue/100))*Range)+int(TempMin);
      }
      else if (Flipped==true) {

        Out = int(TempMax)-int(((SOCvalue/100))*Range);
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

        delay(200);
      }
    }

    if (theControlEvent.controller().name().equals("SOC")) {

      SOCvalue = theControlEvent.controller().value();

      int Range = abs(FGH-FGL);


      if (Flipped==false) {

        Out = int(((SOCvalue/100))*Range)+int(TempMin);
      }
      else if (Flipped==true) {

        Out = int(TempMax)-int(((SOCvalue/100))*Range);
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

        delay(200);
      }
    }

    if (theControlEvent.controller().name().equals("LL")) {
      LLvalue = theControlEvent.controller().value();
      //println("Warn is "+round(LLvalue));
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
      }
    }


    if (theControlEvent.controller().name().equals("FLIP")) {   

      if (Flipped == false) {
        Flipped = true;  
        print("on");
      }

      else {
        Flipped = false;
        print("off");
      }
    }

    if (theControlEvent.controller().name().equals("ZERO")) {   //this updates range values

        slipStart();
      slipSend(0x00);    //version
      slipSend(0x00);    //Payload Size MSB
      slipSend(0x00);    //Payload Size LSB
      slipSend(0x16);    //Packet type

      slipSend(0x00);     // checksum
      slipEnd();

      // LoadfromAB();
    }

    if (theControlEvent.controller().name().equals("UPDATE")) {   //this updates range values

        println("update");

      slipStart();
      slipSend(0x00);    //version
      slipSend(0x00);    //Payload Size MSB
      slipSend(0x00);    //Payload Size LSB
      slipSend(0x10);    //Packet type

      slipSend(0x00);     // checksum
      slipEnd();
    }

    if (theControlEvent.controller().name().equals("LOAD")) {   //this updates range values

        LoadfromAB();
    }

    if (theControlEvent.controller().name().equals("CALIBRATE")) {

      InterceptCalibrate = Intercept;  // original Zero value now stored.

      // zero again to get value when power is flowing.

      slipStart();                  
      slipSend(0x00);    //version
      slipSend(0x00);    //Payload Size MSB
      slipSend(0x00);    //Payload Size LSB
      slipSend(0x16);    //Packet type
      slipSend(0x00);     // checksum
      slipEnd();
      //
      LoadfromAB();

      println("MinA" + theControlEvent.controller().stringValue());
      println("zero intercept is:" + InterceptCalibrate);
      println("powered intercept is:" + Intercept);

      float newslope = float(theControlEvent.controller().stringValue());

      newslope = abs(round((newslope * 10000)/(InterceptCalibrate-Intercept)));

      println("new slope is:" + newslope);
      // println(packet.ConfigBuffer);

      //program new values to EEPROM

      slipStart();
      slipSend(0x00);    //version
      slipSend(0x00);    //Payload Size MSB
      slipSend(0x13);    //Payload Size LSB
      slipSend(0x15);    //Packet type

      slipSend(packet.ConfigBuffer[0]);    //Fuel Gauge High end
      slipSend(packet.ConfigBuffer[1]);    //Fuel Gauge High end          

      slipSend(packet.ConfigBuffer[2]);    //Fuel Gauge Low end          
      slipSend(packet.ConfigBuffer[3]);    //Fuel Gauge Low end          

      slipSend(packet.ConfigBuffer[4]);
      slipSend(packet.ConfigBuffer[5]); 

      slipSend(packet.ConfigBuffer[6]);    
      slipSend(packet.ConfigBuffer[7]);    

      slipSend(packet.ConfigBuffer[8]);   

      slipSend((round(newslope) >> 8) & 0x03);     // Slope MSB
      slipSend(round(newslope) & 0xff);            // SLOPE LSB

      slipSend(byte((InterceptCalibrate&0x0000FF00)>>8));
      slipSend(byte((InterceptCalibrate&0x000000FF)));

      slipSend(OUTPUTMODE); 

      slipSend(0x00);     // checksum
      slipEnd();
    }



    if (theControlEvent.controller().name().equals("CON")) {   //this updates range values

        if (CONNECTED == false && portselected == true) {

        CONNECTED = true; 
        println("connected");
        // println("intercept = "+ Intercept);   

        controlP5.getController("CON")
          .setCaptionLabel("CONNECTED");

        // CONLabel.setValue("CONNECTED");
        //  CONLabel.setControlFont(new ControlFont(createFont("ISOCPEUR", 20)));
        CON.setWidth(112);
        CON.setColorForeground(0xFF39E444);
        CON.setColorBackground(0xFF00C90D);

        openPortAndGo();

        LoadfromAB();
      }

      else if (CONNECTED == true && portselected == true) {

        CONNECTED = false;
        println("disconnecting");

        controlP5.getController("CON")
          .setCaptionLabel("CONNECT");

        // CONLabel.setValue("CONNECT");
        // CONLabel.setControlFont(new ControlFont(createFont("ISOCPEUR", 20)));
        CON.setWidth(89);
        CON.setColorBackground(color(60));
        CON.setColorForeground(0xFF00C90D);

        serialPort.clear();
        // Close the port
        serialPort.stop();
      }
    }
  }
}

void openPortAndGo() {
  serialPort = new Serial(this, portName, 115200);
  serialPort.clear();
  serialPort.bufferUntil(byte(SlipEnd));
  serialReader = new SerialReader(serialPort, "serial1", portName);
}


void slipStart() {
  serialPort.write(0xC0);
}

void slipEnd() {
  serialPort.write(0xC0);
  println("");
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

  print(hex(dataByte, 2) +" ");
}

void customize2(DropdownList ddl2) {

  ddl2.setBackgroundColor(color(190));
  ddl2.setItemHeight(23);
  ddl2.setBarHeight(24);
  ddl2.captionLabel().set("Select Serial Port");
  ddl2.captionLabel().style().marginTop = 8;
  ddl2.captionLabel().style().marginLeft = 3;  
  ddl2.valueLabel().style().marginTop = 0;

  //ddl2.captionLabel().setFontSize(20);

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

        if (TempFGH > TempFGL) {

          r1.setHighValue(TempFGH);
          r1.setLowValue(TempFGL);
          T.setState(true);


          FGH = TempFGL;
          FGL = TempFGH;


          Flipped = false;
        }

        else if (TempFGH < TempFGL) {


          r1.setHighValue(TempFGL);
          r1.setLowValue(TempFGH);
          T.setState(false);


          FGH = TempFGH;
          FGL = TempFGL;

          Flipped = true;
        }      

        controlP5.controller("LL").setValue(LLvalue);         
        controlP5.controller("CAP").setValue(CAPvalue);
        controlP5.controller("PPR").setValue(tach);
      }
    }
  }
} 

