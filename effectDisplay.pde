effect efEdit = new effect(10, 8, 180, 180, 1, 0, 300, 0); // inital values for default effect

final int effectMax = 12;
effectAreaMetrics eam = new effectAreaMetrics();
effSel[] es = new effSel[effectMax];
effSel esT = new effSel('B', efEdit);
HSBColor[] refDisp = new HSBColor[LEDCnt];
effect efGeneric; // generic effect for keystoke
boolean testPatternDisplay = true;
int testPatternStartColor = 90;
float effectAreaTextSize;
float spaceBetweenEffectLines;
//initialEffectColor

//--------------------------------------------------------------------------------------
// effectAreaMetrics is where all computed measurements for the effect area are stored
// metrics need only be recomputed once when screen size changes

class effectAreaMetrics {
  int lines;
  float totalLineHeight;
  float lineHeight;
  int textSize;
  float widthLineID;
  float xPosEffect;
  float widthEffect;
  float totalLEDWidth;
  float LEDWidth;
  
  effectAreaMetrics() {
    lines = 0;
    totalLineHeight = 0;
    lineHeight = 0;
    textSize = 0;
    widthLineID = 0;
    xPosEffect = 0;
    widthEffect = 0;
    totalLEDWidth = 0;
    LEDWidth = 0;
  }
  
  void compute(int lines) {
    this.lines = lines;
    totalLineHeight = areaOffset / lines;
    lineHeight = totalLineHeight * 0.8;
    // create a temporary clickable menu item to compute the correct text size
    menuItemClickable mic = new menuItemClickable('%');
    // Compute x axis widths.
    mic.computeSize(lineHeight);
    textSize = mic.txtSz;
    widthLineID = mic.totalWidth;
    xPosEffect = widthLineID * 1.2;
    widthEffect = width - xPosEffect;
    totalLEDWidth = widthEffect / LEDCnt;
    LEDWidth = totalLEDWidth * 0.9;
  }
}

//---------------------------------------------------------------------------------

void setupEffectSelectAry() {
  char ch = 'A';
  for(int i = 0; i < effectMax; i++) {
    es[i] = new effSel(ch, efEdit);
    ch++;
  }
}

void setupReferenceDisplay() {
  for(int i = 0; i < refDisp.length; i++) refDisp[i] = new HSBColor();
  for(int i = 0; i < refDisp.length; i += 2) refDisp[i].set((i * 5) % 360, 100, 100);
}

void rePositionEffects() {
  eam.compute(effectMax + 2);
  for(int i = 0; i < es.length; i++) 
    es[i].computePlacement(i);
}

void drawEffDisp() {
  noStroke();
  textSize(effectAreaTextSize);
  for(int i = 0; i < es.length; i++) es[i].itemDraw();
  displayEffectLine(refDisp, eam.xPosEffect, YPosEffect);
}

void effectClicked() {
  return;
}

void displayEffectLine(HSBColor[] ary, float xPos, float yPos) {
  color cc;
  
  if(ary == null) return;
  for(int i = 0; i < ary.length; i++) {
    cc = ary[i].getColor();
    fill(cc);
    rect(xPos, yPos, eam.LEDWidth, eam.lineHeight);
    xPos += eam.totalLEDWidth;
  }
}

//--------------------------------------------------------------------------------


class effSel {
  menuItemClickable mic;
  effect eff;
  int effType;
  float xPosEff; //<>//
  float yPosEff;

  effSel() {
    mic = null;
    eff = null;
    effType = 0;
    xPosEff = 0;
    yPosEff = 0;
  }

  effSel(char ch, effect ef) {
    mic = new menuItemClickable(ch);
    eff = new effect(ef);
    if(testPatternDisplay) {
      setupTestDisplay(testPatternStartColor, eff.efAry);
      testPatternStartColor += 15;
    }
    effType = 0;
    xPosEff = 0;
    yPosEff = 0;
  }
  void computePlacement(int idx) {
    yPosEff = YPosEffect + (idx + 2) * eam.totalLineHeight; //<>//
    mic.setPosition(0, yPosEff);
  }
  
  void setupTestDisplay(int startColor, HSBColor[] ary) {
    for(int i = 0; i < ary.length; i++) ary[i] = new HSBColor();
    for(int i = 0; i < ary.length; i++) ary[i].set((startColor + i * 2) % 360, 100, 100);
  }

  
  void itemDraw() {
    mic.itemDraw();
    displayEffectLine(eff.efAry, eam.xPosEffect, yPosEff);
  }
}