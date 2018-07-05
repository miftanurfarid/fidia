function [output_correlogram] = mcorrelogram(lowfreq, highfreq, filterdensity, mindelay, maxdelay, transduction, binauralswitch, wave, infoflag)
% function [output_correlogram] = ...
% mcorrelogram(lowfreq, highfreq, filterdensity, mindelay, maxdelay, ...
%              transduction, binauralswitch, wave, infoflag)
% 
%----------------------------------------------------------------
% Generates a binaural correlogram.
% No frequency or delay weightings are applied.
%-----------------------------------------------------------------
%
% Input parameters:
%   lowfreq       =  lower frequency of gammatone filterbank (Hz)
%   highfreq      =  upper frequency of gammatone filterbank (Hz)
%                     (see below)
%   filterdensity =  density of filterbank (filters per ERB number)
%                     (see below)
%   mindelay      =  leftmost (most negative) delay of delay axis (usecs)
%   maxdelay      =  rightmost (most positive) delay of delay axis (usecs)
%   transduction  =  type of neural transduction applied to the 
%                     output of the gammatone filters. Can be one of:
%                     'linear'       = dont do anything
%                     'hw'           = linear + halfwave rectification
%                     'log'          = halfwave rectification + log compression
%                     'power'        = halfwave rectification + power-law (^0.4) compression of waveform
%                     'envelope'     = halfwave rectification + power-law (^0.2 then ^2) compression of envelope
%                     'v=3'          = halfwave rectification + power-law (^3) expansion of waveform
%                     'meddishigh'   = Meddis et al (1990) haircell, high-spontaneous rate
%                     'meddismedium' = Meddis et al (1990) haircell, medium-spontaneous rate
%  binauralswitch = what kind of binaural processing to do:
%                     'cp' (crossproduct):     cross-multiply left x right without dividing by power
%                     'cc' (crosscorrelation): cross-multiply left x right *with* division by power
%                     's' (subtraction)  :     cross-subtract left - right (without dividing by power)
%  wave            =  input 'wave' signal
%  infoflag        = 2: plot figures and report some information while running
%                  = 1: report some information while running only
%                  = 0  dont report anything
%
% Output parameters
%   output_correlogram = 'correlogram' structure, as defined 
%                        in mccgramcreate.m
%   It can be 3d-displayed in Windows 95 by ccdisplay.exe via 
%   mcallccdisplay.m or (in MATLAB) can be plotted using 
%   mccgramplot4panel.m
%
% Figures:
%  figure 1 plots the left and right waveforms.
%  figure 2 plots the left and right excitation patterns before 
%            and after neural trasnduction.
%  figure 3 plots the correlogram in a variety of forms
%
%
% The correlogram algorithm is:
%    Filter left/right waveforms using matched gammatone filterbanks.
%    Apply neural transduction.
%    Binaural process: cross-multiply (or cross-subtract) the 
%      left filter outputs by the right filter outputs,
%      as a function of freq and internal time delay.
%    Average that across the duration of the sound 
%      (=rectangular integration function)
%    Plot the correlogram if required
%
% 
% The first filter is placed at lowfreq.  The second is placed
% at 1/filterdensity above that, the third at 2/filterdensity,
% and so on, as far as the first filter *above* highfreq,
% 
% If the filterdensity has a value of 0 then only *one* filter is 
% made, whose center frequency is equal to lowfreq.
%
% The various compressions are described in mmonuaraltransduction.m
%
%
% Examples:
% to create the correlogram of a previously-made signal wave1
% (see mcreatetone.m), using a filterbank from 47.4 to 1694 Hz at
% a spacing of 1 filter per ERB, using a delay axis from -3500 to
% 3500 us, using 'envelope' compression, and using cross-products,
% type:
% >> cc1 = mcorrelogram(47.4, 1690, 1, -3500, 3500, 'envelope', 'cp', wave1, 2);
%
% to use half-wave rectification instead of envelope compression,
% type:
% >> cc1 = mcorrelogram(47.4, 1690, 1, -3500, 3500, 'hw', 'cp', wave1, 2);
%
% to use subtraction instead of cross-products, type:
% >> cc1 = mcorrelogram(47.4, 1690, 1, -3500, 3500, 'envelope', 's', wave1, 2);
%
% to use a single-channel at 500-Hz instead of the full filterbank,
% type:
% >> cc1 = mcorrelogram(500, 1690, 0, -3500, 3500, 'hw', 'cp', wave1, 2);
%
%
%
% Thanks to Klaus Hartung for speeding the code up
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


