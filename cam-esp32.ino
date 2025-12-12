#include <ArduCAM.h>
#include <Wire.h>
#include <SPI.h>
#include "memorysaver.h"

// In memorysaver.h make sure ONLY this is enabled:
//   #define OV2640_MINI_2MP

#define CAM_CS   5      // CS pin
#define I2C_SDA  21     // SDA
#define I2C_SCL  22     // SCL

ArduCAM myCAM(OV2640, CAM_CS);

void setup() {
  uint8_t vid, pid;

  Serial.begin(115200);
  delay(1000);
  Serial.println("\n[ArduCAM] Serial JPEG capture start");

  Wire.begin(I2C_SDA, I2C_SCL);
  SPI.begin(18, 19, 23, CAM_CS);

  pinMode(CAM_CS, OUTPUT);
  digitalWrite(CAM_CS, HIGH);

  // --- Verify SPI with TEST1 ---
  myCAM.write_reg(ARDUCHIP_TEST1, 0x55);
  uint8_t t = myCAM.read_reg(ARDUCHIP_TEST1);
  Serial.print("TEST1 = 0x");
  Serial.println(t, HEX);
  if (t != 0x55) {
    Serial.println("SPI still not OK, stopping.");
    while (1) { delay(1000); }
  }

  // --- Detect OV2640 sensor over I2C ---
  myCAM.wrSensorReg8_8(0xFF, 0x01);
  myCAM.rdSensorReg8_8(0x0A, &vid);
  myCAM.rdSensorReg8_8(0x0B, &pid);
  Serial.print("Sensor VID = 0x");
  Serial.print(vid, HEX);
  Serial.print(", PID = 0x");
  Serial.println(pid, HEX);

  if (vid != 0x26 || (pid != 0x41 && pid != 0x42)) {
    Serial.println("OV2640 not detected, stopping.");
    while (1) { delay(1000); }
  }

  Serial.println("OV2640 detected, configuring...");

  myCAM.set_format(JPEG);
  myCAM.InitCAM();
  myCAM.OV2640_set_JPEG_size(OV2640_320x240); // smaller = faster over 115200
  myCAM.clear_fifo_flag();

  Serial.println("Ready to capture frames.");
}

void loop() {
  // Capture one frame
  myCAM.flush_fifo();
  myCAM.clear_fifo_flag();
  myCAM.start_capture();

  // Wait for capture done
  while (!myCAM.get_bit(ARDUCHIP_TRIG, CAP_DONE_MASK)) {
    // could add timeout if you want
  }

  uint32_t len = myCAM.read_fifo_length();
  Serial.print("Captured frame, length = ");
  Serial.println(len);

  if (len == 0 || len > 400000) { // basic sanity check
    Serial.println("Bad length, skipping frame.");
    myCAM.clear_fifo_flag();
    delay(1000);
    return;
  }

  // --- Send marker + length header ---
  // Protocol: 0xAA + [4 bytes little-endian length] + JPEG data
  Serial.write(0xAA);
  Serial.write((uint8_t*)&len, 4);

  // --- Burst read from FIFO and push over serial ---
  myCAM.CS_LOW();
  SPI.transfer(BURST_FIFO_READ);

  uint32_t remaining = len;
  while (remaining--) {
    uint8_t b = SPI.transfer(0x00);
    Serial.write(b);
  }

  myCAM.CS_HIGH();
  myCAM.clear_fifo_flag();

  Serial.println("\nFrame sent.");
  delay(1500); // wait before next frame
}
