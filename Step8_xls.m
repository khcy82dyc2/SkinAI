clc
clear
close all
% D:\Nick_image\image_out_nick\thumb2\new_ori_seg\

PathNameRGBrgb= 'D:\Nick_image\image_out_nick\thumb2\new_ori_seg\';
PathNameRGBori= 'D:\Nick_image\image_out_nick\thumb2\new_ori_seg\segcell\';
imagefiles = dir([PathNameRGBori '*_bluecell.png*']);
nfiles = length(imagefiles);


% xlsinfor1={newStrori, wholearea_epi,wholearea_below,num_cell_blue_Epi,num_cell_blue_Below,num_cell_brown_Epi,num_cell_brown_Below,Blue_epi,Blue_below,Brown_epi,Brown_below,Percentage_area_Blue_epi,Percentage_area_Blue_below,Percentage_area_Brown_epi,Percentage_area_Brown_below,Percentage_num_Blue_epi,Percentage_num_Blue_below,Percentage_num_Brown_epi,Percentage_num_Brown_below,cell_brown_Epi_averageintensity,cell_brown_Below_averageintensity };


xlsinfor4={'Stain','Image numer','FileName','Number of Brown Cells/um (epidermis)', 'Number of Brown Cells/um (below)','Number of Brown Cells/pixel (epidermis)','Number of Brown Cells/pixel (below)',...
    'Percentage of Brown Cells (epidermis)','Percentage of Brown Cells (below)',...
    'Average Brown Signal/um (epidermis)','Average Brown Signal/um (below)','Average Brown Signal/pixel (epidermis)','Average Brown Signal/pixel (below)',...
    'Average Brown Signal/cell (epidermis)','Average Brown Signal/cell (below)'...
    'Area (Pixel,epidermis)','Area (Pixel,below)','Area (Pixel,um)','Area (epidermis,um)',...
    'Number of Blue Cells (epidermis)','Number of Blue Cells (below)','Number of Brown Cells (epidermis)','Number of Brown Cells (below)',...
    'Brown Total Intensity (epidermis)','Brown Total Intensity (below)'};


% xlsinfor4={'filename', 'wholearea_epi','wholearea_below','num_cell_blue_Epi','num_cell_blue_Below','num_cell_brown_Epi','num_cell_brown_Below','Blue_epi','Blue_below','Brown_epi','Brown_below','Percentage_area_Blue_epi','Percentage_area_Blue_below','Percentage_area_Brown_epi','Percentage_area_Brown_below','Percentage_num_Blue_epi','Percentage_num_Blue_below','Percentage_num_Brown_epi','Percentage_num_Brown_below','cell_brown_Epi_averageintensity','cell_brown_Below_averageintensity'};
filename1 = 'Nick_new_normalisedsignalz_newcell.xlsx';
xlswrite(filename1,xlsinfor4,1,sprintf('A%d',1));



