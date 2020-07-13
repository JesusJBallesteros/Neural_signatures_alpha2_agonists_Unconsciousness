% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.

clear all;

%% Session
animal = 'NAME';
drug = 'Dexmedetomidine';
ROI = [{'S1'} {'S2'} {'PMv'}];
dBscale = 1;

%% Multitaper
params.tapers = [1 5 7]; % [W T p] -> 2TW-p tapers are used 
params.Fs = 1000;
params.fpass = [0.5 59];
params.pad = 0;
movingwin = [5 5];  % movingwin(1) MUST == T

%% F-Banding
frequencies = [.5, 4;...
                4, 7;...
                7, 12;...
               12, 18;...
               18, 30;...
               30, 58];%...

%% Gather Data
LFPpath = strcat('L:\Project2\Data\', animal, '\LFP\', drug);
spectrsave = strcat('L:\Project2\Results\Spectrograms\', animal, '\', drug, '\Finals');
LFPFiles = dir([LFPpath, '\*S2_str.mat']);
cd(LFPpath); 

for file = 1:length(LFPFiles)
  % LOAD DATA
  cd(LFPpath);
  sessionname = LFPFiles(file).name;  
  load(LFPFiles(file).name);
  fprintf('Processing Session: %s\n', sessionname); 
   sessionInfo.trialErrors = trialErrors;
   sessionInfo.trialTimes = trialTimes;
    
   if file == 8, isantag = 1;
   else, isantag = 0; end
        
  % Filtering 60Hz, not too strong
  d = designfilt('bandstopiir','FilterOrder',2, ...         
       'HalfPowerFrequency1',59.5,'HalfPowerFrequency2',60.5, ... 
       'DesignMethod','butter','SampleRate',params.Fs);
   
  for r = 1:3
      for ch = 1:size(LFPdata.(ROI{r}),2)
         LFPdata.(ROI{r})(:,ch) = filtfilt(d,LFPdata.(ROI{r})(:,ch));
      end
  end
  clear d 
   
  % Calculate spectrograms ch by ch 
  [spectralData,t,f,startAnesthesiaTime] = ...
      calculate_spectrogram(LFPdata, DataArray, Anesthesia, ROI, movingwin,params);
  
  % Calculates the mean spectrogram per array
  for r = 1:3
      for ch = 1:length(spectralData.(ROI{r}))
         temp.(ROI{r})(:,:,ch) = spectralData.(ROI{r}){ch};
      end
    spectralData_mean.(ROI{r}) = mean(temp.(ROI{r}),3);
  end

  fprintf('Calculating frequency bands\n');
  [freq_data_Zmean, freq_data_score, freq_data_baseline] = ...
      extract_freq_band(spectralData, t, f, startAnesthesiaTime, ROI, frequencies);
  
  fprintf('Plotting spectrograms\n');
  plot_bhv_spectrograms(sessionInfo, spectralData_mean, t, f, sessionname, DataArray, ROI, dBscale)

  fprintf('Plotting frequencies\n');
  plot_fbands_Zscored(freq_data_Zmean, t, frequencies, DataArray, signif_points)

    cd(spectrsave);
    save(strcat(sessionname(1:7),'_w',int2str(movingwin(1)),'_theta_S2.mat'), 'spectralData', ...
    'DataArray', 'Anesthesia', 'LFPdata', 'params', 'sessionInfo', 'sessionname',...
    'spectralData_mean', 'movingwin', 't', 'f', 'freq_data_Zmean', 'ROI');
end
