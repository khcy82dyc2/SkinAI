clc
clear
close all
addpath function
PathNameRGBori= 'Y:\Eczema Methotrexate\**\';
PathNameRGBseg= 'D:\Nick_image\image_out_nick\';
imagefiles = dir([PathNameRGBori '*.svs*']);
nfiles = length(imagefiles);
for ii=1:nfiles
    clearvars -except ii nfiles imagefiles PathNameRGB PathNameRGBori PathNameRGBmain PathNameRGBseg
    currentfilename= imagefiles(ii).name;
    currentfoldername= imagefiles(ii).folder;
    [pathstr,subname,ext] = fileparts(currentfilename);
    
    %     [pathstrfold,subnamefold,extfold] = fileparts(currentfoldername);
    
    %      datamaskeos =  imfinfo([currentfoldername '\' subname ext]);
    %     %     subnamez='D:\image_folder\nick2\images\NFAT5\433595.svs';
    %     %     datamasksmall =  imread([subnamez],4);
    %     %     datamaskbig =  imread([subnamez],1);
    
    
    
    datamaskbig =  imread([currentfoldername '\' subname ext],1);
    %       datamasksmall =  imread([currentfoldername '\' subname ext],4);
    datamasksmall =  imresize(datamaskbig,0.0625);
    
    
    datamaskbig=imresize(datamaskbig,0.5, 'nearest');
    hsvii=3;
    rgbii=1;
    oriimage=datamasksmall;
    hsvimg=(rgb2hsv(oriimage));
    rgbimage=(oriimage);
    rgbimageim=double(imcomplement(rgbimage(:,:,rgbii)));
    hsvimgim=double(imcomplement(hsvimg(:,:,hsvii)));
    rgbimage=double(oriimage);
    grascalecombi4=mat2gray(rgbimage(:,:,rgbii).*hsvimg(:,:,hsvii));
    level = graythresh(grascalecombi4);
    BW = imbinarize(grascalecombi4,level);
    BW233=imclose(~BW,ones(20,20));
    BW233 = bwareaopen(BW233,5000);
    
    
    if exist([PathNameRGBseg subname 'seg1.png'],'file')==2
        
         
       imageout= imread([PathNameRGBseg subname 'seg1.png']);
        
    else
        imageout=mydeepseg_cic_Nonorm_derm(datamaskbig,'fold_model_1.mat',1,50,BW233,1);
        
        
        if ~exist(PathNameRGBseg,'dir')
            mkdir(PathNameRGBseg);
        end
        
        imwrite(imageout,[PathNameRGBseg subname 'seg1.png']);
        
    end
    
    clear datamaskbig
    imageout=imageout==1;
    imageout=imclose(imageout,ones(10,10));
    imageout = bwareaopen(imageout,20000);
    imageout = ~bwareaopen(~imageout,1000);
    %     imageout=imresize(imageout,2,'nearest');
    
    
    
    imwrite(imageout,[PathNameRGBseg subname '.png']);
    
    imwrite(datamasksmall,[PathNameRGBseg subname '_ori.jpg']);
    
    %     imageout=imresize(imageout,2,'nearest');
    
    siz=size(imageout); % image dimensions
    % Label the disconnected foreground regions (using 8 conned neighbourhood)
    L=bwlabel(imageout);
    
    clear imageout
    % Get the bounding box around each object
    bb=regionprops(L,'BoundingBox');
    % Crop the individual objects and store them in a cell
    n=max(L(:)); % number of objects
    ObjCell=cell(n,1);
    for i=1:n
        datamasksegbk=L==i;
        
        
        bb_i=ceil(bb(i).BoundingBox);
        idx_x=[bb_i(1)-100 bb_i(1)+bb_i(3)+100];
        idx_y=[bb_i(2)-100 bb_i(2)+bb_i(4)+100];
        if idx_x(1)<1, idx_x(1)=1; end
        if idx_y(1)<1, idx_y(1)=1; end
        if idx_x(2)>siz(2), idx_x(2)=siz(2); end
        if idx_y(2)>siz(1), idx_y(2)=siz(1); end
        
        %                aaa=  imread([subnamez],1,'PixelRegion',{[idx_y(1)*2,idx_y(2)*2],[idx_x(1)*2,idx_x(2)*2]});
        
        aaa=  imread([currentfoldername '\' subname ext],1,'PixelRegion',{[idx_y(1)*2,idx_y(2)*2],[idx_x(1)*2,idx_x(2)*2]});
        aaaseg=datamasksegbk(idx_y(1):idx_y(2),idx_x(1):idx_x(2),:);
        aaa=imresize(aaa,size(aaaseg));
        Acolour = imoverlay(im2uint8(aaa),imdilate(edge(aaaseg)>0,ones(20,20)), [1 0 0] );
        
        subfolder=[PathNameRGBseg 'thumb2\'];
        
        if ~exist(subfolder,'dir')
            mkdir(subfolder);
        end
        
        imwrite( imresize(Acolour,0.2),[subfolder subname '_' num2str(i) '.jpg']);
        
    end
    
    
    %     a
end
