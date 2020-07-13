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
fs = 1000;
f_idx = [1 63];
alpha = 0.05;
isantag = 0;
%     CND = [{'Awake'} {'Anesthesia'}  {'Antagonist'}]; 
    CND = [{'Awake'} {'Anesthesia'} {'ROC'} {'ROPAP'}];

%% Extract filtered LFP epochs per channel, calculate their spectrum, 
lfpdata.location = strcat('L:\Project2\Data\', animal, '\LFP\', drug);
lfpdata.files = dir([lfpdata.location, '\*_str.mat']);

for j = 1:length(lfpdata.files)
  cd(lfpdata.location); 
  lfpdata.name = lfpdata.files(j).name;
  load(strcat(lfpdata.location,'\',lfpdata.name), 'LFPdata', 'DataArray', ...
      'Anesthesia', 'startAnesthesiaTime', 'endAnesthesiaTime', 'sessionInfo');  
  
  spectra.name = [lfpdata.name(1:7), '-spectra'];
  spectra.folder = strcat('L:\Project2\Results\Spectral\',...
      animal, '\', drug,'\',lfpdata.name(1:7));
  mkdir(spectra.folder)

  % Filtering 60Hz, not too strong
  d = designfilt('bandstopiir','FilterOrder',2, ...         
               'HalfPowerFrequency1',59.5,'HalfPowerFrequency2',60.5, ... 
               'DesignMethod','butter','SampleRate',fs);
           
  cd(spectra.folder)  
% Find and Filter (filtfilt) selected time-epochs for each channel
  for r = 1:3 
    n_channels.(ROI{r}) = size(LFPdata.(ROI{r}),2);
    for ch = 1:size(LFPdata.(ROI{r}),2)
        
        if strcmp(CND{3},'ROC')
        epoch.(ROI{r}).Awake(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((startAnesthesiaTime-60.0001)*fs:(startAnesthesiaTime)*fs-1,ch));
        epoch.(ROI{r}).Anesthesia(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((endAnesthesiaTime-360.0001)*fs:(endAnesthesiaTime-300)*fs-1,ch));
        epoch.(ROI{r}).ROC(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.rocTime)*fs:(sessionInfo.rocTime+60.0001)*fs-1,ch));
        epoch.(ROI{r}).ROPAP(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((sessionInfo.ropapTime)*fs:(sessionInfo.ropapTime+60.0001)*fs-1,ch)); %+300 
        
        elseif strcmp(CND{3},'Antagonist')
        epoch.(ROI{r}).Awake(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((startAnesthesiaTime-60.0001)*fs:(startAnesthesiaTime)*fs-1,ch));
        epoch.(ROI{r}).Anesthesia(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((endAnesthesiaTime-2160.0001)*fs:(endAnesthesiaTime-2100)*fs-1,ch));
        epoch.(ROI{r}).Antagonist(:,ch) = filtfilt(d,LFPdata.(ROI{r})...
            ((startAnesthesiaTime+1859.9999)*fs:(startAnesthesiaTime+1920)*fs-1,ch));
        end
    end
    
    for c = 1:length(CND)
     [power_spectrum.(ROI{r}).(CND{c}), freqs.(ROI{r}).(CND{c})] =...
            pwelch(epoch.(ROI{r}).(CND{c}), 1*fs, [], [], fs);

     % Transform data to dB (logarithmic transformation)
       power_spectrum.(ROI{r}).(CND{c}) = pow2db(power_spectrum.(ROI{r}).(CND{c}));
     % Average the spectra across channels 
       power_average.(ROI{r}).(CND{c}) = nanmean(power_spectrum.(ROI{r}).(CND{c}),2);

     % fit the single ch data to extract mu & CIs.
     sprintf('Condition: %s', (CND{c})) 
     disp('Test Name                  Test Statistic   p-value   Normality (1:Normal,0:Not Normal)')
     disp('-----------------------    --------------  ---------  --------------------------------')
     for f = 1:f_idx(2)
        try 
        % Test for Normality
        Norm_Results.(ROI{r}).(CND{c}){f} = ...
            normalitytest(power_spectrum.(ROI{r}).(CND{c})(f,:),alpha,0);
        fprintf('Shapiro-Wilk Test            %6.4f \t   %6.4f             %1.0f \r',...
            Norm_Results.(ROI{r}).(CND{c}){f}(7,1),...
            Norm_Results.(ROI{r}).(CND{c}){f}(7,2),...
            Norm_Results.(ROI{r}).(CND{c}){f}(7,3))
        fprintf('KS Limiting Form test        %6.4f \t   %6.4f             %1.0f \r',...
            Norm_Results.(ROI{r}).(CND{c}){f}(1,1),...
            Norm_Results.(ROI{r}).(CND{c}){f}(1,2),...
            Norm_Results.(ROI{r}).(CND{c}){f}(1,3))

        % When no-normal, search best fit
        if Norm_Results.(ROI{r}).(CND{c}){f}(7,3) == 0
            fit_F.(ROI{r}).(CND{c}){f} =...
                fitmethis(abs(power_spectrum.(ROI{r}).(CND{c})(f,:)),...
                'dtype','continous','figure','off','output','off');
            fprintf('-> Best fit is "%s" \r',fit_F.(ROI{r}).(CND{c}){f}(1).name)                
        end
        
        % Normally, all data will be normal, so:
        % Fit the data to 'Distribution' to obtain mu and CI
            temp{1,1} = fitdist(power_spectrum.(ROI{r}).(CND{c})(f,:)','Normal'); 
        catch
            Norm_Results.(ROI{r}).(CND{c}){f} = [];
            fit_F.(ROI{r}).(CND{c}){f} = [];
            temp = NaN;
        end

        if iscell(temp)
            tempci = paramci(temp{1,1}); % store CIntervals temporally
            power_average.(ROI{r}).(CND{c})(f,2) = temp{1,1}.mu;   % Get mu
            power_average.(ROI{r}).(CND{c})(f,3:4) = tempci(:,1)'; % Get CIntervals
        else
            tempci = NaN(2,2);                             
            power_average.(ROI{r}).(CND{c})(f,2) = NaN;
            power_average.(ROI{r}).(CND{c})(f,3:4) = tempci(:,1)'; 
        end
        temp = [];
        tempci= [];
     end  
    end
  end
  clear temp tempci i j n freq
  
  save([spectra.name,'.mat'], 'LFPdata', 'sessionInfo', 'startAnesthesiaTime', ...
      'endAnesthesiaTime','animal','DataArray','Anesthesia','drug','Norm_Results',...
      'freqs','power_average','power_spectrum','epoch','n_channels')

%% Repeated Measures ANOVA 'fitrm(t,modelspec)'
% Inside a struct per array, build the data table as 
%   [sess  freq   ch    Meas1   ...   MeasX;
%    1       1    1       dB    ...    dB   ;
%    1       2    2       dB    ...    dB   ;
%    ...         ...            ...         ;
%    2       1    3       dB    ...    dB   ;
%    ...         ...            ...         ;
%    3       1    ch      dB    ...    dB   ;
for r = 1:3
rept = 0;
  for f = 1:f_idx(2)
    for ch = 1:size(power_spectrum.(ROI{r}).(CND{c}),2)
      rept = rept+1;
      freq.(ROI{r}){rept,1} = num2str(f,'%02d');
      chns.(ROI{r}){rept,1} = int2str(ch);
        for c = 1:length(CND)
          t_rm.(ROI{r})(rept,c) =...
                power_spectrum.(ROI{r}).(CND{c})(f,ch);
        end
    end
  end
  
  % make table for the rm model
  varnames.(ROI{r}){1,1} = 'frequency';
  varnames.(ROI{r}){1,2} = 'channel';
  for i = 3:length(CND)+2
       v = strcat('meas',num2str(i-2));
       varnames.(ROI{r}){1,i} = v;
  end
  
  atbl_rm.(ROI{r}) = table(freq.(ROI{r}),chns.(ROI{r}),'VariableNames',varnames.(ROI{r})(1,1:2));
      atbl_rm.(ROI{r}).frequency = categorical(atbl_rm.(ROI{r}).frequency);
      atbl_rm.(ROI{r}).channel = categorical(atbl_rm.(ROI{r}).channel);
  btbl_rm.(ROI{r}) = array2table(t_rm.(ROI{r}), 'VariableNames',varnames.(ROI{r})(1,3:end));
  tbl_rm.(ROI{r}) = [atbl_rm.(ROI{r}) btbl_rm.(ROI{r})];
  clear atbl_rm btbl_rm 
end
Meas = table([1:length(CND)]','VariableNames',{'Conditions'});
clear conds rept t_rm varnames v freq chns

% Fit a repeated Measures Model within Condition-measures by freq
for r = 1:3
    % Each frequency has (#ch) samples
    if length(CND)<4 % antagonist
    rm.(ROI{r})  = fitrm(tbl_rm.(ROI{r}),...
        'meas1-meas3 ~ frequency', 'WithinDesign', Meas);
    else             % regular sessions
    rm.(ROI{r})  = fitrm(tbl_rm.(ROI{r}),...
        'meas1-meas4 ~ frequency', 'WithinDesign', Meas);
    end
    
    % Test spericity. Checks if epsilon corrections on RANOVA test
    % are necessary or not.
    mauchlytbl.(ROI{r}) = mauchly(rm.(ROI{r}));

    % Run RANOVA to test for ANY difference btw Conditions. Gives 
    % original p-value and those after epsilon corrections.
    ranovatbl.(ROI{r}) = ranova(rm.(ROI{r}),'WithinModel','Conditions');
end

% Run Multiple comparisons
  % alpha correction for post-hoc only
  corr_alpha = alpha/((length(CND)*(length(CND)-1))*f_idx(2));
for r = 1:3
%     Mult_comp.(ROI{r}).tbl = ...
%         multcompare(rm.(ROI{r}), 'Conditions','By','frequency',...
%                     'Alpha', corr_alpha, 'ComparisonType', 'dunn-sidak'); %t-distr less conserv
    Mult_comp.(ROI{r}).tbl = ...
       multcompare(rm.(ROI{r}), 'Conditions','By','frequency',...
                    'Alpha', corr_alpha, 'ComparisonType', 'bonferroni'); %t-distr conserv
%     Mult_comp.(ROI{r}).tbl = ...
%       multcompare(rm.(ROI{r}), 'Conditions','By','frequency',...
%                     'Alpha', corr_alpha, 'ComparisonType', 'scheffe'); %F-distr
% 
    % Convert multiple comparisons table to array 
    % headers are: freq, Cond1, Cond2, Diff, StdErr, pValue, Lower, Upper
    Mult_comp.(ROI{r}).array = table2array(Mult_comp.(ROI{r}).tbl(:,2:8));
        ffs = double(table2array(Mult_comp.(ROI{r}).tbl(:,1)));
    Mult_comp.(ROI{r}).array = [ffs Mult_comp.(ROI{r}).array];
    clear ffs
end

%% Plot Average PSD& CIs
saveplot = 0;
% Get significantly different (pv<corr_alpha) freqs to Awake measurement
for r = 1:3
  rept = 1;
  for f = 1:f_idx(2)
    signif_vsAwake.(ROI{r}){f} = ...
      find(Mult_comp.(ROI{r}).array(rept:rept+3,2) == 1 &...
            Mult_comp.(ROI{r}).array(rept:rept+3,6) <=  corr_alpha);
    rept = rept+(length(CND)*(length(CND)-1));
  end
  clear rept
end
% Create vectors to draw lines of significance vs. Awake
for r = 1:3
sig_lin.(ROI{r}) = NaN(length(CND)-1,f_idx(2));
    for f = 1:f_idx(2)
      if ~isempty(signif_vsAwake.(ROI{r}){f})
       temp = signif_vsAwake.(ROI{r}){f} == [1:length(CND)-1];
           if size(temp,1) == 1
             sig_lin.(ROI{r})(:,f) = temp;
           else
             [~, col] = find(temp==1);
             sig_lin.(ROI{r})(col,f) = 1;
           end
        temp = [];
      end
    end
sig_lin.(ROI{r})(sig_lin.(ROI{r})==0) = NaN;
end
% Draw
for r = 1:3
txt = strcat((ROI{r}), ' n= ', string(n_channels.(ROI{r})));
figure,
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.3, 0.225, 0.45]);
    suptitle(strcat('PS&CI-', spectra.name, '-at-', ROI{r}));
    if strcmp(CND{3},'ROC')
        % Assign data to the different y-errorbar pairs
        y1= power_average.(ROI{r}).Awake(1:f_idx(2),2)'; 
        y1errbar = [power_average.(ROI{r}).Awake(1:f_idx(2),4)';...
                    power_average.(ROI{r}).Awake(1:f_idx(2),3)'];

        y3=  power_average.(ROI{r}).Anesthesia(1:f_idx(2),2)'; 
        y3errbar = [power_average.(ROI{r}).Anesthesia(1:f_idx(2),4)';...
                    power_average.(ROI{r}).Anesthesia(1:f_idx(2),3)'];

        y4=  power_average.(ROI{r}).ROC(1:f_idx(2),2)'; 
        y4errbar = [power_average.(ROI{r}).ROC(1:f_idx(2),4)';...
                    power_average.(ROI{r}).ROC(1:f_idx(2),3)'];

        y5=  power_average.(ROI{r}).ROPAP(1:f_idx(2),2)'; 
        y5errbar = [power_average.(ROI{r}).ROPAP(1:f_idx(2),4)';...
                    power_average.(ROI{r}).ROPAP(1:f_idx(2),3)'];

        % Draw Assigned data
        s1 = shadedErrorBarCI(freqs.(ROI{r}).Awake(1:f_idx(2)),y1,y1errbar,...
            'lineprops','-k','patchSaturation',0.2,'transparent',1);
            s1.mainLine.LineWidth = 2; 
            s1.edge(1).Color = 'none'; s1.edge(2).Color = 'none';
            hold on
        s3 = shadedErrorBarCI(freqs.(ROI{r}).Anesthesia(1:f_idx(2)),y3,y3errbar,...
            'lineprops','-b','patchSaturation',0.2,'transparent',1); 
            s3.mainLine.LineWidth = 2;
            s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
            hold on
        s4 = shadedErrorBarCI(freqs.(ROI{r}).ROC(1:f_idx(2)),y4,y4errbar,...
          'lineprops','-r','patchSaturation',0.2,'transparent',1); 
            s4.mainLine.LineWidth = 2;
            s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
            hold on
        s5 = shadedErrorBarCI(freqs.(ROI{r}).ROPAP(1:f_idx(2)),y5,y5errbar,...
            'lineprops','-c','patchSaturation',0.2,'transparent',1);
            s5.mainLine.LineWidth = 2;
            s5.edge(1).Color = 'none'; s5.edge(2).Color = 'none';
            hold on

    elseif strcmp(CND{3},'Antagonist')
        % Assign data to the different y-errorbar pairs
        y1= power_average.(ROI{r}).Awake(1:f_idx(2),2)'; 
        y1errbar = [power_average.(ROI{r}).Awake(1:f_idx(2),4)';...
                    power_average.(ROI{r}).Awake(1:f_idx(2),3)'];

        y3=  power_average.(ROI{r}).Anesthesia(1:f_idx(2),2)'; 
        y3errbar = [power_average.(ROI{r}).Anesthesia(1:f_idx(2),4)';...
                    power_average.(ROI{r}).Anesthesia(1:f_idx(2),3)'];

        y4=  power_average.(ROI{r}).Antagonist(1:f_idx(2),2)'; 
        y4errbar = [power_average.(ROI{r}).Antagonist(1:f_idx(2),4)';...
                    power_average.(ROI{r}).Antagonist(1:f_idx(2),3)'];

        % Draw Assigned data
        s1 = shadedErrorBarCI(freqs.(ROI{r}).Awake(1:f_idx(2)),y1,y1errbar,...
            'lineprops','-k','patchSaturation',0.2,'transparent',1);
            s1.mainLine.LineWidth = 2; 
            s1.edge(1).Color = 'none'; s1.edge(2).Color = 'none';
            hold on
        s3 = shadedErrorBarCI(freqs.(ROI{r}).Anesthesia(1:f_idx(2)),y3,y3errbar,...
            'lineprops','-b','patchSaturation',0.2,'transparent',1); 
            s3.mainLine.LineWidth = 2;
            s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
            hold on
        s4 = shadedErrorBarCI(freqs.(ROI{r}).Antagonist(1:f_idx(2)),y4,y4errbar,...
          'lineprops','-c','patchSaturation',0.2,'transparent',1); 
            s4.mainLine.LineWidth = 2;
            s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
            hold on
    end

    xlim([0.5 58]);
    ylim([-70 -16]);
    xticks([0.5 10 20 30 40 50]);
    %yticks();
    xlabel('Frequency (Hz)');
    ylabel('Power (dB)');
    hold on

    % Now paint the significant points
    % Maximun of 3 lines (Anesth, ROC, ROPAP) or (Anesth, Antagonist)
    if strcmp(CND{3},'ROC')
        scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                sig_lin.(ROI{r})(1,2:f_idx(2))-66, 40, 'sb', 'filled'), hold on
        scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                sig_lin.(ROI{r})(2,2:f_idx(2))-67, 40, 'sr', 'filled'), hold on
        scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                sig_lin.(ROI{r})(3,2:f_idx(2))-68, 40, 'sc', 'filled'), hold on
    elseif strcmp(CND{3},'Antagonist')
        scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                sig_lin.(ROI{r})(1,2:f_idx(2))-67, 40, 'sb', 'filled'), hold on
        scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                sig_lin.(ROI{r})(2,2:f_idx(2))-68, 40, 'sc', 'filled'), hold on
    end
    
    text(40,-22,txt,'FontSize',14)
    
    if saveplot == 1
        saveas(gcf,(strcat(spectra.name,'_',(ROI{r}),'.fig')),'fig');
        saveas(gcf,(strcat(spectra.name,'_',(ROI{r}),'.jpg')));
    end
end
  
%% Plot PSD Change&CIs + Sig_diff vs Anesth.
        % Get significantly different (pv<corr_alpha) freqs to Anesth measurement
        for r = 1:3
          if strcmp(CND{3},'ROC'),            rept = 5;
          elseif strcmp(CND{3},'Antagonist'), rept = 4; end
          for f = 1:f_idx(2)
            signif_vsAnesth.(ROI{r}){f} = ...
              find(Mult_comp.(ROI{r}).array(rept:rept+1,2) == 2 &...
                    Mult_comp.(ROI{r}).array(rept:rept+1,6) <=  corr_alpha);
            rept = rept+(length(CND)*(length(CND)-1));
          end
          clear rept
        end
        % Create vectors to draw lines of significance vs. Awake
        for r = 1:3
        sig_lin2.(ROI{r}) = NaN(length(CND)-2,f_idx(2));
            for f = 1:f_idx(2)
              if ~isempty(signif_vsAnesth.(ROI{r}){f})
               temp = signif_vsAnesth.(ROI{r}){f} == [1:length(CND)-2];
                   if size(temp,1) == 1
                     sig_lin2.(ROI{r})(:,f) = temp;
                   else
                     [~, col] = find(temp==1);
                     sig_lin2.(ROI{r})(col,f) = 1;
                   end
                temp = [];
              end
            end
        sig_lin2.(ROI{r})(sig_lin2.(ROI{r})==0) = NaN;
        end
        % Draw
        for r = 1:3
        txt = strcat((ROI{r}), ' n=', string(n_channels.(ROI{r})));
        figure,
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.3, 0.225, 0.45]);
            suptitle(strcat('PS diff&CI ', spectra.name, ' at ', ROI{r}));
            s1 = line(0:f_idx(2),zeros(1,f_idx(2)+1)); 
                s1.Color = 'black';
                s1.LineStyle = '--';
                s1.LineWidth = 2;

            if strcmp(CND{3},'ROC')
                maxcomb = (length(CND)*(length(CND)-1));
                % Assign data to the different y-errorbar pairs
                y3=  Mult_comp.(ROI{r}).array(1:12:end,4)'; 
                y3errbar = [Mult_comp.(ROI{r}).array(1:maxcomb:end,8)'; ...
                            Mult_comp.(ROI{r}).array(1:maxcomb:end,7)';];

                y4=  Mult_comp.(ROI{r}).array(2:maxcomb:end,4)'; 
                y4errbar = [Mult_comp.(ROI{r}).array(2:maxcomb:end,8)';...
                            Mult_comp.(ROI{r}).array(2:maxcomb:end,7)'];

                y5=  Mult_comp.(ROI{r}).array(3:maxcomb:end,4)'; 
                y5errbar = [Mult_comp.(ROI{r}).array(3:maxcomb:end,8)';...
                            Mult_comp.(ROI{r}).array(3:maxcomb:end,7)'];

                % Draw Assigned data
                s3 = shadedErrorBarCI(freqs.(ROI{r}).Anesthesia(1:f_idx(2)),-y3,-y3errbar,...
                    'lineprops','-b','patchSaturation',0.2,'transparent',1); 
                    s3.mainLine.LineWidth = 2;
                    s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
                    hold on
                s4 = shadedErrorBarCI(freqs.(ROI{r}).ROC(1:f_idx(2)),-y4,-y4errbar,...
                  'lineprops','-r','patchSaturation',0.2,'transparent',1); 
                    s4.mainLine.LineWidth = 2;
                    s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
                    hold on
                s5 = shadedErrorBarCI(freqs.(ROI{r}).ROPAP(1:f_idx(2)),-y5,-y5errbar,...
                    'lineprops','-c','patchSaturation',0.3,'transparent',1);
                    s5.mainLine.LineWidth = 2;
                    s5.edge(1).Color = 'none'; s5.edge(2).Color = 'none';
                    hold on

            elseif strcmp(CND{3},'Antagonist')
                maxcomb = (length(CND)*(length(CND)-1));
                % Assign data to the different y-errorbar pairs
                y3=  Mult_comp.(ROI{r}).array(1:maxcomb:end,4)'; 
                y3errbar = [Mult_comp.(ROI{r}).array(1:maxcomb:end,8)'; ...
                            Mult_comp.(ROI{r}).array(1:maxcomb:end,7)';];

                y4=  Mult_comp.(ROI{r}).array(2:maxcomb:end,4)'; 
                y4errbar = [Mult_comp.(ROI{r}).array(2:maxcomb:end,8)';...
                            Mult_comp.(ROI{r}).array(2:maxcomb:end,7)'];

                % Draw Assigned data
                s3 = shadedErrorBarCI(freqs.(ROI{r}).Anesthesia(1:f_idx(2)),-y3,-y3errbar,...
                    'lineprops','-b','patchSaturation',0.2,'transparent',1); 
                    s3.mainLine.LineWidth = 2;
                    s3.edge(1).Color = 'none'; s3.edge(2).Color = 'none';
                    hold on
                s4 = shadedErrorBarCI(freqs.(ROI{r}).Antagonist(1:f_idx(2)),-y4,-y4errbar,...
                  'lineprops','-c','patchSaturation',0.2,'transparent',1); 
                    s4.mainLine.LineWidth = 2;
                    s4.edge(1).Color = 'none'; s4.edge(2).Color = 'none';
                    hold on
            end

            xlim([0 58]);
            ylim([-17 20]);
            xticks([0.5 10 20 30 40 50]);
            %yticks();
            xlabel('Frequency (Hz)');
            ylabel('Power change vs. Awake (dB)');
            hold on

            % Now paint the significant points
            % Maximun of 2 lines (ROC, ROPAP) or (Antagonist)
            if strcmp(CND{3},'ROC')
                scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                        sig_lin2.(ROI{r})(1,2:f_idx(2))-16, 40, 'sr', 'filled'), hold on
                scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                        sig_lin2.(ROI{r})(2,2:f_idx(2))-17, 40, 'sc', 'filled'), hold on
            elseif strcmp(CND{3},'Antagonist')
                scatter(freqs.(ROI{r}).Awake(2:f_idx(2)),...
                        sig_lin2.(ROI{r})(1,2:f_idx(2))-16, 40, 'sc', 'filled'), hold on
            end

            text(40,17,txt,'FontSize',14)

            if saveplot == 1
                saveas(gcf,(strcat(spectra.name,'_Change_',(ROI{r}),'.fig')),'fig');
                saveas(gcf,(strcat(spectra.name,'_Change_',(ROI{r}),'.jpg')));
            end
        end
  
close all
save([spectra.name,'.mat'], 'corr_alpha', 'Mult_comp', 'Meas', ...
        'tbl_rm', 'rm', 'mauchlytbl', 'ranovatbl', 'signif_vsAwake', ...
        'signif_vsAnesth', 'sig_lin', 'sig_lin2','-append')

clear corr_alpha Mult_comp tbl_rm rm mauchlytbl ranovatbl signif_vsAwake...
    signif_vsAnesth sig_lin sig_lin2 DataArray Anesthesia ...
    Norm_Results fit_F freqs power_average power_spectrum epoch c col ch ...
    y1 y3 y4 y5 y1errbar y3errbar y4errbar temp Meas maxcomb s1 s3 s4 ...
    spectra r i f 
end
