class menuItemClickable {
  char ch;
  float xP;
  float yP;
  private float textXPos;
  private float textYPos;
  private float xBorder;  // x axis area around character for select box
  private float yBorder;  // y axis area around character for select box
  int txtSz;  // text size for this area
  float totalWidth;
  float totalHeight;
  
  menuItemClickable(char ch) {
    this.ch = ch;
    this.xP = 0;
    this.yP = 0;
  }
  
  void computeSize(float heightOfLEDStrip) {
    // adjust height until it fits within a pixel
    txtSz = globalFontSize + 1;
    do {
      txtSz--;
      textSize(txtSz);
      yBorder = textAscent() * 0.125;
      totalHeight = textAscent() + yBorder + yBorder;
    } while(totalHeight > heightOfLEDStrip && txtSz > 1);
    String ss = "W";
    float ff = textWidth(ss);
    xBorder = ff * 0.125;
    totalWidth = ff + xBorder + xBorder;
  }
  
  void setPosition(float xPos, float yPos) {
    xP = xPos;
    yP = yPos;
    textXPos = xP + xBorder;
    textYPos = yP + yBorder + textAscent();
  }

  void itemDraw() {
    // call textSize(obj.txtSz) before multiple calls to itemDraw
    if(mouseOver(mouseX, mouseY)) {
      fill(backgroundHighlight);
      rect(xP, yP, totalWidth, totalHeight);
      fill(fillHighlight);
    }
    else
      fill(fillNormal);
    text(ch, textXPos, textYPos);
  }
  
  
  boolean mouseOver(int mX, int mY) {
    if(mX >= xP && mX < (xP + totalWidth) && mY >= yP && 
      mY < (yP + totalHeight)) return true;
    return false;
  }
  
}

class menuItem {
  String iText;
  int xPos;
  int yPos;
  int tWidth;
  int toKey;
  
  menuItem() {
    iText = "";
    xPos = 0;
    yPos = 0;
    tWidth = 0;
    toKey = 0;
  }
  
  menuItem(String iText, int toKey) {
    this.iText = iText;
    this.tWidth = int(textWidth(iText));
    this.toKey = toKey;
  }
  
  menuItem(String iText, int xPos, int yPos, int toKey) {
    this.iText = iText;
    this.xPos = xPos;
    this.yPos = yPos;
    this.tWidth = int(textWidth(iText));
    this.toKey = toKey;
  }
  
  void itemDraw() {
    fill(fillNormal);
    if(mouseOver(mouseX, mouseY)) {
      fill(backgroundHighlight);
      int overFill = textHeight / 7;
      int th = textHeight + overFill;
      rect(xPos - overFill, yPos - th + int(textDescent()), tWidth + overFill + overFill, th);
      fill(fillHighlight);
    }
    text(iText, xPos, yPos);
  }

  boolean mouseOver(int mX, int mY) {
    if(mX >= xPos && mX <= (xPos + tWidth) && mY <= yPos && 
      mY >= (yPos - textHeight)) return true;
    return false;
  }

  void display() {
    println(iText + "  xPos: " + xPos + "  yPos: " + yPos + "  tWidth: " + tWidth + 
      "  toKey: " + hex(toKey));      
  }
}



ArrayList<menuItem> mItm = new ArrayList<menuItem>();

void setupMenu() {
  // Objects can be added to an ArrayList with add()
  mItm.add(new menuItem("SPACE: pause / playback", int(' ')));
  mItm.add(new menuItem("ctrl-l: load data", 0x004C000C));
  mItm.add(new menuItem("ctrl-s: save data", 0x00530013));
  mItm.add(new menuItem("END: save file and end program", 0x00030000));
  mItm.add(new menuItem("DELETE: abandon unsaved data", 0x00930000));
  mItm.add(new menuItem("ENTER: play from beginning", 0xD));
  mItm.add(new menuItem("ESC: exit", 0x1B)); // not really needed, processing exits on ESC
  mItm.add(new menuItem("'-': decrease window size", 0x008C002D));
  mItm.add(new menuItem("", 0x2D));
  mItm.add(new menuItem("'+': increase window size", 0x008B002B));
  mItm.add(new menuItem("", 0x003D002B)); // second code for '+'
}


void rePositionMenu() {
  menuItem mi;
  int xPos, yPos, yOffset, yPosText, yPosUpperLimit;
  
  xPos = 10;
  yOffset = textHeight + textHeight / 3;
  yPosText = YPosMenu + textHeight * 2;
  yPos = yPosText; 
  yPosUpperLimit = YPosMenu + areaOffset - textHeight;
  
  for (int i = 0; i < mItm.size(); i++) {
    mi = mItm.get(i);
    if(mi.tWidth != 0) {
      mi.xPos = xPos;
      mi.yPos = yPos;
      yPos += yOffset;
      if(yPos > yPosUpperLimit) {
        yPos = yPosText;
        xPos = width / 2 + 10;
      }
    }
    //mi.display();
  }
}


void drawMenu() {
  
  menuItem mi;
  
  for (int i = 0; i < mItm.size(); i++) {
    mi = mItm.get(i);
    if(mi.tWidth != 0) mi.itemDraw();
  }
}


int keyToMenuNum(int kk) {
  menuItem mi;
  
  for (int i = 0; i < mItm.size(); i++) {
    mi = mItm.get(i);
    if(mi.toKey == kk) return i; 
  }
  return -1;
}

int menuItemClicked(int mX, int mY) {
  menuItem mi;
  
  for (int i = 0; i < mItm.size(); i++) {
    mi = mItm.get(i);
    if(mi.mouseOver(mX, mY)) return i; 
  }
  return -1;
}