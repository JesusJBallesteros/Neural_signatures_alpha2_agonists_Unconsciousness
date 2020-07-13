function plotanim_trajectories_3D(SS3D, ROI, videorec, r, setpause, sessionInfo, scale, drug, isantag)
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


%% Record?
if videorec == 1
    myVideo = VideoWriter(['StateSpace_Traject_,' sessionInfo.session]);    %open video file
    myVideo.FrameRate = 30;         % can adjust this
    open(myVideo)
end

%% Play
figure,
  ph1 = plot3(SS3D.(ROI{r})(1,3), SS3D.(ROI{r})(1,2), SS3D.(ROI{r})(1,1),...
      'or', 'MarkerSize', 4);               % plot start point
      xlabel('Ratio 3 PC1'); ylabel('Ratio 2 PC1'); zlabel('Ratio 1 PC1');
      hold on
  ph2 = plot3(SS3D.(ROI{r})(1,3), SS3D.(ROI{r})(1,2), SS3D.(ROI{r})(1,1),...
      'or', 'MarkerSize', 4);               % plot start point
      hold on
      
  set(gca,'Xlim',scale.xax, 'Ylim',scale.yax, 'Zlim',scale.zax);
    view(-230, 2);       % Initial view
    
for i=1:length(SS3D.(ROI{r}))
    view(-230+i/4, 2)    % view rotation
    if i <= 60
    ph1.LineWidth = 1.5;  ph1.Color = [1 0.1 0.1];
    ph1.MarkerSize = 4;
        ph1.XData = SS3D.(ROI{r})(1:i,3);         % change x coordinate of the point
        ph1.YData = SS3D.(ROI{r})(1:i,2);         % change y coordinate of the point
        ph1.ZData = SS3D.(ROI{r})(1:i,1);         % change z coordinate of the point
    ph2.LineWidth = 1.5;  ph2.Color = [1 0.1 0.1];
    ph2.MarkerSize = 4;
        ph2.XData = SS3D.(ROI{r})(1:i,3);         % change x coordinate of the point
        ph2.YData = SS3D.(ROI{r})(1:i,2);         % change y coordinate of the point
        ph2.ZData = SS3D.(ROI{r})(1:i,1);         % change z coordinate of the point
      drawnow
    else 
    ph1.LineWidth = 1;  ph1.Color = [0.25 0.25 0.25];
    ph1.MarkerSize = 1;
        ph1.XData = SS3D.(ROI{r})(1:i-61,3); 
        ph1.YData = SS3D.(ROI{r})(1:i-61,2); 
        ph1.ZData = SS3D.(ROI{r})(1:i-61,1); 
        
    ph2.LineWidth = 1.5;  ph2.Color = [1 0.1 0.1];
    ph2.MarkerSize = 3;
        ph2.XData = SS3D.(ROI{r})(i-60:i,3);         % change x coordinate of the point
        ph2.YData = SS3D.(ROI{r})(i-60:i,2);         % change x coordinate of the point
        ph2.ZData = SS3D.(ROI{r})(i-60:i,1);         % change x coordinate of the point
     drawnow
    end
    if isantag == 1
        if i < sessionInfo.startAnesthesiaTime
            title(sprintf('t = %.2f min. AWAKE', i/60))
            pause([setpause.awake])                            
        elseif i >= sessionInfo.startAnesthesiaTime && i < sessionInfo.locTime
            title(sprintf('t = %.2f min. %s Infusion', i/60, drug))
            pause([setpause.infpreloc])                            
        elseif i >= sessionInfo.locTime && i < sessionInfo.startAnesthesiaTime+1800
            title(sprintf('t = %.2f min. %s Infusion. LOC', i/60, drug))
            pause([setpause.infpostloc])                            
        elseif i >= sessionInfo.startAnesthesiaTime+1800 && i < sessionInfo.endAnesthesiaTime
            title(sprintf('t = %.2f min. %s +ANTAGONIST', i/60, drug))
            pause([setpause.ropap])
        elseif i >= sessionInfo.endAnesthesiaTime
            title(sprintf('t = %.2f min. RECOVERY', i/60))
            pause([setpause.ropap])
        end
    else
        if i < sessionInfo.startAnesthesiaTime
            title(sprintf('t = %.2f min. AWAKE', i/60))
            pause([setpause.awake])                            
        elseif i >= sessionInfo.startAnesthesiaTime && i < sessionInfo.locTime
            title(sprintf('t = %.2f min. %s Infusion', i/60, drug))
            pause([setpause.infpreloc])                            
        elseif i >= sessionInfo.locTime && i < sessionInfo.endAnesthesiaTime
            title(sprintf('t = %.2f min. %s Infusion. LOC', i/60, drug))
            pause([setpause.infpostloc])                            
        elseif i >= sessionInfo.endAnesthesiaTime && i < sessionInfo.rocTime
            title(sprintf('t = %.2f min. Recovery', i/60))
            pause([setpause.rec])                            
        elseif i >= sessionInfo.rocTime && i < sessionInfo.ropapTime 
            title(sprintf('t = %.2f min. ROC', i/60))
            pause([setpause.roc])                          
        elseif i >= sessionInfo.ropapTime
            title(sprintf('t = %.2f min. ROPAP', i/60))
            pause([setpause.ropap])
        end
    end
    
    if videorec == 1
    frame = getframe(gcf); %get frame
    writeVideo(myVideo, frame);
    end
end

if videorec == 1
close(myVideo)
end  

end