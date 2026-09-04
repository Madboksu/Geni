import sys
from PIL import Image

try:
    img = Image.open("assets/burn-tree-boss.png")
    img = img.convert("RGBA")
    w, h = img.size
    print(f"Size: {w}x{h}")
    
    # Try different slice widths
    for count in range(4, 15):
        if w % count != 0:
            continue
        slice_w = w // count
        print(f"\nTrying {count} frames (width {slice_w}):")
        
        # Check center of mass of non-transparent pixels in each frame
        for i in range(count):
            left = i * slice_w
            frame = img.crop((left, 0, left + slice_w, h))
            
            # find bounding box
            bbox = frame.getbbox()
            if bbox:
                # center of bbox
                center = (bbox[0] + bbox[2]) / 2
                print(f"  Frame {i}: bbox {bbox}, center={center:.1f}")
            else:
                print(f"  Frame {i}: empty")
except Exception as e:
    print(e)
