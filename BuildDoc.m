%% Build documentation

wrkdir = 'M:\MSR\';
docdir = 'doc';
mainFile = '+Current_Systems\Evaluate_Current_System.m';
Tools.buildDocumentation( wrkdir, docdir, mainFile, false, true );

mainFile = '+Current_Systems\loadCurrentSRsystem.m';
Tools.buildDocumentation( wrkdir, docdir, mainFile,  true, true );
