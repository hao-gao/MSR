clc;
clear;
close all;
if (matlabpool('size') ~= 0); matlabpool close; end; %Close existing pool if open
matlabpool %Start new pool

error = [];
frequencies = 1:6;
parfor f = frequencies %Parallel processed for loop
%% Setup
    zones = [];
    monofields = [];
    soundfield = [];


%% Zone 1, Frequency 1
    % Sound in Zone: Frequency, Radius, Source Type, Weight, Angle, Source Distance
    zones = [zones spatial_zone(f*1000, 0.3, 'pw', 1.0, 0)];    
    zones = [zones spatial_zone(f*1000, 0.3, 'quiet')];

%% Zone 2, Frequency 2
    % Sound in Zone: Frequency, Radius, Source Type, Weight, Angle, Source Distance
%     zones = [zones spatial_zone(2000, 0.3, 'pw', 1.0, 45)];    
%     zones = [zones spatial_zone(2000, 0.3, 'quiet')];

%% Frequency 1
    monofields = [monofields global_soundfield];
    % Location of Zone: Distance and Angle from Origin
    monofields(1) = monofields(1).addSpatialZone(zones(1), 0.6, 180);
    monofields(1) = monofields(1).addSpatialZone(zones(2), 0.6, 0);
    
%% Frequency 2
%     monofields = [monofields global_soundfield];
%     % Location of Zone: Distance and Angle from Origin
%     monofields(2) = monofields(2).addSpatialZone(zones(3), 1.0, 0);
%     monofields(2) = monofields(2).addSpatialZone(zones(4), 1.0, 180);


%% Wideband field
    soundfield = wideband_soundfield;
    %Add each monofield to the wideband field
    for n = 1:length(monofields)
        soundfield = soundfield.addGlobalSoundfield(monofields(n));
    end
    
    %Create wideband field
    soundfield = soundfield.setResolution(150); % Resolution is in samples per metre
    soundfield = soundfield.createWidebandSoundfield();
    
    
%% Calculate error in each zone from interferring zones
     soundfield = soundfield.calcErrorField;
     soundfield.plotError;
     error = [error soundfield.Error_Total_MSEdb];
    
%% Display Sound Field
       soundfield.plotSoundfield;
%      field = soundfield.Soundfield_Wideband .* soundfield.Soundfield_ZoneMask;
%      soundfield.plotSoundfield(soundfield.Soundfield_Wideband, max(abs(real( field(:) ))));
    
end

%%
plot(frequencies*1000, error);
    
    