if (infoflag >= 1)
  fprintf('\n');
  fprintf('This is %s ...\n', mfilename);
end;


% get variable names and sampling rate
programname = mfilename;
waveformname = inputname(7);
samplerate = wave.samplefreq;


% clear figures
% for n=1:5
%    close;
% end;

% measure max/min values of waveforms
maxoverall = wave.overallmax; 

% make a true time axis
timeaxis_samples = 1:1:length(wave.leftwaveform);
timeaxis_ms = timeaxis_samples/samplerate*1000;
onesample = 1000000/samplerate; % us
if (infoflag >= 1)
  fprintf('waveform length = %d samples = %.1f ms\n', length(wave.leftwaveform), length(wave.leftwaveform)/samplerate*1000);
  fprintf('sampling rate   = %d Hz\n', samplerate);
  fprintf('one sample      = %.1f us\n', onesample);
end;



%**************************************************
% filter/transduction code
%**************************************************

% gammatone filter each waveform: outputs are(in order)
% multichanneloutputs, filter freqs, number of filters, 
% actual freq of lowest filter, actual freq of highest filter,
% q factor, bwmin factor
%
% The actual low filter is the requested value as this is 
% the startpoint of the filter center-freq calculations. 
% The actual high filter is *not* the requested high freq as 
% its really equal to the first filter above the requested value 
% (and so is determined by the density of filters per ERB). 
% The result is that the requested high fequency is 
% included in the filterbank range,
%
% If density = 0 then 1 filter is made whose freq = lowfreq
%
if (infoflag >= 1)
   fprintf('\n');
   fprintf('applying filterbank to left waveform ...\n');
end;
[multichanneloutput_l, fbankcf, nfilters, truelowfreq, truehighfreq, qfactor, bwminfactor] = mgammatonefilterbank(lowfreq, highfreq, filterdensity, wave.leftwaveform, samplerate, infoflag);

if (infoflag >= 1)
   fprintf('applying same filterbank to right waveform ...\n');
end;
[multichanneloutput_r, fbankcf, nfilters, truelowfreq, truehighfreq, qfactor, bwminfactor] = mgammatonefilterbank(lowfreq, highfreq, filterdensity, wave.rightwaveform, samplerate, 0);

npoints = length(multichanneloutput_l);

