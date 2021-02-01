function cmap = camvidColorMap()
% Define the colormap used by CamVid dataset.

cmap = [
    50 50 50 % epi
    100 100 100        % derpmpap
    150 150 150 % artefact
    1 1 1 % other
    ];

% Normalize between [0 1].
cmap = cmap ./ 255;
end