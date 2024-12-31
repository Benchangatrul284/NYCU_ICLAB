import numpy as np
import os


NUMBER_OF_PATTERN = 10

def float_to_ieee_fp32(value):
    '''
    convert a float to its IEEE 754 single-precision representation
    '''
    np_float32 = np.float32(value)
    ieee_fp32_uint = np_float32.view(np.uint32)
    ieee_fp32_hex = format(ieee_fp32_uint, '08x').upper()
    return ieee_fp32_hex


def generate_opt_file(opt_file):
    '''
    generate a random 0 or 1 for opt file
    '''
    opt_value = np.random.randint(0, 2)
    opt_file.write(f"{opt_value}\n")
    opt_file.write('\n')
    return opt_value


def generate_image_file(image_file):
    image_array = np.random.uniform(-0.5, 0.5, (3, 5, 5)).astype(np.float32) # (channel, height, width)
    for c in range(3):
        for h in range(5):
            for w in range(5):
                image_file.write(f"{float_to_ieee_fp32(image_array[c][h][w])}\n")

    image_file.write('\n')
    # pad the image array with zeros
    image_array = np.pad(image_array, ((0,0),(1,1),(1,1)), 'constant', constant_values=0)
    print(image_array.shape)
    return image_array

def generate_kernel_file(kernel_file):
    kernel = np.random.uniform(-0.5, 0.5, (3, 2, 2)).astype(np.float32)
    for c in range(3):
        for i in range(2):
            for j in range(2):
                kernel_file.write(f"{float_to_ieee_fp32(kernel[c][i][j])}\n")
    kernel_file.write('\n')
    return kernel

def generate_weight_file(weight_file):
    weight_array = np.random.uniform(-0.5, 0.5, (3, 8)).astype(np.float32)
    for c in range(3):
        for i in range(8):
            weight_file.write(f"{float_to_ieee_fp32(weight_array[c][i])}\n")
    weight_file.write('\n')
    return weight_array.T

def write_output_file(out_file, output_array):
    for c in range(3):
        out_file.write(f"{float_to_ieee_fp32(output_array[c])}\n")
    out_file.write('\n')

def padding(opt_value, image_array):
    '''
    opt_value = 0 -> sigmoid and zero padding
    opt_value = 1 -> tanh and replication padding
    '''
    if opt_value == 0:
        return image_array
    elif opt_value == 1:
        for c in range(3):
            # corners
            image_array[c][0][0] = image_array[c][1][1]
            image_array[c][0][6] = image_array[c][1][5]
            image_array[c][6][0] = image_array[c][5][1]
            image_array[c][6][6] = image_array[c][5][5]
            
            # top and bottom
            image_array[c][0][1] = image_array[c][1][1]
            image_array[c][0][2] = image_array[c][1][2]
            image_array[c][0][3] = image_array[c][1][3]
            image_array[c][0][4] = image_array[c][1][4]
            image_array[c][0][5] = image_array[c][1][5]
            
            image_array[c][6][1] = image_array[c][5][1]
            image_array[c][6][2] = image_array[c][5][2]
            image_array[c][6][3] = image_array[c][5][3]
            image_array[c][6][4] = image_array[c][5][4]
            image_array[c][6][5] = image_array[c][5][5]
            
            # left and right
            image_array[c][1][0] = image_array[c][1][1]
            image_array[c][2][0] = image_array[c][2][1]
            image_array[c][3][0] = image_array[c][3][1]
            image_array[c][4][0] = image_array[c][4][1]
            image_array[c][5][0] = image_array[c][5][1]
            
            image_array[c][1][6] = image_array[c][1][5]
            image_array[c][2][6] = image_array[c][2][5]
            image_array[c][3][6] = image_array[c][3][5]
            image_array[c][4][6] = image_array[c][4][5]
            image_array[c][5][6] = image_array[c][5][5]
        
        return image_array

