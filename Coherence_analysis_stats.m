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

%% Inputs
animal = 'NAME';
drug = 'Dexmedetomidine';
ROI = [{'S1'} {'S2'} {'PMv'}];
pair = [{'S1'} {'S1S2'} {'S1PMv'} {'S2'} {'S2PMv'} {'PMv'}];
alpha = 0.01;
f_idx = [.5 63]; %frequency range
isantag = 0;
    % CND = [{'Awake'} {'Anesthesia'}  {'Antagonist'}]; 
    CND = [{'Awake'} {'Anesthesia'} {'ROC'} {'ROPAP'}];

params.tapers = [1 30 57]; % [W T p] -> 2TW-p tapers are used: 
params.Fs = 1000;  % If movingwin is in SECONDS, Fs -> Hz
params.fpass = f_idx;
% params.pad = 0;
% params.trialave = 0;
% params.err = [2 0.05];
movingwin = [30 30];  % movingwin(1) MUST == T

lfpdata.location = strcat('L:\Project2\Data\', animal, '\LFP\', drug);
lfpdata.files = dir([lfpdata.location, '\*_str.mat']);

%% Extract filtered LFP epochs per channel, calculate their coherence ch-to-ch, 
for j = 1:length(lfpdata.files)
    clear data_table_anova ANOVA Mult_comp signif_vsAwake sig_lin 
    clear coherence coherence_average epoch f 
    
  cd(lfpdata.location); 
  lfpdata.name = lfpdata.files(j).name;
  load(strcat(lfpdata.location,'\',lfpdata.name));  
  coher.name = [lfpdata.name(1:7), '-coherence'];
  coher.folder = strcat('L:\Project2\Results\Coherograms\', animal,...
                          '\', drug,'\',lfpdata.name(1:7));
  mkdir(coher.folder)

  % Filtering 60Hz, not too strong
  d = designfilt('bandstopiir','FilterOrder',2, ...         
               'HalfPowerFrequency1',59.5,'HalfPowerFrequency2',60.5, ... 
               'DesignMethod','butter','SampleRate',params.Fs);
           
  cd(coher.folder)  
  % Filter raw siganls between time epochs of interest
  for r = 1:3   
      n_channels.(ROI{r}) = size(LFPdata.(ROI{r}),2);
      for ch = 1:size(LFPdata.(ROI{r}),2)
        epoch.(ROI{r}).Awake(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.startAnesthesiaTime-300.0001)*params.Fs:...
            (sessionInfo.startAnesthesiaTime-270)*params.Fs-1,ch));        
        
        if isantag == 0 
        epoch.(ROI{r}).Anesthesia(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.endAnesthesiaTime-300.0001)*params.Fs:...
            (sessionInfo.endAnesthesiaTime-270)*params.Fs-1,ch));
        epoch.(ROI{r}).ROC(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.rocTime+30)*fs:(sessionInfo.rocTime+60.0001)*fs-1,ch));
        epoch.(ROI{r}).ROPAP(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.ropapTime)*params.Fs:...
            (sessionInfo.ropapTime+30.0001)*params.Fs-1,ch));
        
        else
        epoch.(ROI{r}).Anesthesia(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.endAnesthesiaTime-2100.0001)*params.Fs:...
            (sessionInfo.endAnesthesiaTime-2070)*params.Fs-1,ch));
        epoch.(ROI{r}).Antagonist(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.endAnesthesiaTime-1500.0001)*params.Fs:...
            (sessionInfo.endAnesthesiaTime-1470)*params.Fs-1,ch));
        end
      end
  end
  clear LFPdata d
  
  %% Calculate coherence for short epochs  
     % Needs Chronux toolbox 'cohgramc'
  for c = 1:length(CND)
    for p = 1:length(pair) 
      fprintf('Cycle: %d on CND %d\n', p, c);
        if p == 1
          LFPsource = epoch.S1.(CND{c});
          LFPreference = epoch.S1.(CND{c});
        elseif p == 2
          LFPsource = epoch.S1.(CND{c});
          LFPreference = epoch.S2.(CND{c});
        elseif p == 3
          LFPsource = epoch.S1.(CND{c});
          LFPreference = epoch.PMv.(CND{c});
        elseif p == 4
          LFPsource = epoch.S2.(CND{c});
          LFPreference = epoch.S2.(CND{c});
        elseif p == 5
          LFPsource = epoch.S2.(CND{c});
          LFPreference = epoch.PMv.(CND{c});
        elseif p == 6
          LFPsource = epoch.PMv.(CND{c});
          LFPreference = epoch.PMv.(CND{c});
        end
  
      pp = 0;
      if ~isempty(LFPsource) || ~isempty(LFPreference)
        for i = 1:size(LFPsource,2)
          for ii = 1:size(LFPreference,2)
            if (p == 1  && ii <= i) || (p == 4 && ii <= i) || (p == 6 && ii <= i)
              continue
            end
              pp = pp + 1;
              [coherence.(pair{p}).(CND{c})(:,pp), ~, ~, ~, ~, t, f] =...
                  cohgramc(LFPsource(:,i), LFPreference(:,ii), movingwin, params);
          end
        end
      end
    end
  end
  clear i ii pp LFPreference LFPsource

  %% Normality Test
    % Needs 'normalitytest' function from Mathworks users database.
        % Öner, M., & Deveci Kocakoç, Ý. (2017). JMASM 49: A Compilation of Some Popular 
        % Goodness of Fit Tests for Normal Distribution: Their Algorithms and MATLAB Codes 
        % (MATLAB). Journal of Modern Applied Statistical Methods, 16(2), 30. 
        % Copyright (c) (2016) Öner, M., Deveci Kocakoc, I.
    % Needs 'fitmethis' function from Mathworks users database.
        % Requires Statistics Toolbox
 
  for c = 1:length(CND)
    for p = 1:length(pair) 
      coherence_average.(pair{p}).(CND{c}) = nanmean(coherence.(pair{p}).(CND{c}),2);
     
    % Test for Normality, and Best Fit
     sprintf('Condition: %s', (CND{c})) 
     disp('Test Name                  Test Statistic   p-value   Normality (1:Normal,0:Not Normal)')
     disp('-----------------------    --------------  ---------  --------------------------------')
    for ff = 1:size(coherence.(pair{p}).(CND{c}),1)
        Norm_Results.(pair{p}).(CND{c}){ff} = ...
            normalitytest(coherence.(pair{p}).(CND{c})(ff,:),alpha,0);
        When no-normal, print it and search best fit
        if Norm_Results.(pair{p}).(CND{c}){ff}(1,3) == 0
        fprintf('Shapiro-Wilk Test            %6.4f \t   %6.4f             %1.0f \r',...
            Norm_Results.(pair{p}).(CND{c}){ff}(7,1),...
            Norm_Results.(pair{p}).(CND{c}){ff}(7,2),...
            Norm_Results.(pair{p}).(CND{c}){ff}(7,3))
        fprintf('KS Limiting Form test        %6.4f \t   %6.4f             %1.0f \r',...
            Norm_Results.(pair{p}).(CND{c}){ff}(1,1),...
            Norm_Results.(pair{p}).(CND{c}){ff}(1,2),...
            Norm_Results.(pair{p}).(CND{c}){ff}(1,3))

        fit_F.(pair{p}).(CND{c}){ff} =...
                fitmethis(coherence.(pair{p}).(CND{c})(ff,:),...
                'dtype','continous','figure','off','output','off');
        fprintf('-> Best fit is "%s" \r',fit_F.(pair{p}).(CND{c}){ff}(1).name) 
        end
    end
    end
  end
  
  %% Obtain mu and CIs (Bootstrap)
  CIFcn = @(x,p)prctile(x,abs([0,100]-(100-p)/2));
  nBoot = 1000; %number of bootstraps
  
  for c = 1:length(CND)
    for p = 1:length(pair) 
        % x is a vector, matrix, or any numeric array of data. NaNs are ignored.
        % p is the confidence level (ie, 95 for 95% CI)
        % The output is 1x2 vector showing the [lower,upper] interval values.  
        for ff = 1:size(coherence.(pair{p}).(CND{c}),1)
           coherence_average.(pair{p}).(CND{c})(ff,3:4) =...
                CIFcn(coherence.(pair{p}).(CND{c})(ff,:),95); % Get CIntervals
        end 

        % Run bootci (percentile method)  
        for ff = 1:size(coherence.(pair{p}).(CND{c}),1)
              [ci,~,S.(pair{p}).(CND{c}){ff}] = ...
                    ibootci(nBoot,{@mean,coherence.(pair{p}).(CND{c})(ff,:)},...
                    'alpha',.05,'type','bca','UseParallel','true'); %'per'
              coherence_average.(pair{p}).(CND{c})(ff,5:6) = ci';
              % Grab bootstrap sample mean
              coherence_average.(pair{p}).(CND{c})(ff,2) = ...
                                            S.(pair{p}).(CND{c}){ff}.bc_stat; 
        end
    
    end
  end   
  clear CIFcn nBoot bmeans ci
  
