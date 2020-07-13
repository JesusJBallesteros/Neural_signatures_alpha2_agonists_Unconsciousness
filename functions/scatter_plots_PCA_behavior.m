function scatter_plots_PCA_behavior(SS3D, BHVlabels, speed, sessionInfo, ROI, plot, tplot, saveplot, isantag, cam_pos, scale)
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.

size = [10,200,1024,900];

%% Behavioral Labels
if plot(1) == 1
for r = [1 3]
figure, 
subplot(221),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2), 2,...
        BHVlabels(tplot(1):tplot(2),3),'filled'),
    xlabel('Ratio1 PC1'), ylabel('Ratio2 PC1'), colormap jet
    set(gca,'Xlim',scale.xax, 'Ylim',scale.yax);
    if isantag == 0
        ax = gca; ax.CLim = [1 6];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:6;
        cb.TickLabels = [{'Awake'} {'Inf.Start'} {'LOC'} {'Inf.End'} {'ROC'} {'ROPAP'}];
    else
        ax = gca; ax.CLim = [1 4];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:4;
        cb.TickLabels = [{'Awake'} {'preLOC'} {'Anesth'} {'postAntag'}];
    end
    
subplot(222),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 2,...
        BHVlabels(tplot(1):tplot(2),3),'filled'),
    xlabel('Ratio2 PC1'), ylabel('Ratio3 PC1'), colormap jet
    set(gca,'Xlim',scale.yax, 'Ylim',scale.zax);
    if isantag == 0
        ax = gca; ax.CLim = [1 6];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:6;
        cb.TickLabels = [{'Awake'} {'Inf.Start'} {'LOC'} {'Inf.End'} {'ROC'} {'ROPAP'}];
    else
        ax = gca; ax.CLim = [1 4];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:4;
        cb.TickLabels = [{'Awake'} {'preLOC'} {'Anesth'} {'postAntag'}];
    end
    
subplot(223),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 2,...
        BHVlabels(tplot(1):tplot(2),3),'filled'), 
    xlabel('Ratio1 PC1'), ylabel('Ratio3 PC1'), colormap jet
    set(gca,'Xlim',scale.xax, 'Ylim',scale.zax);
    if isantag == 0
        ax = gca; ax.CLim = [1 6];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:6;
        cb.TickLabels = [{'Awake'} {'Inf.Start'} {'LOC'} {'Inf.End'} {'ROC'} {'ROPAP'}];
    else
        ax = gca; ax.CLim = [1 4];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:4;
        cb.TickLabels = [{'Awake'} {'preLOC'} {'Anesth'} {'postAntag'}];
    end
    
subplot(224),
    scatter3(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3),...
        2, BHVlabels(tplot(1):tplot(2),3), 'filled'),
        set(gca,'Xlim',scale.xax, 'Ylim',scale.yax, 'Zlim',scale.zax);
        ax = gca;
        ax.CameraPosition = cam_pos.(ROI{r});
    if isantag == 0
        ax.CLim = [1 6];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:6;
        cb.TickLabels = [{'Awake'} {'Inf.Start'} {'LOC'} {'Inf.End'} {'ROC'} {'ROPAP'}];
    else
        ax.CLim = [1 4];
        cb = colorbar();  cb.Label.String = 'Behav.State';
        cb.Ticks = 1:4;
        cb.TickLabels = [{'Awake'} {'preLOC'} {'Anesth'} {'postAntag'}];
    end
    xlabel('Ratio1 PC1'),
    ylabel('Ratio2 PC1'),
    zlabel('Ratio3 PC1'),
suptitle(strcat(sessionInfo.session,'-', ROI{r},'-f.band-ratio PC1 - Behavior'));

if saveplot(1) == 1
  sdf(gcf,'default');
    set(gcf,'position',size)
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_08.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_08.jpg')));
end

end
end

% Plot with Performance Labels
if plot(2) == 1
for r = [1 3]
figure, 
subplot(221),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2), 2,...
        BHVlabels(tplot(1):tplot(2),2),'filled'),
    set(gca,'Xlim',scale.xax, 'Ylim',scale.yax);
    xlabel('Ratio1 PC1'), ylabel('Ratio2 PC1'), colormap cool
    ax = gca; ax.CLim = [0 1];

subplot(222),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 2,...
        BHVlabels(tplot(1):tplot(2),2),'filled'),
    set(gca,'Xlim',scale.yax, 'Ylim',scale.zax);
    xlabel('Ratio2 PC1'), ylabel('Ratio3 PC1'), colormap cool
    ax = gca; ax.CLim = [0 1];
    cb = colorbar();  
        cb.Position = [0.92 0.6 0.015 0.2];
        cb.Ticks = [0 0.5 1];
        cb.TickLabels = [{'0'} {'0.5'} {'1'}];
        cb.Label.String = 'Performance Probability';
        
subplot(223),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 2,...
        BHVlabels(tplot(1):tplot(2),2),'filled'), 
    set(gca,'Xlim',scale.xax, 'Ylim',scale.zax);
    xlabel('Ratio1 PC1'), ylabel('Ratio3 PC1'), colormap cool
    ax = gca; ax.CLim = [0 1];

subplot(224),
    scatter3(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3),...
        2, BHVlabels(tplot(1):tplot(2),2), 'filled'),
        set(gca,'Xlim',scale.xax, 'Ylim',scale.yax, 'Zlim',scale.zax);
    ax = gca;
        ax.CameraPosition = cam_pos.(ROI{r});
    xlabel('Ratio1 PC1'),
    ylabel('Ratio2 PC1'),
    zlabel('Ratio3 PC1'),