% measure various levels *before* transduction: 
% (these get plotted later)
beforetransductionrms_l = (sqrt(mean(power(multichanneloutput_l, 2)')))';
beforetransductionmax_l = (max(multichanneloutput_l'))';
beforetransductionrms_r = (sqrt(mean(power(multichanneloutput_r, 2)')))';
beforetransductionmax_r = (max(multichanneloutput_r'))';


% apply the neural transduction
if infoflag >= 1
   fprintf('\n');
   fprintf('applying transduction to the multichannel filter outputs (left channel) ... \n');
end;
[multichanneloutput_l, powervector_l, maxvector_l] = mmonauraltransduction(multichanneloutput_l, transduction, samplerate, infoflag);
if infoflag >= 1
   fprintf('applying same transduction to the multichannel filter outputs (right channel) ... \n');
end;
[multichanneloutput_r, powervector_r, maxvector_r] = mmonauraltransduction(multichanneloutput_r, transduction, samplerate, 0);

% measure the levels *after* transduction
% (these also get plotted later)
aftertransductionrms_l = powervector_l;
aftertransductionmax_l = maxvector_l;
aftertransductionrms_r = powervector_r;
aftertransductionmax_r = maxvector_r';


  
   
%*****************************************************
% binaural code
%*****************************************************
if infoflag >= 1
   fprintf('\n');
   fprintf('binaural processing ... \n');
end;

% quantize min/max delay to an integer number of samples
maxdelay = round(maxdelay/onesample) * onesample;
mindelay = round(mindelay/onesample) * onesample;
maxdelay_samples = maxdelay/onesample;
mindelay_samples = mindelay/onesample;

% get width of delay axis in samples; quantized in units of 
% 'delaystep' samples
delaystep = 1;  % samples (1= maximum resolution)
delayindex_samples = mindelay_samples:delaystep:maxdelay_samples;
ndelays = length(delayindex_samples);
delayindex_usecs = delayindex_samples * onesample;


% define 'correlogram' structure
correlogram = mccgramstructure(programname, transduction, samplerate, lowfreq, highfreq, filterdensity, nfilters, qfactor, bwminfactor, mindelay, maxdelay, ndelays, 'binauralcorrelogram');
correlogram.freqaxishz =  fbankcf;
[filter_q, filter_bwmin] = mstandarderbparameters;
correlogram.freqaxiserb =  mhztoerb(fbankcf, filter_q, filter_bwmin, 0);
correlogram.delayaxis = delayindex_usecs;
correlogram.powerleft =  powervector_l;
correlogram.powerright =  powervector_r;
correlogram.hcleft = multichanneloutput_l;
correlogram.hcright = multichanneloutput_r;

%
% main loop !!!----------------------------------------------------
%

if (infoflag >= 1)
   switch binauralswitch
   case 'cp' 
      fprintf('''%s'' = measuring left x right crossproducts in each frequency channel ... \n', binauralswitch);
      fprintf('(not normalized by power in each channel)\n');
   case 'cc' 
      fprintf('''%s'' =measuring left x right crosscorrelationss in each frequency channel ... \n', binauralswitch);
      fprintf('(normalized by power in each channel)\n');
   case 's'
      fprintf('''%s'' =measuring left x right subtractions in each frequency channel ... \n', binauralswitch);
   otherwise
      fprintf('unknown switch for binaural processing ''%s'': can be one of ''cp'', ''cc'', ''ss''\n', binauralswitch);
      return;
   end;
end;

if (infoflag >= 1)
   fprintf('(final values = unweighted averaged across full stimulus duration)\n');
   fprintf('number of delays = %.0f \n', ndelays);
   fprintf('limits           = %.0f to %.0f microsecs\n', mindelay, maxdelay);
   fprintf('doing delay #');
end;


correlogram.data = zeros(nfilters, ndelays);   

npoints = length(multichanneloutput_l);
delayedoutput_l = zeros(size(multichanneloutput_l));
delayedoutput_r = zeros(size(multichanneloutput_r));

% for the power normalization in 'cc' option ...
denominator = (correlogram.powerleft .* correlogram.powerright);
      
% loop through each delay ...
for delay=1:ndelays;
   
   if (infoflag >= 1)
      fprintf(' %.0f', delay);
      if mod(delay,20) ==0
         fprintf('\n');
      end;
   end;
      
   delay_samples = delayindex_samples(delay);
        
   % go through each filter and shift left or right
   % filter output depending on sign of delay
   % (does all filters in one go so faster than a 'for' loop)
   if delay_samples < 0
      delayedoutput_l(:,1:abs(delay_samples)) = 0;
      delayedoutput_l(:,abs(delay_samples)+1:npoints) = multichanneloutput_l(:,1:(npoints-abs(delay_samples)));
      delayedoutput_r = multichanneloutput_r;
   elseif delay_samples == 0
      delayedoutput_l = multichanneloutput_l;
      delayedoutput_r = multichanneloutput_r;
   else
      delayedoutput_r(:,1:abs(delay_samples)) = 0;
      delayedoutput_r(:,abs(delay_samples)+1:npoints) = multichanneloutput_r(:,1:(npoints-abs(delay_samples)));
      delayedoutput_l = multichanneloutput_l;
   end;
      
   % do the actual binaural comparison!
   switch binauralswitch
   case 'cp' 
      % cross multiply, then average across the whole duration 
      % of the sound
      correlogram.data(:, delay) = mean(delayedoutput_l .* delayedoutput_r, 2);
      correlogram.title = 'first-level correlogram (cross-product)';
      
   case 'cc' 
      % cross multiply, then average across the whole duration 
      % of the sound, then normalise by the average power in 
      % each channel
      correlogram.data(:, delay) = mean(delayedoutput_l .* delayedoutput_r, 2);
      correlogram.data(:, delay) = correlogram.data(:, delay) ./ denominator;
      correlogram.data(:, delay) = sqrt(correlogram.data(:, delay));
      correlogram.title = 'first-level correlogram (cross-correlation)';

   case 's'
      % cross subtract and then make positive ('abs') and 
      % then take the average across the whole duration
      correlogram.data(:, delay) = mean(abs(delayedoutput_l - delayedoutput_r), 2);
      correlogram.title = 'first-level correlogram (subtraction)';
      
   end;
   
   
end;  % next delay

if (infoflag >= 1)
   fprintf('\n\n');
end;



%*****************************************************
% plotting code
%*****************************************************

screenwidth = 1024; 
screenheight = 768; 
aspectratio = screenwidth/screenheight; % used so a width=height figure actually looks square
figurewidth = 600; % pixels


% define the size  of the upcoming four-panel plots
% MATLAB's 'position' is a 4-member array: [x y width height]:   
% (x, y) is of bottom lefthand corner of picture, relative to bottom left-hand corner of screen, in pixels I think
% (width, height) is of figure, in pixels I think
position_figure1_xy = [100 85];
position_figure2_xy = [120 65];
position_figure3_xy = [140 45];
position_figure1_wh = [figurewidth*aspectratio, figurewidth];
position_figure2_wh = [figurewidth*aspectratio, figurewidth];
position_figure3_wh = [figurewidth*aspectratio, figurewidth];


% plot waveforms in figure 1
if infoflag >= 2
   fprintf('plotting waveforms in figure %d \n', gcf);
   mwaveplot_2(wave, 'stereo', -1, -1);
   set(gcf, 'Name', [programname, ' : input = ', waveformname, ' ... waveforms']);
   set(gcf, 'Position', [position_figure1_xy position_figure1_wh]);
  end;


% if infoflag >= 2
%    plotstart = mhztoerb(truelowfreq, filter_q, filter_bwmin, 0);
%    plotend = mhztoerb(truehighfreq, filter_q, filter_bwmin, 0);
%    if nfilters == 1
%       % special code for single filters
%       plotstart = truelowfreq - 100;
%       plotend = truelowfreq + 100;;
%       end;
%    % plot the mean filter outputs in figure 2;
%    figure(5);
%    fprintf('plotting monaural excitation patterns in figure %d \n', gcf);
%    set(gcf, 'Name', [programname, ' : input = ', waveformname, ' ... monaural excitation patterns']);
%    set(gcf, 'Position', [position_figure2_xy position_figure2_wh]);
%    subplot(2,2,1);
%    hold on;
%    if nfilters > 1
%       plot(correlogram.freqaxiserb, 20*log10(beforetransductionrms_l), 'b');
%       plot(correlogram.freqaxiserb, 20*log10(beforetransductionrms_r), 'r');
%       maxislabels_freq('xtick', 'xticklabel');
%    else
%       plot(truelowfreq, 20*log10(beforetransductionrms_l), 'b*', 'markersize', 10);
%       plot(truelowfreq, 20*log10(beforetransductionrms_r), 'r*', 'markersize', 10);
%    end;
%    hold off;
%    axesrange=axis;
%    axesrange(1) = plotstart;
%    axesrange(2) = plotend;
%    axesrange(3) = 0;
%    axesrange(4) = 90;
%    axis(axesrange);
%    grid on;
%    xlabel('Frequency (Hz)');
%    ylabel('Mean filter output (db)');
%    title('RMS filter output before transduction (dB)');
% 
%    subplot(2,2,3);
%    hold on;
%    if nfilters > 1
%       plot(correlogram.freqaxiserb, 20*log10(beforetransductionmax_l), 'b');
%       plot(correlogram.freqaxiserb, 20*log10(beforetransductionmax_r), 'r');
%       maxislabels_freq('xtick', 'xticklabel');
%    else
%       plot(truelowfreq, 20*log10(beforetransductionmax_l), 'b*', 'markersize', 10);
%       plot(truelowfreq, 20*log10(beforetransductionmax_r), 'r*', 'markersize', 10);
%    end;
%    hold off;
%    axesrange=axis;
%    axesrange(1) = plotstart;
%    axesrange(2) = plotend;
%    axesrange(3) = 0;
%    axesrange(4) = 90;
%    axis(axesrange);
%    grid on;
%    xlabel('Frequency (Hz)');
%    ylabel('Max filter output (db)');
%    title('Max filter output before transduction (dB)');
% 
%    subplot(2,2,2);
%    hold on;
%    if nfilters > 1
%       plot(correlogram.freqaxiserb, aftertransductionrms_l, 'b');
%       plot(correlogram.freqaxiserb, aftertransductionrms_r, 'r');
%       maxislabels_freq('xtick', 'xticklabel');
%    else
%       plot(truelowfreq, aftertransductionrms_l, 'b*', 'markersize', 10);
%       plot(truelowfreq, aftertransductionrms_r, 'r*', 'markersize', 10);
%    end;
%    hold off;
%    axesrange=axis;
%    axesrange(1) = plotstart;
%    axesrange(2) = plotend;
%    axesrange(3) = 0;
%    axis(axesrange);
%    grid on;
%    xlabel('Frequency (Hz)');
%    ylabel('Mean excitation (linear)');
%    title('RMS filter output after transduction (linear)');
% 
%    subplot(2,2,4);
%    hold on;
%    if nfilters > 1
%       plot(correlogram.freqaxiserb, aftertransductionmax_l, 'b');
%       plot(correlogram.freqaxiserb, aftertransductionmax_r, 'r');
%       maxislabels_freq('xtick', 'xticklabel');
%    else
%       plot(truelowfreq, aftertransductionmax_l, 'b*', 'markersize', 10);
%       plot(truelowfreq, aftertransductionmax_r, 'r*', 'markersize', 10);
%    end;
%    hold off;
%    axesrange=axis;
%    axesrange(1) = plotstart;
%    axesrange(2) = plotend;
%    axesrange(3) = 0;
%    axis(axesrange);
%    grid on;
%    xlabel('Frequency (Hz)');
%    ylabel('Max excitation (linear)');
%    title('Max filter output after transduction (linear)');
%    
% end;



% plot the correlogram in a variety of forms in figure 3
if (infoflag >= 2)
   figure(4);
   mccgramplot4panel(correlogram)
   set(gcf, 'Name', [programname, ' : input = ', waveformname, ' ... correlograms']);
end;



%*****************************************************

% return values
output_correlogram = correlogram;
output_correlogram.title = 'first-level correlogram';

if infoflag >= 1
   fprintf('storing correlogram of size %d x %d to workspace ... \n', size(output_correlogram.data, 1), size(output_correlogram.data, 2));
end;


if infoflag >= 1,
   fprintf('\n');
end;

% plot ITD per kanal frekuensi

[a,b]=max(correlogram.data'); %mencari max peak sebagai ITD
c=b-(((length(correlogram.data(1,:))-1)/2)+1);
d=c*onesample;
masker.itd_m=d;
figure(6);
plot(d)
xlabel('Frequency Channel')
ylabel('ITD ( \musecs )')
title('Interaural Time Difference')


% the end!
%----------------------------------------------------------