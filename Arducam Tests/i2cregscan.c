#include <stdio.h>
#include <stdint.h>

// ==========================================
// 1. HARDWARE ADDRESSES
// ==========================================
#define SPI_BASE      0x10002000UL
#define I2C_BASE      0x10003000UL // AXI IIC Address

// Helper Macros
#define REG32(addr)   (*(volatile uint32_t *)(addr))

// ==========================================
// 2. CONSTANTS
// ==========================================
#define ARDUCHIP_TEST1       0x00
#define OV2640_ADDR          0x30  // 7-bit I2C Address

// ==========================================
// 3. LOW-LEVEL UTILS
// ==========================================
void delay_loop(int count) {
    for(volatile int i=0; i<count; i++);
}

// ==========================================
// 4. SPI DRIVER (For Chip Check)
// ==========================================
void spi_init(void) {
    REG32(SPI_BASE + 0x40) = 0x0A; // Reset
    delay_loop(5000);
    REG32(SPI_BASE + 0x60) = 0x186; // Master | Manual SS | Enable
    REG32(SPI_BASE + 0x60) = 0x086; // Release FIFO Reset
    REG32(SPI_BASE + 0x70) = 0xFFFFFFFF; // Deselect Slave
}

// ==========================================
// 5. I2C DRIVER (For Scanner)
// ==========================================
void i2c_init(void) {
    REG32(I2C_BASE + 0x40) = 0x0A; // Reset
    delay_loop(1000);
    REG32(I2C_BASE + 0x100) = 0x01; // Enable
}

void i2c_scan() {
    printf("\n[I2C SCANNER] Checking hardware bus...\n");
    
    // 1. Check if Bus is Healthy (Not stuck low)
    int timeout = 0;
    while((REG32(I2C_BASE + 0x104) & 0x80) == 0) { 
        timeout++;
        if(timeout > 1000000) {
            printf("[FATAL] Bus is stuck LOW. Check Wiring!\n");
            printf("        -> Ensure you are using the INNER HEADER (J4).\n");
            printf("        -> Ensure SCL/SDA are not swapped or loose.\n");
            return;
        }
    }
    printf("[OK] Bus is idle. Scanning for Camera (Address 0x30)...\n");

    // 2. Try to ping the Camera (Address 0x30)
    // Start + Write Addr (0x30 << 1 = 0x60)
    REG32(I2C_BASE + 0x108) = 0x100 | (OV2640_ADDR << 1); 
    
    // Stop (Just pinging, sending no data)
    REG32(I2C_BASE + 0x108) = 0x200;

    // 3. Wait for result
    timeout = 0;
    while((REG32(I2C_BASE + 0x104) & 0x80) == 0) { // Wait for TX FIFO Empty
         timeout++;
         if (timeout > 1000000) { printf("[FAIL] Timeout waiting for TX.\n"); return; }
    }
    
    // 4. Check for ACK/NACK (Bit 1 of Status Register)
    // 0 = ACK (Device found)
    // 1 = NACK (No device)
    // Note: We might need to wait slightly for the bus transaction to finish on the wire
    delay_loop(5000); 
    
    uint32_t status = REG32(I2C_BASE + 0x104);
    
    if ((status & 0x02) == 0) {
        printf("[SUCCESS] Camera Found at 0x30! Wires are correct.\n");
        printf("          -> You are ready to run the Master Code.\n");
    } else {
        printf("[FAIL] No ACK received.\n");
        printf("       -> Camera is not responding.\n");
        printf("       -> Try swapping SCL and SDA wires.\n");
        printf("       -> Check if Camera is powered (3.3V).\n");
    }
}

// ==========================================
// 6. MAIN
// ==========================================
int main() {
    printf("\n[VEGA] I2C Diagnostic Tool\n");
    
    spi_init();
    i2c_init(); 
    
    i2c_scan();
    
    while(1);
    return 0;
}