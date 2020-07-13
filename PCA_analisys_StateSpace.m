% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.

%% Input 
animal = 'NAME'; %
drug = 'dexmedetomidine';
session = 'ADDMMYY'; %
ROI = [{'S1'} {'S2'} {'PMv'}];
isantag = 1; % 1 for antagonist session, 0 for regular

filestring = '_S2_str.mat';
genfolderdata = 'L:\Project2\Data\';

% Save plots:
saveplot = 0; % 1 for yes
plotsave = strcat('L:\Project2\Results\StateTransitions\', drug, '\', session, '\bands\');

%% Multitaper Info
% Multitaper parameters 
params.tapers = [1 5 7]; % [W T p] -> 2TW-p tapers are used 
params.Fs = 1000;
params.fpass = [0.5 59];
params.pad = 0;
movingwin = [5 1];  % movingwin(1) MUST == T

%% Some plotting info
% General scaling and perspective for plots
if isantag == 0
    scale.xax = [-0.6 0.4]; %[-8e-3 6e-3];
    scale.yax = [-1 1]; %[-0.05 0.3];
    scale.zax = [-0.5 1]; %[-4e-3 10e-3];
    
    cam_pos.PMv = [-3 2.9 2.6]; %original [-1.5 16 3.5];
    cam_pos.S1 = [3.2 15.3 3.9]; 
else
    scale.xax = [-0.7 0.6]; %[-4e-3 10e-3];
    scale.yax = [-1     1]; %[-0.05 0.3];
    scale.zax = [-0.2 0.4]; %[-8e-3 6e-3];

    cam_pos.PMv = [-3 2.9 2.6]; %original [-1.5 16 3.5];
    cam_pos.S1 = [3.2 15.3 3.9]; 
end                    

% Time points to plot around recovery
pre =  599; % in sec 
post =  600; % in sec (also, first point)

% Video animation
videorec = 1; 
setpause.awake     = .01; % in sec. less will be faster
setpause.infpreloc = .01;
setpause.infpostloc= .01;
setpause.rec       = .01;
setpause.roc       = .01;
setpause.ropap     = .01;

%% Load data here
% LFP raw data as structure.
cd([genfolderdata, animal, '\LFP\', drug]);
load([session, filestring]);
tplot =  [1 length(t)] ;
mkdir(plotsave);
cd(plotsave);

%% Filtering and cleaning channels
% Remove bad channels
  LFPdata.S1(:,bad_channels.S1) = []; 
  LFPdata.PMv(:,bad_channels.PMv) = [];  
  LFPdata.S2(:,bad_channels.S2) = [];

  d = designfilt('bandstopiir','FilterOrder',2, ...         
       'HalfPowerFrequency1',59.5,'HalfPowerFrequency2',60.5, ... 
       'DesignMethod','butter','SampleRate',params.Fs);
  
for r = [1 3]
  LFPdata.(ROI{r}) = filtfilt(d,LFPdata.(ROI{r}));
end
clear d
  
%% Construction of 2D state-Space from LFP signals
% Will be based on two/three spectral amplitude ratios
    % Obtain FFT
    [spectralData,t,f,~] = calculate_spectrogram(LFPdata,DataArray,Anesthesia,ROI,movingwin,params);

    % Visualize a single channel spectrogram, optional
    %plot_spectrograms(sessionInfo, spectralData, t, f, ROI, saveplot)

    % Calculate freq. band ratios
    [ratio1, ratio2, ratio3, fbands] = extract_freq_band_ratios(spectralData, ROI, LFPdata, f, t, drug);

    % Visualize ratios dynamics
    plot_fbands_ratios(ratio1, ratio2, ratio3, sessionInfo, ROI, saveplot, drug, 1)

%% Create Behavioral Labels
% Create function for usability
    BHVlabels = NaN(length(t),3);
    BHV = [];
    tr = 1;
    for sec = 1:length(BHVlabels)
        if isantag == 0
            % Regular Sessions
            if sec <= round(sessionInfo.startAnesthesiaTime)
                BHV = 1; % Awake
            elseif sec > round(sessionInfo.startAnesthesiaTime) && sec <= round(sessionInfo.locTime)
                BHV = 2; % preLOC
            elseif sec > round(sessionInfo.locTime) && sec <= round(sessionInfo.endAnesthesiaTime)
                BHV = 3; % Anesthesia
            elseif sec > round(sessionInfo.endAnesthesiaTime) && sec <= round(sessionInfo.rocTime)
                BHV = 4; % preROC
            elseif sec > round(sessionInfo.rocTime) && sec <= round(sessionInfo.ropapTime)
                BHV = 5; % postROC
            elseif sec > round(sessionInfo.ropapTime) && sec <= length(t)
                BHV = 6; % postROPAP
            end
        else
            % Antagonist Sessions
            if sec <= round(sessionInfo.startAnesthesiaTime)
                BHV = 1; % Awake
            elseif sec > round(sessionInfo.startAnesthesiaTime) && sec <= round(sessionInfo.locTime)
                BHV = 2; % preLOC
            elseif sec > round(sessionInfo.locTime) && sec <= round(sessionInfo.startAnesthesiaTime)+1800
                BHV = 3; % Anesthesia
            elseif sec > round(sessionInfo.startAnesthesiaTime)+1800 && sec <= length(t)
                BHV = 4; % PostAntag 
            end
        end
        if sec < round(sessionInfo.trialTimes(tr))
            BHVlabels(sec,1) = sessionInfo.bEngage(tr,4);
            BHVlabels(sec,2) = sessionInfo.bPerform(tr,4);
            BHVlabels(sec,3) = BHV;
            continue
        end

        tr = tr+1;
        if tr <= length(sessionInfo.trialTimes)
            BHVlabels(sec,1) = sessionInfo.bEngage(tr,4);
            BHVlabels(sec,2) = sessionInfo.bPerform(tr,4);
            BHVlabels(sec,3) = BHV;
        else
            BHVlabels(sec:end,1) = sessionInfo.bEngage(end,4);
            BHVlabels(sec:end,2) = sessionInfo.bPerform(end,4);
            BHVlabels(sec,3) = BHV;
            break
        end
    end
    clear BHV tr

%% Principal Components Analysis
% Applied to the same ratio across all single channels, for each ratio
% PCs explaining >70% of data variance will be used.

   % [PCA_ratio1, PCA_ratio2, PCA_ratio3, SS3D] = calculate_PCA_fbandratios(ratio1, ratio2, ratio3, ROI);
    for r = [1 3]
        SS3D.(ROI{r}) = [ratio1.(ROI{r})(:,end), ratio2.(ROI{r})(:,end), ratio3.(ROI{r})(:,end)];
    end

    % Visualization smoothed PCs Scores. Optional
    for r = [1 3]
    % figure, 
    % subplot(221), 
    %     biplot(PCA_ratio1.(ROI{r}).coeff,'Scores',PCA_ratio1.(ROI{r}).score_smooth, ...
    %     ... %'Varlabels',vbls.S1, ...
    %     'MarkerFaceColor', 'r');
    % subplot(222), 
    %     biplot(PCA_ratio2.(ROI{r}).coeff,'Scores',PCA_ratio2.(ROI{r}).score_smooth, ...
    %     ... %'Varlabels',vbls.S1, ...
    %     'Marker', 'x', ...
    %     'MarkerEdgeColor', 'b');
    % subplot(223), 
    %     biplot(PCA_ratio3.(ROI{r}).coeff,'Scores',PCA_ratio3.(ROI{r}).score_smooth, ...
    %     ... %'Varlabels',vbls.S1, ...
    %     'Marker', 'o', ...
    %     'MarkerEdgeColor', 'g');
    % suptitle([session,'-', ROI{r},'-PCA coeff. and Scores']);
    % title([session,' - ', ROI{r},' - PCA coeff. and Scores']);
    % 
    % if saveplot == 1
    %   sdf(gcf,'default');
    %   saveas(gcf,(strcat(session,'_',(ROI{r}),'_03.fig')),'fig');
    %   saveas(gcf,(strcat(session,'_',(ROI{r}),'_03.jpg')));
    % end
    end

    % Obtain Distances between consecutive points
    % for speed representations
    for r = [1 3]
        [vel.(ROI{r}),speed.(ROI{r})] = extract_speedvelocity(SS3D.(ROI{r}));
    end

%% Scatter plots visualization on 2D-3D spaces 
% vector [1 1 1 1]:
    % 1st = simple scatter. 2nd = Scatter +Histograms. 
    % 3rd = Density plots. 4th = Scatter colored with time.

    scatter_plots_PCA(SS3D, t, sessionInfo,...
        ROI, [1 1 1 1], tplot, [0 0 0 0], cam_pos, scale)

%% Scatter plot visualization on 2D-3D spaces colored VS Behavior-Label
    scatter_plots_PCA_behavior(SS3D, BHVlabels, speed, sessionInfo,...
        ROI, [0 1 1 1], tplot, [0 1 1 1], isantag, cam_pos, scale)

%% Scatter plot for specific time around LOC and around ROC
    plot_trajectory_around(SS3D, speed, pre, post, 1, ROI, sessionInfo, 1)


save(strcat(sessionInfo.session,'_StateSpace.mat'));