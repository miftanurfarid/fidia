%______________________________________________________________________________________________________________________
% 
% @file         myspectrogram.m
% @author       Kamil Wojcicki
% @date         April 2007
% @revision     002
% @brief        Wrapper for Matlab's spectrogram function
%______________________________________________________________________________________________________________________
%
% @inputs       s       - speech signal
%               fs      - sampling frequency
%               nfft    - fft analysis length
%               T       - vector of frame width and frame shift (ms), i.e. [Tw, Ts]
%               w       - analysis window handle
%               Slim    - vector of spectrogram limits (dB), i.e. [Smin Smax]
%               alpha   - fir pre-emphasis filter coefficients
%               cmap    - color map 
%               cbar    - color bar (boolean)
%
% @output       handle  - plot handle
%______________________________________________________________________________________________________________________
%
% @usage        [handle] = myspectrogram(s, fs, nfft, T, w, Slim, alpha, cmap, cbar);
%               [handle] = myspectrogram(s, 8000, 1024, [18,1], @hamming, [-45 -2], false, 'default', false);
%               [handle] = myspectrogram(s, 8000, 1024, [18,1], @hamming, [-45 -2], [1 -0.97], 'default', true);
%
%
% edited April 2018 : for warungpintar
%______________________________________________________________________________________________________________________

function [S, F, T] = myspectrogram(s, fs, nfft, T, w, Slim, alpha, cmap, cbar)


    %__________________________________________________________________________________________________________________
    % VALIDATE INPUTS 
    switch nargin
    case 1, cbar=false; cmap='default'; alpha=false; Slim=[-45,-2]; w=@hamming; T=[20,10]; nfft=2048; fs=16000;
    case 2, cbar=false; cmap='default'; alpha=false; Slim=[-45,-2]; w=@hamming; T=[20,10]; nfft=2048; 
    case 3, cbar=false; cmap='default'; alpha=false; Slim=[-45,-2]; w=@hamming; T=[20,10]; 
    case 4, cbar=false; cmap='default'; alpha=false; Slim=[-45,-2]; w=@hamming; 
    case 5, cbar=false; cmap='default'; alpha=false; Slim=[-45,-2]; 
    case 6, cbar=false; cmap='default'; alpha=false;
    case 7, cbar=false; cmap='default'; 
    case 8, cbar=false; 
    case 9
    otherwise, error('Invalid number of input arguments.');
    end


    %__________________________________________________________________________________________________________________
    % VARIABLES
    Tw = T(1);
    Ts = T(2);
    Nw = round(fs * Tw * 0.001);
    Ns = round(fs * Ts * 0.001);
    N  = length(s);
    Smin = Slim(1);
    Smax = Slim(2);
    if(ischar(w)), w = str2func(w); end


    %__________________________________________________________________________________________________________________
    % PRE PROCESS SPEECH
    if(islogical(alpha) && alpha), s = filter([1 -0.97],1,s);
    elseif(~islogical(alpha)) s = filter(alpha,1,s); end

       
    %__________________________________________________________________________________________________________________
    % GET SPECTROGRAM DATA 
    % if isOctave == 1
        % [S,F,T] = specgram(s,2^nextpow2(Nw),fs,Nw,Ns); % octave compatibility
    % else
        [S,F,T] = spectrogram(s,w(Nw).',Nw-Ns,nfft,fs);
        % [S,F,T] = specgram(s,nfft,fs,w(Nw).',Nw-Ns); % depreciated 
    % end
    
    %__________________________________________________________________________________________________________________
    % SET DYNAMIC RANGE 
    S = abs(S);
    S(S==0) = eps;
    % fprintf('awal max %.2f min %.2f\n',max(max(S)), min(min(S)))
    S = 20*log10(S);
    % fprintf('tengah max %.2f min %.2f\n',max(max(S)), min(min(S)))
    % S = S-max(max(S));
    % fprintf('akhir max %.2f min %.2f\n',max(max(S)), min(min(S)))


    %__________________________________________________________________________________________________________________
    % PLOT RESULTS 
    maxF = 5000;
    der = (F - maxF).^2;
    [val, loc] = min(der);

    imagesc(T,F(1:loc),S(1:loc,:),[Smin Smax]); axis tight;
    axis('xy'); axis([0 N/fs  0 fs/2]);
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    set(gca,'YDir','normal');

    if(cbar), colorbar; end

    switch(lower(cmap))
    case {'default','speech',''}
%         colormap('gray');
%         map=colormap;
%         colormap(1-map);
        colormap(cmap);
    otherwise, colormap(cmap);
    end
    
    handle = gca;


%______________________________________________________________________________________________________________________
%                                                       EOF