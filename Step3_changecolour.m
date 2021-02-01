clc
clear
close all
addpath function

labelDir ='D:\Nick_image\traincell\ori\';
labelDir_mask ='D:\Nick_image\traincell\mask\';

outori ='D:\Nick_image\traincell\ori_out\';
outmask ='D:\Nick_image\traincell\mask_out\';

if ~exist(outmask, 'dir')
    mkdir(outmask)
end

if ~exist(outori, 'dir')
    mkdir(outori)
end


imagefiles = dir([labelDir '*.png']);
nfilesmask = length(imagefiles);



for ii=1:nfilesmask
    currentfilename= imagefiles(ii).name;
    [pathstr,subname,ext] = fileparts(currentfilename);
    readinputimage=uint8(imread( [labelDir subname '.png'] ));
    readinputimage=normalizeStainingsimple(readinputimage);
    imwrite(readinputimage, [outori subname '.png']);
    clear readinputimage
    
    
    readinputimage=uint8(imread( [labelDir_mask subname '.png'] )); 
    readinputimage(readinputimage>3)=150; 
    readinputimage(readinputimage==2)=100;
    readinputimage(readinputimage==3)=100; 
    readinputimage(readinputimage==1)=50; 
    readinputimage(readinputimage==0)=1;
    
    
    Seudocolor = cat(3, readinputimage, readinputimage, readinputimage);
    
    imwrite(Seudocolor, [outmask subname '.tif']);
    
end