import serial
import struct
import time
import os

PORT = "COM21" 
BAUD = 115200

ser = serial.Serial(PORT, BAUD, timeout=5)
print(f"Opened {PORT} at {BAUD} baud")

img_count = 0

def read_exact(n):
    """Read exactly n bytes or raise."""
    data = b""
    while len(data) < n:
        chunk = ser.read(n - len(data))
        if not chunk:
            raise TimeoutError("Serial timeout while reading data")
        data += chunk
    return data

while True:
    # Look for start marker 0xAA
    b = ser.read(1)
    if not b:
        print("No data, waiting...")
        continue

    if b != b'\xAA':
        # ignore stray bytes (like debug text)
        continue

    # Read 4-byte little-endian length
    length_bytes = read_exact(4)
    length = struct.unpack("<I", length_bytes)[0]
    print(f"Incoming frame, length = {length} bytes")

    # Read JPEG data
    jpeg_data = read_exact(length)

    filename = f"frame_{img_count:03d}.jpg"
    with open(filename, "wb") as f:
        f.write(jpeg_data)

    print(f"Saved {filename}")
    img_count += 1
