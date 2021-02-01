function cmap = camvidColorMap()
% Define the colormap used by CamVid dataset.

cmap = [
    50 50 50 % pos_nuc
    100 100 100        % neg_mem
    150 150 150 % pos_mem
    10 10 10 % neg_nuc
    1 1 1 % other
    ];

% Normalize between [0 1].
cmap = cmap ./ 255;
end