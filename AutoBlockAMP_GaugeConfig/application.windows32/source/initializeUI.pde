void createSliders()
{

  Slider s1 = controlP5.addSlider("SOC", 0, 100, 50, SOCX, SOCY, SOCW, SOCH);  //this is the SOC slider
  s1.setSliderMode(Slider.FIX);
  s1.setMoveable(false);
  s1.valueLabel().setVisible(false);
  s1.setCaptionLabel("");
  s1.setHandleSize(5) ;

  Slider s2 = controlP5.addSlider("LL", 0, 100, 15, LLX, LLY, LLW, LLH);    // this is the warning slider
  s2.setSliderMode(Slider.FLEXIBLE);
  s2.setMoveable(false);
  s2.valueLabel().setVisible(false);
  s2.setCaptionLabel("");
  //s2.setNumberOfTickMarks(51);
  s2.setColorBackground(color(50));
  s2.setColorActive(0xFFD1526C);
  s2.setColorForeground(0xFF95001E);
  s2.setHandleSize(5) ;

  Slider s3 = controlP5.addSlider("CAP", 1, 300, 200, CAPX, CAPY, CAPW, CAPH);  // this is capacity slider
  //s3.setSliderMode(Slider.FIX);
  s3.setMoveable(false);
  s3.valueLabel().setVisible(false);
  s3.setCaptionLabel("");
  //s3.setNumberOfTickMarks(40);

  Slider s4 = controlP5.addSlider("AMP", 0, 1000, 0, AMPX, AMPY, 150, 20);   // this is the tach output slider
  s4.setSliderMode(Slider.FLEXIBLE);
  s4.setMoveable(false);
  s4.valueLabel().setVisible(false);
  s4.setCaptionLabel("");
  //s4.setNumberOfTickMarks(199);
  s4.setHandleSize(5) ;

  Slider s5 = controlP5.addSlider("PPR", 1, 4, 0, TACHX+10, TACHY-21, 132, 20);  // this is the PPR slider
  s5.setSliderMode(Slider.FLEXIBLE);
  s5.setMoveable(false);
  s5.valueLabel().setVisible(false);
  s5.setCaptionLabel("");
  s5.setNumberOfTickMarks(4);  

  Slider s6 = controlP5.addSlider("FULL", 0, 1023, (1024/4)*3, SOCX+25, SOC2, SOCW-50, 20);  //this is the FULL slider
  s6.setSliderMode(Slider.FLEXIBLE);
  s6.setMoveable(false);
  s6.valueLabel().setVisible(false);
  s6.setCaptionLabel("");
  s6.setHandleSize(10) ;
  s6.setColorBackground(color(50));

  Slider s7 = controlP5.addSlider("EMPTY", 0, 1023, (1024/4)*1, SOCX+25, SOC3, SOCW-50, 20);  //this is the EMPTY slider
  s7.setSliderMode(Slider.FLEXIBLE);
  s7.setMoveable(false);
  s7.valueLabel().setVisible(false);
  s7.setCaptionLabel("");
  s7.setHandleSize(10) ;
  s7.setColorBackground(color(50));
}

void createlabels()
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



  LLlevellabel = controlP5.addTextlabel("label5", LLvalue +" %", LLX+LLW+1, LLY);  

  SOClevellabel = controlP5.addTextlabel("label4", SOCvalue+" %", SOCX+SOCW+5, SOCY+5);    

  PPRlabel = controlP5.addTextlabel("label15", tach +" PPR", TACHX+150, TACHY-22);

  AMPLabel = controlP5.addTextlabel("label12", AMPvalue+" %", AMPX+160, AMPY-1);

  CAPlevelLabel = controlP5.addTextlabel("label7", CAPvalue + "Ah", CAPX+CAPW+5, CAPY-1);
  
  FGHIGHLabel = controlP5.addTextlabel("label21", 0 + "", CAPX+CAPW+5, CAPY-55);
  
  FGLOWLabel = controlP5.addTextlabel("label22", 0 + "", CAPX+CAPW+5, CAPY-28);  
  
}

void createButtons()
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

  FUP = controlP5.addButton("FUP", 0, SOCW+80, SOC2, 20, 20);
  FUP.setCaptionLabel("");  

  EDOWN = controlP5.addButton("EDOWN", 0, SOCX, SOC3, 20, 20);
  EDOWN.setCaptionLabel("");  

  EUP = controlP5.addButton("EUP", 0, SOCW+80, SOC3, 20, 20);
  EUP.setCaptionLabel("");  



//  Slider s6 = controlP5.addSlider("FULL", 0, 1023, (1024/4)*3, SOCX+25, SOC2, SOCW-50, 20);  //this is the FULL slider

  
  
  
}

