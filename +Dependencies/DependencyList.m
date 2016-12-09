function p = DependencyList
%DEPENDENCYLIST Additions to the search path defaults.
%   DEPENDENCYLIST returns a string that can be used as input to ADDPATH
%   in order to set the path.


p = [...
%%% BEGIN ENTRIES %%%
     genpath('M:\amtoolbox'), ...
     'M:\arrow;', ...
     'M:\colour_printf;', ...
     genpath('M:\DSP_Tools'), ...
     'M:\export_fig;', ...
     'M:\fastISM;', ...
     'M:\GenerateFunctionMFile;', ...
     'M:\gridLegend;', ...
     'M:\ISO226;', ...
     'M:\MCRoomSim;', ...
     'M:\mmstream2;', ...
     'M:\mmx;', ...
     'M:\mtimesx;', ...
     'M:\newFunction;', ...
     'M:\Parfor_Progress;', ...
     'M:\PESQ;', ...
     'M:\PhaseUnwrapping2D;', ...
     'M:\playrec-master;', ...
     'M:\python;', ...
     'M:\RIR_Generator;', ...
     'M:\roomsim;', ...
     'M:\scientific_colormaps;', ...
     'M:\Speech_Recognition_API;', ...
     genpath('M:\SpeechSP_Tools'), ...
     'M:\sqdistance;', ...
     'M:\SweptSineAnalysis;', ...
     'M:\tightfig;', ...
     'M:\tightPlots;', ...
     'M:\voicebox;', ...
%%% END ENTRIES %%%
     ...
];
