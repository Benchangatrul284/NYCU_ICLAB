import os
import subprocess
import time
import re
import random

def replace_seed(filename):
    # Generate a new random seed
    new_seed = random.randint(1, 1000000)  # Generate a new seed between 1 and 10000

    # Ensure proper encoding while reading the file
    with open(filename, 'r', encoding='utf-8') as file:
        content = file.read()
        
    # Search for the SEED line and replace it with the new seed
    # updated_content = re.sub(r'(integer\s+SEED\s*=\s*)\d+;', rf'\1{new_seed};', content)
    updated_content = re.sub(r'(`define\s+SEED\s+)\d+', lambda match: f"{match.group(1)}{new_seed}", content)
    
    # Ensure proper encoding while writing the updated content back
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(updated_content)

    # print(f"SEED updated to: {new_seed}")

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
                        value = random.randint(0, 255)
                        f.write(f"{value:X} ")
                        temp_pic.append(value)
                f.write(f"\n")
                temp.append(temp_pic)
            f.write(f"\n")

random.seed(0)
os.chdir('../01_RTL')

cnt = 0
total_latency = 0
latency_pattern = re.compile(r"Total Latency = (\d+)")
error_pattern = re.compile(r"\[ERROR\].*")
    


for _ in range(100):
    cnt += 1
    print(f"Running test {cnt}")
    generate_dram_data("../00_TESTBED/DRAM/dram.dat")
    replace_seed("../00_TESTBED/PATTERN.v")

    # Run the shell script with Popen
    process = subprocess.Popen(
        ['sh', '../01_RTL/01_run_vcs_rtl'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )

    # Stream the output and error to the console
    stdout_lines = []
    stderr_lines = []
    for line in iter(process.stdout.readline, ''):
        print(line, end='')  # Print to terminal immediately
        stdout_lines.append(line)
    for line in iter(process.stderr.readline, ''):
        print(line, end='')  # Print to terminal immediately
        stderr_lines.append(line)

    process.stdout.close()
    process.stderr.close()
    process.wait()  # Ensure the process completes


    result = ''.join(stdout_lines) + ''.join(stderr_lines)

    # Extract latency and error messages
    latency_match = latency_pattern.search(result)
    error_match = error_pattern.search(result)

    if error_match:
        error_message = error_match.group(0)
        print(f"Error Message: {error_message}")
        exit()

    if latency_match:
        latency = latency_match.group(1)
        latency = int(latency)
        print(f"Total Latency: {latency}")
        total_latency += latency
    else:
        raise ValueError("Latency not found in output.")

    print(f"Completed {cnt} tests.")
    print(f"Average Latency: {total_latency // cnt}")

    process = subprocess.Popen(
        ['sh', '../01_RTL/09_clean_up'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )

    time.sleep(1)