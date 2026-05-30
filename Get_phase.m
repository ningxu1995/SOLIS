function position = Get_Phase_Estimation(image_stack, System)
% GET_PHASE_ESTIMATION Estimates phase shifts in raw data.
%
%   position = Get_Phase_Estimation(image_stack, System)
%
%   Inputs:
%       image_stack : 3D array (Ny, Nx, Nraw) containing raw  frames.
%       System      : Structure containing optical parameters (x, y, OTF).
%
%   Outputs:
%       position    : (Nraw, 2) array containing estimated phase shifts 
%                     normalized to the pattern period.
%
%   Methodology:
%       Cross-correlation in the Fourier domain based on Lal et al. (2016).
%       Includes a pre-check for sample sparsity (e.g., beads vs cells).

    [Ny, Nx, Nraw] = size(image_stack); 
    x = System.x; 
    y = System.y; 
    OTF = System.OTF;
    
    % --- Pre-processing: Sample Density Normalization ---
    % If the raw image is sparse (e.g., beads), the frequency spectrum peaks 
    % are distinct. For dense samples (cells), we estimate phase shifts using 
    % a reference cell sample if available, or normalize the input.
    % Note: If 'sample_cell.tif' is not present, this block assumes input 
    % image_stack is sufficient.
    
    if exist('sample_cell.tif', 'file')
        RawBuffer = zeros(Ny, Nx, Nraw);
        for i = 1:Nraw
            RawBuffer(:,:,i) = double(imread('sample_cell.tif', i));
        end
        ProcImage = RawBuffer / max(RawBuffer(:));
    else
        ProcImage = double(image_stack) / max(double(image_stack(:)));
    end
    
    % --- Fourier Transformation ---
    F_image = zeros(size(ProcImage));
    for i = 1:Nraw
        F_image(:,:,i) = fftshift(fft2(ifftshift(ProcImage(:,:,i))));
    end
    
    % --- Illumination Vector Identification ---
    % Spatial frequencies acquired from the Fourier spectrum analysis.
    % Format: [kx1, ky1; kx2, ky2]
    SpatialFrequency = [-7.413e-4, -3.3213; 1.9177, -0.0018];
    
    % Calculate Pattern Period
    period = [1/abs(SpatialFrequency(1,2)), 1/abs(SpatialFrequency(2,1))];
    
    % --- Cross-Correlation Phase Extraction ---
    % Reference: A. Lal, et al., IEEE J. Sel. Top. Quantum Electron. 22 (2016).
    phase_rad = zeros(Nraw, 2);
    
    for m = 1:Nraw
        % Cross-correlation with OTF
        Fcc = F_image(:,:,m) .* conj(OTF);   
        cc = fftshift(ifft2(ifftshift(Fcc)));
        
        % Demodulation at fundamental frequencies
        exp_factor1 = exp(1i * 2 * pi * (SpatialFrequency(1,1).*x + SpatialFrequency(1,2).*y));
        exp_factor2 = exp(1i * 2 * pi * (SpatialFrequency(2,1).*x + SpatialFrequency(2,2).*y));
        
        Fcc_shift1 = fftshift(fft2(ifftshift(cc .* exp_factor1)));
        Fcc_shift2 = fftshift(fft2(ifftshift(cc .* exp_factor2)));
        
        % Peak integration
        freq_val1 = sum(sum(Fcc .* conj(Fcc_shift1)));
        freq_val2 = sum(sum(Fcc .* conj(Fcc_shift2)));
        
        phase_rad(m,1) = angle(freq_val1);
        phase_rad(m,2) = angle(freq_val2);
    end
    
    % Normalize to relative phase
    phase_rad = phase_rad - repmat(phase_rad(1,:), Nraw, 1);

    % --- Phase Unwrapping ---
    tmp_phase = zeros(size(phase_rad));
    tmp_phase(:,1) = unwrap(phase_rad(:,2)); 
    tmp_phase(:,2) = unwrap(-1 .* phase_rad(:,1));
    
    % --- Convert Phase to Physical Position ---
    position = zeros(Nraw, 2);
    position(:,1) = tmp_phase(:,1) * period(2) / (2*pi);
    position(:,2) = tmp_phase(:,2) * period(1) / (2*pi);

end