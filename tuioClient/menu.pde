import controlP5.*;
class menu {
  ControlP5 cp5;

  ListBox l;

  int cnt = 0;
  HashMap<Integer, String> attributes;

  menu(PApplet theParent, HashMap<Integer, String> idToAttr) {

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
    l.captionLabel().set("A Listbox");
    l.captionLabel().setColor(0xffff0000);
    l.captionLabel().style().marginTop = 3;
    l.valueLabel().style().marginTop = 3;

    for (int i=1;i<10;i++) {
      ListBoxItem lbi = l.addItem(attributes.get(i), i);
      lbi.setColorBackground(0xffff0000);
    }
  }

void hide(){
  l.setSize(0,0)
     .setPosition(0,0);
}

void show(){
  l.setSize(120,150)
     .setPosition(mouseX,mouseY);
}

void reDraw(){
  l.clear();
  for (int key : attributes.keySet()) {
    
    if (key < 10){
    ListBoxItem lbi = l.addItem(attributes.get(key), key);
      lbi.setColorBackground(0xffff0000);
    }

    }
  
}

void remove(int kii){
  if(attributes.containsKey(kii)){
    attributes.remove(kii);
  }
}

  
}

