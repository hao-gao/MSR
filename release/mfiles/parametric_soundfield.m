classdef parametric_soundfield
    %PARAMETRIC_SOUNDFIELD Summary of this class goes here
    %   Detailed explanation goes here
    
    % Author: Jacob Donley
    % University of Wollongong
    % Email: jrd089@uowmail.edu.au
    % Copyright: Jacob Donley 2016
    % Date: 13 May 2016
    % Revision: 0.1
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Public Properties
    properties (Access = public)
        % Field Parameters
        res = 50;  % samples per metre %Resolution of soundfield          
        field_size = []; % [X, Y]

        P1 = 1;
        P2 = 0.99;
        omega;% Angular frequency of carrier wave
        
        % Modulation parameters
        m = 0.5;
        mode = 'USB'; % Upper Sideband (USB) or Lower Sideband (LSB)
        
        % Transducer Parameters
        Spkr_Dimensions = [0.12 0.1 0.12]; % metres
        %A = 0.2; %Cross sectional area in metres^2
        Origin = [0, 0]; % [X, Y]
        Angle = 30; % Parametric array source angle in degrees
        
        %%% Environmental Parameters
        
        % https://en.wikibooks.org/wiki/Engineering_Acoustics/The_Acoustic_Parameter_of_Nonlinearity
        % https://en.wikipedia.org/wiki/Nonlinear_acoustics
        Beta = 1.2; % Coefficient of non-linearity (Beta = 1 + 1/2 * B/A for fluids) (B/A = 0.4 for Diatomic Gases (Air))
        
        c = 343; %Speed of sound in air
        rho = 1.225; % Density of medium
        
        %Following ISO 9613-1. http://resource.npl.co.uk/acoustics/techguides/absorption/
        alpha1 = 1.1639; %Absorption Coefficient of ultrasound primary frequency 1  (20degC, 50%Humid., 40kHz, 101.325kPa)
        alpha2 = 1.1639; %Absorption Coefficient of ultrasound primary frequency 2  (20degC, 50%Humid., 40kHz, 101.325kPa)
        
        tau; %Retarded time
        
         % Results
            % 3D
            Soundfield = [];
    end
    
    % Private Properties
    properties (Access = private)
        f1 = 40000; % Carrier frequency (Primary frequency 1)
        f2 = 42000; % Modulated frequency (Primary frequency 2)
        fd = 2000;  % Message frequency (Difference frequency)        
    end
    
    
    %% Private Methods
    methods (Access = public)
%         function obj = parametric_soundfield(~)
%             obj.omega = 2 * pi * obj.f1;
%         end
        
        function obj = createEmptySoundfield(obj)
                wi = int16(obj.res * obj.field_size(1));
                le = int16(obj.res * obj.field_size(2));
                obj.Soundfield = zeros(wi,le);                
        end
        
    end
    
