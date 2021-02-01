function labelIDs = camvidPixelLabelIDs()
% Return the label IDs corresponding to each class.
%
% The CamVid dataset has 32 classes. Group them into 11 classes following
% the original SegNet training methodology [1].
%
% The 11 classes are:
%   "Sky" "Building", "Pole", "Road", "Pavement", "Tree", "SignSymbol",
%   "Fence", "Car", "Pedestrian",  and "Bicyclist".
%
% CamVid pixel label IDs are provided as RGB color values. Group them into
% 11 classes and return them as a cell array of M-by-3 matrices. The
% original CamVid class names are listed alongside each RGB value. Note
% that the Other/Void class are excluded below.
labelIDs = { ...
    
    % "epi"
    [
    50 50 50; ... % "pos_nuc
    ]
    
    % "dermpap" 
    [
    100 100 100; ... % "neg_mem"
    ]
    
    % "artefact"
    [
    150 150 150; ... % "pos_mem"
    ]
    
    % other
    [
    10 10 10; ... % "neg_nuc"
    ] 
    
    % other
    [
    1 1 1; ... % "other" 
    ] 
    };
end

% 
%  readinputimage(readinputimageold==7)=150; %"pos_mem"
%     readinputimage(readinputimageold==8)=150; %"pos_mem"
%     readinputimage(readinputimageold==9)=100; %"neg_mem"
%     readinputimage(readinputimageold==10)=50; %"pos_nuc"
%     readinputimage(readinputimageold==11)=50; %"pos_nuc"
%     readinputimage(readinputimageold==12)=10; %"neg_nuc"
%     readinputimage(readinputimageold==0)=1; %"other"