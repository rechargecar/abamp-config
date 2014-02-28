import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AutoBlockAMP_GaugeConfig extends PApplet {

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
int windowindicator;   // 1 = SOC, 2 = TA, 3 = nonething

final int SlipEnd = PApplet.parseInt(0xC0);

int  LLX = 100, LLY = 101, LLW = 300, LLH = 20;    //LLY=71

int SOCX = 100, SOCY = LLY +28, SOCW = 300, SOCH = 40;
int SOC2 = SOCY + 47;  // full slider
int SOC3 = SOC2 + 27;  // empty slider
int CAPX = 100, CAPY = SOCY+102, CAPW = 300, CAPH = 20;

float CAPvalue = 200;
int TACHX = 40, TACHY = CAPY+104;  //84
int AMPX = 250, AMPY = TACHY-15;
int TACHmsb;
int TACHlsb;

float AMPvalue = 100;

int SerialX = 30, SerialY =    42;
int PGMX =   410, PGMY =       60;
int CONX =   195, CONY =       17;
int LOADX =  510, LOADY =      60;

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
FGHIGHLabel_LOADED, FGLOWLabel_LOADED;

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


public void setup() {
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

  windowindicator = 3;
}

int darkerbox = 75;   // actually lighter
int lighterbox = 35;   


public void draw() {

  background(0);

  fill(color(255));

  image(img, 315, 385);   //15

    if (windowindicator == 1) {      
    fill(color(darkerbox));    // big box darker
    quad(29, 91, 465, 91, 465, 262, 29, 262);

    fill(color(lighterbox));    // small box
    quad(29, 308, 465, 308, 465, 357, 29, 357);

    fill(color(darkerbox));    // FG box
    quad(29, 65, 190, 65, 190, 91, 29, 91); 

    fill(color(lighterbox));    // TA box
    quad(29, 282, 165, 282, 165, 308, 29, 308);
  }

  if (windowindicator == 2)  
  {
    fill(color(lighterbox));    // big box lighter
    quad(29, 91, 465, 91, 465, 262, 29, 262);

    fill(color(darkerbox));    // small box
    quad(29, 308, 465, 308, 465, 357, 29, 357);

    fill(color(lighterbox));    // FG box
    quad(29, 65, 190, 65, 190, 91, 29, 91); 

    fill(color(darkerbox));    // TA box
    quad(29, 282, 165, 282, 165, 308, 29, 308);
  }

  if (windowindicator == 3) {      
    fill(color(lighterbox));    // big box darker
    quad(29, 91, 465, 91, 465, 262, 29, 262);

    fill(color(lighterbox));    // small box
    quad(29, 308, 465, 308, 465, 357, 29, 357);

    fill(color(lighterbox));    // FG box
    quad(29, 65, 190, 65, 190, 91, 29, 91); 

    fill(color(lighterbox));    // TA box
    quad(29, 282, 165, 282, 165, 308, 29, 308);
  }
  
    fill(color(lighterbox));    // AB box
    quad(LOADX-1, 90, LOADX+60, 90, LOADX+60, 400, LOADX-1, 400);
  

  SOClevellabel.setValue(round(SOCvalue)+"%");
  SOClevellabel.setControlFont(labelFont);
  SOClevellabel.setVisible(CONNECTED);

  LLlevellabel.setValue(round(LLvalue)+"%");
  LLlevellabel.setControlFont(labelFont);
  LLlevellabel.setVisible(CONNECTED);

  AMPLabel.setValue(round(AMPvalue)+"A");
  AMPLabel.setControlFont(labelFont);
  AMPLabel.setVisible(CONNECTED);

  PPRlabel.setValue(round(tach)+" PPR");
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
  }
  else
  {
    SOClevellabel.setColorValue(0xFFFFFFFF);
  }
  //}

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

  if (CONNECTED == true) { 

    if ((mouseX > 29 && mouseX < 465 && 
      mouseY > 91 && mouseY < 262 && mousePressed) || 
      (mouseX > 29 && mouseX < 190 && 
      mouseY > 65 && mouseY < 91 && mousePressed) )      

    {

      AMPvalue = 0;
      controlP5.controller("AMP").setValue(AMPvalue); 
      windowindicator = 1;
    }

    if ((mouseX > 29 && mouseX < 465 && 
      mouseY > 308 && mouseY < 357 && mousePressed) || 
      (mouseX > 29 && mouseX < 165 && 
      mouseY > 282 && mouseY < 308 && mousePressed))

    {
      windowindicator = 2;
    }
  }
}

