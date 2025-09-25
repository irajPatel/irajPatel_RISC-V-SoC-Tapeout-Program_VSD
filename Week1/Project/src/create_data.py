import numpy as np
import matplotlib.pyplot as plt

# Clear variables equivalent
# In Python, just start fresh

# Parameters
f_sine = 10        # Sine wave frequency in Hz
Amp = 10           # Amplitude
fs = 100          # Sampling frequency (20x f_sine for smoothness)
duration = 2      # Duration in seconds

# Time vector
t = np.arange(0, duration, 1/fs)

# Generate sine wave
sine_wave = Amp * np.sin(2 * np.pi * f_sine * t)



# Add noise
noise_amplitude = 0.1
noise = np.random.uniform(-noise_amplitude, noise_amplitude, len(sine_wave))
sine_noise = sine_wave + noise

# Normalize
sine_norm = sine_noise / np.max(np.abs(sine_noise))
# Convert from real to integers
total_wordlength = 16
scaling = 7
sine_noise_integers = np.round(sine_norm * (2**scaling)).astype(int)



# Convert integers to binary (signed, 16-bit)
def int_to_bin_signed(val, bits=16):
    """Convert integer to 2's complement binary string"""
    return format(val & (2**bits - 1), '0{}b'.format(bits))

sine_noise_in_binary_signed = [int_to_bin_signed(x, total_wordlength) for x in sine_noise_integers]

# Save to file
with open('signal.data', 'w') as f:
    for b in sine_noise_in_binary_signed:
        f.write(f'{b}\n')

print('Text file for signal finished')
