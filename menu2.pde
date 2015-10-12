// menu item class //<>//
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
  
   
  void setPosition(float xPos, float yPos) {
    xP = xPos;
    yP = yPos;
    textXPos = xP + xBorder;
    textYPos = yP + yBorder + textAscent();
  }

  void itemDraw() {
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

class mainMenu {
  textAndBoxSize tbs = new textAndBoxSize();
  
  class menuItem {
    String iText;
    float xPos;
    float yPos;
    float tWidth;
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
        float overFill = tbs.totalHeight / 7;
        float th = tbs.totalHeight + overFill;
        rect(xPos - overFill, yPos - th + int(textDescent()), tWidth + overFill + overFill, th);
        fill(fillHighlight);
      }
      text(iText, xPos, yPos);
    }
  
    boolean mouseOver(int mX, int mY) {
      if(mX >= xPos && mX <= (xPos + tWidth) && mY <= yPos && 
        mY >= (yPos - tbs.totalHeight)) return true;
      return false;
    }
  
    void display() {
      println(iText + "  xPos: " + xPos + "  yPos: " + yPos + "  tWidth: " + tWidth + 
        "  toKey: " + hex(toKey));      
    }
  }
  
  
  
  ArrayList<menuItem> mItm = new ArrayList<menuItem>();
  
  void setupMenu() {
    String system = System.getProperty("os.name").toString();
    if (system.indexOf("Windows") != -1) {
      mItm.add(new menuItem("SPACE: pause / playback", int(' ')));
      mItm.add(new menuItem("ctrl-l: load data", 0x004C000C));
      mItm.add(new menuItem("ctrl-s: save data", 0x00530013));
      mItm.add(new menuItem("END: save file and end program", 0x00030000));
      mItm.add(new menuItem("DELETE: abandon unsaved data", 0x00930000));
      mItm.add(new menuItem("ENTER: play from beginning", 0xD));
      mItm.add(new menuItem("ESC: exit", 0x1B));
      mItm.add(new menuItem("'-': decrease window size", 0x008C002D));
      mItm.add(new menuItem("", 0x2D));
      mItm.add(new menuItem("'+': increase window size", 0x008B002B));
      mItm.add(new menuItem("", 0x003D002B)); // second code for '+'
    } else if (system.indexOf("Mac OS X") != -1) {
      mItm.add(new menuItem("space: pause / playback", int(' ')));
      mItm.add(new menuItem("fn-left (home): load data", 194345));
      mItm.add(new menuItem("fn-right (end): save data", 259883));
      mItm.add(new menuItem("tab: save file and end program", 9));
      mItm.add(new menuItem("delete: abandon unsaved data", 8));
      mItm.add(new menuItem("return: play from beginning", 10));
      mItm.add(new menuItem("esc: exit", 1769472));
      mItm.add(new menuItem("'-': decrease window size", 45));
      mItm.add(new menuItem("", 2949215));
      mItm.add(new menuItem("'+': increase window size", 61));
      mItm.add(new menuItem("", 3997739)); // second code for '+'
    } else {
      // XXX Currently using Windows keys
      mItm.add(new menuItem("SPACE: pause / playback", int(' ')));
      mItm.add(new menuItem("ctrl-l: load data", 0x004C000C));
      mItm.add(new menuItem("ctrl-s: save data", 0x00530013));
      mItm.add(new menuItem("END: save file and end program", 0x00030000));
      mItm.add(new menuItem("DELETE: abandon unsaved data", 0x00930000));
      mItm.add(new menuItem("ENTER: play from beginning", 0xD));
      mItm.add(new menuItem("ESC: exit", 0x1B));
      mItm.add(new menuItem("'-': decrease window size", 0x008C002D));
      mItm.add(new menuItem("", 0x2D));
      mItm.add(new menuItem("'+': increase window size", 0x008B002B));
      mItm.add(new menuItem("", 0x003D002B)); // second code for '+'
    }
    
    // Objects can be added to an ArrayList with add()
  }
  
  
  void rePositionMenu() {
    menuItem mi;
    float xPos, yPos, yOffset, yPosText, yPosUpperLimit;
    
    textSize(globalFontSize);
    float tHeight = textAscent() + textDescent() + 5;
    tbs.computeSize(tHeight, width); // compute text size
    // TODO: redo all metrics using tbs.
    xPos = 10;
    yOffset = tbs.totalHeight + tbs.totalHeight / 3;
    yPosText = YPosMenu + tbs.totalHeight * 2;
    yPos = yPosText; 
    yPosUpperLimit = YPosMenu + areaOffset - tbs.totalHeight;
    
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
}