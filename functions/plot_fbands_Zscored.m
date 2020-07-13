function plot_fbands_Zscored(freq_data_Zmean, t, frequencies, DataArray, signif_points)
% Function to plot the Z-scored PSD values of all single frequency bands.
% INPUTS:   freq_data_Zmean from 'freq_band_extract' function
%           t               from spectrogram calculation
%           frequencies     from spectrogram calculation
%           res             desired resolution (decimation)

% OUTPUT:   A plot series for each band with S1 & PMv data
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


%% Plot the freq band timelines
  firstTime = DataArray(1,1);
  lastTime = DataArray(end,2);
  xlimit = [firstTime round(lastTime)];

figure,
    for yy = 1:length(frequencies)
    subplot(6,6,[(yy*6)-5 (yy*6)])
        plot(t, freq_data_Zmean.S1(:,yy), 'r', 'linewidth', 1); hold on
        plot(t, freq_data_Zmean.PMv(:,yy),'b', 'linewidth', 1), hold on
%         line([0 t(end)/60],[0 0], 'LineWidth',0.5, 'Color', 'k', 'LineStyle', ':');
        
      ylabel(strcat(num2str(frequencies(yy,1)),'-',num2str(frequencies(yy,2)),'Hz'), 'fontsize', 12);
      xticklabels([]); box off; 
      if yy == 1, %legend('S1', 'PMv', 'location', 'North'); legend ('boxoff');
                   yticks([0 4]); ylim([-1 5]); 
        scatter(t(signif_points.S1{yy}), ...
            ones(1,length(signif_points.S1{yy}))*4, 10, 'r', 'filled', 's');
        scatter(t(signif_points.PMv{yy}), ...
            ones(1,length(signif_points.PMv{yy}))*4.5, 10, 'b', 'filled', 's');
                   
      elseif yy == 2, yticks([0 3]); ylim([-1 6]);
        scatter(t(signif_points.S1{yy}), ...
            ones(1,length(signif_points.S1{yy}))*5, 10, 'r', 'filled', 's');
        scatter(t(signif_points.PMv{yy}), ...
            ones(1,length(signif_points.PMv{yy}))*5.5, 10, 'b', 'filled', 's');
         
      elseif yy == 3, yticks([0 4]); ylim([-1 5]);
        scatter(t(signif_points.S1{yy}), ...
            ones(1,length(signif_points.S1{yy}))*4, 10, 'r', 'filled', 's');
        scatter(t(signif_points.PMv{yy}), ...
            ones(1,length(signif_points.PMv{yy}))*4.5, 10, 'b', 'filled', 's');
          
      elseif yy == 4, yticks([0 1]); ylim([-1 2]);
        scatter(t(signif_points.S1{yy}), ...
            ones(1,length(signif_points.S1{yy}))*1, 10, 'r', 'filled', 's');
        scatter(t(signif_points.PMv{yy}), ...
            ones(1,length(signif_points.PMv{yy}))*1.5, 10, 'b', 'filled', 's');

          
      elseif yy == 5, yticks([-1 0 1]); ylim([-1 2]);
        scatter(t(signif_points.S1{yy}), ...
            ones(1,length(signif_points.S1{yy}))*1, 10, 'r', 'filled', 's');
        scatter(t(signif_points.PMv{yy}), ...
            ones(1,length(signif_points.PMv{yy}))*1.5, 10, 'b', 'filled', 's');
          
      elseif yy == 6, xticklabels(0:2000:20000); xlabel('sec');
          yticks([0 3]); ylim([-1 4]);
        scatter(t(signif_points.S1{yy}), ...
            ones(1,length(signif_points.S1{yy}))*3, 10, 'r', 'filled', 's');
        scatter(t(signif_points.PMv{yy}), ...
            ones(1,length(signif_points.PMv{yy}))*3.5, 10, 'b', 'filled', 's');

      end
      xlim(xlimit);
    end
    sdf(gcf,'fbands');
end