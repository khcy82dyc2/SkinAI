clc
clear
close all
parpool(2);
resnet18();
addpath function
% Specify the network image size. This is typically the same as the traing image sizes.
% imageSize = [720 960 3];
 imageSize = [700 700 3];
%
tempfold='temprfold\';
% pretrainedURL = 'https://www.mathworks.com/supportfiles/vision/data/deeplabv3plusResnet18CamVid.mat';
% pretrainedFolder = fullfile(tempfold,'pretrainedNetwork');
% pretrainedNetwork = fullfile(pretrainedFolder,'deeplabv3plusResnet18CamVid.mat');
% if ~exist(pretrainedFolder,'dir')
%     mkdir(pretrainedFolder);
%     disp('Downloading pretrained network (58 MB)...');
%     websave(pretrainedNetwork,pretrainedURL);
% end
%
% imageURL = 'http://web4.cs.ucl.ac.uk/staff/g.brostow/MotionSegRecData/files/701_StillsRaw_full.zip';
% labelURL = 'http://web4.cs.ucl.ac.uk/staff/g.brostow/MotionSegRecData/data/LabeledApproved_full.zip';
outputFolder = fullfile(tempfold,'CamVid');
%
% if ~exist(outputFolder, 'dir')
%
%     mkdir(outputFolder)
%     labelsZip = fullfile(outputFolder,'labels.zip');
%     imagesZip = fullfile(outputFolder,'images.zip');
%
%     disp('Downloading 16 MB CamVid dataset labels...');
%     websave(labelsZip, labelURL);
%     unzip(labelsZip, fullfile(outputFolder,'labels'));
%
%     disp('Downloading 557 MB CamVid dataset images...');
%     websave(imagesZip, imageURL);
%     unzip(imagesZip, fullfile(outputFolder,'images'));
% end

imgDir ='D:\Nick_image\traincell\ori_out\';
outmask ='D:\Nick_image\traincell\mask_out\';

% imgDir = fullfile(outputFolder,'images','701_StillsRaw_full');
imds = imageDatastore(imgDir);


% I = readimage(imds,1);
% I = histeq(I);
% imshow(I)

classes = [
    "Epi"
    "dermpap"
    "artefact"
    "other" 
    ];


labelIDs = camvidPixelLabelIDs();


% labelDir = fullfile(outputFolder,'labels');
labelDir=outmask;
pxds = pixelLabelDatastore(labelDir,classes,labelIDs);


C = readimage(pxds,1);
cmap = camvidColorMap;
% B = labeloverlay(I,C,'ColorMap',cmap);
% imshow(B)
pixelLabelColorbar(cmap,classes);


tbl = countEachLabel(pxds)


frequency = tbl.PixelCount/sum(tbl.PixelCount);

bar(1:numel(classes),frequency)
xticks(1:numel(classes))
xticklabels(tbl.Name)
xtickangle(45)
ylabel('Frequency')


[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionCamVidData(imds,pxds);


numTrainingImages = numel(imdsTrain.Files)
numValImages = numel(imdsVal.Files)
numTestingImages = numel(imdsTest.Files)




% Specify the number of classes.
numClasses = numel(classes);

% Create DeepLab v3+.
lgraph = helperDeeplabv3PlusResnet18(imageSize, numClasses);


imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq


pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);

% Define validation data.
pximdsVal = pixelLabelImageDatastore(imdsVal,pxdsVal);

% Define training options.
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.3,...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.005, ...
    'ValidationData',pximdsVal,...
    'MaxEpochs',30000, ...
    'MiniBatchSize',16, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', tempfold, ...
    'ExecutionEnvironment','multi-gpu',...
    'VerboseFrequency',2,...
    'Plots','training-progress'); ...
    

augmenter = imageDataAugmenter('RandXReflection',true,...
    'RandXTranslation',[-10 10],'RandYTranslation',[-10 10]);


pximds = pixelLabelImageDatastore(imdsTrain,pxdsTrain, ...
    'DataAugmentation',augmenter);

doTraining = true;
if doTraining
    [net, info] = trainNetwork(pximds,lgraph,options);
else
    data = load(pretrainedNetwork);
    net = data.net;
end


I = readimage(imdsTest,5);
C = semanticseg(I, net);


B = labeloverlay(I,C,'Colormap',cmap,'Transparency',0.4);
imshow(B)
pixelLabelColorbar(cmap, classes);

repeatnum=1;
currentfoldername=['fold_model_' num2str(repeatnum)];
save(sprintf('%s.mat',currentfoldername),'net','info');

%
% expectedResult = readimage(pxdsTest,35);
% actual = uint8(C);
% expected = uint8(expectedResult);
% imshowpair(actual, expected)
%
%
% iou = jaccard(C,expectedResult);
% table(classes,iou)
%
% pxdsResults = semanticseg(imdsTest,net, ...
%     'MiniBatchSize',4, ...
%     'WriteLocation',tempfold, ...
%     'Verbose',false);
%
%
% metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
%
%
% metrics.DataSetMetrics