// This class is used to shrink text and input boxes until it will
// fit within a maxium area. computeSize() calls textSize() so save
// the value used in the last call to textSize if you want to
// retain it.

// Set textSize to the largest size you want, not necessarilty the
// maximum size that will fit, before calling computeSize(). The
// resulting size will be <= the textSize when computeSize() is 
// called.

// The new text size is in obj.txtSize. The metrics are stored in 
// the other member variables.
//
// Text height and width are determined the usual way by calling
// textAscent(), textDescent(), and textWidth() after calling 
// computeSize(). 

class textAndBoxSize {
  int txtSize;
  // the upper right corner of box is position 0,0
  // the text positions are relative to upper right corner of box
  float textYPos;  // relative to zero
  float textXPos;  // relative to zero
  float yBorder;
  float totalHeight;  // total height of input box
  float xBorder;
  float totalWidth;
  float borderMultiplier;
  float charWidth;  // width of average character

  void computeSize(float maxHeight, char ch) {
    computeSize(maxHeight, textWidth(ch));
  }
  
  void computeSize(float maxHeight, char ch, float mult) {
    computeSize(maxHeight, textWidth(ch) * mult);
  }
  
  void computeSize(float maxHeight, String ss) {
    computeSize(maxHeight, textWidth(ss));
  }
  
  void computeSize(float maxHeight, float maxWidth) {
    borderMultiplier = 0.125;
    // adjust height until it fits within a maxium
    txtSize = globalFontSize + 1;
    do {
      txtSize--;
      textSize(txtSize);
      yBorder = textAscent() * borderMultiplier;
      totalHeight = textAscent() + yBorder + yBorder;
      charWidth = textWidth('%');
      xBorder = charWidth * borderMultiplier;
      textXPos = xBorder;
      totalWidth = charWidth + xBorder + xBorder;
    } while((totalHeight >= maxHeight || totalWidth >= maxWidth) && txtSize > 1);
    textYPos = textAscent() + yBorder;
  }

}