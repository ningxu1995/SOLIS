% Script: SRspotN_N_Optimized.m
% Description: 
%   Implements a Weighted Gerchberg-Saxton (GS) Iterative Fourier Transform Algorithm (IFTA) 
%   to generate a pure phase hologram. The target is a SR N x N spot array 
%   constrained by the diffraction limit of the optical system.
% Author: Ning Xu, Tsinghua University

clc; clear; close all;

%% --- Initialization and Grid Definition ---
M = 3100;           % Simulation grid size (Pixels)
N_spot_dim = 388;   % Dimension of the target spot region
Efficiency = 0.057; % Target diffraction efficiency parameter

% Define Input Plane Amplitude (A1) - Assuming Plane Wave Illumination
% The aperture is defined centrally within the simulation window.
A1 = zeros(M, 'single');
roi_start = M/2 - N_spot_dim/2 + 1;
roi_end = M/2 + N_spot_dim/2;
A1(roi_start:roi_end, roi_start:roi_end) = 1;

%% --- Target Amplitude Definition (Fourier Plane Constraints) ---
% Constructing the target amplitude profile based on Sinc interpolation 
% to simulate diffraction-limited spot generation.

% Define diffraction limit constraint (0.5 * Diffraction Limit)
SincKernel = zeros(11, 'single');
for x = 1:11
    for y = 1:11
        % Sinc function modeling for sub-diffraction spots
        SincKernel(x,y) = (sinc((1/5)*(x-6))) * (sinc((1/5)*(y-6)));
    end
end

% Initialize Target Amplitude Matrix (A_target)
A_target = ones(M, 'single') * Efficiency; 

% Construct the 10x10 Spot Array Matrix
% We tile the SincKernel to create the spot array pattern
SpotArray_Block = zeros(50, 50, 'single'); % Pre-allocating block
% (Note: Manual tiling retained for precise spacing control as per experiment)
% [Block filling logic abstracted for brevity - populating 5x5 sub-blocks]
% Populating top-left quadrant of the block
for r = 0:4
    for c = 0:4
        r_idx = 1 + r*10; 
        c_idx = 1 + c*10;
        SpotArray_Block(r_idx:r_idx+10, c_idx:c_idx+10) = SincKernel;
    end
end

% Extract the functional 50x50 region (approx) and tile to 100x100
SpotUnit = SpotArray_Block(1:50, 1:50);
TargetPattern = [SpotUnit, SpotUnit; SpotUnit, SpotUnit];
[L_pat, ~] = size(TargetPattern);

% Embed TargetPattern into the center of A_target
offset = round(M * 458 / 2048);
center_idx = M/2 - L_pat/2 - offset;
A_target(center_idx + 1 : center_idx + L_pat, center_idx + 1 : center_idx + L_pat) = TargetPattern;

%% --- Iterative Phase Retrieval (GS Algorithm) ---

% Initial Random Phase Estimate
rng(1); % Fixed seed for reproducibility
initial_phase = 2 * pi * rand(M, 'single');
E1 = A1 .* exp(1i * initial_phase);

% Weighting Factor for Uniformity Correction
W = ones(M, 'single'); 

% Stage 1: Standard GS Iteration (Global Convergence)
fprintf('Starting Stage 1: Global Convergence...\n');
for iter = 1:70
    % Forward Propagation (FFT)
    E2 = fftshift(fft2(ifftshift(E1)));
    
    % Amplitude Constraint Application
    A2_meas = abs(E2);
    A2_meas = A2_meas ./ max(A2_meas(:));
    
    % Enforce Target Amplitude (Hybrid Constraint)
    A2_update = A2_meas * 0.9; 
    A2_update(center_idx + 1 : center_idx + L_pat, center_idx + 1 : center_idx + L_pat) = TargetPattern;
    
    % Backward Propagation (IFFT)
    E3 = A2_update .* exp(1i * angle(E2));
    E4 = fftshift(ifft2(ifftshift(E3)));
    
    % Update Input Field (Retain Phase, Reset Amplitude)
    E1 = A1 .* exp(1i * angle(E4));
end

% Stage 2: Weighted GS Iteration (Uniformity Optimization)
% Introduces a feedback loop to suppress zero-order and equalize spot intensity.
fprintf('Starting Stage 2: Weighted Uniformity Optimization...\n');
for iter = 1:70
    E2 = fftshift(fft2(ifftshift(E1)));
    A2_meas = abs(E2);
    A2_meas = A2_meas ./ max(A2_meas(:));
    
    % Update Weights based on discrepancy
    % w_new = w_old * (Target / Measured)^0.8
    W = W .* (A_target ./ (A2_meas + 1e-10)).^0.8; 
    
    % Apply Weighted Target
    A3 = W .* A_target;
    
    % Backward Propagation
    E3 = A3 .* exp(1i * angle(E2));
    E4 = fftshift(ifft2(ifftshift(E3)));
    
    % Update Input Field
    E1 = A1 .* exp(1i * angle(E4));
end

%% --- Result Extraction and Verification ---
FinalPhase = mod(angle(E1), 2*pi);

% Verification: Numerical Reconstruction
Verification_Amp = zeros(M, M, 'single');
Verification_Amp(roi_start:roi_end, roi_start:roi_end) = 1;
E_Recon = Verification_Amp .* exp(1i * FinalPhase);
I_Recon = abs(fftshift(fft2(ifftshift(E_Recon)))).^2;
I_Recon = I_Recon ./ max(I_Recon(:));

% Visualization
figure(100); 
imshow(I_Recon, []); title('Numerical Reconstruction of Spot Array');

% Extract Central Region for SLM loading (1080x1920)
SLM_Height = 1080; SLM_Width = 1920;
ROI_Phase = zeros(SLM_Height, SLM_Width, 'single');

% Center crop logic
start_y = SLM_Height/2 - N_spot_dim/2 + 1;
start_x = SLM_Width/2 - N_spot_dim/2 + 1;
ROI_Phase(start_y:start_y+N_spot_dim-1, start_x:start_x+N_spot_dim-1) = ...
    FinalPhase(roi_start:roi_end, roi_start:roi_end);

Final_SLM_Phase = mod(ROI_Phase, 2*pi);

% Save Output
save('Calculated_Phase_Mask.mat', 'Final_SLM_Phase');
fprintf('Optimization Complete. Phase mask saved.\n');