for ii=1:nfiles
    currentfilename= imagefiles(ii).name;
    [pathstr,subname,ext] = fileparts(currentfilename);
    newStrori = strrep(subname,'_bluecell','');
    
    
    imageumberfile = strrep(currentfilename,'_bluecell','');
    imageumberfile = extractBetween(imageumberfile,'_','.png');
    imageumberfile=imageumberfile{1}; %%order
    
    realname = strrep(newStrori,['_' imageumberfile],'');
    
    X = readtable('MTX.xlsx');
    selectedrow = find(strcmp(X.x_svsFileName, realname)==1);
    try
        stainname=X.Folder{selectedrow};  %%staub
    catch
        stainname='unknown';
    end
    
    
    
    
    
    image_ori =  imread([PathNameRGBrgb newStrori ext]);
    
    image_blue =  imread([PathNameRGBori newStrori '_bluecell' ext])>0;
    image_brown =  imread([PathNameRGBori newStrori '_browncell' ext])>0;
    image_segepi =  imread([PathNameRGBori newStrori '_seg' ext])>0;
    image_segbelow =  imread([PathNameRGBori newStrori '_segbelow' ext])>0;
    
    %cell images
    cell_blue_Epi=(image_blue+image_segepi)>1;
    cell_blue_Below=(image_blue+image_segbelow)>1;
    cell_brown_Epi=(image_brown+image_segepi)>1;
    cell_brown_Below=(image_brown+image_segbelow)>1;
    
    %regional area
    wholearea_epi= sum(sum(image_segepi));
    wholearea_below= sum(sum(image_segbelow));
    wholearea_epi_um= sum(sum(image_segepi>0))*0.252*0.252;
    wholearea_below_um= sum(sum(image_segbelow>0))*0.252*0.252;
    
    
    %number of cells
    [L,num_cell_blue_Epi] = bwlabel(cell_blue_Epi);
    [L,num_cell_blue_Below] = bwlabel(cell_blue_Below);
    [L,num_cell_brown_Epi] = bwlabel(cell_brown_Epi);
    [L,num_cell_brown_Below] = bwlabel(cell_brown_Below);
    
    
    %     %number of cell pixels
    %     Blue_epi= sum(sum(cell_blue_Epi));
    %     Blue_below= sum(sum(cell_blue_Below));
    %     Brown_epi= sum(sum(cell_brown_Epi));
    %     Brown_below= sum(sum(cell_brown_Below));
    %     )
    invertedimage= im2double(imcomplement(rgb2gray(image_ori)));
    %average cell intensity
    stats2 = regionprops(cell_brown_Epi,invertedimage,'MeanIntensity');
    stat2cell1 = cell2mat(struct2cell(stats2));
    cell_brown_Epi_averageintensity=mean(stat2cell1);
    
    stats2 = regionprops(cell_brown_Below,invertedimage,'MeanIntensity');
    stat2cell1 = cell2mat(struct2cell(stats2));
    cell_brown_Below_averageintensity=mean(stat2cell1);
    
    
    %total intensity
    gray_cell_brown_Epi=invertedimage;
    gray_cell_brown_Epi(cell_brown_Epi==0)=0;
    gray_cell_brown_Epi_totalintesity=sum(sum(gray_cell_brown_Epi));
    
    gray_cell_brown_Below=invertedimage;
    gray_cell_brown_Below(cell_brown_Below==0)=0;
    gray_cell_brown_Below_totalintesity=sum(sum(gray_cell_brown_Below));
    
    
    %number per area
    Num_Brown_epi_cell_per_um=num_cell_brown_Epi/wholearea_epi_um;
    Num_Brown_below_cell_per_um=num_cell_brown_Below/wholearea_below_um;
    Num_Brown_epi_cell_per_pixel =num_cell_brown_Epi/wholearea_epi;
    Num_Brown_below_cell_per_pixel=num_cell_brown_Below/wholearea_below;
    
    %percentage cell
    Percentage_Brown_epi_vs_blue=num_cell_brown_Epi/(num_cell_brown_Epi+num_cell_blue_Epi);
    Percentage_Brown_below_vs_blue=num_cell_brown_Below/(num_cell_brown_Below+num_cell_blue_Below);
    
    %signal per area
    Brown_Signal_epi_per_um= gray_cell_brown_Epi_totalintesity/wholearea_epi_um;
    Brown_Signal_below_per_um= gray_cell_brown_Below_totalintesity/wholearea_below_um;
    Brown_Signal_epi_per_pixel=gray_cell_brown_Epi_totalintesity/wholearea_epi;
    Brown_Signal_below_per_pixel=gray_cell_brown_Below_totalintesity/wholearea_below;
    
    %average signal per cell
    Average_signal_percell_epi=cell_brown_Epi_averageintensity;
    Average_signal_percell_below=cell_brown_Below_averageintensity;
    
    
    
    
    
    %        wholearea_epi= sum(sum(image_segepi));
    %     wholearea_below= sum(sum(image_segbelow));
    %     wholearea_epi_um= sum(sum(image_segepi>0))*0.252*0.252;
    %     wholearea_below_um= sum(sum(image_segbelow>0))*0.252*0.252;
    %
    %
    %     %number of cells
    %     [L,num_cell_blue_Epi] = bwlabel(cell_blue_Epi);
    %     [L,num_cell_blue_Below] = bwlabel(cell_blue_Below);
    %     [L,num_cell_brown_Epi] = bwlabel(cell_brown_Epi);
    %     [L,num_cell_brown_Below] = bwlabel(cell_brown_Below);
    %
    %
    %
    
    xlsinfor1={stainname, imageumberfile, newStrori,...
        Num_Brown_epi_cell_per_um, Num_Brown_below_cell_per_um,Num_Brown_epi_cell_per_pixel,Num_Brown_below_cell_per_pixel,...
        Percentage_Brown_epi_vs_blue,Percentage_Brown_below_vs_blue,...
        Brown_Signal_epi_per_um,Brown_Signal_below_per_um,Brown_Signal_epi_per_pixel,Brown_Signal_below_per_pixel,...
        Average_signal_percell_epi,Average_signal_percell_below,...
        wholearea_epi,wholearea_below,wholearea_epi_um,wholearea_below_um,...
        num_cell_blue_Epi,num_cell_blue_Below,num_cell_brown_Epi,num_cell_brown_Below,...
        gray_cell_brown_Epi_totalintesity,gray_cell_brown_Below_totalintesity};
    
    
    
    
    
    %     Percentage_area_Blue_epi=Blue_epi/wholearea_epi;
    %     Percentage_area_Blue_below=Blue_below/wholearea_below;
    %     Percentage_area_Brown_epi=Brown_epi/wholearea_epi;
    %     Percentage_area_Brownweak_epi=Brownweak_epi/wholearea_epi;
    %     Percentage_area_Brown_below=Brown_below/wholearea_below;
    %
    %     Percentage_num_Blue_epi=num_cell_blue_Epi/wholearea_epi;
    %     Percentage_num_Blue_below=num_cell_blue_Below/wholearea_below;
    %     Percentage_num_Brown_epi=num_cell_brown_Epi/wholearea_epi;
    %     Percentage_num_Brownweak_epi=num_cell_brownweak_Epi/wholearea_epi;
    %     Percentage_num_Brown_below=num_cell_brown_Below/wholearea_below;
    
    %     hsvii=2;
    %     rgbii=3;
    %     oriimage=image_ori;
    %     hsvimg=(rgb2hsv(oriimage));
    %     rgbimage=(oriimage);
    %     rgbimageim=double(imcomplement(rgbimage(:,:,rgbii)));
    %     grascalecombi7= ( (rgbimageim.*hsvimg(:,:,hsvii)));
    %     im=grascalecombi7;
    %     im=(im-min(im(:)))/(max(im(:))-min(im(:)));
    %     grascalecombi7=im;
    
    
    
    
    
    
    %
    %     stats2 = regionprops(cell_brownweak_Epi,rgb2gray(image_ori),'MeanIntensity');
    %     stat2cell1 = cell2mat(struct2cell(stats2));
    %     cell_brownweak_Epi_averageintensity=mean(stat2cell1);
    %
    %     stats2 = regionprops(cell_brownweak_Below,rgb2gray(image_ori),'MeanIntensity');
    %     stat2cell1 = cell2mat(struct2cell(stats2));
    %     cell_brownweak_Below_averageintensity=mean(stat2cell1);
    
    %     oriimage= imoverlay(im2uint8(image_ori),imdilate(edge(image_areaout)>0,ones(3,3)), [0 1 0] );
    %     oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(image_area)>0,ones(3,3)), [1 0 0] );
    %
    %     oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_blue_Epi)>0,ones(3,3)), [0 0 1] );
    %     oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_blue_Below)>0,ones(3,3)), [1 1 0] );
    %     oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_brown_Epi)>0,ones(3,3)), [1 0 1] );
    %     oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_brown_Below)>0,ones(3,3)), [0 1 1] );
    %
    %     oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_brownweak_Epi)>0,ones(3,3)), [0.5 0 0.5] );
    %     oriimage= imoverlay(im2uint8(oriimage),imdilate(edge(cell_brownweak_Below)>0,ones(3,3)), [0 0.5 0.5] );
    %
    %     subfolder='F:\image_folder\nick\skinfolder\results2\final2\';
    %     imwrite( oriimage,sprintf('%s%s_ov.jpg',subfolder,newStrori));
    %     imwrite( image_ori,sprintf('%s%s.jpg',subfolder,newStrori));
    %
    
    %     xlsinfor1={newStrori, wholearea_epi,wholearea_below,num_cell_blue_Epi,num_cell_blue_Below,num_cell_brown_Epi,num_cell_brown_Below,Blue_epi,Blue_below,Brown_epi,Brown_below,Percentage_area_Blue_epi,Percentage_area_Blue_below,Percentage_area_Brown_epi,Percentage_area_Brown_below,Percentage_num_Blue_epi,Percentage_num_Blue_below,Percentage_num_Brown_epi,Percentage_num_Brown_below,cell_brown_Epi_averageintensity,cell_brown_Below_averageintensity };
    
    
    keep_tryinga = true;
    
    while keep_tryinga
        keep_tryinga = false;
        try
            [Nnn, Ttt, configinfo2a]=xlsread(filename1,1);
            [xlscolum2a,xlsrow]=size(configinfo2a);
            tt1a=xlscolum2a+1;
            xlswrite(filename1,xlsinfor1,1,sprintf('A%d',tt1a));
        catch
            
            keep_tryinga = true;
        end
        
    end
end
% end