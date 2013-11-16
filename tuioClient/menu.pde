import controlP5.*;
class menu {
  ControlP5 cp5;

  ListBox l;

  ArrayList<String> attributes;

  menu(PApplet theParent, ArrayList<String> idToAttr) {

    attributes = idToAttr;
    //ControlP5.printPublicMethodsFor(ListBox.class);

    cp5 = new ControlP5(theParent);
    l = cp5.addListBox("myList")
      .setPosition(100, 100)
        .setSize(120, 150)
          .setItemHeight(15)
            .setBarHeight(15)
              .setColorBackground(color(255, 128))
                .setColorActive(color(0))
                  .setColorForeground(color(255, 100, 0));

    l.captionLabel().toUpperCase(true);
    l.captionLabel().set("Assignable values");
    l.captionLabel().setColor(0xffff0000);
    l.captionLabel().style().marginTop = 3;
    l.valueLabel().style().marginTop = 3;

    for (int i=0;i<attributes.size();i++) {
      ListBoxItem lbi = l.addItem(attributes.get(i), i);

      if ( i == 0) { 
        lbi.setColorBackground(0xffff0000);
      }
      else {
        lbi.setColorBackground(0xffc1c1c1);
      }
    }
  }

  void hide() {
    l.setSize(0, 0)
      .setPosition(0, 0);
  }

  void show() {
    l.setSize(120, 150)
      .setPosition(20, 50);
  }

  void reDraw() {
    l.clear();
    for (int i=1;i<attributes.size();i++) {


      ListBoxItem lbi = l.addItem(attributes.get(i), i);
      if ( i == 0) { 
        lbi.setColorBackground(0xffff0000);
      }
      else {
        lbi.setColorBackground(color(0, 64));
      }
    }
  }

  //use the ArrayList passed by the calling method
  void reDraw(ArrayList<String> newAttributes) {
    attributes = newAttributes;
    l.clear();
    for (int i=0;i < attributes.size();i++) {


      ListBoxItem lbi = l.addItem(attributes.get(i), i);
      if ( i == 0) { 
        lbi.setColorBackground(0xffff0000);
      }
      else {
        lbi.setColorBackground(color(0, 64));
      }
    }
  }
}

