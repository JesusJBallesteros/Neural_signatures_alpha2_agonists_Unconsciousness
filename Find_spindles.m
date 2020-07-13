% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.

clear all

%% Using FMAToolbox to filter LFP and detect Spindles
    % Needs the FMAToolbox!
% Input 
animal = 'NAME'; % ''
drug = 'Dexmedetomidine';
session = 'ADDMMYY'; 
ROI = [{'S1'} {'S2'} {'PMv'}];
isantag = 1; 

if isantag == 1
conds = [{'awake'} {'anesth'} {'antag'}]; 
else, conds = [{'awake'} {'anesth'} {'recperf'} {'recnonperf'}];
end

tchunks = 1; % Set unit (minutes) of time for events/time
color.purple= [0.5412, 0.1686, 0.8863];
color.orange= [1, .5, 0];
% c = 0;
params.Fs = 1000;
    
%% Load data here
% LFP raw data as structure
cd(['L:\Project2\Data\', animal, '\LFP\', drug]);
load([session, '_S2_str.mat'], 'DataArray', 'LFPdata', 'sessionInfo');
cd(['L:\Project2\Results\EventFinder\Dexmedetomidine\' session]);
  
%% Timings
if exist('sessionInfo','var')
    times.startAnesth = sessionInfo.startAnesthesiaTime*params.Fs; % (samples)
    if isantag == 0
        times.endAnesth = sessionInfo.endAnesthesiaTime*params.Fs; % (samples)

        % Over 90% performance's last trial and trial start-time (sec)
        perfindx = find(sessionInfo.bPerform(:,4)> 0.9);
        trialperf = find(diff(perfindx) == 1);
        trialperf = perfindx(trialperf(end)+1);
        tperf = [trialperf, sessionInfo.trialTimes(trialperf)];
            times.recperf = tperf(2)*params.Fs;          % upper limit 

        % Under 30% engagement's last trial and trial start-time (sec)
        nonperfindx = find(sessionInfo.bEngage(:,4)< 0.3);
        trialnonperf = find(diff(nonperfindx) == 1);
        trialnonperf = nonperfindx(trialnonperf(end)+1);
        tnonperf = [trialnonperf, sessionInfo.trialTimes(trialnonperf)];
            times.recnonperf = 235*60000; %tnonperf(2)*params.Fs;    % upper limit 

        times.startAntag = 0;
        times.endAntag = 0;
    
        clear perfindx nonperfindx trialperf trialnonperf
    elseif isantag == 1
        times.endAnesth = times.startAnesth+(30*60*params.Fs); % (samples)

        times.recperf = 0;
        times.recnonperf = 0;

        times.startAntag = times.endAnesth;
        times.endAntag = times.startAntag+(30*60*params.Fs);
    end
else
    times.startAnesth = 1800*params.Fs;
    times.endAnesth = 5400*params.Fs;
    times.startAntag = 0;
    times.endAntag = 0;
    times.recperf = 0;
    times.recnonperf = 0;
end
% How long the time periods are (in minutes)
times.tawake = 10; 
times.tanesth = 10;
times.trecperf = 10;
times.trecnonperf = 10;
times.tantag = 10;

%% Filtering and cleaning channels
d = designfilt('bandstopiir','FilterOrder',2, ...         
       'HalfPowerFrequency1',59.5,'HalfPowerFrequency2',60.5, ... 
       'DesignMethod','butter','SampleRate',params.Fs);

% Create time vector
  t = linspace(DataArray(1,1),DataArray(end,2),length(LFPdata.S1));

%% Concatenate 't' and 'v', filtering 60Hz
for r = 1:3
  LFPdata.(ROI{r}) =[t' filtfilt(d,LFPdata.(ROI{r}))];
end
clear t d
  
%% Filter for Spindles
for r = 1:3
 LFPfiltered.(ROI{r}) = FilterLFP(LFPdata.(ROI{r}),'passband',[9 17]);
end 
 
%% Find Spindles
for r = 1:3
  for ch = 1:size(LFPfiltered.(ROI{r}),2)-1
    spindles.(ROI{r}){:,ch} = FindSpindles(LFPfiltered.(ROI{r})(:,[1 ch+1]),...
         'threshold', 4,...
         'peak', 6,...
         'durations', [500 2500]);
  end
end

% Remove hyper-amplitude spindles (artifacts)
capat = 50; % Peak ampl value
for r = 1:3
  for ch = 1:size(LFPfiltered.(ROI{r}),2)-1
      spindles.(ROI{r}){:,ch} = spindles.(ROI{r}){:,ch}(spindles.(ROI{r}){:,ch}(:,4) < capat,:);
  end
end

%% Allocate Spindles and count them
for r = 1:3
    % Pre-allocate counter of events per unit of time
    maxtchunks = floor(size(LFPdata.(ROI{r}),1)/params.Fs/60/tchunks);
    density.(ROI{r}).all = zeros(maxtchunks,size(LFPdata.(ROI{r}),2));
    count.(ROI{r}).all = zeros(1,size(LFPdata.(ROI{r}),2)-1);
    
   for ch = 1:size(LFPdata.(ROI{r}),2)-1 % Ch by Ch
       for ci = 1:length(conds)  % Let's preallocate all possible conditions for all channels 
        events.(ROI{r}).(conds{ci}){1,ch}(1,:) = NaN;
        events.(ROI{r}).(conds{ci}){2,ch}(1,:) = NaN;
        count.(ROI{r}).(conds{ci})(ch) = 0;
       end
       
    % Go through every spindle center-time
      for sp = 1:size(spindles.(ROI{r}){1,ch},1)-1
       % Locate the spindle raw voltage trace   
       sp_idx = find(LFPdata.(ROI{r})(:,1)>=spindles.(ROI{r}){1,ch}(sp,1) &...
                LFPdata.(ROI{r})(:,1)<=spindles.(ROI{r}){1,ch}(sp,3));
       
       % Find time and amplitude of the peak 
       peakt = spindles.(ROI{r}){:,ch}(sp,2);
       peakz = spindles.(ROI{r}){:,ch}(sp,4);
       
       % Depending on what time sp comes from
       if peakt*params.Fs >= times.startAnesth-(times.tawake*60*params.Fs) &&...
            peakt*params.Fs < times.startAnesth
           ci = 1; % Awake: tanesthStart-10 - tanesthStart
       elseif peakt*params.Fs >= times.endAnesth-((times.tanesth+25)*60*params.Fs) &&...
                peakt*params.Fs < times.endAnesth-(25*60*params.Fs)
           ci = 2; % Anesth: tanesthEnd-10 - tanesthEnd
       elseif isantag == 0 && peakt*params.Fs >= times.recperf-(times.trecperf*60*params.Fs) &&...
                                peakt*params.Fs < times.recperf
           ci = 3; % 
       elseif isantag == 1 && peakt*params.Fs >= times.startAntag+(2*60*params.Fs) &&...
                                peakt*params.Fs < times.startAntag+((2+times.tantag)*60*params.Fs)
           ci = 3; % 
       elseif isantag == 0 && peakt*params.Fs >= times.recnonperf-(times.trecnonperf*60*params.Fs) &&...
                                peakt*params.Fs < times.recnonperf
           ci = 4; % 
       else
           ci = 0;   % None of the specified conditions
           continue,
       end

       % Allocate the peak under the corresponding condition
       count.(ROI{r}).all(1,ch) = count.(ROI{r}).all(1,ch) + 1;
       count.(ROI{r}).(conds{ci})(ch) = count.(ROI{r}).(conds{ci})(ch) + 1;
       if ci > 0
         events.(ROI{r}).(conds{ci}){1,ch}(count.(ROI{r}).(conds{ci})(ch),1) = peakt;
         events.(ROI{r}).(conds{ci}){2,ch}(count.(ROI{r}).(conds{ci})(ch),1) = peakz;
        end    
      end
      clear peakt peakz
   end
end

%% Obtain Spindle density (events per unit of time)
for r = 1:3
   for ch = 1:size(LFPdata.(ROI{r}),2)-1 
      for tt = 1:maxtchunks
        density.(ROI{r}).all(tt,ch) =...
            length(find(spindles.(ROI{r}){1,ch}(:,2) > (tt-1)*60*tchunks ...
                      & spindles.(ROI{r}){1,ch}(:,2) <= tt*60*tchunks));
      end
   end
end

%% Obtain Spindle duration
for r = 1:3
   for ch = 1:size(LFPdata.(ROI{r}),2)-1 % Ch by Ch
       for ci = 1:length(conds)  % restart counters 
        count.(ROI{r}).(conds{ci})(ch) = 0;
        duration.(ROI{r}).(conds{ci}){1,ch} = [];
       end

    % Gets duration of all spindles found in channel
    duration.(ROI{r}).all{1,ch} = spindles.(ROI{r}){1,ch}(:,3) - spindles.(ROI{r}){1,ch}(:,1);
    
    % Go through every spindle center-time
      for sp = 1:size(spindles.(ROI{r}){1,ch},1)-1
       peakt = spindles.(ROI{r}){:,ch}(sp,2);
       % Depending on what time sp comes from
       if peakt*params.Fs >= times.startAnesth-(times.tawake*60*params.Fs) &&...
            peakt*params.Fs < times.startAnesth
           ci = 1; % Awake: tanesthStart-10 - tanesthStart
       elseif peakt*params.Fs >= times.endAnesth-(times.tanesth*60*params.Fs) &&...
                peakt*params.Fs < times.endAnesth
           ci = 2; % Anesth: tanesthEnd-10 - tanesthEnd
       elseif isantag == 0 && peakt*params.Fs >= times.recperf-(times.trecperf*60*params.Fs) &&...
                                peakt*params.Fs < times.recperf
           ci = 3; % 
       elseif isantag == 1 && peakt*params.Fs >= times.startAntag+(2*60*params.Fs) &&...
                                peakt*params.Fs < times.startAntag+((2+times.tantag)*60*params.Fs)
           ci = 3; % 
       elseif isantag == 0 && peakt*params.Fs >= times.recnonperf-(times.trecnonperf*60*params.Fs) &&...
                                peakt*params.Fs < times.recnonperf
           ci = 4; % 
       else
           ci = 0;   % None of the specified conditions
           continue,
       end
       
       count.(ROI{r}).(conds{ci})(ch) = count.(ROI{r}).(conds{ci})(ch) + 1;
       if ci > 0
         duration.(ROI{r}).(conds{ci}){1,ch}(count.(ROI{r}).(conds{ci})(ch),1) =...
             spindles.(ROI{r}){1,ch}(sp,3) - spindles.(ROI{r}){1,ch}(sp,1);
       end
      end
   clear peakt
   end
end

%% Calculate Spindles spectrograms
for r = 1:3
   for ch = 1:size(LFPdata.(ROI{r}),2)-1 % Ch by Ch
       for ci = 1:length(conds)  % restart counters 
        count.(ROI{r}).(conds{ci})(ch) = 0;
       end
       
    % Go through every spindle center-time
      for sp = 1:size(spindles.(ROI{r}){1,ch},1)-1
       % Locate the spindle raw voltage trace   
%        sp_idx = find(LFPdata.(ROI{r})(:,1)>=spindles.(ROI{r}){1,ch}(sp,1) &...
%                 LFPdata.(ROI{r})(:,1)<=spindles.(ROI{r}){1,ch}(sp,3));
       peakt = spindles.(ROI{r}){:,ch}(sp,2);
       
       % Depending on what time sp comes from
       if peakt*params.Fs >= times.startAnesth-(times.tawake*60*params.Fs) &&...
            peakt*params.Fs < times.startAnesth
           ci = 1; % Awake: tanesthStart-10 - tanesthStart
       elseif peakt*params.Fs >= times.endAnesth-(times.tanesth*60*params.Fs) &&...
                peakt*params.Fs < times.endAnesth
           ci = 2; % Anesth: tanesthEnd-10 - tanesthEnd
       elseif isantag == 0 && peakt*params.Fs >= times.recperf-(times.trecperf*60*params.Fs) &&...
                                peakt*params.Fs < times.recperf
           ci = 3; % 
       elseif isantag == 1 && peakt*params.Fs >= times.startAntag+(2*60*params.Fs) &&...
                                peakt*params.Fs < times.startAntag+((2+times.tantag)*60*params.Fs)
           ci = 3; % 
       elseif isantag == 0 && peakt*params.Fs >= times.recnonperf-(times.trecnonperf*60*params.Fs) &&...
                                peakt*params.Fs < times.recnonperf
           ci = 4; % 
       else
           ci = 0;   % None of the specified conditions
           continue,
       end
       
       count.(ROI{r}).(conds{ci})(ch) = count.(ROI{r}).(conds{ci})(ch) + 1;
       if ci > 0
       % Calculate spectrogram for the spindle  
            [imf,~,~] = emd(LFPdata.(ROI{r})(spindles.(ROI{r}){1,ch}(sp,1)*params.Fs:...
           spindles.(ROI{r}){1,ch}(sp,3)*params.Fs,ch+1),'Interpolation','spline','Display',0);
            [hht,httf,~] = hht(imf,params.Fs,'FrequencyLimits',[7 20], 'FrequencyResolution', 0.5);
            % imagesc(events.S1.anesth{3,1}{1,1})
            % yticks(1:2:27)
            % yticklabels(7:1:20)
            
           % get power peak and frequency and time peaks
           peakpw = full(max(max(hht)));
           [i,~] = find(hht==peakpw(1));
           peakpw = httf(i);
       
         events.(ROI{r}).(conds{ci}){3,ch}{count.(ROI{r}).(conds{ci})(ch),:} = hht;
         events.(ROI{r}).(conds{ci}){4,ch}(count.(ROI{r}).(conds{ci})(ch),1) = peakpw;
         clear imf hht httf peakpw i j 
       end
      end
   clear httf peakt
   end
end

%% Average across conditions
for r = 1:3
   for ci = 1:length(conds)
    density.(ROI{r}).mean(:,1) = mean(density.(ROI{r}).all,2);
    density.(ROI{r}).mean(:,2) = std(density.(ROI{r}).all,0,2);

   % 'averages.(roi)' is a 3-d matrix (:,:,condition)
   % [Counts      mean, std]
   % [Duration    mean, std]
   % [Count/min   mean, std]
   % [Peak freq   mean, std]
   
   % The counts and durations
     averages.(ROI{r}){1,1,ci} = nanmean(count.(ROI{r}).all(1,:),2);  % counts mean
      averages.(ROI{r}){1,2,ci} = nanstd(count.(ROI{r}).all(1,:),0,2); % counts std
     averages.(ROI{r}){2,1,ci} = cellfun(@mean, duration.(ROI{r}).all); % duration mean (all)
      averages.(ROI{r}){2,2,ci} = cellfun(@std, duration.(ROI{r}).all); % duration std (all)
     averages.(ROI{r}){5,1,ci} = cellfun(@mean, duration.(ROI{r}).(conds{ci})); % duration mean (cond)
      averages.(ROI{r}){5,2,ci} = cellfun(@std, duration.(ROI{r}).(conds{ci})); %  duration std (cond)

   % The counts per minute
     if ci == 1
      averages.(ROI{r}){3,1,ci} = count.(ROI{r}).(conds{ci})/times.tawake; %,2); % counts/min 
     elseif ci == 2
      averages.(ROI{r}){3,1,ci} = count.(ROI{r}).(conds{ci})/times.tanesth;%,2);
     elseif ci == 3 && isantag == 0
      averages.(ROI{r}){3,1,ci} =  count.(ROI{r}).(conds{ci})/times.trecperf;%,2);
      elseif ci == 3 && isantag == 1
      averages.(ROI{r}){3,1,ci} =  count.(ROI{r}).(conds{ci})/times.tantag;%,2);
     elseif ci == 4 && isantag == 0
      averages.(ROI{r}){3,1,ci} =  count.(ROI{r}).(conds{ci})/times.trecnonperf;%,2);
     end      
     
     averages.(ROI{r}){3,2,ci}(1,1) = mean(averages.(ROI{r}){3,1,ci}); % counts/min mean  
     averages.(ROI{r}){3,2,ci}(1,2) = std(averages.(ROI{r}){3,1,ci},0,2); % counts/min std  

   % The peak frequency
     if size(events.(ROI{r}).(conds{ci}),1) >= 4
     averages.(ROI{r}){4,1,ci} = cellfun(@mean, events.(ROI{r}).(conds{ci})(4,:)); % frequency peak mean
     averages.(ROI{r}){4,2,ci} = cellfun(@nanstd, events.(ROI{r}).(conds{ci})(4,:)); % frequency peak std
     else
     averages.(ROI{r}){4,1,ci} = NaN(1,size(events.(ROI{r}).(conds{ci}),2)); % frequency peak mean
     averages.(ROI{r}){4,2,ci} = NaN(1,size(events.(ROI{r}).(conds{ci}),2)); % frequency peak std
     end
   end
