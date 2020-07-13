function plot_spindle_summary(count, ROI, averages, freqdataZmean, density, maxtchunks, sessionInfo, session, isantag, color, plotparams, times, t, saveplot)
% UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Lets plot one channel's raw trace and filtered signal.
% Below, some descriptive data from all channels per area
% and the dynamics of spindle density along the session
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


figure,
%% Traces (uncomment if desired)
% % Awake
%     subplot(5,8,[1,2]); % Raw channel 'plotparams.ch' trace
%         plot(LFPdata.(ROI{plotparams.r})...
%             (plotparams.xlimit.awake(1):plotparams.xlimit.awake(2),plotparams.ch), 'k'); 
%         xlim([0 5000]); 
%         xticklabels([]);
%         ylim([-0.5 0.5]);
%         ylabel('mV'); box off;
%         title([(ROI{plotparams.r}), ', ', int2str(plotparams.ch-1), ', ', 'Awake']);
% 
%     subplot(5,8,[9,10]);     % Filtered channel 'plotparams.ch' trace
%         plot(LFPfiltered.(ROI{plotparams.r})...
%             (plotparams.xlimit.awake(1):plotparams.xlimit.awake(2),plotparams.ch), '-k');
%         hold on;    
%         xlim([0 5000]); 
%         box off;
%         xlabel('sec'); % X, Y limits
%         xticks(1000:2000:5000); xticklabels({'1', '3', '5'});
%         ylabel('mV'); yticks([-0.05, 0, 0.05]); yticklabels({'-0.05' '0' '0.05'});
%         ylim([-0.1 0.1]);
%         
% %Anesthesia    
%     subplot(5,8,[3,4]); % Raw channel 'plotparams.ch' trace
%         plot(LFPdata.(ROI{plotparams.r})...
%             (plotparams.xlimit.anesth(1):plotparams.xlimit.anesth(2),plotparams.ch), 'k'); 
%         xlim([0 5000]); 
%         xticklabels([]);
%         ylim([-0.5 0.5]); yticks([]); yticklabels([]);
%         box off;
%         title([(ROI{plotparams.r}), ', ', int2str(plotparams.ch-1), ', ', 'Anesthesia']);
%         
%     subplot(5,8,[11,12]); % Filtered channel 'plotparams.ch' trace
%         plot(LFPfiltered.(ROI{plotparams.r})...
%             (plotparams.xlimit.anesth(1):plotparams.xlimit.anesth(2),plotparams.ch), '-k');
%         hold on;    
%         xlim([0 5000]); 
%         box off;
%         xticks(1000:2000:5000); xticklabels({'1', '3', '5'});
%         ylim([-0.1 0.1]); yticks([]); yticklabels([]);
%         xlabel('sec');
%         
%     if isantag == 0
%     % Rec.Performing
%     subplot(5,8,[5,6]); % Raw channel 'plotparams.ch' trace
%         plot(LFPdata.(ROI{plotparams.r})...
%             (plotparams.xlimit.recperforming(1):plotparams.xlimit.recperforming(2),plotparams.ch), 'k'); 
%         xlim([0 5000]); 
%         xticklabels([]);
%         ylim([-0.5 0.5]); yticks([]); yticklabels([]);
%         box off;
%         title([(ROI{plotparams.r}), ', ', int2str(plotparams.ch-1), ', ', 'Rec.Performing']);
% 
%     subplot(5,8,[13,14]);     % Filtered channel 'plotparams.ch' trace
%         plot(LFPfiltered.(ROI{plotparams.r})...
%             (plotparams.xlimit.recperforming(1):plotparams.xlimit.recperforming(2),plotparams.ch), '-k');
%         hold on;    
%         xlim([0 5000]); 
%         box off;
%         xlabel('sec'); % X, Y limits
%         xticks(1000:2000:5000); xticklabels({'1', '3', '5'});
%         ylim([-0.1 0.1]); yticks([]); yticklabels([]);
% 
%     % Rec.Non-Performing
%     subplot(5,8,[7,8]); % Raw channel 'plotparams.ch' trace
%         plot(LFPdata.(ROI{plotparams.r})...
%             (plotparams.xlimit.recnoperforming(1):plotparams.xlimit.recnoperforming(2),plotparams.ch), 'k'); 
%         xlim([0 5000]); 
%         xticklabels([]); yticks([]); yticklabels([]);
%         ylim([-0.5 0.5]); 
%         box off;
%         title([(ROI{plotparams.r}), ', ', int2str(plotparams.ch-1), ', ', 'R.Non-Perf']);
% 
%     subplot(5,8,[15,16]);     % Filtered channel 'plotparams.ch' trace
%         plot(LFPfiltered.(ROI{plotparams.r})...
%             (plotparams.xlimit.recnoperforming(1):plotparams.xlimit.recnoperforming(2),plotparams.ch), '-k');
%         hold on;    
%        xlim([0 5000]); 
%        box off;
%         xlabel('sec'); % X, Y limits
%         xticks(1000:2000:5000); xticklabels({'1', '3', '5'});
%         ylim([-0.1 0.1]); yticks([]); yticklabels([]);
%         
%     elseif isantag == 1
%     % Antagonist
%     subplot(5,8,[5,6]); % Raw channel 'plotparams.ch' trace
%         plot(LFPdata.(ROI{plotparams.r})...
%             (plotparams.xlimit.antag(1):plotparams.xlimit.antag(2),plotparams.ch), 'k'); 
%         xlim([0 5000]); 
%         xticklabels([]);
%         ylim([-0.5 0.5]); yticks([]); yticklabels([]);
%         box off;
%         title([(ROI{plotparams.r}), ', ', int2str(plotparams.ch-1), ', ', 'Antagonist']);
% 
%     subplot(5,8,[13,14]);     % Filtered channel 'plotparams.ch' trace
%         plot(LFPfiltered.(ROI{plotparams.r})...
%             (plotparams.xlimit.antag(1):plotparams.xlimit.antag(2),plotparams.ch), '-k');
%         hold on;    
%         xlim([0 5000]); 
%         box off;
%         xlabel('sec'); % X, Y limits
%         xticks(1000:2000:5000); xticklabels({'1', '3', '5'});
%         ylim([-0.1 0.1]); yticks([]); yticklabels([]);
%     end
%     
    %% Summaries  
    subplot(5,8,[9,10]); % #events 
