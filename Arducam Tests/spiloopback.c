#include <stdio.h>
#include <stdint.h>

// ADDRESS DEFINITIONS
#define SPI_BASE      0x10002000UL
#define REG32(addr)   (*(volatile uint32_t *)(addr))

// REGISTER OFFSETS
#define REG_CR        0x60  // Control Register
#define REG_SR        0x64  // Status Register
#define REG_DTR       0x68  // Data Transmit Register
#define REG_DRR       0x6C  // Data Receive Register
#define REG_SSR       0x70  // Slave Select Register
#define REG_SRR       0x40  // Software Reset Register

void delay_loop(int count) {
    for(volatile int i=0; i<count; i++);
}

void spi_full_diagnostic() {
    printf("\n===================================\n");
    printf("[DIAGNOSTIC] SPI System Health Check\n");
    printf("===================================\n");

    // ---------------------------------------------------------
    // TEST 0: AXI BUS CHECK
    // ---------------------------------------------------------
    uint32_t sr = REG32(SPI_BASE + REG_SR);
    printf("1. Register Read Test:   ");
    if (sr == 0xFFFFFFFF) {
        printf("[FAIL] Bus Floating. Bitstream issue?\n");
        return;
    } else {
        printf("[PASS] Value: 0x%02X\n", sr);
    }

    // ---------------------------------------------------------
    // TEST 1: INTERNAL SILICON LOOPBACK
    // ---------------------------------------------------------
    // This disconnects the pins and connects MISO-MOSI inside the chip.
    
    // 1. Soft Reset
    REG32(SPI_BASE + REG_SRR) = 0x0A; 
    delay_loop(1000);
    
    // 2. Config: Master | Enable | Manual SS | LOOPBACK ON (Bit 0 = 1)
    // 0x187 = 110000111
    REG32(SPI_BASE + REG_CR) = 0x187; 
    
    // 3. Select Slave (Internal)
    REG32(SPI_BASE + REG_SSR) = 0xFFFFFFFE;
    
    // 4. Send Data 0x55
    REG32(SPI_BASE + REG_DTR) = 0x55;
    
    // 5. Start Transaction (Clear Inhibit Bit)
    REG32(SPI_BASE + REG_CR) &= ~0x100;
    
    // 6. Wait for RX (Check Status Reg Bit 0 - RX Empty)
    int timeout = 0;
    while((REG32(SPI_BASE + REG_SR) & 0x01) != 0) {
        timeout++;
        if(timeout > 100000) break;
    }
    
    uint32_t rx_internal = REG32(SPI_BASE + REG_DRR);
    
    printf("2. Internal Loopback:    ");
    if (rx_internal == 0x55) {
        printf("[PASS] Received 0x55. Logic is healthy.\n");
    } else {
        printf("[FAIL] Received 0x%02X. The IP Core is broken.\n", rx_internal);
        // If this fails, the External test is pointless.
        return; 
    }

    // ---------------------------------------------------------
    // TEST 2: EXTERNAL WIRE LOOPBACK
    // ---------------------------------------------------------
    printf("3. External Loopback:    ");
    
    // 1. Config: Master | Enable | Manual SS | LOOPBACK OFF (Bit 0 = 0)
    // 0x186 = 110000110
    REG32(SPI_BASE + REG_CR) = 0x186; 
    
    // 2. Select Slave (External Pin Low)
    REG32(SPI_BASE + REG_SSR) = 0xFFFFFFFE;
    
    // 3. Send Data 0xA5
    REG32(SPI_BASE + REG_DTR) = 0xA5;
    
    // 4. Start Transaction
    REG32(SPI_BASE + REG_CR) &= ~0x100;
    
    // 5. Wait for RX
    timeout = 0;
    while((REG32(SPI_BASE + REG_SR) & 0x01) != 0) {
        timeout++;
        if(timeout > 1000000) {
            printf("[TIMEOUT] MISO line never toggled.\n");
            return;
        }
    }
    
    uint32_t rx_external = REG32(SPI_BASE + REG_DRR);
    
    if (rx_external == 0xA5) {
        printf("[PASS] Received 0xA5. Wires are perfect!\n");
    } else {
        printf("[FAIL] Received 0x%02X.\n", rx_external);
        printf("       -> Your wire is on the wrong pin.\n");
        printf("       -> Or proper contact is not being made.\n");
    }
}

int main() {
    spi_full_diagnostic();
    while(1);
    return 0;
}