end

%% T-testing
for r = 1:3
    % Density
    for ci = 1:size(averages.(ROI{r}),3)
        for cj = 1:size(averages.(ROI{r}),3)
            if ci ~= cj
            [t_test.(ROI{r}).density.(conds{ci}).(conds{cj}).h,...
             t_test.(ROI{r}).density.(conds{ci}).(conds{cj}).p,...
             t_test.(ROI{r}).density.(conds{ci}).(conds{cj}).ci,...
             t_test.(ROI{r}).density.(conds{ci}).(conds{cj}).stats] = ...
                    ttest(averages.(ROI{r}){3,1,ci},averages.(ROI{r}){3,1,cj},'Alpha',0.01);
            end
        end
    end
    % Duration
    for ci = 1:size(averages.(ROI{r}),3)
        for cj = 1:size(averages.(ROI{r}),3)
            if ci ~= cj
            [t_test.(ROI{r}).duration.(conds{ci}).(conds{cj}).h,...
             t_test.(ROI{r}).duration.(conds{ci}).(conds{cj}).p,...
             t_test.(ROI{r}).duration.(conds{ci}).(conds{cj}).ci,...
             t_test.(ROI{r}).duration.(conds{ci}).(conds{cj}).stats] = ...
                    ttest(averages.(ROI{r}){5,1,ci},averages.(ROI{r}){5,1,cj},'Alpha',0.01);
            end
        end
    end
    % Freq peak
    for ci = 1:size(averages.(ROI{r}),3)
        for cj = 1:size(averages.(ROI{r}),3)
            if ci ~= cj
                if ~isempty(averages.(ROI{r}){4,1,ci}) && ~isempty(averages.(ROI{r}){4,1,cj})
                [t_test.(ROI{r}).freqpeak.(conds{ci}).(conds{cj}).h,...
                 t_test.(ROI{r}).freqpeak.(conds{ci}).(conds{cj}).p,...
                 t_test.(ROI{r}).freqpeak.(conds{ci}).(conds{cj}).ci,...
                 t_test.(ROI{r}).freqpeak.(conds{ci}).(conds{cj}).stats] = ...
                        ttest(averages.(ROI{r}){4,1,ci},averages.(ROI{r}){4,1,cj},'Alpha',0.01);
                end
            end
        end
    end

