function scatter_plots_PCA(SS3D, t, sessionInfo, ROI, plot, tplot, saveplot, cam_pos, scale)
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

%% Scatter plots on 2D-3D spaces
if plot(1) == 1
for r = [1 3]
figure,
set(gcf,'position',size)
    subplot(221),
        scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
            SS3D.(ROI{r})(tplot(1):tplot(2),2),1,'k','filled'),
        xlabel('Ratio1 PC1'), ylabel('Ratio2 PC1'), hold on
    subplot(222),
        scatter(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
            SS3D.(ROI{r})(tplot(1):tplot(2),3),1,'r','filled'),
        xlabel('Ratio2 PC1'), ylabel('Ratio3.PC1'), hold on
    subplot(223),
        scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
            SS3D.(ROI{r})(tplot(1):tplot(2),3),1,'b','filled'), 
        xlabel('Ratio1.PC1'), ylabel('Ratio3.PC1'),
    subplot(224),
        scatter3(SS3D.(ROI{r})(tplot(1):tplot(2),1), SS3D.(ROI{r})(tplot(1):tplot(2),2),...
            SS3D.(ROI{r})(tplot(1):tplot(2),3), 1, 'k', 'filled'),
            ax = gca;
            ax.CameraPosition = cam_pos.(ROI{r});
        xlabel('Ratio1 PC1'),
        ylabel('Ratio2 PC1'),
        zlabel('Ratio3 PC1'),
suptitle([sessionInfo.session,'-', ROI{r},'- All-ratios PC1']);
    
if saveplot(1) == 1
  sdf(gcf,'default');
  set(gcf,'position',size)
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_04.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_04.jpg')));
end
end
end

%% Scatter plus histograms, one by one
if plot(2) == 1
for r = [1 3]
figure,
    scatterhist(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
                SS3D.(ROI{r})(tplot(1):tplot(2),2),...
    'Kernel','on','Location','NorthWest',...
    'Direction','out','Color','k','LineStyle','-',...
    'LineWidth',2, 'MarkerSize',1.5, 'Marker','o');%,...
    box off,
suptitle('Ratio1 PC1 vs Ratio2 PC1'); 

figure,
scatterhist(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
            SS3D.(ROI{r})(tplot(1):tplot(2),3),...
    'Kernel','on','Location','NorthWest',...
    'Direction','out','Color','k','LineStyle','-',...
    'LineWidth',2, 'MarkerSize',3, 'Marker','o');%,...
    box off,
suptitle('Ratio1 PC1 vs Ratio3 PC1'); 
    
figure,
scatterhist(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
            SS3D.(ROI{r})(tplot(1):tplot(2),3),...
    'Kernel','on','Location','NorthWest',...
    'Direction','out','Color','k','LineStyle','-',...
    'LineWidth',2, 'MarkerSize',3, 'Marker','o');%,...
    box off,
suptitle('Ratio2 PC1 vs Ratio3 PC1'); 
end
end

%% Density plots 
% Density of points reflects the relative abundance of different brain states
% 'scatter_kde' and 'scatter3_mvks' use Kernel smoothing functions to get 
% the probability density estimate (c) and use it as color maps
if plot(3) ==  1
for r = [1 3]
figure, 
colormap(jet)
subplot(221)    % ratio1 vs ratio 2
    [~, c.(ROI{r})(:,1)] = scatter_kde(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
                SS3D.(ROI{r})(tplot(1):tplot(2),2), 'filled', 'MarkerSize', 4);
    xlabel('Ratio1 PC1'), ylabel('Ratio2 PC1'), hold on
    set(gca,'Xlim',scale.xax, 'Ylim',scale.yax);
    ax = gca; %ax.CLimMode = 'auto';
        ax.CLim = [min(c.(ROI{r})(:,1)) max(c.(ROI{r})(:,1))];% ax.CLim = [0 18];

