function [spectralData,t,f,startAnesthesiaTime] = calculate_spectrogram(LFPdata,DataArray,Anesthesia,ROI,movingwin,params)
% This will calculate the spectrum for all areas of interest with specific
% parameters.
% INPUTS:   LFPdata     = struct array with all LFP data in samples x channel
%           DataArray   = struct with data from behavior
%           Anesthesia  = strcut with anesthesia time and trial times
%           ROI         = cell array with regions of interest
%           movingwin   = value of moving window to apply on the calculation
%           params      = struct with paramenter used by mtspecgramc
% OUTPUTS:
%           spectralData        = Spectral data
%           t                   = time array
%           f                   = frequencies array
%           startAnesthesiaTime = value for start of infusion

% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


addpath(genpath('C:\Project2\Apps\chronux_2_12'));

%% Spectrogram calculation
for r = 1:length(ROI)    % Spectrogram calculation
  for ch = 1:size(LFPdata.(ROI{r}),2)  %% width(LFPtimetable.(ROI{r}))

   % CONSTRAIN LFP DATA TO TASK
   if ch == 1
     timeAxis = 1/1000:1/1000:length(LFPdata.(ROI{r}))/1000;
     firstTime = DataArray(1,1);
     lastTime = DataArray(end,2);
     lfpDataIndex = find(timeAxis>=firstTime & timeAxis<=lastTime);
     startAnesthesiaTime = DataArray(Anesthesia.starttrial,1);
%        endAnesthesiaTime = DataArray(Anesthesia.endtrial,1);
%      timeLimit = startAnesthesiaTime;
   end
   
  % COMPUTE MULTI-TAPER SPECTROGRAM AND Z-SCORE-IT
  [spectralData.(ROI{r}){ch,1}, t, f] = ...
      mtspecgramc(LFPdata.(ROI{r})(lfpDataIndex,ch), movingwin, params);
  end
end
end