end

%% Summary Plots
    plotparams.ch = 2; plotparams.r = 1;
    plotparams.xlimit.awake = [times.startAnesth-30e3 times.startAnesth-25e3];
    plotparams.xlimit.anesth = [times.endAnesth-2100e3 times.endAnesth-2095e3];
    plotparams.xlimit.antag = [times.startAntag+180e3 times.startAntag+185e3];
    plotparams.xlimit.recperforming = [times.recperf-10e3 times.recperf-5e3];
    plotparams.xlimit.recnoperforming = [times.recnonperf-10e3 times.recnonperf-5e3];
    plotparams.barx = [1 2 3 4];
    
    plotparams.xscat.S1 = repmat(plotparams.barx(1)-0.2, [1,length(count.S1.awake)]);
    plotparams.xscat.S2 = repmat(plotparams.barx(1)+0,   [1,length(count.S2.awake)]);
    plotparams.xscat.PMv = repmat(plotparams.barx(1)+0.2, [1,length(count.PMv.awake)]); 

% load spectrogram data if wanted
 % t freq_data_Zmean
 
% Plot
  plot_spindle_summary(count, ROI, averages, freq_data_Zmean,...
    density, maxtchunks, sessionInfo, session, isantag, color, plotparams, times, t, 0)

% Box plots
if isantag == 0
    for r = 1:3
        densitydata.(ROI{r}) = [averages.(ROI{r}){3,1,1};averages.(ROI{r}){3,1,2};...
                            averages.(ROI{r}){3,1,3};averages.(ROI{r}){3,1,4}]';
        freqpeakdata.(ROI{r}) = [averages.(ROI{r}){4,1,1};averages.(ROI{r}){4,1,2};...
                            averages.(ROI{r}){4,1,3};averages.(ROI{r}){4,1,4}]';
        durationdata.(ROI{r}) = [averages.(ROI{r}){5,1,1};averages.(ROI{r}){5,1,2};...
                            averages.(ROI{r}){5,1,3};averages.(ROI{r}){5,1,4}]';
    end
