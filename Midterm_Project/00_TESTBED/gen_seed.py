import re
import random

def replace_seed(filename):
    # Generate a new random seed
    new_seed = random.randint(1, 10000)  # Generate a new seed between 1 and 10000

    
    # Ensure proper encoding while reading the file
    with open(filename, 'r', encoding='utf-8') as file:
        content = file.read()
        
    # Search for the SEED line and replace it with the new seed
    # updated_content = re.sub(r'(integer\s+SEED\s*=\s*)\d+;', rf'\1{new_seed};', content)
    updated_content = re.sub(r'(integer\s+SEED\s*=\s*)\d+\s*;', lambda match: f"{match.group(1)}{new_seed};", content)
    
    # Ensure proper encoding while writing the updated content back
    with open(filename, 'w', encoding='utf-8') as file:
        file.write(updated_content)

    print(f"SEED updated to: {new_seed}")

# Example usage
replace_seed("PATTERN.v")
