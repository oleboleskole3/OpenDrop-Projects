class Reservoir_reversed extends Reservoir {
  Reservoir_reversed(int startI, int dispenseX, int dispenseY, Device d) {
    super(startI, dispenseX, dispenseY, d);
    bOffset = 0;
    rOffset = 1;
    cOffset = 2;
    sOffset = 3;
  }
}
