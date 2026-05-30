function System = Get_System_Parameters(Nx, Ny)
% GET_SYSTEM_PARAMETERS Initializes optical system constraints.
%
%   System = Get_System_Parameters(Nx, Ny)
%
%   Inputs:
%       Nx, Ny : Dimensions of the region of interest (pixels).
%
%   Outputs:
%       System : Struct containing spatial coordinates (x,y), frequency 
%                coordinates (fx,fy), NA, wavelengths, and the 
%                experimentally derived OTF.

    % --- Optical Configuration ---
    System.NA = 1.45;             % Numerical Aperture (Objective)
    System.lambda_illu = 0.488;   % Illumination Wavelength (um)
    System.lambda_ex = 0.519;     % Emission/Excitation Wavelength (um)

    % --- Pixel scaling and Coordinates ---
    % Pixel size calculation accounting for magnification
    % Mag1 and Mag2 represent relay optics magnification factors
    System.dx = 6.5 / 100 / 1.5;  % Effective pixel size (um)
    dx = System.dx;
    
    % Frequency Domain Sampling
    Lfx = 1/dx; 
    Lfy = 1/dx;
    
    % Spatial Grid Generation
    n = (1:Nx)'; 
    m = (1:Ny)';
    x_vec = (-Nx/2 : 1 : Nx/2-1) * dx;
    y_vec = (-Ny/2 : 1 : Ny/2-1) * dx;
    [x, y] = meshgrid(x_vec, y_vec);
    
    % Frequency Grid Generation
    fx_nom = -Lfx/2 + Lfx/Nx * (n-1);
    fy_nom = -Lfy/2 + Lfy/Ny * (m-1);
    [fx, fy] = meshgrid(fx_nom, fy_nom);
    
    % Store in Structure
    System.x = x; 
    System.y = y; 
    System.fx = fx; 
    System.fy = fy;
    
    % --- OTF Generation ---
    % Calculation of the coherent cutoff frequency
    rho0 = System.NA / System.lambda_ex; 
    rho = (fx.^2 + fy.^2).^0.5;

    % Load Experimental Point Spread Function (PSF)
    % Ensures the simulation matches the physical aberrations of the setup
    psf_full = zeros(Ny, Nx);
    
    if exist('psf.mat', 'file')
        data_ptr = load('psf.mat');
        psfdata = data_ptr.psf_ave;
        [H_psf, W_psf] = size(psfdata);
        
        % Center the PSF in the field of view
        offset_x = ceil((Nx - W_psf)/2);
        offset_y = ceil((Ny - H_psf)/2);
        psf_full(offset_y+1:offset_y+H_psf, offset_x+1:offset_x+W_psf) = psfdata;
    else
        warning('psf.mat not found. Using ideal PSF.');
        psf_full(Ny/2, Nx/2) = 1; % Delta function placeholder
    end
    
    % Compute Optical Transfer Function (OTF)
    OTF_raw = fftshift(fft2(ifftshift(psf_full)));
    OTF_norm = abs(OTF_raw) / max(abs(OTF_raw(:)));
    
    % Apply band-limiting filter (Diffraction Limit)
    OTF_filtered = OTF_norm .* (rho <= 2*rho0);
    
    System.OTF = OTF_filtered; 
    System.psf = psf_full;

end