public void controlEvent(ControlEvent theControlEvent) {

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

        int Range = abs(PApplet.parseInt(TempMax)-PApplet.parseInt(TempMin));

        if (TempMax > TempMin) { 

          Out = PApplet.parseInt(((SOCvalue/100))*Range)+PApplet.parseInt(TempMin);
          //  println(Out);
          FGH = PApplet.parseInt(TempMax);   // just changed these...
          FGL = PApplet.parseInt(TempMin);
        }

        else if (TempMax < TempMin) { 

          Out = PApplet.parseInt(TempMin)-PApplet.parseInt(((SOCvalue/100))*Range);
          //   println(Out);
          //    FGH = int(TempMin);
          //    FGL = int(TempMax);
          FGH = PApplet.parseInt(TempMax);   // just changed these...
          FGL = PApplet.parseInt(TempMin);
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

        int Range = abs(PApplet.parseInt(TempMax)-PApplet.parseInt(TempMin));

        if (TempMax > TempMin) { 

          Out = PApplet.parseInt(((SOCvalue/100))*Range)+PApplet.parseInt(TempMin);     
          println(Out);
        }

        else if (TempMax < TempMin) { 

          Out = PApplet.parseInt(TempMin)-PApplet.parseInt(((SOCvalue/100))*Range);
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
      LLvalue = PApplet.parseInt(theControlEvent.controller().value());
      //  println("LL is "+round(LLvalue));
      if (CONNECTED == true) {  

        windowindicator = 1;
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

        slipSend((PApplet.parseInt(LLvalue) >> 8) & 0x03);    //LL MSB
        slipSend(PApplet.parseInt(LLvalue) & 0xff);    //LL LSB  

        slipSend((round(CAPvalue) >> 8) & 0x03);    
        slipSend(round(CAPvalue) & 0xff);    

        slipSend(tach);     

        slipSend((Slope >> 8) & 0x03);    
        slipSend(Slope & 0xff);   

        slipSend(PApplet.parseByte((Intercept&0x0000FF00)>>8));
        slipSend(PApplet.parseByte((Intercept&0x000000FF)));

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
        
       // LoadfromAB();
           windowindicator = 3;
      }
    }


    if (theControlEvent.controller().name().equals("LOAD")) {   //this updates range values

        if (CONNECTED == true) { 
        // updateSOC();
        LoadfromAB();
        windowindicator = 3;
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

        delay(100);

        if (serialReader.available() == false) {   // check to see if we connected, if not, close and try again

          serialPort.clear();
          serialPort.stop();
          openPortAndGo();
          println("2nd attempt");
        }

        LoadfromAB();

        windowindicator = 3;
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
        windowindicator = 3;
      }
    }
  }
}

public void openPortAndGo() {
  serialPort = new Serial(this, portName, 9600);
  serialPort.clear();
  serialPort.bufferUntil(PApplet.parseByte(SlipEnd));
  serialReader = new SerialReader(serialPort, "serial1", portName);
}

public void slipStart() {
  serialPort.write(0xC0);
  // delay(10);
}

public void slipEnd() {
  serialPort.write(0xC0);
  // println("");
}

