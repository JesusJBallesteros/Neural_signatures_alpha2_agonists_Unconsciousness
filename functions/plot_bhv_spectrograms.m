function plot_bhv_spectrograms(sessionInfo, spectralData_mean, t, f, sessionname, DataArray, ROI, dBscale)
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


%% Few Tweaks
  purple = [0.5412, 0.1686, 0.8863];
  orange = [1, .5, 0];
  
  firstTime = DataArray(1,1);
  lastTime = 150*60; %DataArray(end,2);
  xlimit = [firstTime lastTime]; %[1798 3299];
  labels = {'0','30','60','90','120','150','180','210','240','270'};
  
%% Plot
    [~ , ax_] = plot_partitionFigure([16,22], [],...
        [.05, .05, .05, .2, .2, .2, .075], [.1, .7, .2],  (2:1:6), 2);
    sdf(gcf,'Spectr');
    
  % TRIAL ERROR PLOT (ax_(1))
    axes(ax_(1));
    box on; hold on; 
    for i = 1:length(sessionInfo.trialErrors)
      if sessionInfo.trialErrors(i)==0
        line([sessionInfo.trialTimes(i),sessionInfo.trialTimes(i)], [sessionInfo.trialErrors(i)+2, sessionInfo.trialErrors(i)+3], 'color', 'b');
      elseif sessionInfo.trialErrors(i)==1
        line([sessionInfo.trialTimes(i),sessionInfo.trialTimes(i)], [sessionInfo.trialErrors(i), sessionInfo.trialErrors(i)+1], 'color', 'k');
      elseif  sessionInfo.trialErrors(i)==2
        line([sessionInfo.trialTimes(i),sessionInfo.trialTimes(i)], [sessionInfo.trialErrors(i)-2, sessionInfo.trialErrors(i)-1], 'color', 'r');
      end
    end
    xlim(xlimit);
    xticks(0:30*60:round(lastTime)*60); xticklabels([]);
    ylim([0,3]); yticklabels([]);
    title(strcat(sessionname(1:7),'.',(ROI{1,1}),'-',(ROI{1,3})));
    hold off;

  % BEHAVIORAL ESTIMATE PLOT (ax_(2))
    axes(ax_(2)); box on; hold on;
     if length(sessionInfo.trialTimes) < length(sessionInfo.bEngage)
      plot(sessionInfo.trialTimes,sessionInfo.bEngage(1:length(sessionInfo.trialTimes),3), 'color', purple, 'linewidth', 2);
      plot(sessionInfo.trialTimes,sessionInfo.bPerform(1:length(sessionInfo.trialTimes),3), 'color', orange, 'linewidth', 2);
     elseif length(sessionInfo.bEngage) < length(sessionInfo.trialTimes)
      plot(sessionInfo.trialTimes(1:length(sessionInfo.bEngage)),sessionInfo.bEngage(:,3), 'color', purple, 'linewidth', 2);
      plot(sessionInfo.trialTimes(1:length(sessionInfo.bEngage)),sessionInfo.bPerform(:,3), 'color', orange, 'linewidth', 2);
     elseif length(sessionInfo.trialTimes) == length(sessionInfo.bEngage)
      plot(sessionInfo.trialTimes,sessionInfo.bEngage(:,3), 'color', purple, 'linewidth', 2);
      plot(sessionInfo.trialTimes,sessionInfo.bPerform(:,3), 'color', orange, 'linewidth', 2);
     end
     xlim(xlimit); ylim([0,1]);
     xticks(0:30*60:round(lastTime)*60);
     set(gca, 'yticklabel', [], 'xticklabel', []);
     hold off;
      
  % SPECTROGRAMS (ax_(3)) to (ax_(5))
     n = 0;
     for a = 3:5
        n = n + 1;
         if dBscale == 1
             spectralData_mean.(ROI{n}) = pow2db(spectralData_mean.(ROI{n}));
         end
    axes(ax_(a));
      pcolor(t, f, spectralData_mean.(ROI{n})'); hold on;
      ax_(a).FontSize = 14; 
      xlim(xlimit); ylim([1, 40]);
      xticks(0:30*60:round(lastTime)*60);
      yticks([10,20,30,40,50]);
      if n == 1
        ylabel('Hz', 'fontsize', 14);
%         hColor = colorbar; set(hColor, 'position', [0.81 0.65 0.025 0.10]);
        %yHandle = ylabel(hColor, 'PSD', 'fontsize', 14, 'rotation', 270);
        %set(yHandle, 'Position', [3.25 2.5e-4 0]);
        xticks([]);
      elseif n == 2
        ylabel('Hz', 'fontsize', 12);
%         set(gca, 'clim', [-55 -20]);
%         shading interp; colormap(jet);
        hColor = colorbar; set(hColor, 'position', [0.81 0.4 0.025 0.150], ...
                               'Ticks', [-55 -45 -35]);%, ...
%                                'TickLabels', {'-10' '0' '10'});
        if dBscale == 1
            yHandle = ylabel(hColor, 'dB', 'fontsize', 14, 'rotation', 270);
            set(yHandle, 'Position', [3.5 -45 0]);
        else
            yHandle = ylabel(hColor, 'PSD', 'fontsize', 14, 'rotation', 270);
            set(yHandle, 'Position', [3.25 1e-4 0]);
        end
        xticks([]);
      elseif n == 3
        ylabel('Hz', 'fontsize', 12);
%         set(gca, 'clim', [-55 -20]);
%         shading interp; colormap(jet);
%         hColor = colorbar; set(hColor, 'position', [0.81 0.15 0.025 0.10]);
        xticklabels(labels);
        xlabel('min');
      end
      shading interp; colormap(jet);
      if dBscale == 1
          set(gca, 'clim', [-55 -35]);
      else
          set(gca, 'clim', [1e-6 5e-5]);
      end
     end
end
