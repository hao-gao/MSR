clc;
%clear;
%close all;
tic;

%%
writerObj = VideoWriter('example_Monotone_Reproduction.avi');
open(writerObj);
phase = pi/16:pi/16:2*pi;
mov = [];


%%
fprintf('\n====== Rendering ======\n\n');
fprintf('\tCompletion: ');n=0;
for p = 1:length(phase)
    
    quiet  = Orthogonal_Basis_Expansion.spatial_zone(2000, 0, 0.30, 'quiet');
    quiet.res  = 300;
    quiet  =  quiet.setDesiredSoundfield(true, 'suppress_output');
    bright = Orthogonal_Basis_Expansion.spatial_zone(2000, -phase(p), 0.30, 'pw', 1.0, 15);
    bright.res = 300;
    bright = bright.setDesiredSoundfield(true, 'suppress_output');
    
    %%
    soundfield = Orthogonal_Basis_Expansion.multizone_soundfield_OBE;
    soundfield = soundfield.addSpatialZone(quiet,  0.60, 0);
    soundfield = soundfield.addSpatialZone(bright, 0.60, 180);
    
    %%
    soundfield = soundfield.createSoundfield('DEBUG', 1.0);
    
    %%
    setup = Speaker_Setup.loudspeaker_setup;
    setup = setup.addMultizone_Soundfield(soundfield);
    setup.Loudspeaker_Count = 16;
    setup.Speaker_Arc_Angle = 90;
    setup.Angle_FirstSpeaker = 150;
    setup = setup.reproduceSoundfield('', 1.5);
    
    %%
    h=figure(1);
    setup.plotSoundfield();
    %set(gcf,'units','normalized','outerposition',[+1.5 0 0.5 1]); %Maximise current plot window
    set(gcf,'Renderer','zbuffer');
    mov = [mov; getframe(h)];
    
    %%
    tElapsed = toc;
    ratio = p / length(phase);
    tRem = (1-ratio) / ratio * tElapsed;
    tTot = tElapsed + tRem;
    fprintf(repmat('\b',1,n));
    n=fprintf('%.2f%% \n\tRemaining: %d mins %.0f secs \n\tTotal: %d mins %.0f secs\n', ratio * 100, floor(tRem/60), rem(tRem,60), floor(tTot/60), rem(tTot,60));
    
end

%%
writeVideo(writerObj, repmat(mov,20,1) );
close(writerObj);



%%
tEnd = toc;
fprintf('\nExecution time: %dmin(s) %fsec(s)\n', floor(tEnd/60), rem(tEnd,60)); %Time taken to execute this script