% Save workspace
save([coher.name,'.mat']);

%% Friedman's test 
for p = 1:length(pair)
   for ff = 1:size(coherence.(pair{p}).(CND{1}),1)
        for c = 1:length(CND)
           friedman_tbl.(pair{p}){ff}(:,c) =...
                coherence.(pair{p}).(CND{c})(ff,:)';
        end
   end
end

% Run Friedman's on each cell for all array-pairs
for p = 1:length(pair)
   for ff = 1:size(coherence.(pair{p}).(CND{1}),1)
   [friedman_res.(pair{p}).p(ff),friedman_res.(pair{p}).tbl{ff},friedman_res.(pair{p}).stats{ff}] = ...
        friedman(friedman_tbl.(pair{p}){ff} , 1, 'off');
   end
end

% Run Multiple Comparisons test on each obtained Friedman's Stat
corr_alpha = alpha/length(CND);
for p = 1:length(pair) 
   for ff = 1:size(coherence.(pair{p}).(CND{1}),1)
       if friedman_res.(pair{p}).p(ff) < alpha
        Mult_comp.(pair{p}){ff} = ...
           multcompare(friedman_res.(pair{p}).stats{ff},...
                        'alpha', corr_alpha, ...
                        'display', 'off', ...
                        'ctype','hsd bonferroni dunn-sidak'); 
       else
        Mult_comp.(pair{p}){ff} = [];
       end
   end
