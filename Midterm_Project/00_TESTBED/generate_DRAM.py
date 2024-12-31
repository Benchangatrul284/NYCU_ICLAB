import os
import subprocess
import time
import re
import random

def generate_dram_data(filename):
    with open(filename, 'w') as f:
        for pic in range(16):
            f.write(f"@{(65536 + pic * 3072):X}\n")
            temp = []
            for color in range(3):
                # R, G, B
                temp_pic = []
                for idx in range(32):
                    for j in range(32):
                        value = np.random.randint(0, 254)
                        if idx == 31 and j == 31:
                            value = 255
                        f.write(f"{value:X} ")
                        temp_pic.append(value)
                
                f.write(f"\n")
                temp.append(temp_pic)
            f.write(f"\n")

generate_dram_data("../00_TESTBED/DRAM/dram.dat")