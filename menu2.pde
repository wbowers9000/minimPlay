// set mainYPos when known //<>//
class mainMenu {
  float mainYPos;
  float mainHeight;
  textAndBoxSize tbs = new textAndBoxSize();
  
  // action: 0 - mouse over, 1 - mouse clicked
  boolean mouseOver(int mX, int mY, int action) {
    boolean rtn = mY >= mainYPos && mY < (mainYPos + mainHeight);
    if(rtn) {
      if(action == 0) {println("mouse in mainMenu"); return rtn;}
      if(action == 1) {doTask(menuItemClicked(mX, mY)); return rtn;}
    }
    return rtn;
  }
    
  class menuItem {
    String iText;
    float xPos;  // set in rePositionMenu()
    float yPos;  // set in rePositionMenu()
    float tWidth;  // set in rePositionMenu()
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
/*    
    menuItem(String iText, int xPos, int yPos, int toKey) {
      this.iText = iText;
      this.xPos = xPos;
      this.yPos = yPos;
      this.tWidth = int(textWidth(iText));
      this.toKey = toKey;
    }
*/    
    void itemDraw() {
      fill(fillNormal);
      if(mouseOver(mouseX, mouseY)) {
        fill(backgroundHighlight);
        float overFill = tbs.totalHeight / 7;
        rect(xPos, yPos, tWidth, tbs.totalHeight);
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
    float xPos, yPos, yOffset, yp, yPosUpperLimit;
    
    textSize(globalFontSize);
    float tHeight = textAscent() + textDescent() + 5;
    tbs.computeSize(tHeight); // compute text and box size
    // TODO: redo all metrics using tbs.
    xPos = 10;
    yOffset = tbs.totalHeight + tbs.totalHeight / 3;
    yp = mainYPos + tbs.totalHeight;
    yPosUpperLimit = mainYPos + mainHeight - tbs.totalHeight;
    
    for (int i = 0; i < mItm.size(); i++) {
      mi = mItm.get(i);
      if(mi.tWidth != 0) {
        mi.xPos = xPos;
        mi.yPos = yp;
        yp += yOffset;
        if(yp > yPosUpperLimit) {
          yp = mainYPos + tbs.totalHeight;
          xPos = width / 2 + 10;
        }
      }
    }
  }
  
/*  
  void rePositionMenu() {
    menuItem mi;
    float xPos, yPos, yOffset, yPosText, yPosUpperLimit;
    
    textSize(16);
    float tHeight = textAscent() + textDescent() + 5;
    tbs.computeSize(tHeight); // compute text and box size
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
*/
  
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