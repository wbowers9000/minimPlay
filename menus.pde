
class menuItem {
  String iText;
  int xPos;
  int yPos;
  int tWidth;
  
  menuItem() {
    iText = "";
    xPos = 0;
    yPos = 0;
    tWidth = 0;
  }
  
  menuItem(String iText, int xPos, int yPos) {
    this.iText = iText;
    this.xPos = xPos;
    this.yPos = yPos;
    this.tWidth = int(textWidth(iText));
  }
  
  void itemDraw() {
    text(iText, xPos, yPos);
  }
  
  boolean clicked() {
    return false;
  }
  
}
  //fill(240, 50, 100);
  //rect(xPos, yPos - textHeight, textWidth("space: pause / playback"), textHeight);
  //drawMenus();

int menuItemCount;

void setupMenuItems() {
  int xPos, yPos, yOffset, yPosText;
  
  menuItemCount = 0;
  xPos = 10;
  yOffset = textHeight + textHeight / 3;
  yPosText = YPosMenu + textHeight * 2;
  yPos = yPosText; 
  
  mItem[menuItemCount] = new menuItem("ESC: exit", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  
  mItem[menuItemCount] = new menuItem("space: pause / playback", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  
  mItem[menuItemCount] = new menuItem("enter: start from beginning", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  
  mItem[menuItemCount] = new menuItem("backspace: abandon unsaved data", xPos, yPos);
  menuItemCount++;
  
  xPos = width / 2 + 10;
  yPos = yPosText;
  
  mItem[menuItemCount] = new menuItem("F11: load data", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  
  mItem[menuItemCount] = new menuItem("F10: save data", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  
  mItem[menuItemCount] = new menuItem("-: decrease window size", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  
  mItem[menuItemCount] = new menuItem("+: increase window size", xPos, yPos);
  menuItemCount++;
  yPos += yOffset;
  
}

void drawMenus() {
  fill(255);
  for(int i = 0; i < menuItemCount; i++)
    mItem[i].itemDraw();
}