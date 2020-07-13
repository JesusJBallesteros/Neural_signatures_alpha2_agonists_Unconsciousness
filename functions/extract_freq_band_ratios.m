function [ratio1, ratio2, ratio3, fbands] = extract_freq_band_ratios(spectralData, ROI, LFPdata, f, t, drug)
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


switch drug
  case 'Propofol'  
    fbands.S1 =    [16 30;    % S1 beta
                   0.5 5;      % SDelta
                    30 59;      % all > beta 
                   0.5 15 ];   % all < beta 
    fbands.PMv =   [25 35;    % PMv beta
                   0.5  5;     % slow-delta
                    35 59;      % all > beta 
                   0.5 24 ];   % all < beta 
    for r = [1 3]
      band1.(ROI{r}) = find(f>fbands.(ROI{r})(1,1) & f<fbands.(ROI{r})(1,2));
      band2.(ROI{r}) = find(f>fbands.(ROI{r})(2,1) & f<fbands.(ROI{r})(2,2));
      band3.(ROI{r}) = find(f>fbands.(ROI{r})(3,1) & f<fbands.(ROI{r})(3,2));
      band4.(ROI{r}) = find(f>fbands.(ROI{r})(4,1) & f<fbands.(ROI{r})(4,2));
    end
    for r = [1 3]
      ratio1.(ROI{r}) = NaN(size(t,2),size(LFPdata.(ROI{r}),2));
      ratio2.(ROI{r}) = NaN(size(t,2),size(LFPdata.(ROI{r}),2));
      ratio3.(ROI{r}) = NaN(size(t,2),size(LFPdata.(ROI{r}),2));

      for ch = 1:size(LFPdata.(ROI{r}),2)
        for dt = 1:size(t,2)
          ratio1.(ROI{r})(dt,ch) =... % beta / all
            trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band1.(ROI{r})))) / ...
            trapz(abs(spectralData.(ROI{r}){ch,1}(dt, :)));
          ratio2.(ROI{r})(dt,ch) =... % slowdelta / all < beta
            trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band2.(ROI{r})))) / ...
            trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band4.(ROI{r}))));
          ratio3.(ROI{r})(dt,ch) =... % all > beta / all
            trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band3.(ROI{r})))) / ...
            trapz(abs(spectralData.(ROI{r}){ch,1}(dt, :)));
            %trapz(abs(spectralData.(ROI{r}){ch,1}(band4.(ROI{r}),dt)));
        end
      end
    end
        
  case 'Ketamine'
        fbands.S1 =    [18 25;    % S1 beta
                        28 42;    % gamma
                        .5 12;     % slow-alpha
                        15 59 ];  % all > alpha 
        fbands.PMv =   [21 35;    % PMv beta
                        28 42;    % gamma
                        .5  6;     % slow-delta
                        6 10;     % alpha
                        15 59 ];  % all > beta 
        for r = [1 3]
        band1.(ROI{r}) = find(f>fbands.(ROI{r})(1,1) & f<fbands.(ROI{r})(1,2));
        band2.(ROI{r}) = find(f>fbands.(ROI{r})(2,1) & f<fbands.(ROI{r})(2,2));
        band3.(ROI{r}) = find(f>fbands.(ROI{r})(3,1) & f<fbands.(ROI{r})(3,2));
        band4.(ROI{r}) = find(f>fbands.(ROI{r})(4,1) & f<fbands.(ROI{r})(4,2));
        end
        for r = [1 3]
        ratio1.(ROI{r}) = NaN(size(spectralData.(ROI{r}){1,1},2),size(LFPdata.(ROI{r}),2));
        ratio2.(ROI{r}) = NaN(size(spectralData.(ROI{r}){1,1},2),size(LFPdata.(ROI{r}),2));
        ratio3.(ROI{r}) = NaN(size(spectralData.(ROI{r}){1,1},2),size(LFPdata.(ROI{r}),2));

          for ch = 1:size(LFPdata.(ROI{r}),2)
            for dt = 1:size(spectralData.(ROI{r}){ch,1},2)
                ratio1.(ROI{r})(dt,ch) =... % beta / all>alpha
                    trapz(abs(spectralData.(ROI{r}){ch,1}(band1.(ROI{r}),dt))) / ...
                    trapz(abs(spectralData.(ROI{r}){ch,1}(band4.(ROI{r}),dt)));
                ratio2.(ROI{r})(dt,ch) =... % gamma / all>beta
                    trapz(abs(spectralData.(ROI{r}){ch,1}(band2.(ROI{r}),dt))) / ...
                    trapz(abs(spectralData.(ROI{r}){ch,1}(band4.(ROI{r}),dt)));
                ratio3.(ROI{r})(dt,ch) =... % slow-alpha / all
                    trapz(abs(spectralData.(ROI{r}){ch,1}(band3.(ROI{r}),dt))) / ...
                    trapz(abs(spectralData.(ROI{r}){ch,1}(:,dt)));
            end
          end
        end

  case 'Dexmedetomidine'
        fbands.S1 =    [17 35;    % S1 beta
                        1  8;      % slow-delta
                        8 15;      % alpha
                        17 59];    % all > alpha 
        fbands.PMv =   [17 35;    % PMv beta
                        1  8;      % slow-delta
                        8 15;      % alpha
                        17 59];    % all > beta 
        for r = [1 3]
        band1.(ROI{r}) = find(f>fbands.(ROI{r})(1,1) & f<fbands.(ROI{r})(1,2));
        band2.(ROI{r}) = find(f>fbands.(ROI{r})(2,1) & f<fbands.(ROI{r})(2,2));
        band3.(ROI{r}) = find(f>fbands.(ROI{r})(3,1) & f<fbands.(ROI{r})(3,2));
        band4.(ROI{r}) = find(f>fbands.(ROI{r})(4,1) & f<fbands.(ROI{r})(4,2));
        end
        for r = [1 3]
          ratio1.(ROI{r}) = NaN(size(t,2),size(LFPdata.(ROI{r}),2)+1);
          ratio2.(ROI{r}) = NaN(size(t,2),size(LFPdata.(ROI{r}),2)+1);
          ratio3.(ROI{r}) = NaN(size(t,2),size(LFPdata.(ROI{r}),2)+1);

          for ch = 1:size(LFPdata.(ROI{r}),2)
            for dt = 1:size(t,2)
              ratio1.(ROI{r})(dt,ch) =... % beta / all > alpha
                trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band1.(ROI{r})))) / ...
                trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band4.(ROI{r}))));
              ratio2.(ROI{r})(dt,ch) =... % delta / all
                trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band2.(ROI{r})))) / ...
                trapz(abs(spectralData.(ROI{r}){ch,1}(dt, :)));
              ratio3.(ROI{r})(dt,ch) =... % alpha / all
                trapz(abs(spectralData.(ROI{r}){ch,1}(dt, band3.(ROI{r})))) / ...
                trapz(abs(spectralData.(ROI{r}){ch,1}(dt, :)));
            end
          end
              ratio1.(ROI{r})(:,ch+1) =... % mean beta / all > alpha
                mean(ratio1.(ROI{r})(:,1:ch),2);
              ratio2.(ROI{r})(:,ch+1) =... % delta / all
                mean(ratio2.(ROI{r})(:,1:ch),2);
              ratio3.(ROI{r})(:,ch+1) =... % alpha / all
                mean(ratio3.(ROI{r})(:,1:ch),2);
        end
end