end

%% Plot Average PSD& CIs
saveplot = 0;
% Get significantly different (pv<corr_alpha) freqs to Awake measurement
for p = 1:length(pair) 
  for ff = 1:size(coherence.(pair{p}).(CND{1}),1)
      if ~isempty(Mult_comp.(pair{p}){ff})
        signif_vsAwake.(pair{p}){ff} = ...
          find(Mult_comp.(pair{p}){ff}(1:length(CND)-1,1) == 1 &...
                Mult_comp.(pair{p}){ff}(1:length(CND)-1,6) <=  corr_alpha);
      else
        signif_vsAwake.(pair{p}){ff} = [];
      end
  end
end

% Create vectors to draw lines of significance vs. Awake
for p = 1:length(pair) 
sig_lin.(pair{p}) = NaN(length(CND)-1,size(coherence.(pair{p}).(CND{c}),1));
    for ff = 1:size(coherence.(pair{p}).(CND{c}),1)
      if ~isempty(signif_vsAwake.(pair{p}){ff})
       temp = signif_vsAwake.(pair{p}){ff} == [1:length(CND)-1];
           if size(temp,1) == 1
             sig_lin.(pair{p})(:,ff) = temp;
           else
             [~, col] = find(temp==1);
             sig_lin.(pair{p})(col,ff) = 1;
           end
        temp = [];
      end
    end
sig_lin.(pair{p})(sig_lin.(pair{p})==0) = NaN;
end

