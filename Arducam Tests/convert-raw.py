from PIL import Image
import os
import struct

# CONFIGURATION
INPUT_FILE  = "raw_image.bin"
WIDTH       = 320
HEIGHT      = 240

def convert_rgb565(data):
    # OV2640 often defaults to RGB565 (2 bytes per pixel)
    # RRRR RGGG GGGB BBBB
    pixels = []
    for i in range(0, len(data) - 1, 2):
        # Read 16-bit word
        # Note: Might need to swap bytes (little vs big endian)
        # Try big-endian first (byte[0], byte[1])
        b1 = data[i]
        b2 = data[i+1]
        pixel = (b1 << 8) | b2

        # Extract RGB components
        r = (pixel & 0xF800) >> 11
        g = (pixel & 0x07E0) >> 5
        b = (pixel & 0x001F)

        # Scale to 8-bit (0-255)
        r = (r * 255) // 31
        g = (g * 255) // 63
        b = (b * 255) // 31
        
        pixels.append((r, g, b))
    return pixels

def main():
    if not os.path.exists(INPUT_FILE):
        print(f"Error: {INPUT_FILE} not found.")
        return

    with open(INPUT_FILE, "rb") as f:
        raw_data = f.read()

    print(f"File Size: {len(raw_data)} bytes")
    
    # Calculate Expected Size
    # RGB565 = 2 bytes per pixel
    expected_size = WIDTH * HEIGHT * 2
    
    print(f"Expected Size for 320x240 RGB565: {expected_size} bytes")

    if len(raw_data) < expected_size:
        print("Warning: Data is smaller than a full frame. Image will be cut off.")
    
    # CONVERT
    try:
        pixels = convert_rgb565(raw_data)
        
        # Create Image
        img = Image.new("RGB", (WIDTH, HEIGHT))
        
        # Determine how many pixels we actually have
        count = min(len(pixels), WIDTH * HEIGHT)
        
        # Put pixels
        img.putdata(pixels[:count])
        
        img.save("converted_image.png")
        print("[SUCCESS] Image saved as 'converted_image.png'. Open it!")
        
    except Exception as e:
        print(f"Conversion Error: {e}")

if __name__ == "__main__":
    main()