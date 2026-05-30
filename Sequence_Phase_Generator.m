% Script: Sequence_Phase_Generator.m
% Description: 
%   Generates the final combined phase masks for the Spatial Light Modulator (SLM).
%   Combines the GS-optimized spot array phase (pha_newt) with linear phase ramps
%   to scan the spot array across the sample (x and y directions).
% Author: Ning Xu

clc; clear;

% --- Configuration Parameters ---
% Select the scanning period (dx value) corresponding to specific SIM configurations
% Options: 1920, 960, 640, 480, 384, 320, 240, 213 (1920/9), 192, 160, 128...
ScanConfig.dx_period = 1920/9; 
ScanConfig.dy_period = 1080;
ScanConfig.SLM_Width = 1920;
ScanConfig.SLM_Height = 1080;
ScanConfig.PhaseStep = 0.4; % Step size for sigma loop
ScanConfig.PhaseMax = 2;    % Max sigma
ScanConfig.DirectionX = 1;  % Direction flag (+1 or -1)
ScanConfig.DirectionY = 1;

% Load Base Phase Mask (from GS Algorithm)
if exist('pha_newt.mat', 'file')
    load('pha_newt.mat', 'pha_newt');
else
    error('Base phase file pha_newt.mat not found.');
end

% Initialize Coordinates
dx_val = ScanConfig.dx_period;
dy_val = ScanConfig.dy_period;
M = ScanConfig.SLM_Height;
N = ScanConfig.SLM_Width;

x_vec = linspace(0, dx_val, dx_val);
y_vec = linspace(0, dy_val, dy_val);

% --- Pattern Generation Loop ---
file_counter = 1;

fprintf('Generating SLM sequences for Period dx = %.2f...\n', dx_val);

for sigma_x = 0 : ScanConfig.PhaseStep : ScanConfig.PhaseMax
    % Generate X-direction Gradient
    % Create base ramp
    phase_ramp_x = single((ScanConfig.DirectionX * sigma_x * pi / dx_val) .* x_vec);
    
    % Tile the X-ramp to fill the SLM width
    % The logic automatically handles different integer divisors of 1920
    full_phase_x = zeros(M, N, 'single');
    
    % Replicate ramp across width
    num_tiles = ceil(N / dx_val);
    temp_row = repmat(phase_ramp_x, 1, num_tiles);
    
    % Crop to exact width and replicate vertically
    full_phase_x = repmat(temp_row(1:N), M, 1);

    for sigma_y = 0 : ScanConfig.PhaseStep : ScanConfig.PhaseMax
        % Generate Y-direction Gradient
        % Since dy is usually full height, tiling is often 1x1, but logic holds
        phase_ramp_y_col = single((ScanConfig.DirectionY * sigma_y * pi / dy_val) .* y_vec');
        full_phase_y = repmat(phase_ramp_y_col, 1, N);
        
        % Combine Phases
        % Total Phase = Base_GS_Phase + Ramp_X + Ramp_Y
        combined_phase = full_phase_x + full_phase_y;
        
        % Modulo 2pi arithmetic for wrapping
        final_phase = mod(pha_newt + combined_phase, 2*pi);
        
        % --- Output Generation ---
        % File naming convention: [Period]_x+[ShiftX]_y+[ShiftY].bmp
        filename = sprintf('%.0f_x+%3.2f_y+%3.2f.bmp', ...
            dx_val, sigma_x, sigma_y);
        
        % Normalize to 0-1 for bitmap storage (0-255 mapped by imwrite)
        output_img = final_phase / (2*pi);
        
        imwrite(output_img, filename);
        
        file_counter = file_counter + 1;
    end
end

fprintf('Sequence generation complete. %d files created.\n', file_counter-1);