suptitle(strcat(sessionInfo.session,'-', ROI{r},'-f.band-ratio PC1 - Performance'));

if saveplot(2) == 1
  sdf(gcf,'default');
    set(gcf,'position',size)
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Performance.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Performance.jpg')));
end

end
end

% Plot with Engagement Labels
if plot(3) == 1
for r = [1 3]
figure, 
subplot(221),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2), 2,...
        BHVlabels(tplot(1):tplot(2),1),'filled'),
    set(gca,'Xlim',scale.xax, 'Ylim',scale.yax);
    xlabel('Ratio1 PC1'), ylabel('Ratio2 PC1'), colormap cool
    ax = gca; ax.CLim = [0 1];

subplot(222),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 2,...
        BHVlabels(tplot(1):tplot(2),1),'filled'),
    xlabel('Ratio2 PC1'), ylabel('Ratio3 PC1'), colormap cool
    set(gca,'Xlim',scale.yax, 'Ylim',scale.zax);
    ax = gca; ax.CLim = [0 1];
    cb = colorbar();  
        cb.Position = [0.92 0.6 0.015 0.2];
        cb.Ticks = [0 0.5 1];
        cb.TickLabels = [{'0'} {'0.5'} {'1'}];
        cb.Label.String = 'Engagement Probability';

subplot(223),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 2,...
        BHVlabels(tplot(1):tplot(2),1),'filled'), 
    set(gca,'Xlim',scale.xax, 'Ylim',scale.zax);
    xlabel('Ratio1 PC1'), ylabel('Ratio3 PC1'), colormap cool
    ax = gca; ax.CLim = [0 1];

subplot(224),
    scatter3(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3),...
        2, BHVlabels(tplot(1):tplot(2),1), 'filled'),
        set(gca,'Xlim',scale.xax, 'Ylim',scale.yax, 'Zlim',scale.zax);
    ax = gca;
        ax.CameraPosition = cam_pos.(ROI{r});
    xlabel('Ratio1 PC1'),
    ylabel('Ratio2 PC1'),
    zlabel('Ratio3 PC1'),
suptitle(strcat(sessionInfo.session,'-', ROI{r},'-f.band-ratio PC1 - Engagement'));

if saveplot(3) == 1
  sdf(gcf,'default');
    set(gcf,'position',size)
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Engagement.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Engagement.jpg')));
end

end
end

%% Speed Plots
if plot(4) == 1
for r = [1 3]
figure, 
subplot(221),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2), 2,...
        speed.(ROI{r})(tplot(1):tplot(2),1),'filled'),
    set(gca,'Xlim',scale.xax, 'Ylim',scale.yax);
    xlabel('Ratio1 PC1'), ylabel('Ratio2 PC1'), colormap jet
    ax = gca;
    ax.CLim = [min(speed.(ROI{r})(tplot(1):tplot(2),1))...
                max(speed.(ROI{r})(tplot(1):tplot(2),1))*0.5];

subplot(222),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 3,...
        speed.(ROI{r})(tplot(1):tplot(2),1),'filled'),
    set(gca,'Xlim',scale.yax, 'Ylim',scale.zax);
    xlabel('Ratio2 PC1'), ylabel('Ratio3 PC1'), colormap jet
    ax = gca;
    ax.CLim = [min(speed.(ROI{r})(tplot(1):tplot(2),1))...
                max(speed.(ROI{r})(tplot(1):tplot(2),1))*0.5];
    cb = colorbar(); 
        cb.Position = [0.92 0.6 0.015 0.2];
        cb.Ticks = [min(speed.(ROI{r})(tplot(1):tplot(2),1))...
            max(speed.(ROI{r})(tplot(1):tplot(2),1))*0.5];
        cb.TickLabels = [{'Min'} {'Max'}];
        cb.Label.String = 'Speed';
         
subplot(223),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 3,...
        speed.(ROI{r})(tplot(1):tplot(2),1),'filled'),
    set(gca,'Xlim',scale.xax, 'Ylim',scale.zax);
    xlabel('Ratio1 PC1'), ylabel('Ratio3 PC1'), colormap jet
    ax = gca;
    ax.CLim = [min(speed.(ROI{r})(tplot(1):tplot(2),1))...
                max(speed.(ROI{r})(tplot(1):tplot(2),1))*0.5];

subplot(224),
    scatter3(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3),...
        4, speed.(ROI{r})(tplot(1):tplot(2),1), 'filled'), 
        set(gca,'Xlim',scale.xax, 'Ylim',scale.yax, 'Zlim',scale.zax);
    ax = gca;
        ax.CameraPosition = cam_pos.(ROI{r});
    ax.CLim = [min(speed.(ROI{r})(tplot(1):tplot(2),1))*10 ...
                max(speed.(ROI{r})(tplot(1):tplot(2),1))*0.5];        
    xlabel('Ratio1 PC1'),
    ylabel('Ratio2 PC1'),
    zlabel('Ratio3 PC1'),
suptitle(strcat(sessionInfo.session,'-', ROI{r},'-f.band-ratio PC1 - Speed'));

if saveplot(4) == 1
  sdf(gcf,'default');
   set(gcf,'position',size)
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Speed.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Speed.jpg')));
end
end
end
end
