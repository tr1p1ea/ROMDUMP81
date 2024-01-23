const byte interruptPin = 4;
const byte dataPin = 5;

volatile char ROMBUFFER[32768];

volatile byte dataBit = 0;
volatile byte dataByte = 0;
volatile byte bitCount = 0;
volatile int byteCount = 0;
volatile bool getDataFlag = false;

int outputByte = 0;

void IRAM_ATTR readBit() {
  if (byteCount < 32768) {
    dataBit = digitalRead(dataPin);
    dataByte = (dataByte << 1 | dataBit) & 0xFF;
    bitCount++;
    if (bitCount == 8) {
      ROMBUFFER[byteCount] = dataByte;
      bitCount = 0;
      dataByte = 0;
      byteCount++;
    }
  }
}

void setup() {
  pinMode(interruptPin, INPUT);
  pinMode(dataPin, INPUT);
  Serial.begin(115200);
  attachInterrupt(interruptPin, readBit, CHANGE);
  getDataFlag = true;
  Serial.println("TI-81 ROM Dumper ready - awaiting calculator.");
}

void loop() {
  if (getDataFlag == true && outputByte < byteCount) {
    if (outputByte == 0) {
      Serial.print("TI81ROM:\r\n .db ");
    }
    Serial.print("$");
    if (ROMBUFFER[outputByte] < 16) {
      Serial.print("0");
    }
    Serial.print(ROMBUFFER[outputByte], HEX);
    outputByte++;
    if (outputByte > 32767) {
      getDataFlag = false;
    }
    if (outputByte > 0 && outputByte % 32 != 0) {
      Serial.print(",");
    }
    if (outputByte % 32 == 0 && outputByte > 0 && outputByte < 32768) {
      Serial.print("\r\n .db ");
    }
  }
}