subplot(222) % ratio1 vs ratio 3
    [~, c.(ROI{r})(:,2)] = scatter_kde(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 'filled', 'MarkerSize', 4);
        xlabel('Ratio2 PC1'), ylabel('Ratio3 PC1'), hold on
        set(gca,'Xlim',scale.yax, 'Ylim',scale.zax);
    ax = gca; %ax.CLimMode = 'auto';
        ax.CLim = [min(c.(ROI{r})(:,2)) max(c.(ROI{r})(:,2))];
    cb = colorbar();
        cb.Position = [0.92 0.6 0.015 0.2];
        cb.Ticks = [min(c.(ROI{r})(:,2)) max(c.(ROI{r})(:,2))];
        cb.TickLabels = [{'Min'} {'Max'}];
        cb.Label.String = 'Probability density estimate';

subplot(223) % ratio2 vs ratio 3
    [~, c.(ROI{r})(:,3)] = scatter_kde(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 'filled', 'MarkerSize', 4);
        xlabel('Ratio1 PC1'), ylabel('Ratio3 PC1'), hold on
        set(gca,'Xlim',scale.xax, 'Ylim',scale.zax);
    ax = gca; %ax.CLimMode = 'auto';
        ax.CLim = [min(c.(ROI{r})(:,3)) max(c.(ROI{r})(:,3))];

subplot(224)
    [~, c.(ROI{r})(:,4)] = scatter3_mvks(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 0.1,...
        'filled', 'MarkerSize', 4);
    set(gca,'Xlim',scale.xax, 'Ylim',scale.yax, 'Zlim',scale.zax);
    ax = gca;
    ax.CameraPosition = cam_pos.(ROI{r});
        ax.CLim = [min(c.(ROI{r})(:,4)) max(c.(ROI{r})(:,4))];
        ax.CLim = [3 14];
    xlabel('Ratio1 PC1'), 
    ylabel('Ratio2 PC1'),
    zlabel('Ratio3 PC1'),
suptitle([sessionInfo.session,'-', ROI{r},'- All-ratios PC1 - KDE']);

if saveplot(3) == 1
  sdf(gcf,'default');
    set(gcf,'position',size)
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Density.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_Density.jpg')));
end

end
end

%% Scatter plot visualization on 2D-3D spaces colored VS time
if plot(4) == 1
for r = [1 3]
figure, 
subplot(221),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2), 3, t(tplot(1):tplot(2)),'filled'),
    xlabel('Ratio1 PC1'), ylabel('Ratio2 PC1'),
    cb = colorbar();  cb.Label.String = 'time (s)';

subplot(222),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 3, t(tplot(1):tplot(2)),'filled'),
    xlabel('Ratio2 PC1'), ylabel('Ratio3 PC1'),
    cb = colorbar();  cb.Label.String = 'time (s)';

subplot(223),
    scatter(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3), 3, t(tplot(1):tplot(2)),'filled'), 
    xlabel('Ratio1 PC1'), ylabel('Ratio3 PC1'),
    cb = colorbar();  cb.Label.String = 'time (s)';

subplot(224),
    scatter3(SS3D.(ROI{r})(tplot(1):tplot(2),1),...
        SS3D.(ROI{r})(tplot(1):tplot(2),2),...
        SS3D.(ROI{r})(tplot(1):tplot(2),3),...
        4, t(tplot(1):tplot(2)), 'filled'),
    ax = gca;
        ax.CameraPosition = cam_pos.(ROI{r});
    cb = colorbar();  cb.Label.String = 'time (s)';
    xlabel('Ratio1 PC1'),
    ylabel('Ratio2 PC1'),
    zlabel('Ratio3 PC1'),
suptitle([sessionInfo.session,'-', ROI{r},'-f.band-ratio PC1 - time']);

if saveplot(4) == 1
  sdf(gcf,'default');
    set(gcf,'position',size)
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_07.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_07.jpg')));
end

end
end

end