%% Public Methods
    methods
        
        function obj = createSoundfield(obj)            
            if length(obj.field_size) ~= 2
                error('Soundfield size has not been set correctly (Two dimensions).');
            end
            
            obj = obj.createEmptySoundfield();
            
            obj = obj.reproduceSoundfield();
            
        end
        
        function obj = reproduceSoundfield(obj,model)
            if nargin<2
                model='';
            end
            t = 0; %time zero
            
            wi = size(obj.Soundfield,1);
            le = size(obj.Soundfield,2);
            
            O = obj.Origin*obj.res;
            
            x = (1:wi) - O(1) - 1;
            y = (1:le) - O(2) - 1;            
            [xx, yy] = meshgrid( x/obj.res, y/obj.res );
            [Th,R0] = cart2pol( xx, yy );
             
            rotAng = obj.Angle/180*pi;
            if mod( rotAng + pi/2, 2*pi ) > pi % Flip angle mesh every 180 degrees so there is no dicontinuity
                Th = rot90(rot90(Th));
                rotAng = rotAng - pi;
            end            
            rotAng = mod(rotAng + pi, 2*pi) - pi; % Limit range from -pi to pi
            Th = Th - rotAng;
            mask = ((Th < pi/2) & (Th > - pi/2)); % Force positive directivity only (one-sided parametric array source)            
            R0 = R0 .* mask;
            Th = Th .* mask;
            
            if strcmp(model,'convolutional')
                
                p = obj.convolutionalModel(Th,R0,zeros(size(Th)));
                
            else
                
                omega_d = 2*pi*obj.fd;
                
                p = ( obj.Beta * obj.P1 * obj.P2 * omega_d^2) ./ (4*pi*obj.rho*obj.c^4 .* R0 *(obj.alpha1+obj.alpha2)) ...
                    .* (-1 + 1i*omega_d*tan(Th).^2 / (2*obj.c*(obj.alpha1+obj.alpha2)) ).^(-1) ...
                    .* exp(-1i*omega_d * (t - R0/obj.c));                            
                
            end
            
            
            p( isinf(p) ) = 0;
            
            obj.Soundfield = p ./ max(p(:));
            
        end
        
        function p = convolutionalModel(obj, Th, R0, Directions, Frequency)
            t=0;
            if nargin < 5 || isempty(Frequency)
                omega_d = 2*pi*obj.fd(:);
            else
                omega_d = 2*pi * Frequency(:);
            end
            
            if mod( Directions + pi/2, 2*pi ) > pi % Flip angle mesh every 180 degrees so there is no dicontinuity
                Th = rot90(rot90(Th));
                Directions = Directions - pi;
            end            
            Directions = mod(Directions + pi, 2*pi) - pi; % Limit range from -pi to pi
            Th = Th - Directions;
            mask = ((Th < pi/2) & (Th > - pi/2)); % Force positive directivity only (one-sided parametric array source)
            Th = Th .* mask;
            R0 = R0 .* mask;            
            
            psi = linspace(-pi,pi,180)';
            
            sz_1 = size(Th,1);
            sz_2 = size(Th,2);
            sz_om = size(omega_d,1);     
            sz_psi= length(psi);
            
            Th      = permute( repmat( Th     , 1   , 1   , sz_om, sz_psi ), [1 2 3 4]);
            R0      = permute( repmat( R0     , 1   , 1   , sz_om, sz_psi ), [1 2 3 4]);
            omega_d = permute( repmat( omega_d, 1   , sz_1, sz_2 , sz_psi ), [2 3 1 4]);
            psi_n   = permute( repmat( psi    , 1   , sz_1, sz_2 , sz_om  ), [2 3 4 1]);
            
            alpha_s = obj.alpha1+obj.alpha2;
            %spkr_r = sqrt(sum(obj.Spkr_Dimensions(1:2).^2)); % approximate speaker radius
            spkr_r = sqrt(prod(obj.Spkr_Dimensions(1:2))/pi); % approximate speaker radius
            k1 = 2*pi*obj.f1/obj.c;
            k2 = 2*pi*obj.f2/obj.c;
            k_d = omega_d / obj.c;
            K = ( obj.Beta * omega_d.^2) ./ (4*pi*obj.rho*obj.c^4 .* R0 * alpha_s);
            D_W = alpha_s./ sqrt( alpha_s^2 + k_d.^2.*tan(Th-psi_n).^4 );
%             D_W = 1./ sqrt( 1 + (omega_d.^2 * tan(Th).^2)./(4*obj.c^2*(obj.alpha1+obj.alpha2)^2) );
            D_1 = exp( -1/4 *(k1*spkr_r)^2 * tan(psi_n).^2);
            D_2 = exp( -1/4 *(k2*spkr_r)^2 * tan(psi_n).^2);
            
%             p = K(:,:,:,1).*cos(omega_d(:,:,:,1)*t - k_d(:,:,:,1).*R0(:,:,:,1)).* sum(D_1.*D_2.*D_W,4);
            
              p = K(:,:,:,1) .* sum(D_1.*D_2.*D_W,4) .* exp(-1i*omega_d(:,:,:,1) .* (t - R0(:,:,:,1)/obj.c));

