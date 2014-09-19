/**
 * ABamp configuration sketch
 *
 * Author:   RechargeCar Inc.
 * Version:  0.1
 *
 * License:  GPLv3
 *   (http://www.fsf.org/licensing/)
 *
 *
 * DISCLAIMER **
 * THIS SOFTWARE IS PROVIDED TO YOU "AS IS," AND WE MAKE NO EXPRESS OR IMPLIED WARRANTIES WHATSOEVER 
 * WITH RESPECT TO ITS FUNCTIONALITY, OPERABILITY, OR USE, INCLUDING, WITHOUT LIMITATION, ANY IMPLIED 
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR INFRINGEMENT. WE EXPRESSLY 
 * DISCLAIM ANY LIABILITY WHATSOEVER FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL OR SPECIAL 
 * DAMAGES, INCLUDING, WITHOUT LIMITATION, LOST REVENUES, LOST PROFITS, LOSSES RESULTING FROM BUSINESS 
 * INTERRUPTION OR LOSS OF DATA, REGARDLESS OF THE FORM OF ACTION OR LEGAL THEORY UNDER WHICH THE LIABILITY 
 * MAY BE ASSERTED, EVEN IF ADVISED OF THE POSSIBILITY OR LIKELIHOOD OF SUCH DAMAGES.
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

float LLvalue = 20;
float TempFGH = 1024;

int DCmsb;
int DClsb;

float SOCvalue = 1200;
float previousSOCvalue;
int windowindicator;   // 1 = SOC, 2 = TA, 3 = LL, 4 = NONE

final int SlipEnd = int(0xC0);

int  LLX = 100, LLY = 101, LLW = 300, LLH = 20;    //LLY=71

int FGBX1 = 29;
int FGBY1 = 177;
int FGBX2 = 465;
int FGBY2 = 177;
int FGBX3 = 465;
int FGBY3 = 337-55;
int FGBX4 = 29;
int FGBY4 = 337-55;

int TAX1 = 29;
int TAY1 = 327;
int TAX2 = 465-175;
int TAY2 = 327;
int TAX3 = 465-175;
int TAY3 = 383;
int TAX4 = 29;
int TAY4 = 383;

int LOWX1 = 29;
int LOWY1 = 91;
int LOWX2 = 465;
int LOWY2 = 91;
int LOWX3 = 465;
int LOWY3 = 130;
int LOWX4 = 29;
int LOWY4 = 130;


int SOCX = 100, SOCY = 445, SOCW = 300, SOCH = 20;
int SOC2 = 191;  // full slider
int SOC3 = SOC2 + 27;  // empty slider
int CAPX = 100, CAPY = 291-45, CAPW = 300, CAPH = 20;

float CAPvalue = 200;
int TACHX = 40, TACHY = CAPY+115;  //104
int AMPX = 250, AMPY = SOCY-27;
int TACHmsb;
int TACHlsb;

float AMPvalue = 100;

int SerialX = 30, SerialY =    42;
int PGMX =   410, PGMY =       17;
int CONX =   195, CONY =       17;
int LOADX =  510, LOADY =      17;

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

Textlabel FULLLabel, EMPTYLabel, LevelLabel, LLLabel, SOClevellabel, LLlevellabel, CAPLabel, 
CAPlevelLabel, TachLabel, ZEROLabel, CONLabel, AMPLabel, UPDATELabel, PPRlabel, FGLabel, 
TALabel, FGHIGHLabel, FGLOWLabel, LLlevellabel_LOADED, PPRlabel_LOADED, CAPlevelLabel_LOADED, 
FGHIGHLabel_LOADED, FGLOWLabel_LOADED, PPRLabel, LLSLabel, TACHLabel;

DropdownList d2;
String DDListname;

Button PGRM, CON, LOAD, CONFIG, RUN, FDOWN, FUP, EDOWN, EUP;

Slider s1, s2, s3, s4, s5, s6, s7;

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
  size(600, 500);

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

  windowindicator = 4;
}

int darkerbox = 75;   // actually lighter
int lighterbox = 35;   

void draw() {

  background(0);

  fill(color(255));

  image(img, 315, 385-50);

  fill(color(lighterbox));    // AB box (UNDER LOAD)
  quad(LOADX-1, 90, LOADX+60, 90, LOADX+60, TAY3, LOADX-1, TAY3);

  if (windowindicator == 1) {   // FG is active 
    fill(color(darkerbox));    // big box darker
    quad(FGBX1, FGBY1, FGBX2, FGBY2, FGBX3, FGBY3, FGBX4, FGBY4);

    fill(color(darkerbox));    // FG LABEL
    quad(FGBX1, FGBY1-26, FGBX2-275, FGBY2-26, FGBX3-275, FGBY1, FGBX4, FGBY1); 

    fill(color(lighterbox));    // TA box
    quad(TAX1, TAY1, TAX2, TAY2, TAX3, TAY4, TAX4, TAY4);

    fill(color(lighterbox));    // TA LABEL
    quad(TAX1, TAY1-26, FGBX2-275, TAY2-26, FGBX2-275, TAY1, TAX4, TAY1);

    fill(color(lighterbox));    // LL SIGNAL BOX
    quad(LOWX1, LOWY1, LOWX2, LOWY2, LOWX3, LOWY3, LOWX4, LOWY4);

    fill(color(lighterbox));    // LOW LABEL
    quad(LOWX1, LOWY1-26, LOWX2-275, LOWY2-26, LOWX2-275, LOWY1, LOWX1, LOWY1);
  }

  if (windowindicator == 2) {   // TA is active
    fill(color(lighterbox));    // FUEL GUAGE BOX
    quad(FGBX1, FGBY1, FGBX2, FGBY2, FGBX3, FGBY3, FGBX4, FGBY4);

    fill(color(lighterbox));    // FG LABEL
    quad(FGBX1, FGBY1-26, FGBX2-275, FGBY2-26, FGBX3-275, FGBY1, FGBX4, FGBY1); 

    fill(color(darkerbox));    // TA BOX
    quad(TAX1, TAY1, TAX2, TAY2, TAX3, TAY4, TAX4, TAY4);

    fill(color(darkerbox));    // TA LABEL
    quad(TAX1, TAY1-26, FGBX2-275, TAY2-26, FGBX2-275, TAY1, TAX4, TAY1);

    fill(color(lighterbox));    // LL SIGNAL BOX
    quad(LOWX1, LOWY1, LOWX2, LOWY2, LOWX3, LOWY3, LOWX4, LOWY4);

    fill(color(lighterbox));    // LOW LABEL
    quad(LOWX1, LOWY1-26, LOWX2-275, LOWY2-26, LOWX2-275, LOWY1, LOWX1, LOWY1);
  }


  if (windowindicator == 3) {      // LL is active
    fill(color(lighterbox));    // FUEL GUAGE BOX
    quad(FGBX1, FGBY1, FGBX2, FGBY2, FGBX3, FGBY3, FGBX4, FGBY4);

    fill(color(lighterbox));    // FG LABEL
    quad(FGBX1, FGBY1-26, FGBX2-275, FGBY2-26, FGBX3-275, FGBY1, FGBX4, FGBY1); 

    fill(color(lighterbox));    // // TA BOX
    quad(TAX1, TAY1, TAX2, TAY2, TAX3, TAY4, TAX4, TAY4);

    fill(color(lighterbox));    // TA LABEL
    quad(TAX1, TAY1-26, FGBX2-275, TAY2-26, FGBX2-275, TAY1, TAX4, TAY1);
    
    fill(color(darkerbox));    // LL SIGNAL BOX
    quad(LOWX1, LOWY1, LOWX2, LOWY2, LOWX3, LOWY3, LOWX4, LOWY4);

    fill(color(darkerbox));    // LOW LABEL
    quad(LOWX1, LOWY1-26, LOWX2-275, LOWY2-26, LOWX2-275, LOWY1, LOWX1, LOWY1);
  }

  if (windowindicator == 4) {      //none are active
    fill(color(lighterbox));    // FUEL GUAGE BOX
    quad(FGBX1, FGBY1, FGBX2, FGBY2, FGBX3, FGBY3, FGBX4, FGBY4);

    fill(color(lighterbox));    // FG LABEL
    quad(FGBX1, FGBY1-26, FGBX2-275, FGBY2-26, FGBX3-275, FGBY1, FGBX4, FGBY1); 

    fill(color(lighterbox));    // // TA BOX
    quad(TAX1, TAY1, TAX2, TAY2, TAX3, TAY4, TAX4, TAY4);

    fill(color(lighterbox));    // TA LABEL
    quad(TAX1, TAY1-26, FGBX2-275, TAY2-26, FGBX2-275, TAY1, TAX4, TAY1);

    fill(color(lighterbox));    // LL SIGNAL BOX
    quad(LOWX1, LOWY1, LOWX2, LOWY2, LOWX3, LOWY3, LOWX4, LOWY4);

    fill(color(lighterbox));    // LOW LABEL
    quad(LOWX1, LOWY1-26, LOWX2-275, LOWY2-26, LOWX2-275, LOWY1, LOWX1, LOWY1);
  }

  SOClevellabel.setValue(round(SOCvalue)+"%");
  SOClevellabel.setControlFont(labelFont);
  SOClevellabel.setVisible(CONNECTED);

  LLlevellabel.setValue(round(LLvalue)+"%");
  LLlevellabel.setControlFont(labelFont);
  LLlevellabel.setVisible(CONNECTED);

  AMPLabel.setValue(round(AMPvalue)+"A");
  AMPLabel.setControlFont(labelFont);
  AMPLabel.setVisible(CONNECTED);

  PPRlabel.setValue(round(tach)+" ");
  PPRlabel.setControlFont(labelFont);
  PPRlabel.setVisible(CONNECTED);

  FGHIGHLabel.setValue(round(TempMax)+"");
  FGHIGHLabel.setControlFont(labelFont);
  FGHIGHLabel.setVisible(CONNECTED);

  FGLOWLabel.setValue(round(TempMin)+"");
  FGLOWLabel.setControlFont(labelFont);
  FGLOWLabel.setVisible(CONNECTED);

  CAPlevelLabel.setValue(round(CAPvalue)+"Ah");
  CAPlevelLabel.setControlFont(labelFont);
  CAPlevelLabel.setVisible(CONNECTED);

  // LLlevellabel_LOADED.setValue(round(CAPvalue)+"Ah");
  LLlevellabel_LOADED.setControlFont(labelFont);
  LLlevellabel_LOADED.setVisible(CONNECTED);

  // PPRlabel_LOADED.setValue(round(CAPvalue)+"Ah");
  PPRlabel_LOADED.setControlFont(labelFont);
  PPRlabel_LOADED.setVisible(CONNECTED);

  // CAPlevelLabel_LOADED.setValue(round(CAPvalue)+"Ah"); //
  CAPlevelLabel_LOADED.setControlFont(labelFont);
  CAPlevelLabel_LOADED.setVisible(CONNECTED);

  // FGHIGHLabel_LOADED.setValue(TempFGH);
  FGHIGHLabel_LOADED.setControlFont(labelFont);
  FGHIGHLabel_LOADED.setVisible(CONNECTED);

  //FGLOWLabel_LOADED.setValue(round(CAPvalue)+"Ah");
  FGLOWLabel_LOADED.setControlFont(labelFont);
  FGLOWLabel_LOADED.setVisible(CONNECTED);


  if (SOCvalue < LLvalue) {      
    SOClevellabel.setColorValue(0xFFDE1616);
  } else
  {
    SOClevellabel.setColorValue(0xFFFFFFFF);
  }
  //}

  if (!(controlP5.window().isMouseOver(d2)) && mousePressed) {
    d2.close();
  }

  if ((controlP5.window().isMouseOver(d2))  && mousePressed && !d2.isOpen()  ) {   //repopulates drop-down menu when caption is pressed
    d2.clear();
    for (int i=0; i< (Serial.list ().length); i++) {
      d2.addItem(Serial.list()[i], i);
    }
    d2.setHeight(((Serial.list().length)+1)*23);
  }

  if (CONNECTED == true) { 

    if ((mouseX > FGBX1 && mouseX < FGBX2 && mouseY > FGBY1 && mouseY < FGBY3 && mousePressed) ||   // FG WINDOW
    (mouseX > FGBX1 && mouseX < FGBX2-275 &&  mouseY > FGBY1-26 && mouseY < FGBY1 && mousePressed) )        

    {
      AMPvalue = 0;
      controlP5.controller("AMP").setValue(AMPvalue); 
      windowindicator = 1;
    }

    if ((mouseX > TAX1 && mouseX < TAX2 && mouseY > TAY1 && mouseY < TAY3 && mousePressed) ||    // TA WINDOW
    (mouseX > TAX1 && mouseX < FGBX2-275 && mouseY > TAY1-26 && mouseY < TAY1 && mousePressed))
    
    
 //   quad(TAX1, TAY1-26, FGBX2-275, TAY2-26, FGBX2-275, TAY1, TAX4, TAY1);

    {
      windowindicator = 2;
    }


    if ((mouseX > LOWX1 && mouseX < LOWX2 && mouseY > LOWY1 && mouseY < LOWY3 && mousePressed) ||    // LL INDICATOR
    (mouseX > LOWX1 && mouseX < LOWX2-275 && mouseY > LOWY1-26 && mouseY < LOWY1 && mousePressed))

    {
      AMPvalue = 0;
      controlP5.controller("AMP").setValue(AMPvalue); 
      windowindicator = 3;
    }
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
      for (int i=0; i< (Serial.list ().length); i++) {
        d2.addItem(Serial.list()[i], i);
      }
    }
  } else {

    if ((theControlEvent.controller().name().equals("FULL")) || 
      (theControlEvent.controller().name().equals("EMPTY")) ||
      (theControlEvent.controller().name().equals("FDOWN")) ||
      (theControlEvent.controller().name().equals("FUP")) ||
      (theControlEvent.controller().name().equals("EDOWN")) ||
      (theControlEvent.controller().name().equals("EUP"))

    ) {   // if range sliders are moved, or buttons are pressed.
      if (CONNECTED == true) {

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
        } else if (TempMax < TempMin) { 

          Out = int(TempMin)-int(((SOCvalue/100))*Range);
          //   println(Out);
          //    FGH = int(TempMin);
          //    FGL = int(TempMax);
          FGH = int(TempMax);   // just changed these...
          FGL = int(TempMin);
        }

        //if (CONNECTED == true) {

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

        delay(100);

        windowindicator = 1;
      }
    }

    if (theControlEvent.controller().name().equals("SOC")) {

      SOCvalue = theControlEvent.controller().value();

      if (SOCvalue != previousSOCvalue) {

        int Range = abs(int(TempMax)-int(TempMin));

        if (TempMax > TempMin) { 

          Out = int(((SOCvalue/100))*Range)+int(TempMin);     
          println(Out);
        } else if (TempMax < TempMin) { 

          Out = int(TempMin)-int(((SOCvalue/100))*Range);
          println(Out);
        }

        if (CONNECTED == true) {      

          AMPvalue = 0;
          controlP5.controller("AMP").setValue(AMPvalue); 
          windowindicator = 1;  
          //println("1"); 

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
      if (CONNECTED == true) {  

        windowindicator = 3;
      }
    }

    if (theControlEvent.controller().name().equals("AMP")) {
      AMPvalue = theControlEvent.controller().value();

      if (CONNECTED == true) {    

        windowindicator = 2;
        //println("2");

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

      if (CONNECTED == true) {  
        windowindicator = 2;
      }
    }

    if (theControlEvent.controller().name().equals("CAP")) {
      CAPvalue = theControlEvent.controller().value();
      if (CONNECTED == true) {  
        windowindicator = 1;
      }
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

        delay(250);

        LoadfromAB();
        windowindicator = 4;
      }
    }


    if (theControlEvent.controller().name().equals("LOAD")) {   //this updates range values

        if (CONNECTED == true) { 
        // updateSOC();
              LoadfromAB();

//        slipStart();
//        slipSend(0x00);    //version
//        slipSend(0x00);    //Payload Size MSB
//        slipSend(0x00);    //Payload Size LSB
//        slipSend(0x17);    //Packet type
//        slipSend(0x00);     // checksum
//        slipEnd();

        windowindicator = 4;
      }
    }
    
        if (theControlEvent.controller().name().equals("RUN")) {   //this updates range values

        if (CONNECTED == true) { 
        // updateSOC();
        //      LoadfromAB();

        slipStart();
        slipSend(0x00);    //version
        slipSend(0x00);    //Payload Size MSB
        slipSend(0x00);    //Payload Size LSB
        slipSend(0x17);    //Packet type
        slipSend(0x00);     // checksum
        slipEnd();

        windowindicator = 4;
      }
    }

    if (theControlEvent.controller().name().equals("CON")) { 

      if (CONNECTED == false && portselected == true) {

        CONNECTED = true; 

        openPortAndGo();
        println("First attempt to connect");
        //;
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

        s1.setColorBackground(0xFF00C90D);
        s1.setColorForeground(0xFF39E444);
        s1.setColorActive(0xFF67E46F);

        s2.setColorBackground(color(50));
        s2.setColorActive(0xFFD1526C);
        s2.setColorForeground(0xFF95001E);

        s3.setColorBackground(0xFF00C90D);
        s3.setColorForeground(0xFF39E444);
        s3.setColorActive(0xFF67E46F);

        s4.setColorBackground(0xFF00C90D);
        s4.setColorForeground(0xFF39E444);
        s4.setColorActive(0xFF67E46F);

        s5.setColorBackground(0xFF00C90D);
        s5.setColorForeground(0xFF39E444);
        s5.setColorActive(0xFF67E46F);

        s6.setColorBackground(color(60));
        s6.setColorForeground(0xFF39E444);
        s6.setColorActive(0xFF67E46F);

        s7.setColorBackground(color(60));
        s7.setColorForeground(0xFF39E444);
        s7.setColorActive(0xFF67E46F);

        FDOWN.setColorBackground(0xFF00C90D);
        FDOWN.setColorForeground(0xFF39E444);
        FDOWN.setColorActive(0xFF67E46F);

        FUP.setColorBackground(0xFF00C90D);
        FUP.setColorForeground(0xFF39E444);
        FUP.setColorActive(0xFF67E46F);

        EDOWN.setColorBackground(0xFF00C90D);
        EDOWN.setColorForeground(0xFF39E444);
        EDOWN.setColorActive(0xFF67E46F);

        EUP.setColorBackground(0xFF00C90D);
        EUP.setColorForeground(0xFF39E444);
        EUP.setColorActive(0xFF67E46F);
        
        RUN.setColorBackground(0xFF00C90D);
        RUN.setColorForeground(0xFF39E444);
        RUN.setColorActive(0xFF67E46F);

        delay(100);

        if (serialReader.available() == false) {   // check to see if we connected, if not, close and try again

          serialPort.clear();
          serialPort.stop();
          openPortAndGo();
          println("2nd attempt");
        }

        LoadfromAB();

        windowindicator = 4;
      } else if (CONNECTED == true && portselected == true) {

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

        s1.setColorBackground(color(60));
        s1.setColorForeground(color(60));
        s1.setColorActive(color(60));

        s2.setColorBackground(color(60));
        s2.setColorForeground(color(60));
        s2.setColorActive(color(60));

        s3.setColorBackground(color(60));
        s3.setColorForeground(color(60));
        s3.setColorActive(color(60));

        s4.setColorBackground(color(60));
        s4.setColorForeground(color(60));
        s4.setColorActive(color(60));

        s5.setColorBackground(color(60));
        s5.setColorForeground(color(60));
        s5.setColorActive(color(60));

        s6.setColorBackground(color(60));
        s6.setColorForeground(color(60));
        s6.setColorActive(color(60));

        s7.setColorBackground(color(60));
        s7.setColorForeground(color(60));
        s7.setColorActive(color(60));

        FDOWN.setColorBackground(color(60));
        FDOWN.setColorForeground(color(60));
        FDOWN.setColorActive(color(60));

        FUP.setColorBackground(color(60));
        FUP.setColorForeground(color(60));
        FUP.setColorActive(color(60));

        EDOWN.setColorBackground(color(60));
        EDOWN.setColorForeground(color(60));
        EDOWN.setColorActive(color(60));

        EUP.setColorBackground(color(60));
        EUP.setColorForeground(color(60));
        EUP.setColorActive(color(60));


        serialPort.clear();

        delay(100);
        LoadfromAB();   // why was this here again? it seems to make diconnecting more consistant..I guess.
        serialPort.stop();
        windowindicator = 4;
      }
    }
  }
}

void openPortAndGo() {
  serialPort = new Serial(this, portName, 1200);
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
  } else if (dataByte == 0xC0) {
    serialPort.write(0xDB); //SlipEsc
    serialPort.write(0xDC); //SlipEscEnd
  } else { //must be 0xDB / SlipEsc
    serialPort.write(0xDB);//SlipEsc
    serialPort.write(0xDD);//SlipEscEsc
  }

  //print(hex(dataByte, 2) +" ");
}

void customize2(DropdownList ddl2) {

  // ddl2.setBackgroundColor(0xFF00C90D);
  // ddl2.setColorBackground(0xFF00C90D);
  ddl2.setItemHeight(23);
  ddl2.setBarHeight(24);
  ddl2.captionLabel().set("SELECT SERIAL PORT");
  ddl2.captionLabel().style().marginTop = 8;
  ddl2.captionLabel().style().marginLeft = 3;  
  ddl2.valueLabel().style().marginTop = 0;

  for (int i=0; i< (Serial.list ().length); i++) {
    ddl2.addItem(Serial.list()[i], i);
  }

  //ddl2.setColorBackground(color(80));
  ddl2.setBackgroundColor(0xFF00C90D);
  //ddl2.setColorActive(color(80));
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

          CAPlevelLabel_LOADED.setValue(round(CAPvalue)+"Ah");    
          PPRlabel_LOADED.setValue(round(tach)+" PPR");   
          LLlevellabel_LOADED.setValue(round(LLvalue)+" %");
          FGHIGHLabel_LOADED.setValue(TempFGH+"");
          FGLOWLabel_LOADED.setValue(round(TempFGL)+"");


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

