function useMeasuredATF(SYS)
% Swaps the simulated RIRs (Room ATFs) with the measured ATFs
% 
% Syntax:	useMeasuredATF( SYS ) Explain usage here
% 
% Inputs: 
% 	SYS - Soundfield reproduction system object
% 
% See also: List related files here

% Author: Jacob Donley
% University of Wollongong
% Email: jrd089@uowmail.edu.au
% Copyright: Jacob Donley 2017
% Date: 26 April 2017 
% Revision: 0.1
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    SYS = Current_Systems.loadCurrentSRsystem;
end

%% Find correct setups
ArrType = SYS.system_info.CurrentSpeakerArrayType;
% isCircArray = contains(ArrType, 'circ');
isLineArray = contains(ArrType, 'line');
I = cellfun(@(x) contains(x,ArrType) ,{SYS.Main_Setup.Speaker_Array_Type},'un',0);
S = SYS.Main_Setup([I{:}]);

if isempty(S), return; end

%% Load current RIRs
[DB,~,RIR_FilePath] = Room_Acoustics.loadRIRDatabaseFromSetup( S(1), SYS.Room_Setup, SYS.system_info.Drive );

% Get path strings
[fpath,fname,fext]=fileparts(RIR_FilePath);
if ~(isfield(DB,'isRecordedRIR') && ~DB.isRecordedRIR)
    
    RIRfiles = Tools.getAllFiles(fpath);
    DBs = cellfun(@load , RIRfiles, 'un', 0);
    
    hasIsRecField = cellfun(@(d) isfield(d,'isRecordedRIR'), DBs,'un',0);
    hasIsRecField = [hasIsRecField{:}];
    DBsWithIsRecFld = [DBs{hasIsRecField}];
    SimRIRs = hasIsRecField;
    SimRIRs(hasIsRecField) = ~[DBsWithIsRecFld.isRecordedRIR];
    
    if any(SimRIRs)
        potentialSimFile = RIRfiles(SimRIRs); % Hopefully there is just one of these
        fileinfo1 = dir(potentialSimFile{1});
        fileinfo2 = dir(RIR_FilePath);
        
        oneMin = 60/(60*60*24);
        if ~(daysdif(fileinfo2.date, fileinfo1.date) > oneMin) % if RIR_FilePath is NOT more than a minute newer than potentialSimFile{1}
            DB = DBs{SimRIRs};
        end
        
    end
end
RIRs = DB.RIRs;


%% Get Saved Transfer Functions
filter_location = Tools.getAllFiles([SYS.system_info.Drive SYS.system_info.FilterData_dir]);
filter_location(~contains( filter_location, 'Transfer_Functions'))=[];
filter_location = sort(filter_location);
if isempty(filter_location)
    Tools.simpleWarning('No measured acoustic transfer functions were found, using simulations instead.');
    return;
end
filts = load( filter_location{end} ); % 1st element should be the newest (most recent) set of filters
TF = filts.TF;
fs = filts.fs;

%%
rir_sim = RIRs.Bright_RIRs;

% if isLineArray
%     TFAlign = Speaker_Setup.Calibration.linTFalign(SYS);
% end

rir_rec=[];
for r=1:size(TF,3)
    tftmp = TF(:,:,r);
%     if isLineArray
%         tftmp = Tools.fconv( tftmp, TFAlign.');
%     end
    for s = 1:size(TF,2)
        tmp = decimate(tftmp(:,s), SYS.system_info.fs/SYS.signal_info.Fs);
        rir_rec(r,:,s) = tmp(1:size(rir_sim,2));
    end
end

rir_rec = repmat(rir_rec,size(rir_sim,1)/size(rir_rec,1),1,1);

%% Rename and overwrite RIR files that exist
newRIRs = RIRs;
newRIRs.Quiet_RIRs = rir_rec;
newRIRs.Bright_RIRs = flip(rir_rec,3);

% Re-save simulated RIRs
isRecordedRIR = false;
save([fpath filesep 'Simulated_' fname fext],'RIRs','isRecordedRIR');

% Save new recorded RIRs
RIRs = newRIRs; isRecordedRIR = true;
save(RIR_FilePath,'RIRs','isRecordedRIR');
save([fpath filesep 'Recorded_' fname fext],'RIRs','isRecordedRIR');


end