else
    for r = 1:3
        densitydata.(ROI{r}) = [averages.(ROI{r}){3,1,1};averages.(ROI{r}){3,1,2};...
                            averages.(ROI{r}){3,1,3}]';
        freqpeakdata.(ROI{r}) = [averages.(ROI{r}){4,1,1};averages.(ROI{r}){4,1,2};...
                            averages.(ROI{r}){4,1,3}]';
        durationdata.(ROI{r}) = [averages.(ROI{r}){5,1,1};averages.(ROI{r}){5,1,2};...
                            averages.(ROI{r}){5,1,3}]';                        
    end
end

%% Rest of plots
% Density
figure,
    subplot(3,2,[1,2])
        boxplot(densitydata.S1,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('counts/min');
      xlim([0.5 4.5]);
    if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
    else
      xticklabels({'awake' 'anesth' 'antag'});
    end
    title('S1')
      ylim([-0.5 12]);

    subplot(3,2,[3,4])
        boxplot(densitydata.S2,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('counts/min');
      xlim([0.5 4.5]);
    if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
    else
      xticklabels({'awake' 'anesth' 'antag'});
    end
    title('S2')
      ylim([-0.5 12]);
      
    subplot(3,2,[5,6])
        boxplot(densitydata.PMv,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('counts/min');
      xlim([0.5 4.5]); 
     if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
     else
      xticklabels({'awake' 'anesth' 'antag'});
     end
     title('PMv')
     ylim([-0.5 12]);
    suptitle(session);

% Duration
figure,
    subplot(3,2,[1,2])
        boxplot(durationdata.S1,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('seconds');
      xlim([0.5 4.5]);
    if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
    else
      xticklabels({'awake' 'anesth' 'antag'});
    end
    title('S1')
      ylim([0.5 1.5]);
    
    subplot(3,2,[3,4])
        boxplot(durationdata.S2,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('seconds');
      xlim([0.5 4.5]);
    if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
    else
      xticklabels({'awake' 'anesth' 'antag'});
    end
    title('S2')
      ylim([0.5 1.5]);
      
    subplot(3,2,[5,6])
        boxplot(durationdata.PMv,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('seconds');
      xlim([0.5 4.5]); 
     if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
     else
      xticklabels({'awake' 'anesth' 'antag'});
     end
     title('PMv')
     ylim([0.5 1.5]);
    suptitle(session);
    
% Frequency peak
figure,
    subplot(3,2,[1,2])
        boxplot(freqpeakdata.S1,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('Hz');
      xlim([0.5 4.5]);
    if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
    else
      xticklabels({'awake' 'anesth' 'antag'});
    end
    title('S1')
      ylim([7 21]);
      yticks([8 12 16 20]);
      yticklabels({'8' '12' '16' '20'});
    
    subplot(3,2,[3,4])
        boxplot(freqpeakdata.S2,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('Hz');
      xlim([0.5 4.5]);
    if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
    else
      xticklabels({'awake' 'anesth' 'antag'});
    end
    title('S2')
      ylim([7 21]);
      yticks([8 12 16 20]);
      yticklabels({'8' '12' '16' '20'});
    
    subplot(3,2,[5,6])
        boxplot(freqpeakdata.PMv,'BoxStyle','outline','Colors','krmb',...
            'MedianStyle','target','Notch','on','Symbol','x',...
            'Widths',0.2,'ExtremeMode','compress','Whisker',0)
      box off; 
      ylabel('Hz');
      xlim([0.5 4.5]); 
     if isantag == 0
      xticklabels({'awake' 'anesth' 'perf' 'nonperf'});
     else
      xticklabels({'awake' 'anesth' 'antag'});
     end
     title('PMv')
      ylim([7 21]);
      yticks([8 12 16 20]);
      yticklabels({'8' '12' '16' '20'});
    suptitle(session);
    
%% Save
save([session, '_Spindles_S2.mat']);

