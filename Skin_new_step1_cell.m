clc
clear
close all
addpath recentbk
PathNameRGBmain= 'D:\image_folder\annoatation\processimage2\';
PathNameRGBori= 'D:\image_folder\nick2\images\';
PathNameRGB= 'D:\image_folder\annoatation\cell_mask\';

imagefiles = dir([PathNameRGB '*-mask.png*']);
nfiles = length(imagefiles);
for ii=1:nfiles
    clearvars -except ii nfiles imagefiles PathNameRGB PathNameRGBori PathNameRGBmain
    currentfilename= imagefiles(ii).name;
    [pathstr,subname,ext] = fileparts(currentfilename);
    datamaskeos =  imread([PathNameRGB subname ext]);
    datamaskeosother=datamaskeos>0;
    
    se = strel('disk',50);
    datamaskeosother = imclose(datamaskeosother,se);
    
    subnameRGBmain = eraseBetween(subname,'.svs','-mask');
    subnameRGBmain = erase(subnameRGBmain,'-mask');
    stats = regionprops(datamaskeosother,'BoundingBox');
    sizestate= size(stats);
    convertsizeratio=3;
    %     databigcrop = imread([PathNameRGBori subnameRGBmain],1);
    
    searchfile=dir([PathNameRGBori '\**\']);
    indexsearch = find(strcmp({searchfile.name}, subnameRGBmain)==1);
    datamaskeosinfo = imfinfo([searchfile(indexsearch).folder '\' subnameRGBmain]);
    
    
    large40xinfo=datamaskeosinfo(1);
    %     datapadsmallbw=imresize(BW233,[large40xinfo.Height large40xinfo.Width], 'nearest')>0;
    
    for iibox=1:sizestate(1)
        iibox
        boundingboxpos=stats(iibox).BoundingBox;
        
        extenszie=0;
        boundingboxpos(1)=boundingboxpos(1)-extenszie;
        boundingboxpos(2)=boundingboxpos(2)-extenszie;
        boundingboxpos(3)=boundingboxpos(3)+(extenszie);
        boundingboxpos(4)=boundingboxpos(4)+(extenszie);
        
        poscrop=boundingboxpos*convertsizeratio;
        
        imagedata=  imread([searchfile(indexsearch).folder '\' subnameRGBmain],1,'PixelRegion',{[poscrop(2)+1,poscrop(2)+poscrop(4)],[poscrop(1)+1,poscrop(1)+poscrop(3)]});
        datamaskeos_small=imresize(imcrop(datamaskeos,boundingboxpos),size(imagedata(:,:,1)),'nearest');
        
        
        newdirstoragetrainori=fullfile(PathNameRGBmain, 'traincell\ori\');
        newdirstoragetrainmask=fullfile(PathNameRGBmain, 'traincell\mask\');
        newdirstoragetrainoverlay=fullfile(PathNameRGBmain, 'traincell\overlay\');
        
        if exist(newdirstoragetrainori, 'dir')
            
        else
            mkdir(newdirstoragetrainori)
        end
        
        if exist(newdirstoragetrainmask, 'dir')
            
        else
            mkdir(newdirstoragetrainmask)
        end
        
        if exist(newdirstoragetrainoverlay, 'dir')
            
        else
            mkdir(newdirstoragetrainoverlay)
        end
        
        
        
        imwrite(imagedata,[PathNameRGBmain 'traincell\' subnameRGBmain '_' num2str(iibox) '_ori' '.tif'])
        imwrite(datamaskeos_small,[PathNameRGBmain 'traincell\' subnameRGBmain '_' num2str(iibox) '_mask' '.tif'])
        
        imagedata=imresize(imagedata,1,'nearest');
        datamaskeos_small=imresize(datamaskeos_small,1,'nearest');
        
        
        
        windowsize=300;
        
        [xxxxxsize yyyysize]=size(datamaskeos_small);
        for xxi=1:200:xxxxxsize
            for yyi=1:200:yyyysize
                try
                    ori500=imagedata(xxi:xxi+windowsize-1,yyi:yyi+windowsize-1,:);
                    mask500=datamaskeos_small(xxi:xxi+windowsize-1,yyi:yyi+windowsize-1);
                    
                    if (sum(sum(rgb2gray(ori500)>240))/(windowsize*windowsize))<0.90
                        if (sum(sum(mask500==0))/(windowsize*windowsize))<0.95
                            %                             [ori5002] = normalizeStainingsimple(ori500);
                            imwrite(ori500,[newdirstoragetrainori subnameRGBmain '_' num2str(iibox) num2str(xxi) num2str(yyi)  '.png'])
                            %                             imwrite(ori500,['F:\image_folder\nick\skinfolder\2nd attempt (penny scanner)\traincell\orirgb\' subnameRGBmain '_' num2str(iibox) num2str(xxi) num2str(yyi)  '.tif'])
                            imwrite(uint8(mask500),[newdirstoragetrainmask subnameRGBmain '_' num2str(iibox) num2str(xxi) num2str(yyi) '.png'])
                            
                            imwrite(labeloverlay(ori500,uint8(mask500),'ColorMap',jet),[newdirstoragetrainoverlay subnameRGBmain '_' num2str(iibox) num2str(xxi) num2str(yyi) '.png'])
                            
                            
                            
                        end
                    end
                    %
                end
            end
        end
        
    end
    
end