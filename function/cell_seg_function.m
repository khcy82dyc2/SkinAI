function [finalblue, finalbrown]=cell_seg_function(aaa)

% aaa=image_ori;
datamasksmall=imresize(aaa,0.2);


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


imageout=mydeepseg_cic_no_norm_cell(aaa,'AI_cell_new.mat',1,50,BW233,1);
%  imageout=mydeepseg_cic_Nonorm2(aaa,'skin22colorcellll.mat',1,50,BW233,1);



cmap = rgb2hsv(aaa);
haha1=cmap(:,:,1)>0.2;
haha2=cmap(:,:,1)<0.9;
bluecolour=(haha1+haha2)>1;

hsvii=2;
rgbii=3;
oriimage=aaa;
hsvimg=(rgb2hsv(oriimage));
rgbimage=(oriimage);
rgbimageim=double(imcomplement(rgbimage(:,:,rgbii)));
%         grascalecombi7=im2uint8(mat2gray(rgbimageim.*hsvimg(:,:,hsvii)));
grascalecombi7= ( (rgbimageim.*hsvimg(:,:,hsvii)));


im=grascalecombi7;
im=(im-min(im(:)))/(max(im(:))-min(im(:)));
grascalecombi7=im;

grascalecombi7bluecell=grascalecombi7;
grascalecombi7bluecell(bluecolour==0)=0;

grascalecombi7brown=grascalecombi7;
grascalecombi7brown(bluecolour==1)=0;

level = graythresh(grascalecombi7bluecell);
BW = imbinarize(grascalecombi7bluecell,level);
BWblue = bwareaopen(BW,10);


newmultiimagesoam=imbinarize(grascalecombi7brown);

% newmultiimagesoam=adaptivethreshold(grascalecombi7brown,500,-0.01);
BWbrown = bwareaopen(newmultiimagesoam,10);



% image_brownweak=imageout==1;
image_brownstrong=imageout==1;
image_brown = bwareaopen((image_brownstrong+BWbrown)>0,100);


image_blue=imageout==3;
image_blue=imclose(image_blue,ones(5,5));
image_blue=(image_blue+BWblue)>0;
image_blue = bwareaopen((image_blue-image_brown)>0,100);


V1=grascalecombi7brown.*im2double(image_brown);

%         V1small=imresize(V1,0.5);
finalbrown=split2017( (V1),7,0.6)>0;
finalbrown = bwareaopen(finalbrown,100);

V1=grascalecombi7bluecell.*im2double(image_blue);
finalblue=split2017( (V1),7,0.6)>0;
finalblue = bwareaopen(finalblue,100);
