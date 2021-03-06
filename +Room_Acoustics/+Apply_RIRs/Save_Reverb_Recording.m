function Save_Reverb_Recording(Original_, Rec_Sigs_B, Rec_Sigs_Q, Fs, RecordingsPath, Output_file_path_ext, FileName, Output_file_ext)
%SAVE_REVERB_STOI_RESULT Summary of this function goes here
% 
% Syntax:	SAVE_REVERB_RECORDING(INPUTARGS) Explain usage here
% 
% Inputs: 
% 	input1 - Description
% 	input2 - Description
% 	input3 - Description
% 
% Outputs: 
% 	output1 - Description
% 	output2 - Description
% 
% Example: 
% 	Line 1 of example
% 	Line 2 of example
% 	Line 3 of example
% 
% See also: List related files here

% Author: Jacob Donley
% University of Wollongong
% Email: jrd089@uowmail.edu.au
% Copyright: Jacob Donley 2015
% Date: 16 August 2015 
% Revision: 0.2 (9 February 2016)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sc = '_';

%% Calculate Results
if ~isempty(Original_)
    Original_(length(Original_):size(Rec_Sigs_B,2))=0; % Resize the original signal because the reverberant signal will be longer
    if (length(Original_) ~= length(Rec_Sigs_B)) || (length(Original_) ~= length(Rec_Sigs_Q))
        error('Size of the original signal does not match the reproduced signal!');
    end
end

%%
if ~exist([RecordingsPath Output_file_path_ext],'dir'); mkdir([RecordingsPath Output_file_path_ext]); end

save([RecordingsPath Output_file_path_ext FileName sc 'Bright.mat'], 'Rec_Sigs_B');
save([RecordingsPath Output_file_path_ext FileName sc 'Quiet.mat'], 'Rec_Sigs_Q');

if ~isempty(Original_)
    audiowrite( [RecordingsPath Output_file_path_ext FileName sc 'Original' Output_file_ext], Original_, Fs);
end


end