public void slipSend (int dataByte) { 

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

public void customize2(DropdownList ddl2) {

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

public void serialEvent(Serial p) {
  serialReader.checkSerial();
}

public void LoadfromAB() {

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


public void updateSOC()
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

public void createSliders()
{

  s1 = controlP5.addSlider("SOC", 0, 100, 50, SOCX, SOCY, SOCW, SOCH);  //this is the SOC slider
  s1.setSliderMode(Slider.FIX);
  s1.setMoveable(false);
  s1.valueLabel().setVisible(false);
  s1.setCaptionLabel("");
  s1.setHandleSize(5) ;
  s1.setColorBackground(color(60));
  s1.setColorForeground(color(60));
  s1.setColorActive(color(60));

  s2 = controlP5.addSlider("LL", 0, 100, 15, LLX, LLY, LLW, LLH);    // this is the warning slider
  s2.setSliderMode(Slider.FLEXIBLE);
  s2.setMoveable(false);
  s2.valueLabel().setVisible(false);
  s2.setCaptionLabel("");
  //s2.setNumberOfTickMarks(51);
//  s2.setColorBackground(color(50));
//  s2.setColorActive(0xFFD1526C);
//  s2.setColorForeground(0xFF95001E);
  // s2.setHandleSize(15) ;
  //s2.setNumberOfTickMarks(21);
    s2.setColorBackground(color(60));
  s2.setColorForeground(color(60));
  s2.setColorActive(color(60));


  s3 = controlP5.addSlider("CAP", 1, 300, 200, CAPX, CAPY, CAPW, CAPH);  // this is capacity slider
  //s3.setSliderMode(Slider.FIX);
  s3.setMoveable(false);
  s3.valueLabel().setVisible(false);
  s3.setCaptionLabel("");
  //s3.setNumberOfTickMarks(40);
    s3.setColorBackground(color(60));
  s3.setColorForeground(color(60));
  s3.setColorActive(color(60));

  s4 = controlP5.addSlider("AMP", 0, 800, 0, AMPX, AMPY, 150, 20);   // this is the tach output slider
  s4.setSliderMode(Slider.FLEXIBLE);
  s4.setMoveable(false);
  s4.valueLabel().setVisible(false);
  s4.setCaptionLabel("");
  //s4.setNumberOfTickMarks(199);
  s4.setHandleSize(5) ;
  s4.setNumberOfTickMarks(9);  
      s4.setColorBackground(color(60));
  s4.setColorForeground(color(60));
  s4.setColorActive(color(60));

  s5 = controlP5.addSlider("PPR", 1, 4, 0, TACHX+10, TACHY-15, 132, 20);  // this is the PPR slider
  s5.setSliderMode(Slider.FLEXIBLE);
  s5.setMoveable(false);
  s5.valueLabel().setVisible(false);
  s5.setCaptionLabel("");
  s5.setNumberOfTickMarks(4);  
      s5.setColorBackground(color(60));
  s5.setColorForeground(color(60));
  s5.setColorActive(color(60));

  s6 = controlP5.addSlider("FULL", 0, 1023, (1024/4)*3, SOCX+25, SOC2, SOCW-50, 20);  //this is the FULL slider
  s6.setSliderMode(Slider.FLEXIBLE);
  s6.setMoveable(false);
  s6.valueLabel().setVisible(false);
  s6.setCaptionLabel("");
  s6.setHandleSize(10) ;
//  s6.setColorBackground(color(60));
//  s6.setColorForeground(0xFF39E444);
//  s6.setColorActive(0xFF67E46F);
    s6.setColorBackground(color(60));
  s6.setColorForeground(color(60));
  s6.setColorActive(color(60));
   
  s7 = controlP5.addSlider("EMPTY", 0, 1023, (1024/4)*1, SOCX+25, SOC3, SOCW-50, 20);  //this is the EMPTY slider
  s7.setSliderMode(Slider.FLEXIBLE);
  s7.setMoveable(false);
  s7.valueLabel().setVisible(false);
  s7.setCaptionLabel("");
  s7.setHandleSize(10) ;
      s7.setColorBackground(color(60));
  s7.setColorForeground(color(60));
  s7.setColorActive(color(60));
}

public void createlabels()
{

  LLLabel = controlP5.addTextlabel("label3", "WARN", 34, LLY);   //LLX-64
  LLLabel.draw(this); 
  LLLabel.setControlFont(labelFont);

  LevelLabel = controlP5.addTextlabel("label2", "LEVEL", 34, SOCY+10);  //SOCX-64
  LevelLabel.draw(this); 
  LevelLabel.setControlFont(labelFont);

  FULLLabel = controlP5.addTextlabel("label17", "FULL", 34, SOC2);   //RangeX-67
  FULLLabel.draw(this); 
  FULLLabel.setControlFont(labelFont);

  EMPTYLabel = controlP5.addTextlabel("label", "EMPTY", 34, SOC3);  // rangeX-67
  EMPTYLabel.draw(this); 
  EMPTYLabel.setControlFont(labelFont);

  CAPLabel = controlP5.addTextlabel("label6", "PACK", 34, CAPY-0);   //CAPX-55
  CAPLabel.draw(this); 
  CAPLabel.setControlFont(labelFont);

  FGLabel = controlP5.addTextlabel("label8", "FUEL GAUGE SETUP", 34, LLY-31);   //LLX-64
  FGLabel.draw(this); 
  FGLabel.setControlFont(labelFont1);
  FGLabel.setColorValue(60);

  TALabel = controlP5.addTextlabel("label9", "TACH-AMMETER", 34, LLY+186);   //LLX-64
  TALabel.draw(this); 
  TALabel.setControlFont(labelFont1);
  TALabel.setColorValue(60);



  LLlevellabel = controlP5.addTextlabel("label5", LLvalue +" %", SOCX+SOCW+5, LLY); 
  
  LLlevellabel_LOADED = controlP5.addTextlabel("label23", LLvalue +" %", LOADX, LLY);  // NEW

  SOClevellabel = controlP5.addTextlabel("label4", SOCvalue+" %", SOCX+SOCW+5, SOCY+9);    

  PPRlabel = controlP5.addTextlabel("label15", tach +" PPR", TACHX+150, TACHY-15); 
  
  PPRlabel_LOADED = controlP5.addTextlabel("label24", tach +" PPR", LOADX, TACHY-15);  // NEW

  AMPLabel = controlP5.addTextlabel("label12", AMPvalue+" %", SOCX+SOCW+5, AMPY-1); 

  CAPlevelLabel = controlP5.addTextlabel("label7", CAPvalue + "Ah", SOCX+SOCW+5, CAPY-1); 
  
  CAPlevelLabel_LOADED = controlP5.addTextlabel("label25", CAPvalue + "Ah", LOADX, CAPY-1);  // NEW

  FGHIGHLabel = controlP5.addTextlabel("label21", 0 + "", CAPX+CAPW+5, CAPY-55);
  
  FGHIGHLabel_LOADED = controlP5.addTextlabel("label26", 0 + "", LOADX, CAPY-55);  // NEW

  FGLOWLabel = controlP5.addTextlabel("label22", 0 + "", CAPX+CAPW+5, CAPY-28);
  
  FGLOWLabel_LOADED = controlP5.addTextlabel("label27", 0 + "", LOADX, CAPY-28);  // NEW
  
 
}

public void createButtons()
{

  //  CONFIG = controlP5.addButton("CONFIG", 0, 345, CONY, 53, 25);  // use this as a mode indicator
  //  controlP5.getController("CONFIG")
  //    .getCaptionLabel()
  //    .setControlFont(labelFont);
  //  CONFIG.captionLabel().getStyle().marginTop = 1;
  //  CONFIG.setCaptionLabel("");  
  //  
  //   RUN = controlP5.addButton("RUN", 0, 412, CONY, 53, 25);       // use this as a mode indicator
  //  controlP5.getController("RUN")
  //    .getCaptionLabel()
  //    .setControlFont(labelFont);
  //  RUN.captionLabel().getStyle().marginTop = 1;
  //  RUN.setCaptionLabel("");  

  PGRM = controlP5.addButton("PGRM", 0, PGMX, PGMY, 55, 25);
  controlP5.getController("PGRM")
    .getCaptionLabel()
      .setControlFont(labelFont);
  PGRM.captionLabel().getStyle().marginTop = 1;

  PGRM.setColorBackground(color(60));   // make it grey
  PGRM.setColorForeground(color(60));
  PGRM.setColorActive(color(60));

  LOAD = controlP5.addButton("LOAD", 0, LOADX, LOADY, 52, 25);
  controlP5.getController("LOAD")
    .getCaptionLabel()
      .setControlFont(labelFont);
  LOAD.captionLabel().getStyle().marginTop = 1;

  LOAD.setColorBackground(color(60));   // make it grey
  LOAD.setColorForeground(color(60));
  LOAD.setColorActive(color(60));

  CON= controlP5.addButton("CON", 0, CONX, CONY, 89, 24);

  controlP5.getController("CON")
    .setCaptionLabel("CONNECT");
  controlP5.getController("CON")
    .getCaptionLabel()
      .setControlFont(labelFont);
  CON.captionLabel().getStyle().marginTop = 0;

  CON.setColorBackground(color(60));
  CON.setColorActive(color(60));
  CON.setColorForeground(color(60));


  FDOWN = controlP5.addButton("FDOWN", 0, SOCX, SOC2, 20, 20);
  FDOWN.setCaptionLabel("");  
  FDOWN.setColorBackground(color(60));
  FDOWN.setColorForeground(color(60));
  FDOWN.setColorActive(color(60));

  FUP = controlP5.addButton("FUP", 0, SOCW+80, SOC2, 20, 20);
  FUP.setCaptionLabel("");  
  FUP.setColorBackground(color(60));
  FUP.setColorForeground(color(60));
  FUP.setColorActive(color(60));

  EDOWN = controlP5.addButton("EDOWN", 0, SOCX, SOC3, 20, 20);
  EDOWN.setCaptionLabel("");  
  EDOWN.setColorBackground(color(60));
  EDOWN.setColorForeground(color(60));
  EDOWN.setColorActive(color(60));

  EUP = controlP5.addButton("EUP", 0, SOCW+80, SOC3, 20, 20);
  EUP.setCaptionLabel(""); 
  EUP.setColorBackground(color(60));
  EUP.setColorForeground(color(60));
  EUP.setColorActive(color(60)); 



  //  Slider s6 = controlP5.addSlider("FULL", 0, 1023, (1024/4)*3, SOCX+25, SOC2, SOCW-50, 20);  //this is the FULL slider
}

/*
 * ----------------------------------
 *  serialFunctions Class for Processing 2.0
 * ----------------------------------
 *
 *
 * DEPENDENCIES:
 *   N/A
 *
 * Created:  April, 23 2012
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
 



public class RCIPacket {
  public int packetType;
  public int value;
  public int ConfigBuffer[];
}

public class SerialReader {
  final int SlipEnd = 0xC0;
  final int SlipEsc = 0xDB;
  final int SlipEscEnd = 0xDC;
  final int SlipEscEsc = 0xDD;

  private String id; // Thread name/id, in case of multiple instances
  private String port; // Serial port name to open for the thread
  private boolean available; // Has a new packet been received and parsed?
  private boolean newData;
  private Serial myPort;
  private int readResult;
  private int[] packetBuffer;
  private int bufferPosition;
  private RCIPacket packet;

  // Constructor, probably want the serial port name passed in here
  public SerialReader(Serial tempSerial, String s, String portName) {
    id = s;
    readResult = 0;
    packetBuffer = new int[30];
    packet = new RCIPacket();
    bufferPosition = 0;
    newData = false;
    available = false;

    myPort = tempSerial;
    //    myPort.clear();
    //    myPort.bufferUntil(SlipEnd);
  }

  public void checkSerial() {
    //    if(myPort.available() > 0) readResult = slipRead(packetBuffer, bufferPosition, 20);
    int tempRead = slipRead(packetBuffer, bufferPosition, 20);
    if (tempRead > 2) {    
      newData = true;
    }
    bufferPosition += tempRead;
    if (newData) {
      newData = false;
      if (bufferPosition > 8) {

        if (packetBuffer[3] == 5) {

          packet.packetType = 5;
          
          packet.value =  ((packetBuffer[4] & 0xff) << 16) | ((packetBuffer[5] & 0xff) << 8)  | (packetBuffer[6] & 0xff);
          available = true;
          
        }

        if (packetBuffer[3] == 4) {

          packet.packetType = 4;
          packet.value = ((packetBuffer[4] & 0xff) << 24) | ((packetBuffer[5] & 0xff) << 16) | ((packetBuffer[6] & 0xff) << 8)  | (packetBuffer[7] & 0xff);      
          available = true;
          
        } 
        
        if (packetBuffer[3] == 0x18) {

          packet.packetType = 18;
          packet.ConfigBuffer = subset(packetBuffer, 4, 14); 
          available = true;
          
        }      
        bufferPosition = 0;
      }
    }
  }

  public boolean available() {
    return available;
  }

  public RCIPacket getPacket() {
    available = false;
    return packet;
  }  

  /// <summary>
  /// Overrides base SerialProvider.Read() method to provide SLIP framing.
  /// </summary>
  /// <param name="buffer"></param>
  /// <param name="offset"></param>
  /// <param name="size"></param>
  public int slipRead(int[] buffer, int offset, int size) {
    int bytesReceived = 0;  
    int failures = 0;  
    int b = -1;
    boolean readComplete = false;
  
    while ((!readComplete) && (myPort.available() > 0) && (bytesReceived <= size) && (failures < 3)) {
      if (b != -1) {
        buffer[offset + bytesReceived++] = PApplet.parseInt(b);
      }

      try {
        b = -1;
        b = myPort.read();
      } 
      catch (Exception ex) {
        println("SlipProvider.Read - An exception occured while trying to read from port. <" + ex + ">");
        failures++;
      }

      switch (b) {
        case -1:
        case SlipEnd:
          if (bytesReceived == 0) {
            b = -1;
            continue;
          }
          readComplete = true;
          newData = true;
          break;
        case SlipEsc:
          b = myPort.read();
          switch (b) {
            case SlipEscEnd:
              b = SlipEnd;
              break;
            case SlipEscEsc:
              b = SlipEsc;
              break;
            default:
              break;
          }
        break;
        default:
        break;
//        }
//        break;
//      default:
//        break;
      }
    }

    //base.lastReadBytesReceived = bytesReceived;
    return bytesReceived;
  }

  /// <summary>
  /// Serial Write function to provide SLIP framing.
  /// </summary>
  /// <param name="buffer"></param>
  /// <param name="pSize"></param>
  public void slipWrite(int[] buffer, int offset, int pSize) {
    int[] framedBuffer = new int[pSize * 2 + 2];

    int pos = 0;
    framedBuffer[pos++] = SlipEnd;

    int i = 0;
    while (i < pSize) {
      switch (buffer[i + offset])
      {
        case SlipEnd:
          framedBuffer[pos++] = SlipEsc;
          framedBuffer[pos++] = SlipEscEnd;
          break;
  
        case SlipEsc:
          framedBuffer[pos++] = SlipEsc;
          framedBuffer[pos++] = SlipEscEsc;
          break;
  
        default:
          framedBuffer[pos++] = buffer[i + offset];
          break;
      }
      i++;
    }

    framedBuffer[pos++] = SlipEnd;

    myPort.write("Finish this function!");
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "AutoBlockAMP_GaugeConfig" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
