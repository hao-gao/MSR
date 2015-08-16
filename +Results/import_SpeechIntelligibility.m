function [Audio_filename,SI_WC_Bright,SI_WC_Quiet] = import_SpeechIntelligibility(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [AUDIO_FILENAME,SI_WC_BRIGHT,SI_WC_QUIET] = IMPORTFILE(FILENAME) Reads
%   data from text file FILENAME for the default selection.
%
%   [AUDIO_FILENAME,SI_WC_BRIGHT,SI_WC_QUIET] = IMPORTFILE(FILENAME,
%   STARTROW, ENDROW) Reads data from rows STARTROW through ENDROW of text
%   file FILENAME.
%
% Example:
%   [Audio_filename,SI_WC_Bright,SI_WC_Quiet] = importfile('SI_Results_PrivacyWeighted_v5.csv',1, 180);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2015/05/15 17:39:00

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
%	column7: double (%f)
%   column9: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%*s%*s%*s%*s%f%*s%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
Audio_filename = dataArray{:, 1};
SI_WC_Bright = dataArray{:, 2};
SI_WC_Quiet = dataArray{:, 3};