%         errorbar(plotparams.barx-0.1, bary.S1.(bands{b})(1,1:4), bary.S1.(bands{b})(2,1:4),'-plotparams.r'); hold on
            scatter(plotparams.xscat.S1, count.S1.awake(1,:),30,'r','LineWidth',1); hold on
            scatter(plotparams.xscat.S1+1, count.S1.anesth(1,:),30,'r','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.S1+2, count.S1.recperf(1,:),30,'r','LineWidth',1); hold on
             scatter(plotparams.xscat.S1+3, count.S1.recnonperf(1,:),30,'r','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.S1+2, count.S1.antag(1,:),30,'r','LineWidth',1); hold on
            end
            
            scatter(plotparams.xscat.S2, count.S2.awake(1,:),30,'m','LineWidth',1); hold on
            scatter(plotparams.xscat.S2+1, count.S2.anesth(1,:),30,'m','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.S2+2, count.S2.recperf(1,:),30,'m','LineWidth',1); hold on
             scatter(plotparams.xscat.S2+3, count.S2.recnonperf(1,:),30,'m','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.S2+2, count.S2.antag(1,:),30,'m','LineWidth',1); hold on
            end

%         errorbar(plotparams.barx+0.1, bary.PMv.(bands{b})(1,1:4), bary.PMv.(bands{b})(2,1:4),'-b'); hold on
            scatter(plotparams.xscat.PMv, count.PMv.awake(1,:),30,'b','LineWidth',1); hold on
            scatter(plotparams.xscat.PMv+1, count.PMv.anesth(1,:),30,'b','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.PMv+2, count.PMv.recperf(1,:),30,'b','LineWidth',1); hold on
             scatter(plotparams.xscat.PMv+3, count.PMv.recnonperf(1,:),30,'b','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.PMv+2, count.PMv.antag(1,:),30,'b','LineWidth',1); hold on
            end
        box off;
        ylabel('#events');
        ylim([-10 150]);
        if isantag == 0
        xticks(1:4), xticklabels({'Awake' 'Anesth' 'Perf' 'Non-perf'}), xlim([0.5 4.5]);
        else, xticks(1:3), xticklabels({'Awake' 'Anesth' 'Antag'}), xlim([0.5 3.5]);
        end
        
    subplot(5,8,[11,12]); % average peak frequencies
%         errorbar(plotparams.barx-0.1, bary2.S1.(bands{b})(1,1:4), bary2.S1.(bands{b})(2,1:4),'-plotparams.r'); hold on
          if ~isempty(averages.S1{4,1,1}), scatter(plotparams.xscat.S1, averages.S1{4,1,1},30,'r','LineWidth',1); hold on; end
            scatter(plotparams.xscat.S1+1, averages.S1{4,1,2},30,'r','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.S1+2, averages.S1{4,1,3},30,'r','LineWidth',1); hold on
             scatter(plotparams.xscat.S1+3, averages.S1{4,1,4},30,'r','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.S1+2, averages.S1{4,1,3},30,'r','LineWidth',1); hold on
            end
%         errorbar(plotparams.barx-0.1, bary2.S1.(bands{b})(1,1:4), bary2.S1.(bands{b})(2,1:4),'-plotparams.r'); hold on
          if ~isempty(averages.S2{4,1,1}), scatter(plotparams.xscat.S2, averages.S2{4,1,1},30,'m','LineWidth',1); hold on; end
            scatter(plotparams.xscat.S2+1, averages.S2{4,1,2},30,'m','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.S2+2, averages.S2{4,1,3},30,'m','LineWidth',1); hold on
             scatter(plotparams.xscat.S2+3, averages.S2{4,1,4},30,'m','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.S2+2, averages.S2{4,1,3},30,'m','LineWidth',1); hold on
            end
%         errorbar(plotparams.barx+0.1, bary2.PMv.(bands{b})(1,1:4), bary2.PMv.(bands{b})(2,1:4),'-b'); hold on
          if ~isempty(averages.PMv{4,1,1}), scatter(plotparams.xscat.PMv, averages.PMv{4,1,1},30,'b','LineWidth',1); hold on, end
            scatter(plotparams.xscat.PMv+1, averages.PMv{4,1,2},30,'b','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.PMv+2, averages.PMv{4,1,3},30,'b','LineWidth',1); hold on
             scatter(plotparams.xscat.PMv+3, averages.PMv{4,1,4},30,'b','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.PMv+2, averages.PMv{4,1,3},30,'b','LineWidth',1); hold on
            end
        box off;
        ylabel('Peak Freq. (Hz)');
        ylim([7 20]);
        if isantag == 0
        xticks(1:4), xticklabels({'Awake' 'Anesth' 'Perf' 'Non-perf'}), xlim([0.5 4.5]);
        else, xticks(1:3), xticklabels({'Awake' 'Anesth' 'Antag'}), xlim([0.5 3.5]);
        end

    subplot(5,8,[13,14]); % Subplot for spindle duration
%         errorbar(plotparams.barx-0.1, bary.S1.(bands{b})(1,5:8), bary.S1.(bands{b})(2,5:8),'-plotparams.r'); hold on
            scatter(plotparams.xscat.S1(1:size(averages.S1{5,1,1},2)), averages.S1{5,1,1},30,'r','LineWidth',1); hold on 
            scatter(plotparams.xscat.S1(1:size(averages.S1{5,1,2},2))+1, averages.S1{5,1,2},30,'r','LineWidth',1); hold on 
            if isantag == 0
             scatter(plotparams.xscat.S1(1:size(averages.S1{5,1,3},2))+2, averages.S1{5,1,3},30,'r','LineWidth',1); hold on 
             scatter(plotparams.xscat.S1(1:size(averages.S1{5,1,4},2))+3, averages.S1{5,1,4},30,'r','LineWidth',1); hold on 
            else
             scatter(plotparams.xscat.S1(1:size(averages.S1{5,1,3},2))+2, averages.S1{5,1,3},30,'r','LineWidth',1); hold on
            end
            
            scatter(plotparams.xscat.S2(1:size(averages.S2{5,1,1},2)), averages.S2{5,1,1},30,'m','LineWidth',1); hold on
            scatter(plotparams.xscat.S2(1:size(averages.S2{5,1,2},2))+1, averages.S2{5,1,2},30,'m','LineWidth',1); hold on 
            if isantag == 0
             scatter(plotparams.xscat.S2(1:size(averages.S2{5,1,3},2))+2, averages.S2{5,1,3},30,'m','LineWidth',1); hold on 
             scatter(plotparams.xscat.S2(1:size(averages.S2{5,1,4},2))+3, averages.S2{5,1,4},30,'m','LineWidth',1); hold on 
            else
             scatter(plotparams.xscat.S2(1:size(averages.S2{5,1,3},2))+2, averages.S2{5,1,3},30,'m','LineWidth',1); hold on
            end

%         errorbar(plotparams.barx+0.1, bary.PMv.(bands{b})(1,5:8), bary.PMv.(bands{b})(2,5:8),'-b'); hold on
            scatter(plotparams.xscat.PMv(1:size(averages.PMv{5,1,1},2)), averages.PMv{5,1,1},30,'b','LineWidth',1); hold on 
            scatter(plotparams.xscat.PMv(1:size(averages.PMv{5,1,2},2))+1, averages.PMv{5,1,2},30,'b','LineWidth',1); hold on 
            if isantag == 0
             scatter(plotparams.xscat.PMv(1:size(averages.PMv{5,1,3},2))+2, averages.PMv{5,1,3},30,'b','LineWidth',1); hold on 
             scatter(plotparams.xscat.PMv(1:size(averages.PMv{5,1,4},2))+3, averages.PMv{5,1,4},30,'b','LineWidth',1); hold on 
            else
             scatter(plotparams.xscat.PMv(1:size(averages.PMv{5,1,3},2))+2, averages.PMv{5,1,3},30,'b','LineWidth',1); hold on
            end
        box off;
        ylabel('Event dur. (sec)');
        ylim([0 2]);
        if isantag == 0
        xticks(1:4), xticklabels({'Awake' 'Anesth' 'Perf' 'Non-perf'}), xlim([0.5 4.5]);
        else, xticks(1:3), xticklabels({'Awake' 'Anesth' 'Antag'}), xlim([0.5 3.5]);
        end
        
     subplot(5,8,[15,16]); % Ocurrence of events/min
%         errorbar(plotparams.barx-0.1, bary3.S1.(bands{b})(1,1:4), bary3.S1.(bands{b})(2,1:4),'-plotparams.r'); hold on
             scatter(plotparams.xscat.S1, averages.S1{3,1,1},30,'r','LineWidth',1); hold on
             scatter(plotparams.xscat.S1+1, averages.S1{3,1,2},30,'r','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.S1+2, averages.S1{3,1,3},30,'r','LineWidth',1); hold on
             scatter(plotparams.xscat.S1+3, averages.S1{3,1,4},30,'r','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.S1+2, averages.S1{3,1,3},30,'r','LineWidth',1); hold on
            end
            
            scatter(plotparams.xscat.S2, averages.S2{3,1,1},30,'m','LineWidth',1); hold on
             scatter(plotparams.xscat.S2+1, averages.S2{3,1,2},30,'m','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.S2+2, averages.S2{3,1,3},30,'m','LineWidth',1); hold on
             scatter(plotparams.xscat.S2+3, averages.S2{3,1,4},30,'m','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.S2+2, averages.S2{3,1,3},30,'m','LineWidth',1); hold on
            end

%         errorbar(plotparams.barx+0.1, bary3.PMv.(bands{b})(1,1:4), bary3.PMv.(bands{b})(2,1:4),'-b'); hold on
             scatter(plotparams.xscat.PMv, averages.PMv{3,1,1},30,'b','LineWidth',1); hold on
             scatter(plotparams.xscat.PMv+1, averages.PMv{3,1,2},30,'b','LineWidth',1); hold on
            if isantag == 0
             scatter(plotparams.xscat.PMv+2, averages.PMv{3,1,3},30,'b','LineWidth',1); hold on
             scatter(plotparams.xscat.PMv+3, averages.PMv{3,1,4},30,'b','LineWidth',1); hold on
            else
             scatter(plotparams.xscat.PMv+2, averages.PMv{3,1,3},30,'b','LineWidth',1); hold on
            end
        box off;
        ylabel('events/min');
        ylim([-2 15]);
        if isantag == 0
        xticks(1:4), xticklabels({'Awake' 'Anesth' 'Perf' 'Non-perf'}), xlim([0.5 4.5]);
        else, xticks(1:3), xticklabels({'Awake' 'Anesth' 'Antag'}), xlim([0.5 3.5]);
        end
      
     subplot(5,8,25:32); % Ocurrence progression (min-1) plus behavior
        sh1 = shadedErrorBar([1:maxtchunks]', mean(density.S1.all,2),...
            std(density.S1.all,0,2),'lineProps', '-r', 'patchSaturation',0.1,'transparent',1); hold on
        sh2 = shadedErrorBar([1:maxtchunks]', mean(density.PMv.all,2),...
            std(density.PMv.all,0,2),'lineProps', '-b', 'patchSaturation',0.1,'transparent',1); hold on
        sh3 = shadedErrorBar([1:maxtchunks]', mean(density.S2.all,2),...
            std(density.S2.all,0,2),'lineProps', '-m', 'patchSaturation',0.1,'transparent',1); hold on

        sh1.mainLine.LineWidth = 2;
        sh2.mainLine.LineWidth = 2;
        sh3.mainLine.LineWidth = 2;
        
         % Infusion period
         line([sessionInfo.startAnesthesiaTime/60, sessionInfo.startAnesthesiaTime/60],...
             [0 60], 'color', 'k', 'linewidth', 1.5, 'linestyle', ':');
         line([sessionInfo.endAnesthesiaTime/60, sessionInfo.endAnesthesiaTime/60],...
             [0 60], 'color', 'k', 'linewidth', 1.5, 'linestyle', ':');

         % Analysis periods
         line([times.startAnesth/60000-10, times.startAnesth/60000], [20, 20], 'color', 'k', 'linewidth', 1, 'linestyle', '-');
         line([times.endAnesth/60000-10, times.endAnesth/60000], [20, 20], 'color', 'k', 'linewidth', 1, 'linestyle', '-');
         if isantag == 1
           line([times.startAntag/60000+2, times.startAntag/60000+12], [20, 20], 'color', 'k', 'linewidth', 1, 'linestyle', '-');
           txt = [{'Awake'} {'Anesthesia'} {'Antagonist'}];
           text(times.startAntag/60000+2,22,txt(3));
         elseif isantag == 0
           line([times.recperf/60000-times.trecperf, times.recperf/60000], [20, 20], 'color', 'k', 'linewidth', 1, 'linestyle', '-');
           line([times.recnonperf/60000-times.trecnonperf, times.recnonperf/60000], [20, 20], 'color', 'k', 'linewidth', 1, 'linestyle', '-');
           txt = [{'Awake'} {'Anesthesia'} {'R.Perf'} {'R.NonPerf'}];
           text(times.recperf/60000-times.trecperf,22,txt(3));
           text(times.recnonperf/60000-times.trecnonperf,22,txt(4));
         end 
         
         text(times.startAnesth/60000-10,22,txt(1));
         text(times.endAnesth/60000-10,22,txt(2));

        box off;
        ylabel('events/min');   xlabel('min');
        ylim([0 20]);         xlim([1 maxtchunks-2]);
        xticks([0:30:maxtchunks]);
        yticks([-4 -2 0 5 10 15 20]);
        yticklabels({'0' '1' '0' '5' '10' '15' '20'});
        hold off;

        % Behavior 
     subplot(5,8,17:24); 
        if length(sessionInfo.trialTimes) < length(sessionInfo.bEngage)
          plot(sessionInfo.trialTimes,sessionInfo.bEngage(1:length(sessionInfo.trialTimes),3),...
              'color', color.purple, 'linewidth', 2);
          plot(sessionInfo.trialTimes,sessionInfo.bPerform(1:length(sessionInfo.trialTimes),3),...
              'color', color.orange, 'linewidth', 2);
         elseif length(sessionInfo.bEngage) < length(sessionInfo.trialTimes)
          plot(sessionInfo.trialTimes(1:length(sessionInfo.bEngage)),sessionInfo.bEngage(:,3),...
              'color', color.purple, 'linewidth', 2);
          plot(sessionInfo.trialTimes(1:length(sessionInfo.bEngage)),sessionInfo.bPerform(:,3),...
              'color', color.orange, 'linewidth', 2);
         elseif length(sessionInfo.trialTimes) == length(sessionInfo.bEngage)
          plot(sessionInfo.trialTimes/60,(sessionInfo.bEngage(:,3)), 'color', color.purple, 'linewidth', 2); hold on
          plot(sessionInfo.trialTimes/60,(sessionInfo.bPerform(:,3)), 'color', color.orange, 'linewidth', 2);
        end
        
         % Infusion period
         line([sessionInfo.startAnesthesiaTime/60, sessionInfo.startAnesthesiaTime/60],...
             [0 1], 'color', 'k', 'linewidth', 1.5, 'linestyle', ':');
         line([sessionInfo.endAnesthesiaTime/60, sessionInfo.endAnesthesiaTime/60],...
             [0 1], 'color', 'k', 'linewidth', 1.5, 'linestyle', ':');
       box off;
        ylim([0 1]);         xlim([1 maxtchunks-2]);
        xticks([0:30:maxtchunks]);
        yticks([0 1]);
        hold off;
        
    subplot(5,8,33:40); % Normalized Alpha power
        plot(t(1:2:end)', freqdataZmean.S1((1:2:end),3),'-r','linewidth', 1.5);
            hold on
        plot(t(1:2:end)', freqdataZmean.S2((1:2:end),3),'-m','linewidth', 1.5);
            hold on
        plot(t(1:2:end)', freqdataZmean.PMv((1:2:end),3), '-b','linewidth', 1.5);
            hold on
        
         % Infusion period
         line([sessionInfo.startAnesthesiaTime, sessionInfo.startAnesthesiaTime],...
             [0 60], 'color', 'k', 'linewidth', 1.5, 'linestyle', ':');
         line([sessionInfo.endAnesthesiaTime, sessionInfo.endAnesthesiaTime],...
             [0 60], 'color', 'k', 'linewidth', 1.5, 'linestyle', ':');

        box off;
        ylabel('alpha norm. power');   xlabel('min');
        ylim([-1 20]);         
        xlim([1*60 (maxtchunks-2)*60]);
        xticks([0:30*60:maxtchunks*60]);
        xticklabels({'1' '30' '60' '90' '120' '150' '180' '210' '240' '270' '300'});
        yticks([0 5 10 15 20]);
        hold off;

    suptitle([session, ' Spindles (9-17Hz)']);
    set(gcf,'position',[0,0,1920,1080])
    if saveplot == 1
    saveas(gcf,(strcat(session, '_spindles_2_summary.fig')));
    saveas(gcf,(strcat(session, '_spindles_2_summary.jpg')));
    end
end