%             p = ( obj.Beta * omega_d(:,:,:,1).^2) ./ (4*pi*obj.rho*obj.c^4 .* R0(:,:,:,1) *(obj.alpha1+obj.alpha2)) ...
%                  .* sum( D_1 .* D_2 ...
%                  .* abs((-1 + 1i*omega_d.*tan(Th-psi_n).^2 / (2*obj.c*(obj.alpha1+obj.alpha2)) ).^(-1)) , 4 ) ...
%                 .* exp(-1i*omega_d(:,:,:,1) .* (t - R0(:,:,:,1)/obj.c));
            
%             p = ( obj.Beta * obj.P1 * obj.P2 * omega_d(:,:,:,1).^2) ./ (4*pi*obj.rho*obj.c^4 .* R0(:,:,:,1) *(obj.alpha1+obj.alpha2)) ...
%                 .* (-1 + 1i*omega_d(:,:,:,1).*tan(Th(:,:,:,1)).^2 / (2*obj.c*(obj.alpha1+obj.alpha2)) ).^(-1) ...
%                 .* exp(-1i*omega_d(:,:,:,1) .* (t - R0(:,:,:,1)/obj.c));
            
            p = squeeze(p);
        end
        
        function obj = setTau(obj, t, z)
           obj.tau = t - z/obj.c; 
        end
        
        function obj = set_fd(obj, fd)
           obj.fd = fd;
           obj.f2 = obj.f1 + obj.fd;
        end
        function fd = get_fd(obj)
            fd = obj.fd;
        end
        
        function obj = set_f1(obj, f1)
           obj.f1 = f1;
           obj.f2 = obj.f1 + obj.fd;
        end
        function f1 = get_f1(obj)
            f1 = obj.f1;
        end
        
        function obj = set_f2(obj, f2)
           obj.f2 = f2;
           obj.f1 = obj.f2 - obj.fd;
        end
        function f2 = get_f2(obj)
            f2 = obj.f2;
        end
        
        %%
        function h = plotSoundfield(obj, field, field_type, colour)
            if nargin < 4; colour = parula; end;
            if nargin < 3; field_type = 'real'; end;
            if nargin < 2; field = obj.Soundfield; end;
            
            %%% Show parametric-style field strength
            if strcmp(field_type, 'complex')
                F = mag2db(abs(field));
                CaxisSize = db2mag(max(F(:)) - 35);
            elseif strcmp(field_type, 'real')
                F = abs(real(field));
                CaxisSize = max(F(:));
            else
                error('Incompatible field type.');
            end
            
            if ~isempty(F(:))
                CaxisSize = CaxisSize*4/3;
            end            
            %%%
            
            %XYTick = [1 length(field)/4 length(field)/2 length(field)*3/4 length(field)];
            %XYTickLabel = { -length(field)/2/obj.res, -length(field)/4/obj.res, 0, length(field)/4/obj.res, length(field)/2/obj.res};
            XYTick = [1  length(field)/2  length(field)];
            XYTickLabel = { -length(field)/2/obj.res,  0,  length(field)/2/obj.res};
            
            %             subplot(1,2,1);
            h = surf(real(field),'EdgeColor','None');
            colormap(colour);
            view(2);
            title('Real',...
                'FontWeight','bold',...
                'FontSize',24,...
                'FontName','Arial');
            axis('square');
            box on;
            axis([1 length(field) 1 length(field)]);
            set(gca, 'XTick', XYTick); set(gca, 'XTickLabel', XYTickLabel);
            set(gca, 'YTick', XYTick); set(gca, 'YTickLabel', XYTickLabel);
            set(gca, 'FontSize', 16);
            set(gca, 'FontName', 'Arial');
            % Create xlabel
            xlabel('Width (metres)','FontSize',20,'FontName','Arial');
            % Create ylabel
            ylabel('Length (metres)','FontSize',20,'FontName','Arial');
            % Create zlabel
            zlabel('Amplitude','Visible','off');
            caxis([-CaxisSize CaxisSize]);
            if (strcmp(version('-release'), '2012b'))
                tick_str = 'Ztick';
            else                
                tick_str = 'Ticks';
            end
            colorbar(tick_str,[-1 -0.5 0 0.5 1],'FontSize',16, 'FontName','Arial');
           
            
        end
        

        
    end
    
end

