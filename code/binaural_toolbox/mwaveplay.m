function null = mwaveplay(wave, amplitudescaling, channelflag, infoflag)
% function null = 
% mwaveplay(wave, amplitudescaling, channelflag, infoflag)
%
%------------------------------------------------------------------
% Plays a 'wave' signal (interface to the MATLAB function 'sound')
%------------------------------------------------------------------
%
% Input parameters:
%    wave             = input wave structure
%    amplitudescaling = amplitudenormalization factor (see below)
%                     = 32657 for most situations
%                     = -1 for autoscaling (ala 'soundsc');
%    channelflag      = 'stereo' play both channels 
%                       'swap'   play both channels but with 
%                                  left/right swapped
%                       'random' use either of stereo or swap,
%                                  chosen at random
%                       'left'   play left channel only
%                       'right'  play right channel only
%    infoflag         = 1 report running information
%                     = 0 dont report anything
%
% Output parameters:
%   none
%
%
% The MATLAB function 'sound' uses a amplitude range of 
% +1...-1 (although its 0.99 to -0.99 seems to work better).
% The 'amplitudescaling' parameter here sets the range of the 'wave'
% signal to fit in this range. If a value of -1 is specified
% then the signal is scaled to a maximum of 0.99. If a value
% of anything else is used then the signal is divided by that value.
%
%
% Examples:
% to play both channels of a previously-made signal wave1 
% (see mcreatetone) at the maximum amplitude without clipping, type:
% >> mwaveplay(wave1, -1, 'stereo', 1);
%
% to play the left channel only of a previously-made signal wave1 
% (see mcreatetone) at the maximum amplitude without clipping, type:
% >> mwaveplay(wave1, -1, 'left', 1);
%
% to play both channels (but with left and right swapped) of a 
% previously-made signal wave1 (see mcreatetone) at the 
% maximum amplitude without clipping, type:
% >> mwaveplay(wave1, -1, 'swap', 1);
%
% to play both channels of a previously-made signal wave1 
% (see mcreatetone), but so that a sample value of 32765 corresponds
% to the maximum amplitude of +0.99 allowed in 'sound', type:
% >> mwaveplay(wave1, 32765, 'stereo', 1);
%
%
% version 1.0 (Jan 20th 2001)
% MAA Winter 2001 
%----------------------------------------------------------------

% ******************************************************************
% This MATLAB software was developed by Michael A Akeroyd for 
% supporting research at the University of Connecticut
% and the University of Sussex.  It is made available
% in the hope that it may prove useful. 
% 
% Any for-profit use or redistribution is prohibited. No warranty
% is expressed or implied. All rights reserved.
% 
%    Contact address:
%      Dr Michael A Akeroyd,
%      Laboratory of Experimental Psychology, 
%      University of Sussex, 
%      Falmer, 
%      Brighton, BN1 9QG, 
%      United Kingdom.
%    email:   maa@biols.susx.ac.uk 
%    webpage: http://www.biols.susx.ac.uk/Home/Michael_Akeroyd/
%  
% ******************************************************************


   
programname = mfilename;
waveformname = inputname(1);
   
% extract channels from input waveform
samplefreq = wave.samplefreq;

if (infoflag >= 1)
   fprintf('\n');
   fprintf('input waveform = %s\n', inputname(1));
   fprintf('duration = %d samples = %.1f msecs\n', wave.duration_samples, wave.duration_ms);
end;


% put 100-ms of silence on end (so that my portable computerdoesn't
% go 'click' at the end of the sound)
silenceduration_ms = 100;
silence = zeros((silenceduration_ms/1000)*samplefreq, 1);
leftwaveform = [wave.leftwaveform; silence];
rightwaveform = [wave.rightwaveform; silence];


% create a stereo waveform
switch channelflag
case 'stereo'
   if (infoflag >= 1)
      fprintf('''stereo'': leftchannel in leftear and rightchannel in rightear\n');
   end;
   stereowaveform = [leftwaveform, rightwaveform];
   
case 'swap'
   if (infoflag >= 1)
      fprintf('''swap'': leftchannel in rightear and rightchannel in leftear\n');
   end;
   stereowaveform = [rightwaveform, leftwaveform];
   
case 'left'
   if (infoflag >= 1)
      fprintf('''left'': leftchannel only\n');
   end;
   silence = zeros(length(rightwaveform), 1);   
   stereowaveform = [leftwaveform, silence];
   
case 'right'
   if (infoflag >= 1)
      fprintf('''left'': rightchannel only\n');
   end;
   silence = zeros(length(leftwaveform), 1);   
   stereowaveform = [silence, rightwaveform];
   
case 'random'
   randomvalue = rand(1);
   if (randomvalue >=0.5)
      if (infoflag >= 1)
         fprintf('''random'': normal: leftchannel in leftear and rightchannel in rightear\n');
      end;
      stereowaveform = [leftwaveform, rightwaveform];
   else
      if (infoflag >= 1)
         fprintf('''random'': swapped: leftchannel in rightear and rightchannel in leftear\n');
      end;
      stereowaveform = [rightwaveform, leftwaveform];
   end;
   
otherwise
   fprintf('\n'); 
   fprintf('%s: error! invalid channelflag ''%s''\n', mfilename, channelflag);
   fprintf('\n'); 
   return;
end;


% amplitude normalization
if (amplitudescaling == -1)
   largestamplitude=max(max(abs(stereowaveform)));
   % add a factor of 1% so the actual range is 0.99 to -0.99
   largestamplitude = largestamplitude * 1.01;
   stereowaveform = stereowaveform/largestamplitude;
   if (infoflag >= 1)
      fprintf('auto-scaling amplitude to +1...-1\n');
   end;
else   
   stereowaveform = stereowaveform/amplitudescaling;
   if (infoflag >= 1)
      fprintf('scaling amplitude using factor of %.1f\n', amplitudescaling);
      fprintf('new maximum = %.3f \n', max(max(stereowaveform)));
      fprintf('new minimum = %.3f \n', min(min(stereowaveform)));
  end;
end;


% play
if (infoflag >= 1)
   fprintf('playing using ''sound'' ...\n');
   fprintf('\n');
end;
sound(stereowaveform, samplefreq);

  
% the end!
%-------------------------------------------------
