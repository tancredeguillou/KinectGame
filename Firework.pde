int N = 500;

class Firework {
  ArrayList<Fire> f;

  Firework() {
      f = new ArrayList<Fire>();
  }
  
  void fire(PVector pos) {
    for (int i = 0; i < 500; i++) {
        f.add(new Fire(pos.copy()));
    }
  }
  
  void run() {
    for (int i = 0; i < f.size(); i++) {
      f.get(i).run();
      if (f.get(i).isDead()) {
        f.remove(i);
      }
    }
  }
}
