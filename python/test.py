import numpy as np
#from scipy.stats import norm
import matplotlib.pyplot as plt


np.random.seed(0)

def binarizePY(input):
    output = input
    output[input > 0] = 1
    output[input <= 0] = -1
    return output

# Funktion for statt -1 zero
# def zero_ones(input):
#     output = input
#     output[input > 0] = 1
#     output[input <= 0] = 0
#     return output

    
# print("hello ya world!")
# sim = weights
# sim = zero_ones(sim)
# print(sim)


wm_rows = 64 # weight matrix rows (anzahl der neuronen)
wm_cols = 576 # weights per neuron
im_cols = 196 # anzahl columns

# create random values between (-1,+1)
weights = 2*np.random.rand(wm_rows, wm_cols) - 1
# binarize weight matrix
weights = binarizePY(weights)
np.set_printoptions(threshold=np.inf)

# print(weights)

# create random values between (-1,+1)
inputs = 2*np.random.rand(wm_cols, im_cols) - 1
inputs = binarizePY(inputs)
# inputs = np.transpose(inputs)

# print(inputs)


popcount = np.matmul(weights, inputs) # 2*pop - n = pop*
popcount = (popcount + wm_cols)/2
# print(popcount)

# create random values between (0,191)
thresholds = (wm_cols)*np.random.rand(wm_rows)
thresholds = thresholds.astype(int)
# from one threshold
# threshold = 300
# print(thresholds)

# transfer a value in n-bit representation of binary  
# thresholds_binary = [ bin(indx0)[2:].zfill(32) for indx0 in thresholds ]
# getbinary = lambda x, n: format(x, 'b').zfill(n)
# print(getbinary(thresholds, 32))
# thresholds = np.binary_repr(thresholds, width=32)
# for i in enumerate(thresholds):
#     thresholds[i] = np.binary_repr(thresholds[i], width=32)
# res = [int(i) for i in bin(thresholds[i])[2:]]

# print(thresholds_binary)
# print(thresholds[0])

np.set_printoptions(linewidth=5000)

# bits needed for threshold
bits_for_thresholds = np.ceil(np.log2(wm_cols))
# print(bits_for_thresholds)

# print(popcount)
# print(thresholds)

activations = np.zeros((wm_rows, im_cols))
# print(activations.shape)----
# thresholding for one threshold
# activations = []
for idx1, pre_a_map in enumerate(popcount):
    for idx2, value in enumerate(pre_a_map):
        activations[idx1][idx2] = value >= thresholds[idx1] #frag Mikail danach!!!!!!!!!!!!!!!!!!!!
                # activations[idx1][idx2] = value >= threshold


activations = activations.astype(int)
activations = np.transpose(activations)


res = activations
res0 = str(res).replace(' ', '')
with open(r'C:\Users\user1455\Desktop\python\activations.txt', 'w') as fp:
            # fp.write(res0)
                # fp.write(res0)
                fp.write('\n'.join(''.join(map(str,sl)) for sl in res))

print("The Result Activations Matrix is:")
print('\n'.join(''.join(map(str,sl)) for sl in res))

str_1 = np.array2string(activations[0])
# str_example = f'MEM8X4 := ("{activations[0]}", "{activations[0]}");'
# print(str_1)

str_1 = str_1.replace("[","")
str_1 = str_1.replace("]","")
str_1 = str_1.replace(" ","")

str_example = f'MEM8X4 := ("{str_1}");'
print("first column")
print(str_example)

str_2 = np.array2string(activations[1])
str_2 = str_2.replace("[","")
str_2 = str_2.replace("]","")
str_2 = str_2.replace(" ","")
str2_example = f'MEM8X4 := ("{str_2}");'
print("second column")
print(str2_example)

str_3 = np.array2string(activations[2])
str_3 = str_3.replace("[","")
str_3 = str_3.replace("]","")
str_3 = str_3.replace(" ","")
str3_example = f'MEM8X4 := ("{str_3}");'
print("third column")
print(str3_example)

# Funktion for statt -1 zero
def zero_ones(input):
    output = input
    output[input > 0] = 1
    output[input <= 0] = 0
    return output


    
# print("weights!")
sim_w = weights
sim_w = zero_ones(sim_w)

sim_w_0 = str(sim_w).replace('.', '').replace(' ', '').replace('[', '').replace(']', '')
with open(r'C:\Users\user1455\Desktop\python\weights.txt', 'w') as fp:
            fp.write(sim_w_0)



# print("Input!")
sim_d = np.transpose(inputs)
sim_d = zero_ones(sim_d)
sim_d_0 = str(sim_d).replace(' ', '').replace('.', '').replace('[', '').replace(']', '')
with open(r'C:\Users\user1455\Desktop\python\inputs.txt', 'w') as fp:
            fp.write(sim_d_0)



# print("Threshold!")
sim_T = [ bin(indx0)[2:].zfill(32) for indx0 in thresholds ]
# sim_T_0 = str(sim_T).replace(',', '').replace(' ', '')
with open(r'C:\Users\user1455\Desktop\python\threshold.txt', 'w') as fp:
            # fp.write("%s\n"% sim_T_0)
            fp.write('\n'.join(str(line) for line in sim_T))

# print(sim_T_0)


# print(activations)

