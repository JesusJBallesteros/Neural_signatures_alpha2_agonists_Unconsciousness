function plot_trajectory_around(SS3D, speed, pre, post, showall, ROI, sessionInfo, saveplot)
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


%% Around LOC
for r = [1 3]
figure, 
subplot(221),
    if showall == 1
        scatter(SS3D.(ROI{r})(:,1), SS3D.(ROI{r})(:,2), 3, [0.8 0.8 0.8],'filled'), hold on
    end
    scatter(SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,1),...
        SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,2), 10,...
        speed.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,1),'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter(SS3D.(ROI{r})(round(sessionInfo.locTime),1),...
        SS3D.(ROI{r})(round(sessionInfo.locTime),2), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a triangle
    scatter(SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),1),...
        SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),2), 70, 'vk' ,'filled'), hold on

    colormap jet;
    ax = gca; ax.CLim = [min(speed.(ROI{r})(:,1))...
                        max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    xlabel('Ratio1 PC1 (a.u.)'), ylabel('Ratio2 PC1 (a.u.)'),
    if r == 1, xticks([]); yticks([]); %xticks([-1.5 -1 -0.5 0 0.5 1 1.5]); yticks([-1.5 -1 -0.5 0 0.5 1 1.5]);
    elseif r == 3, xticks([]); yticks([]); end % xticks([-0.5 0 0.5]); yticks([-0.5 0 0.5]);
    
subplot(222),
    if showall == 1
        scatter(SS3D.(ROI{r})(:,2), SS3D.(ROI{r})(:,3), 3, [0.8 0.8 0.8],'filled'), hold on
    end
    scatter(SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,2),...
        SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,3), 10,...
        speed.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,1),'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter(SS3D.(ROI{r})(round(sessionInfo.locTime),2),...
        SS3D.(ROI{r})(round(sessionInfo.locTime),3), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a triangle
    scatter(SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),2),...
        SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),3), 70, 'vk' ,'filled'), hold on

    colormap jet;
    ax = gca; ax.CLim = [min(speed.(ROI{r})(:,1))...
                        max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    xlabel('Ratio2 PC1 (a.u.)'), ylabel('Ratio3 PC1 (a.u.)'),
    if r == 1, xticks([]); yticks([]); %xticks([-1.5 -1 -0.5 0 0.5 1 1.5]); yticks([-1.5 -1 -0.5 0 0.5 1 1.5]);
    elseif r == 3, xticks([]); yticks([]); end % xticks([-0.5 0 0.5]); yticks([-0.5 0 0.5]);

subplot(223),
    if showall == 1
        scatter(SS3D.(ROI{r})(:,1), SS3D.(ROI{r})(:,3), 3, [0.8 0.8 0.8],'filled'), hold on
    end
    scatter(SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,1),...
        SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,3), 10,...
        speed.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,1),'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter(SS3D.(ROI{r})(round(sessionInfo.locTime),1),...
        SS3D.(ROI{r})(round(sessionInfo.locTime),3), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a triangle
    scatter(SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),1),...
        SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),3), 70, 'vk' ,'filled'), hold on

    colormap jet;
    ax = gca; ax.CLim = [min(speed.(ROI{r})(:,1))...
                        max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    xlabel('Ratio1 PC1 (a.u.)'), ylabel('Ratio3 PC1 (a.u.)'),
    if r == 1, xticks([]); yticks([]); 
    elseif r == 3, xticks([]); yticks([]); end

subplot(224),
    if showall == 1
        scatter3(SS3D.(ROI{r})(:,1), SS3D.(ROI{r})(:,2), SS3D.(ROI{r})(:,3),...
        4, [0.8 0.8 0.8], 'filled'), hold on
    end
    
    scatter3(SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,1),...
        SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,2),...
        SS3D.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,3),...
        5, speed.(ROI{r})(sessionInfo.locTime-pre:sessionInfo.locTime+post,1), 'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter3(SS3D.(ROI{r})(round(sessionInfo.locTime),1),...
        SS3D.(ROI{r})(round(sessionInfo.locTime),2),...
        SS3D.(ROI{r})(round(sessionInfo.locTime),3), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a black triangle
    scatter3(SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),1),...
        SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),2),...
        SS3D.(ROI{r})(round(sessionInfo.locTime-post+5),3), 70, 'vk' ,'filled'), hold on
    
    colormap jet;
    ax = gca;
        ax.CameraPosition = [-1.5 16 3.5];
    ax.CLim = [min(speed.(ROI{r})(:,1))...
               max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    if r == 1, xticks([]); yticks([]); 
    elseif r == 3, xticks([]); yticks([]); end

    xlabel('ratio1'),
    ylabel('ratio2'),
    zlabel('ratio3'),
suptitle([sessionInfo.session,'-', ROI{r},'-Ratios.PC1 - LOC']);
   
if saveplot == 1
  sdf(gcf,'default');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_12_LOC.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_12_LOC.jpg')));
end
end
%% Around ROC
for r = [1 3]
figure, 
subplot(221),
    if showall == 1
        scatter(SS3D.(ROI{r})(:,1), SS3D.(ROI{r})(:,2), 3, [0.8 0.8 0.8],'filled'), hold on
    end
    scatter(SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,1),...
        SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,2), 10,...
        speed.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,1),'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter(SS3D.(ROI{r})(round(sessionInfo.rocTime),1),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime),2), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a triangle
    scatter(SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),1),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),2), 70, 'vk' ,'filled'), hold on

    colormap jet;
    ax = gca; ax.CLim = [min(speed.(ROI{r})(:,1))...
                        max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    xlabel('Ratio1 PC1 (a.u.)'), ylabel('Ratio2 PC1 (a.u.)'),
    if r == 1, xticks([]); yticks([]); %xticks([-1.5 -1 -0.5 0 0.5 1 1.5]); yticks([-1.5 -1 -0.5 0 0.5 1 1.5]);
    elseif r == 3, xticks([]); yticks([]); end % xticks([-0.5 0 0.5]); yticks([-0.5 0 0.5]);
    
subplot(222),
    if showall == 1
        scatter(SS3D.(ROI{r})(:,2), SS3D.(ROI{r})(:,3), 3, [0.8 0.8 0.8],'filled'), hold on
    end
    scatter(SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,2),...
        SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,3), 10,...
        speed.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,1),'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter(SS3D.(ROI{r})(round(sessionInfo.rocTime),2),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime),3), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a triangle
    scatter(SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),2),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),3), 70, 'vk' ,'filled'), hold on

    colormap jet;
    ax = gca; ax.CLim = [min(speed.(ROI{r})(:,1))...
                        max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    xlabel('Ratio2 PC1 (a.u.)'), ylabel('Ratio3 PC1 (a.u.)'),
    if r == 1, xticks([]); yticks([]); %xticks([-1.5 -1 -0.5 0 0.5 1 1.5]); yticks([-1.5 -1 -0.5 0 0.5 1 1.5]);
    elseif r == 3, xticks([]); yticks([]); end % xticks([-0.5 0 0.5]); yticks([-0.5 0 0.5]);

subplot(223),
    if showall == 1
        scatter(SS3D.(ROI{r})(:,1), SS3D.(ROI{r})(:,3), 3, [0.8 0.8 0.8],'filled'), hold on
    end
    scatter(SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,1),...
        SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,3), 10,...
        speed.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,1),'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter(SS3D.(ROI{r})(round(sessionInfo.rocTime),1),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime),3), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a triangle
    scatter(SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),1),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),3), 70, 'vk' ,'filled'), hold on

    colormap jet;
    ax = gca; ax.CLim = [min(speed.(ROI{r})(:,1))...
                        max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    xlabel('Ratio1 PC1 (a.u.)'), ylabel('Ratio3 PC1 (a.u.)'),
    if r == 1, xticks([]); yticks([]); 
    elseif r == 3, xticks([]); yticks([]); end

subplot(224),
    if showall == 1
        scatter3(SS3D.(ROI{r})(:,1), SS3D.(ROI{r})(:,2), SS3D.(ROI{r})(:,3),...
        4, [0.8 0.8 0.8], 'filled'), hold on
    end
    
    scatter3(SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,1),...
        SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,2),...
        SS3D.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,3),...
        5, speed.(ROI{r})(sessionInfo.rocTime-pre:sessionInfo.rocTime+post,1), 'filled'), hold on
    %Plot the point at loc/roc as a black circle
    scatter3(SS3D.(ROI{r})(round(sessionInfo.rocTime),1),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime),2),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime),3), 70, 'ok' ,'filled'), hold on
    %Plot the starting point as a black triangle
    scatter3(SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),1),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),2),...
        SS3D.(ROI{r})(round(sessionInfo.rocTime-post+5),3), 70, 'vk' ,'filled'), hold on
    
    colormap jet;
    ax = gca;
        ax.CameraPosition = [-1.5 16 3.5];
    ax.CLim = [min(speed.(ROI{r})(:,1))...
               max(speed.(ROI{r})(:,1))*0.75];
    cb = colorbar();  cb.Label.String = 'Speed';
        cb.Ticks = [min(speed.(ROI{r})(:,1))...
                    max(speed.(ROI{r})(:,1))*0.75];
        cb.TickLabels = [{'Min'} {'Max'}];
    if r == 1, xticks([]); yticks([]); 
    elseif r == 3, xticks([]); yticks([]); end

    xlabel('ratio1'),
    ylabel('ratio2'),
    zlabel('ratio3'),
suptitle([sessionInfo.session,'-', ROI{r},'-Ratios.PC1 - ROC']);   

if saveplot == 1
  sdf(gcf,'default');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_12_ROC.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_12_ROC.jpg')));
end
end
end