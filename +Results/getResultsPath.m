function [Path, err] = getResultsPath( SYS_or_setup, database_res, room, signal_info, database_workingdir, method )
%GETDATABASEFROMSETUP Summary of this function goes here

SYS_type = 'Current_Systems.SR_System';

%%
latest_method = 'new';
if nargin < 6
    method = latest_method;
end
if nargin == 1
    if isa(SYS_or_setup,SYS_type)
        SYS = SYS_or_setup;
        setup = SYS.Main_Setup;
        database_res = SYS.system_info.LUT_resolution;
        room = SYS.Room_Setup;
        signal_info = SYS.signal_info;
        database_workingdir = SYS.system_info.Drive;
    else
        error(['Single input argument must be of type: ' SYS_type]);
    end
elseif nargin > 1
    setup = SYS_or_setup;
    if nargin < 5
        database_workingdir = 'Z:\';
    end
    if nargin < 4
        signal_info = [];
    end
end

Recordings_Path = [ ...
    database_workingdir ...
    '+Results\'];

err = false;
try
    
    if strcmpi(method, latest_method)
        sc = '_';
        
        [~,~,~,~,reproduction_info_dirs] = Broadband_Tools.getLoudspeakerSignalPath( setup, signal_info, database_res );
        
        spkr_sig_info_dir = [ ...
            '+' num2str(signal_info.f_low ) 'Hz-' ...
            num2str(signal_info.f_high) 'Hz' sc sc ...
            'method' sc signal_info.method filesep ];
        
        [~,~,room_info_dir1,room_info_dir2] = Room_Acoustics.getRIRDatabasePath( setup, room );
        room_info_dirs = [room_info_dir1, room_info_dir2, filesep];
        
        if isfield(signal_info, 'recording_type') && strcmpi(signal_info.recording_type, 'realworld')
            realworld_path = '+Physical_World\';
        else
            realworld_path = [];
        end
        
        Path = [Recordings_Path ...
            realworld_path, ...
            reproduction_info_dirs, ...
            room_info_dirs, ...
            spkr_sig_info_dir];
        
        
    elseif strcmpi(method, 'old')
        spkr_sig_dir = ['+' num2str(setup.Radius*2) 'm_SpkrDia\+' num2str(setup.Loudspeaker_Count) 'Spkrs_' num2str(setup.Speaker_Arc_Angle) 'DegArc_LUT_' database_res '\'];
                
        Path = [ ...
            Recordings_Path
            '+Reverb__' num2str(room.NoReceivers) 'Rec_' ...
            room.Room_Size_txt 'Dim_' ...
            room.Reproduction_Centre_txt 'Ctr_' ...
            num2str(room.Wall_Absorb_Coeff) 'Ab\' ...
            spkr_sig_dir];
            
    else
        error('Method to load Results path from setup and room is not supported.')
    end
    
catch ex
    switch ex.identifier
        case 'MATLAB:load:couldNotReadFile'
            warning(['Could not load Results path using the ' method ' method.']);
            err = true;
        otherwise
            rethrow(ex)
    end
end


end