% Draw
res=1; % Changes resolution of data to plot
for p = 1:length(pair) 
txt = strcat((pair{p}), ' n= ', string(size(coherence.(pair{p}).Awake,2)));  
figure,
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.3, 0.225, 0.45]);
    suptitle(strcat('Coherence&CI-', coher.name, '-at-',(pair{p})));
    if strcmp(CND{3},'ROC')
        % Assign data to the different y-errorbar pairs
        y1= coherence_average.(pair{p}).Awake(1:res:end,1)'; 
        y1errbar = [coherence_average.(pair{p}).Awake(1:res:end,6)';...
                    coherence_average.(pair{p}).Awake(1:res:end,5)'];

        y3=  coherence_average.(pair{p}).Anesthesia(1:res:end,1)'; 
        y3errbar = [coherence_average.(pair{p}).Anesthesia(1:res:end,6)';...
                    coherence_average.(pair{p}).Anesthesia(1:res:end,5)'];

        y4=  coherence_average.(pair{p}).ROC(1:res:end,1)'; 
        y4errbar = [coherence_average.(pair{p}).ROC(1:res:end,6)';...
                    coherence_average.(pair{p}).ROC(1:res:end,5)'];

        y5=  coherence_average.(pair{p}).ROPAP(1:res:end,1)'; 
        y5errbar = [coherence_average.(pair{p}).ROPAP(1:res:end,6)';...
                    coherence_average.(pair{p}).ROPAP(1:res:end,5)'];

        % Draw Assigned data
        s1 = shadedErrorBarCI(f(1:res:end),y1,y1errbar,...
            'lineprops','-k','patchSaturation',0.2,'transparent',1);
            s1.mainLine.LineWidth = 2; 
            s1.edge(1).Color = 'none'; s1.edge(2).Color = 'none';
            hold on
        s3 = shadedErrorBarCI(f(1:res:end),y3,y3errbar,...
            'lineprops','-b','patchSaturation',0.2,'transparent',1); 
            s3.mainLine.LineWidth = 2;
            s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
            hold on
        s4 = shadedErrorBarCI(f(1:res:end),y4,y4errbar,...
          'lineprops','-r','patchSaturation',0.2,'transparent',1); 
            s4.mainLine.LineWidth = 2;
            s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
            hold on
        s5 = shadedErrorBarCI(f(1:res:end),y5,y5errbar,...
            'lineprops','-c','patchSaturation',0.2,'transparent',1);
            s5.mainLine.LineWidth = 2;
            s5.edge(1).Color = 'none'; s5.edge(2).Color = 'none';
            hold on

    elseif strcmp(CND{3},'Antagonist')
        % Assign data to the different y-errorbar pairs
        y1= coherence_average.(pair{p}).Awake(1:res:end,1)'; 
        y1errbar = [coherence_average.(pair{p}).Awake(1:res:end,6)';...
                    coherence_average.(pair{p}).Awake(1:res:end,5)'];

        y3=  coherence_average.(pair{p}).Anesthesia(1:res:end,1)'; 
        y3errbar = [coherence_average.(pair{p}).Anesthesia(1:res:end,6)';...
                    coherence_average.(pair{p}).Anesthesia(1:res:end,5)'];

        y4=  coherence_average.(pair{p}).Antagonist(1:res:end,1)'; 
        y4errbar = [coherence_average.(pair{p}).Antagonist(1:res:end,6)';...
                    coherence_average.(pair{p}).Antagonist(1:res:end,5)'];

        % Draw Assigned data
        s1 = shadedErrorBarCI(f(1:res:end),y1,y1errbar,...
            'lineprops','-k','patchSaturation',0.2,'transparent',1);
            s1.mainLine.LineWidth = 2; 
            s1.edge(1).Color = 'none'; s1.edge(2).Color = 'none';
            hold on
        s3 = shadedErrorBarCI(f(1:res:end),y3,y3errbar,...
            'lineprops','-b','patchSaturation',0.2,'transparent',1); 
            s3.mainLine.LineWidth = 2;
            s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
            hold on
        s4 = shadedErrorBarCI(f(1:res:end),y4,y4errbar,...
          'lineprops','-c','patchSaturation',0.2,'transparent',1); 
            s4.mainLine.LineWidth = 2;
            s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
            hold on
    end

    xlim([0 58]);
    ylim([-0.1 1]);
    xticks([0.5 10 20 30 40 50]);
    %yticks();
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    hold on

    % Now paint the significant points
    % Maximun of 3 lines (Anesth, ROC, ROPAP) or (Anesth, Antagonist)
    if strcmp(CND{3},'ROC')
        scatter(f(1:res:end),...
                sig_lin.(pair{p})(1,1:res:end)-1.07, 40, 'sb', 'filled'), hold on
        scatter(f(1:res:end),...
                sig_lin.(pair{p})(2,1:res:end)-1.04, 40, 'sr', 'filled'), hold on
        scatter(f(1:res:end),...
                sig_lin.(pair{p})(3,1:res:end)-1.01, 40, 'sc', 'filled'), hold on
    elseif strcmp(CND{3},'Antagonist')
        scatter(f(1:res:end),...
                sig_lin.(pair{p})(1,1:res:end)-1.04, 40, 'sb', 'filled'), hold on
        scatter(f(1:res:end),...
                sig_lin.(pair{p})(2,1:res:end)-1.01, 40, 'sc', 'filled'), hold on
    end
    
    text(30,0.9,txt,'FontSize',14)
    
    if saveplot == 1
        saveas(gcf,(strcat(coher.name,'_',(pair{p}),'.fig')),'fig');
        saveas(gcf,(strcat(coher.name,'_',(pair{p}),'.jpg')));
    end
end

%% Repeated Measures ANOVA 'fitrm(t,modelspec)'
% Inside a struct per array, build the data table as 
    %   [sess  freq   ch    Meas1   ...   MeasX;
    %    1       1    1       dB    ...    dB   ;
    %    1       2    2       dB    ...    dB   ;
    %    ...         ...            ...         ;
    %    2       1    3       dB    ...    dB   ;
    %    ...         ...            ...         ;
    %    3       1    ch      dB    ...    dB   ;
for p = 1:length(pair) 
rept = 0;
  for ff = 1:size(coherence.(pair{p}).(CND{c}),1)
    for pp = 1:size(coherence.(pair{p}).(CND{c}),2)
      rept = rept+1;
      freqs.(pair{p}){rept,1} = num2str(ff,'%02d');
      pairs.(pair{p}){rept,1} = int2str(pp);
        for c = 1:length(CND)
          t_rm.(pair{p})(rept,c) =...
                coherence.(pair{p}).(CND{c})(ff,pp);
        end
    end
  end
  
  % make table for the rm model
  varnames.(pair{p}){1,1} = 'frequency';
  varnames.(pair{p}){1,2} = 'pairs';
  for i = 3:length(CND)+2
       v = strcat('meas',num2str(i-2));
       varnames.(pair{p}){1,i} = v;
  end
  
  atbl_rm.(pair{p}) = table(freqs.(pair{p}),pairs.(pair{p}),'VariableNames',varnames.(pair{p})(1,1:2));
      atbl_rm.(pair{p}).frequency = categorical(atbl_rm.(pair{p}).frequency);
      atbl_rm.(pair{p}).pairs = categorical(atbl_rm.(pair{p}).pairs);
  btbl_rm.(pair{p}) = array2table(t_rm.(pair{p}), 'VariableNames',varnames.(pair{p})(1,3:end));
  tbl_rm.(pair{p}) = [atbl_rm.(pair{p}) btbl_rm.(pair{p})];
  clear atbl_rm btbl_rm 
end
Meas = table([1:length(CND)]','VariableNames',{'Conditions'});
clear conds rept t_rm varnames v freqs chns

% Fit a repeated Measures Model within Condition-measures by freq
for p = 1:length(pair) 
    % Each frequency has (#ch) samples
    if length(CND)<4 % antagonist
    rm.(pair{p})  = fitrm(tbl_rm.(pair{p}),...
        'meas1-meas3 ~ frequency', 'WithinDesign', Meas);
    else             % regular sessions
    rm.(pair{p})  = fitrm(tbl_rm.(pair{p}),...
        'meas1-meas4 ~ frequency', 'WithinDesign', Meas);
    end
    
    % Test spericity. Checks if epsilon corrections on RANOVA test
    % are necessary or not.
    mauchlytbl.(pair{p}) = mauchly(rm.(pair{p}));

    % Run RANOVA to test for ANY difference btw Conditions. Gives 
    % original p-value and those after epsilon corrections.
    ranovatbl.(pair{p}) = ranova(rm.(pair{p}),'WithinModel','Conditions');
end

% Run Multiple comparisons
  % alpha correction for post-hoc only
  corr_alpha = alpha/((length(CND)*(length(CND)-1))*size(coherence.(pair{p}).(CND{c}),1));
for p = 1:length(pair) 
%     Mult_comp.(pair{p}).tbl = ...
%         multcompare(rm.(pair{p}), 'Conditions','By','frequency',...
%                     'Alpha', corr_alpha, 'ComparisonType', 'dunn-sidak'); %t-distr less conserv
    Mult_comp.(pair{p}).tbl = ...
       multcompare(rm.(pair{p}), 'Conditions','By','frequency',...
                    'Alpha', corr_alpha, 'ComparisonType', 'bonferroni'); %t-distr conserv
%     Mult_comp.(pair{p}).tbl = ...
%       multcompare(rm.(pair{p}), 'Conditions','By','frequency',...
%                     'Alpha', corr_alpha, 'ComparisonType', 'scheffe'); %F-distr
% 
    % Convert multiple comparisons table to array 
    % headers are: freq, Cond1, Cond2, Diff, StdErr, pValue, Lower, Upper
    Mult_comp.(pair{p}).array = table2array(Mult_comp.(pair{p}).tbl(:,2:8));
        ffs = double(table2array(Mult_comp.(pair{p}).tbl(:,1)));
    Mult_comp.(pair{p}).array = [ffs Mult_comp.(pair{p}).array];
    clear ffs
end

%% Plot Average PSD& CIs
saveplot = 0;
% Get significantly different (pv<corr_alpha) freqs to Awake measurement
for p = 1:length(pair) 
  rept = 1;
  for ff = 1:f_idx(2)
    signif_vsAwake.(pair{p}){ff} = ...
      find(Mult_comp.(pair{p}).array(rept:rept+3,2) == 1 &...
            Mult_comp.(pair{p}).array(rept:rept+3,6) <=  corr_alpha);
    rept = rept+(length(CND)*(length(CND)-1));
  end
  clear rept
end

% Create vectors to draw lines of significance vs. Awake
for p = 1:length(pair) 
sig_lin.(pair{p}) = NaN(length(CND)-1,size(coherence.(pair{p}).(CND{c}),1));
    for ff = 1:f_idx(2)
      if ~isempty(signif_vsAwake.(pair{p}){ff})
       temp = signif_vsAwake.(pair{p}){ff} == [1:length(CND)-1];
           if size(temp,1) == 1
             sig_lin.(pair{p})(:,ff) = temp;
           else
             [~, col] = find(temp==1);
             sig_lin.(pair{p})(col,ff) = 1;
           end
        temp = [];
      end
    end
sig_lin.(pair{p})(sig_lin.(pair{p})==0) = NaN;
end

% Draw
for p = 1:length(pair) 
txt = strcat((pair{p}), ' n= ', string(size(coherence.(pair{p}).Awake,2)));  
figure,
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.3, 0.225, 0.45]);
    suptitle(strcat('Coherence&CI-', coher.name, '-at-',(pair{p})));
    if strcmp(CND{3},'ROC')
        % Assign data to the different y-errorbar pairs
        y1= coherence_average.(pair{p}).Awake(1:f_idx(2),2)'; 
        y1errbar = [coherence_average.(pair{p}).Awake(1:f_idx(2),4)';...
                    coherence_average.(pair{p}).Awake(1:f_idx(2),3)'];

        y3=  coherence_average.(pair{p}).Anesthesia(1:f_idx(2),2)'; 
        y3errbar = [coherence_average.(pair{p}).Anesthesia(1:f_idx(2),4)';...
                    coherence_average.(pair{p}).Anesthesia(1:f_idx(2),3)'];

        y4=  coherence_average.(pair{p}).ROC(1:f_idx(2),2)'; 
        y4errbar = [coherence_average.(pair{p}).ROC(1:f_idx(2),4)';...
                    coherence_average.(pair{p}).ROC(1:f_idx(2),3)'];

        y5=  coherence_average.(pair{p}).ROPAP(1:f_idx(2),2)'; 
        y5errbar = [coherence_average.(pair{p}).ROPAP(1:f_idx(2),4)';...
                    coherence_average.(pair{p}).ROPAP(1:f_idx(2),3)'];

        % Draw Assigned data
        s1 = shadedErrorBarCI(0:f(end),y1,y1errbar,...
            'lineprops','-k','patchSaturation',0.2,'transparent',1);
            s1.mainLine.LineWidth = 2; 
            s1.edge(1).Color = 'none'; s1.edge(2).Color = 'none';
            hold on
        s3 = shadedErrorBarCI(0:f(end),y3,y3errbar,...
            'lineprops','-b','patchSaturation',0.2,'transparent',1); 
            s3.mainLine.LineWidth = 2;
            s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
            hold on
        s4 = shadedErrorBarCI(0:f(end),y4,y4errbar,...
          'lineprops','-r','patchSaturation',0.2,'transparent',1); 
            s4.mainLine.LineWidth = 2;
            s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
            hold on
        s5 = shadedErrorBarCI(0:f(end),y5,y5errbar,...
            'lineprops','-c','patchSaturation',0.2,'transparent',1);
            s5.mainLine.LineWidth = 2;
            s5.edge(1).Color = 'none'; s5.edge(2).Color = 'none';
            hold on

    elseif strcmp(CND{3},'Antagonist')
        % Assign data to the different y-errorbar pairs
        y1= power_average.(pair{p}).Awake(1:f_idx(2),2)'; 
        y1errbar = [power_average.(pair{p}).Awake(1:f_idx(2),4)';...
                    power_average.(pair{p}).Awake(1:f_idx(2),3)'];

        y3=  power_average.(pair{p}).Anesthesia(1:f_idx(2),2)'; 
        y3errbar = [power_average.(pair{p}).Anesthesia(1:f_idx(2),4)';...
                    power_average.(pair{p}).Anesthesia(1:f_idx(2),3)'];

        y4=  power_average.(pair{p}).Antagonist(1:f_idx(2),2)'; 
        y4errbar = [power_average.(pair{p}).Antagonist(1:f_idx(2),4)';...
                    power_average.(pair{p}).Antagonist(1:f_idx(2),3)'];

        % Draw Assigned data
        s1 = shadedErrorBarCI(0:f(end),y1,y1errbar,...
            'lineprops','-k','patchSaturation',0.2,'transparent',1);
            s1.mainLine.LineWidth = 2; 
            s1.edge(1).Color = 'none'; s1.edge(2).Color = 'none';
            hold on
        s3 = shadedErrorBarCI(0:f(end),y3,y3errbar,...
            'lineprops','-b','patchSaturation',0.2,'transparent',1); 
            s3.mainLine.LineWidth = 2;
            s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
            hold on
        s4 = shadedErrorBarCI(0:f(end),y4,y4errbar,...
          'lineprops','-c','patchSaturation',0.2,'transparent',1); 
            s4.mainLine.LineWidth = 2;
            s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
            hold on
    end

    xlim([0.5 58]);
    ylim([-0.1 1]);
    xticks([0.5 10 20 30 40 50]);
    %yticks();
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    hold on

    % Now paint the significant points
    % Maximun of 3 lines (Anesth, ROC, ROPAP) or (Anesth, Antagonist)
    if strcmp(CND{3},'ROC')
        scatter(0:f(end),...
                sig_lin.(pair{p})(1,1:f_idx(2))-1.07, 40, 'sb', 'filled'), hold on
        scatter(0:f(end),...
                sig_lin.(pair{p})(2,1:f_idx(2))-1.04, 40, 'sr', 'filled'), hold on
        scatter(0:f(end),...
                sig_lin.(pair{p})(3,1:f_idx(2))-1.01, 40, 'sc', 'filled'), hold on
    elseif strcmp(CND{3},'Antagonist')
        scatter(0:f(end),...
                sig_lin.(pair{p})(1,1:f_idx(2))-0.3, 40, 'sb', 'filled'), hold on
        scatter(0:f(end),...
                sig_lin.(pair{p})(2,1:f_idx(2))-0.2, 40, 'sc', 'filled'), hold on
    end
    
    text(40,0.9,txt,'FontSize',14)
    
    if saveplot == 1
        saveas(gcf,(strcat(coher.name,'_',(pair{p}),'.fig')),'fig');
        saveas(gcf,(strcat(coher.name,'_',(pair{p}),'.jpg')));
    end
end
end
