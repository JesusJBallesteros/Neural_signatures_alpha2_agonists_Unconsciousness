function [f_,ax_] = plot_partitionFigure(figSize,gridSize,rowWeights,columnWeights,axesRows,axesColumns)
% 
% [f_,ax_] = partitionFigure(figSize,gridSize,rowWeights,columnWeights,axesRows,axesColumns)
% Creates a grid of axes, separated by arbitrary spaces, and returns a figure handle and
% a vector of axes handles. Can use with mergeAxes and killAxes to further refine
% axes into non-grid arrangements.
% figSize - [width, height] in inches
% gridSize - [rows columns], gridsize is overruled by rowWeights and columnWeights, and can
%               be [] if rowWeights and columnWeights are defined
% rowWeights - vector of row width weights, values normalized to sum to 1,
%               default is evenly weighted
% columnWeights - vector of row width weights, values normalized to sum to 1,
%               default is evenly weighted
% axesRows - which rows have axes drawn
% axesColumns - like axesRows, but for columns
% params - additional parameters (optional)
% See also mergeAxes, killAxes
% 

if (nargin < 2)
    disp('ERROR: partitionFigure must have at least two inputs');
end
if (nargin < 3 || isempty(rowWeights))
    rowWeights = ones(1,gridSize(1));
else
    gridSize(1) = length(rowWeights);       % take gridSize from rowWeights
end
if (nargin < 4 || isempty(columnWeights))
    columnWeights = ones(1,gridSize(2));
else
    gridSize(2) = length(columnWeights);    % take gridSize from columnWeights
end
if (nargin < 5 || isempty(axesRows))
    axesRows = 1:gridSize(1);
end
if (nargin < 6 || isempty(axesColumns))
    axesColumns = 1:gridSize(2);
end
if (nargin < 7 || isempty(params))
    params = struct('blank','');    
end

if (~ismember(lower('targetResolution'),lower(fieldnames(params)))), params.targetResolution = [1200 700]; end

rowWeights = rowWeights/sum(rowWeights);
columnWeights = columnWeights/sum(columnWeights);

bottomEdges = [1 1-cumsum(rowWeights)];
width_row = abs(diff(bottomEdges));
bottomEdges(1) = [];
leftEdges = [0 cumsum(columnWeights)];
width_col = diff(leftEdges);

keep = [];
pos = zeros(gridSize(1)*gridSize(2),1);
for rowI = 1:gridSize(1)
    for colI = 1:gridSize(2)
        r = gridSize(2)*(rowI-1) + colI;
        pos(r,1) = leftEdges(colI);
        pos(r,2) = bottomEdges(rowI);
        pos(r,3) = width_col(colI);
        pos(r,4) = width_row(rowI);
        if (any(axesRows == rowI) && any(axesColumns == colI))
            keep = [keep r];
        end
    end
end
pos = pos(keep,:);

pappos = [0 0 figSize(1) figSize(2)];
multFact = min(params.targetResolution(1)/figSize(1), params.targetResolution(2)/figSize(2));
h_off = (1280 - figSize(1)*multFact) / 2;
v_off = (800 - figSize(2)*multFact) / 2;
screen_pos = [h_off v_off figSize(1)*multFact figSize(2)*multFact];

f_ = figure('position',screen_pos,'papersize',figSize,'paperposition',pappos,'color','w');;
for axI = 1:size(pos,1)
    ax_(axI) = axes('Position',pos(axI,:)); 
end