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
    imageout=imread([PathNameRGBseg subname '.png']);
    
    aaainfo=  imfinfo([currentfoldername '\' subname ext]);
    imageout=imresize(imageout,[ aaainfo(1).Height aaainfo(1).Width],'nearest');
    
    
    %     multipllll= round(aaainfo(1).Width/ aaainfo(5).Width);
    
    datamasksmall=imread([PathNameRGBseg subname '_ori.jpg']);
    L=bwlabel(imageout);
    n=max(L(:)); % number of objects
    im=imageout>10;
    clear imageout
    subfolder=[PathNameRGBseg 'thumb2\'];
    for i=1:n
        
        if exist([subfolder subname '_' num2str(i) '.jpg'],'file')==2
            datamasksegbk=L==i;
            im(datamasksegbk==1)=1;
        end
    end
    clear datamasksegbk L
    
    im_large=imresize(imclose(imresize(im,0.01),ones(150,150)),size(im))>0;
    %     im_large=im;
    siz=size(im_large); % image dimensions
    L=bwlabel(im_large);
    bb=regionprops(L,'BoundingBox');
    n=max(L(:)); % number of objects
    ObjCell=cell(n,1);
    
    
    
    %     tagimge=  imread([currentfoldername '\' subname ext],5);
    tagimge= imoverlay(im2uint8(datamasksmall),imdilate(edge(imresize(im,size(datamasksmall(:,:,1))))>0,ones(5,5)), [1 0 0] );
    
    sizeimagetag=size(tagimge);
    sizeimagetag=sizeimagetag(1);
    
    sizeimagebn=size(im);
    sizeimagebn=sizeimagebn(1);
    multipllll= round(sizeimagebn/sizeimagetag);
    
    locationfile=[subfolder 'location4_1\'];
    if ~exist(locationfile,'dir')
        mkdir(locationfile);
    end
    
    for i=1:n
        bb_i=ceil(bb(i).BoundingBox);
        idx_x=[bb_i(1)-100 bb_i(1)+bb_i(3)+100];
        idx_y=[bb_i(2)-100 bb_i(2)+bb_i(4)+100];
        if idx_x(1)<1, idx_x(1)=1; end
        if idx_y(1)<1, idx_y(1)=1; end
        if idx_x(2)>siz(2), idx_x(2)=siz(2); end
        if idx_y(2)>siz(1), idx_y(2)=siz(1); end
        
        tagimge = insertText(tagimge,[idx_x(1)/multipllll idx_y(1)/multipllll],[num2str(i)],'FontSize',80);
    end
    imwrite(tagimge,[locationfile subname '.jpg']);
    
    
    
    for i=1:n
        %         datamasksegbk=L==i;
        bb_i=ceil(bb(i).BoundingBox);
        idx_x=[bb_i(1)-100 bb_i(1)+bb_i(3)+100];
        idx_y=[bb_i(2)-100 bb_i(2)+bb_i(4)+100];
        if idx_x(1)<1, idx_x(1)=1; end
        if idx_y(1)<1, idx_y(1)=1; end
        if idx_x(2)>siz(2), idx_x(2)=siz(2); end
        if idx_y(2)>siz(1), idx_y(2)=siz(1); end
        
        
        aaa=  imread([currentfoldername '\' subname ext],1,'PixelRegion',{[idx_y(1),idx_y(2)],[idx_x(1),idx_x(2)]});
        
        
        aaaseg=im(idx_y(1):idx_y(2),idx_x(1):idx_x(2),:);
        %
        subfolder2=[subfolder 'new_ori_seg\'];
        
        if ~exist(subfolder2,'dir')
            mkdir(subfolder2);
        end
        imwrite(aaa,sprintf('%s%s_%04d.png',subfolder2,subname,i));
        
        
        subfolder3=[subfolder2 'segfile\'];
         if ~exist(subfolder3,'dir')
            mkdir(subfolder3);
        end
        imwrite( aaaseg,sprintf('%s%s_%04d_seg.png',subfolder3,subname,i)); 
    end
end
