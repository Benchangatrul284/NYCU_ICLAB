import random
import json

if __name__ == "__main__":
   with open (f"../00_TESTBED/DRAM/dram.dat", 'w') as f:
     for pic in range (16):
      f.write(f"@{(65536+pic*3072):X}\n")
      temp = []
      for color in range (3):
        # R, G, B
        temp_pic = []
        for idx in range (32):
          for j in range (32):
            value = random.randint(0, 255)
            f.write(f"{value:X} ")
            temp_pic.append(value)
        f.write(f"\n")
        temp.append(temp_pic)
      
      f.write(f"\n")
