clc
clear
close all

addpath function
% PathNameRGBori= 'Y:\Eczema Methotrexate\**\';
% PathNameRGBseg= 'D:\Nick_image\image_out_nick\';
parpool(7)

PathNameRGBori= 'D:\Nick_image\image_out_nick\thumb2\new_ori_seg\';
imagefiles = dir([PathNameRGBori '*.png*']);
nfiles = length(imagefiles);

%      aaaa=imread('F:\image_folder\nick\skinfolder\results2\thumb2\Rosetrees Test-005 (RT5 cyclin B1 - responder)_0001.png')


parfor ii=1:nfiles
    currentfilename= imagefiles(ii).name;
    [pathstr,subname,ext] = fileparts(currentfilename);
%     subname='433452_0002'
    %      if ~exist(subfolder,'dir')
    %         mkdir(subfolder);
    %     end
    
    zzzzzzzz=[PathNameRGBori 'final\'];
    %     imwrite( oriimage,sprintf('%s%s_ov.jpg',subfolder,subname));
    %     imwrite( image_ori,sprintf('%s%s.jpg',zzzzzzzz,subname));
    
    if exist(sprintf('%s%s.jpg',zzzzzzzz,subname),'file')==2
        zzzczxcxz=555;
    else
        
        
        
        
        %    subname= 'Rosetrees Test-004 (RT5 cyclin D1 - responder)_0001';
        image_ori =  imread([PathNameRGBori subname ext]);
        image_area =  imread([PathNameRGBori 'segfile\' subname '_seg' ext]);
        
        
        bb=regionprops(image_area,'BoundingBox','Centroid','Orientation','MinorAxisLength');
        % Crop the individual objects and store them in a cell
        im=image_area;
        L=bwlabel(im);
        n=max(L(:)); % number of objects
        ObjCell=cell(n,1);
        image_arealarge=image_area;
        for i=1:n
            im=L==i;
            angelsize=ceil(bb(i).Orientation);
            SE = strel('line',1500,angelsize+90);
            image_arealarge= (image_arealarge+imdilate(im,SE))>0;
            %             datamasksegenlarge=(datamasksegenlarge+J)>0;
        end
        
        
        
        [image_blue, image_brown]=cell_seg_function(image_ori);
        
        subfolder=[PathNameRGBori 'segcell\'];
        
        if ~exist(subfolder,'dir')
            mkdir(subfolder);
        end
        
        imwrite(image_blue,sprintf('%s%s_bluecell.png',subfolder,subname));
        imwrite( image_brown,sprintf('%s%s_browncell.png',subfolder,subname));
        imwrite( image_arealarge,sprintf('%s%s_seglarge.png',subfolder,subname));
        imwrite( image_area,sprintf('%s%s_seg.png',subfolder,subname));
        
        
        hsvii=3;
        rgbii=1;
        oriimage=image_ori;
        hsvimg=(rgb2hsv(oriimage));
        rgbimage=(oriimage);
        rgbimageim=double(imcomplement(rgbimage(:,:,rgbii)));
        hsvimgim=double(imcomplement(hsvimg(:,:,hsvii)));
        rgbimage=double(oriimage);
        grascalecombi4=mat2gray(rgbimage(:,:,rgbii).*hsvimg(:,:,hsvii));
        level = graythresh(grascalecombi4);
        BW = imbinarize(grascalecombi4,level);
        %         BW2 = bwareaopen(~BW,5000);
        BW233=imclose(~BW,ones(50,50));
        BW233 = ~bwareaopen(BW233,5000);
        
        belowarea=(image_arealarge-BW233-image_area)>0;
        imwrite( belowarea,sprintf('%s%s_segbelow.png',subfolder,subname));
        
        
        image_areaout=belowarea;
        
        cell_blue_Epi=(image_blue+image_area)>1;
        cell_blue_Below=(image_blue+image_areaout)>1;
        
        cell_brown_Epi=(image_brown+image_area)>1;
        cell_brown_Below=(image_brown+image_areaout)>1;
        
        
        oriimage= imoverlay(im2uint8(image_ori),imdilate(edge(image_areaout)>0,ones(3,3)), [0 1 0] );
        oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(image_area)>0,ones(3,3)), [1 0 0] );
        
        oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_blue_Epi)>0,ones(3,3)), [0 0 1] );
        oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_blue_Below)>0,ones(3,3)), [1 1 0] );
        oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_brown_Epi)>0,ones(3,3)), [1 0 1] );
        oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_brown_Below)>0,ones(3,3)), [0 1 1] );
        
        subfolder=[PathNameRGBori 'final\'];
        
        if ~exist(subfolder,'dir')
            mkdir(subfolder);
        end
        
        
        imwrite( oriimage,sprintf('%s%s_ov.jpg',subfolder,subname));
        imwrite( image_ori,sprintf('%s%s.jpg',subfolder,subname));
        
    end
end