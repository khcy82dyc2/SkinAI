clc
clear
close all
addpath function

labelDir ='D:\Nick_image\traincellcell\ori\';
labelDir_mask ='D:\Nick_image\traincellcell\mask\';

outori ='D:\Nick_image\traincellcell\ori_out\';
outmask ='D:\Nick_image\traincellcell\mask_out\';

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
%     readinputimage=normalizeStainingsimple(readinputimage);
    imwrite(readinputimage, [outori subname '.png']);
    clear readinputimage
    
    
    readinputimageold=uint8(imread( [labelDir_mask subname '.png'] ));
    readinputimage=uint8(readinputimageold<99);
    readinputimage(readinputimageold==7)=150; %"pos_mem"
    readinputimage(readinputimageold==8)=150; %"pos_mem"
    readinputimage(readinputimageold==9)=100; %"neg_mem"
    readinputimage(readinputimageold==10)=50; %"pos_nuc"
    readinputimage(readinputimageold==11)=50; %"pos_nuc"
    readinputimage(readinputimageold==12)=10; %"neg_nuc"
    readinputimage(readinputimageold==0)=1; %"other"
    
     
    
    
    Seudocolor = cat(3, readinputimage, readinputimage, readinputimage);
    
    imwrite(Seudocolor, [outmask subname '.tif']);
    
end