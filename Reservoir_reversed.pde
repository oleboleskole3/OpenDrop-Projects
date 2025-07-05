class Reservoir_reversed extends Reservoir {
  Reservoir_reversed(boolean[] buffer, int startI) {
    super(buffer, startI);
    bOffset = 0;
    rOffset = 1;
    cOffset = 2;
    sOffset = 3;
  }
}
