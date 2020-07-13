function [vels,speeds] = extract_speedvelocity(X)
% ARGS:
    % X: T by n data matrix
% RETURNS: 
    % vels: T by n matrix of velocity vectors, last row will be NaN
    % speeds: T by 1 vector of speeds (magnitude of velocity vector), where
    % last element will be NaN
  
% Credit to:
% Jesus J. Ballesteros. 2020.
%
% Series of script used for:
% Neural Signatures of ?2 Adrenergic Agonist-Induced Unconsciousness and
% Awakening by Antagonist. Jesus J. Ballesteros, Jessica Briscoe and Yumiko
% Ishizawa. 2020. Elife Submission
% First pre-print on https://doi.org/10.1101/2020.04.21.053330
% Or newer versions.


T = size(X,1);
vels = NaN(T,size(X,2));
speeds = NaN(T,1);

for t = 2:T
    % get points adjacent in time
    pnt_t = X(t,:);
    pnt_tm1 = X(t-1,:);
    
    % subtract them to get velocity vector    
    vel = pnt_t - pnt_tm1;
    
    %speed is norm of velocity vector
    speeds(t-1) = norm(vel, 2);
    
    %save
    vels(t-1,:) = vel;  
end