def convolution(image_array,kernel_1,kernel_2):
    '''
    perform 2d convolution
    input: image_array: (3,7,7)
           kernel_1: (3,2,2)
            kernel_2: (3,2,2)
    output: image_array: (2,6,6)
    
    the first channel is computed by kernel_1
    the second channel is computed by kernel_2
    '''
    output_array = np.zeros((2,6,6),dtype=np.float32)
    for i in range(6):
        for j in range(6):
            for c in range(3):
                output_array[0][i][j] += np.sum(image_array[c][i:i+2,j:j+2]*kernel_1[c])
                output_array[1][i][j] += np.sum(image_array[c][i:i+2,j:j+2]*kernel_2[c])
    
    return output_array


def max_pooling(image_array):
    '''
    perform max pooling
    input: image_array: (2,6,6)
    output: image_array: (2,2,2)
    the kernel_zie iof max_pooling is fixed to 3x3
    '''
    output_array = np.zeros((2,2,2),dtype=np.float32)
    for c in range(2):
        for i in range(2):
            for j in range(2):
                output_array[c][i][j] = np.max(image_array[c][i*3:i*3+3,j*3:j*3+3])
    return output_array

def activation_function(image_array,opt_value):
    '''
    perform activation function
    input: image_array: (2,2,2)
           opt_value: 0 -> sigmoid
                      1 -> tanh
    output: image_array: (2,2,2)
    '''
    if opt_value == 0:
        image_array = 1/(1+np.exp(-image_array))
    elif opt_value == 1:
        image_array = np.tanh(image_array)
    return image_array



if __name__ == "__main__":
    root_dir = 'lab4_pattern'
    if root_dir not in os.listdir():
        os.mkdir(root_dir)
        
    image_file_path = os.path.join(root_dir, 'Img.txt')
    weight_file_path = os.path.join(root_dir, 'Weight.txt')
    kernel_file1_path = os.path.join(root_dir, 'Kernel_ch1.txt')
    kernel_file2_path = os.path.join(root_dir, 'Kernel_ch2.txt')
    opt_file_path = os.path.join(root_dir, 'Opt.txt')
    out_file_path = os.path.join(root_dir, 'Out.txt')
    
    # check if the files already exist
    if os.path.exists(image_file_path):
        os.remove(image_file_path)
    if os.path.exists(weight_file_path):
        os.remove(weight_file_path)
    if os.path.exists(kernel_file1_path):
        os.remove(kernel_file1_path)
    if os.path.exists(kernel_file2_path):
        os.remove(kernel_file2_path)
    if os.path.exists(opt_file_path):
        os.remove(opt_file_path)
    if os.path.exists(out_file_path):
        os.remove(out_file_path)
    
    # open the files with write mode
    image_file = open(image_file_path, 'w')
    weight_file = open(weight_file_path, 'w')
    kernel_file1 = open(kernel_file1_path, 'w')
    kernel_file2 = open(kernel_file2_path, 'w')
    opt_file = open(opt_file_path, 'w')
    out_file = open(out_file_path, 'w')
    
    for pat in range(NUMBER_OF_PATTERN):
        # write the pattern number
        image_file.write(f'{pat}\n')
        weight_file.write(f'{pat}\n')
        kernel_file1.write(f'{pat}\n')
        kernel_file2.write(f'{pat}\n')
        opt_file.write(f'{pat}\n')
        out_file.write(f'{pat}\n')

        # generate 0 or 1 for opt file
        opt_value = generate_opt_file(opt_file)
        # generate the random float values for image
        image_array = generate_image_file(image_file)
        # generate the random float values for kernel_1 and kernel_2
        kernel_1 = generate_kernel_file(kernel_file1)
        kernel_2 = generate_kernel_file(kernel_file2)
        # generate the random float values for weight
        weight_array = generate_weight_file(weight_file)
        
        # padding
        image_array = padding(opt_value, image_array)
        # convolution
        image_array = convolution(image_array, kernel_1, kernel_2)
        # max pooling
        image_array = max_pooling(image_array)
        # activation function
        image_array = activation_function(image_array,opt_value)
        # fully connected layer
        image_array = np.dot(image_array.reshape(-1),weight_array)
        # softmax
        image_array = np.exp(image_array)/np.sum(np.exp(image_array))
        # write the output array to out file
        write_output_file(out_file, image_array)
        
        
        
    # Close the files
    image_file.close()
    weight_file.close()
    kernel_file1.close()
    kernel_file2.close()
    opt_file.close()
    out_file.close()