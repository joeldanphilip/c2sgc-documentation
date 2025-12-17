import serial
import time
import sys

# CONFIGURATION
SERIAL_PORT = '/dev/ttyUSB1' 
BAUD_RATE   = 115200
OUTPUT_FILE = 'raw_image.bin'

def main():
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
    except Exception as e:
        print(f"Error: {e}"); return

    print(">>> Sending Trigger 'c'...")
    ser.write(b'c')

    buffer = bytearray()
    capturing = False
    
    START_MARKER = b"--- START JPEG ---"
    END_MARKER   = b"--- END JPEG ---"

    print(">>> Listening for RAW data...")
    
    try:
        while True:
            if ser.in_waiting:
                chunk = ser.read(ser.in_waiting)
                buffer += chunk

                if not capturing:
                    # Print text logs
                    try:
                        print(chunk.decode('ascii', errors='ignore'), end='', flush=True)
                    except: pass

                if not capturing and START_MARKER in buffer:
                    print("\n[PC] Start Marker Found! Recording...")
                    capturing = True
                    start_pos = buffer.find(START_MARKER) + len(START_MARKER)
                    # Handle the newline byte (0x0A) often sent after marker
                    if start_pos < len(buffer) and buffer[start_pos] == 0x0A:
                        start_pos += 1
                    buffer = buffer[start_pos:]

                if capturing and END_MARKER in buffer:
                    print("\n[PC] Capture complete.")
                    
                    # Extract Data
                    raw_data = buffer.split(END_MARKER)[0]
                    
                    # Save RAW BINARY
                    with open(OUTPUT_FILE, 'wb') as f:
                        f.write(raw_data)
                    
                    print(f"\n[SUCCESS] Saved raw data to {OUTPUT_FILE} ({len(raw_data)} bytes)")
                    return

    except KeyboardInterrupt:
        ser.close()

if __name__ == "__main__":
    main()