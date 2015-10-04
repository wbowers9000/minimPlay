

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
  
  //menuItemCount = 0;
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