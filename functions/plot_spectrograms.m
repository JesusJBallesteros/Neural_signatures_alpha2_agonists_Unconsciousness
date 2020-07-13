function plot_spectrograms(sessionInfo, spectralData, t, f, ROI, saveplot)
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


for r = [1 3]
ch = 1;
figure, pcolor(t, f, spectralData.(ROI{r}){ch,1}'); hold on;
    xlim([0 t(end)]); 
    ylim([0 50]);
    ylabel('S1 Spectrum (Hz)', 'fontsize', 12);
    xlabel('sec', 'fontsize', 12);
    set(gca, 'clim', [0 0.0005]); shading interp; colormap(hot);
    line([sessionInfo.locTime sessionInfo.locTime], [0 50], 'Color', 'w');
    line([sessionInfo.rocTime sessionInfo.rocTime], [0 50], 'Color', 'w');
title([sessionInfo.session,'-', ROI{r},' spectrogram Ch1']);

if saveplot == 1
  sdf(gcf,'default');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_01.fig')),'fig');
  saveas(gcf,(strcat(sessionInfo.session,'_',(ROI{r}),'_01.jpg')));
%   close(gcf)
end
end
