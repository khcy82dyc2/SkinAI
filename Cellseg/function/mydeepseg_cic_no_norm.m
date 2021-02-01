function imageout=mydeepseg_cic_no_norm(imagedata,currentfoldername,resizefactor,shiftmove,datapadsmallbw,multiplev)
% shiftmove=shiftmove*multiplev;
% imagefolder=sprintf('G:\\Dropbox\\images\\DeepButton\\%s',currentfoldername);
load(currentfoldername)
imagesizenew=net.Layers(1, 1).InputSize;

% databigcrop = imagedata;
[xxxx yyyy zzzz]=size(imagedata);
data=imresize(imagedata,resizefactor, 'nearest');
[xxxx3 yyyy3 zzzz3]=size(data);
clear imagedata
% shiftmove=100;
xxrow=imagesizenew(1)*multiplev;
yyrow=imagesizenew(2)*multiplev;
datapad = padarray(data,[shiftmove+xxrow shiftmove+yyrow],'both');
clear data
[xxxx2 yyyy2 zzzz2]=size(datapad);
finalbigcell= uint8(zeros(xxxx2,yyyy2));
datapadsmallbw=imresize(datapadsmallbw,[xxxx3 yyyy3], 'nearest');
datapadsmallbw = padarray(datapadsmallbw,[shiftmove+xxrow shiftmove+yyrow],0,'both');
%  datapadsmallbw = padarray(datapadsmallbw,[shiftmove+xxrow shiftmove+yyrow],1,'both');
%         xxnum=0;
for xx1=0:(xxrow-shiftmove-shiftmove):xxxx2
    for yy1=0:(yyrow-shiftmove-shiftmove):yyyy2
        try
            imagecropbw=(datapadsmallbw(xx1+1:xx1+xxrow,yy1+1:yy1+yyrow));
            if (sum(sum(imagecropbw==1))/sum(sum(imagecropbw>-99)))>0.1
                %             newmultiimage= uint8(zeros(xxrow,yyrow));
                imagecrop=im2uint8(datapad(xx1+1:xx1+xxrow,yy1+1:yy1+yyrow,1:3));
                
                
                %                 figure,imshow(imagecrop)
                %                   imagecrop = normalizeStainingsimple(imagecrop);
                %                 figure,imshow(imagecrop)
                C = semanticseg(imagecrop, net);
                
                %                 newmultiimage = labeloverlay(imagecrop, C,'ColorMap','jet','Transparency',0);
                newmultiimage= uint8(zeros(xxrow,yyrow));
                newmultiimage(C=='N1')=1;
                newmultiimage(C=='N2')=2;
                newmultiimage(C=='N3')=3;
                newmultiimage(C=='N4')=4;
                %                 newmultiimage(C=='N5')=5;
                %                 newmultiimage(C=='N6')=6;
                %                 newmultiimage(C=='N7')=7;
                
                newmultiimage=newmultiimage(shiftmove+1:end-shiftmove,shiftmove+1:end-shiftmove,:);
                [newsizexxx newsizeyyy newsizezzzz]=size(newmultiimage);
                finalbigcell(xx1+1+shiftmove:xx1+shiftmove+newsizexxx,yy1+1+shiftmove:yy1+shiftmove+newsizeyyy,:)=newmultiimage;
                %                 1
            end
        catch
            %               1
        end
    end
end

finaldatathis=finalbigcell(1+xxrow+shiftmove:end-xxrow-shiftmove, 1+yyrow+shiftmove:end-yyrow-shiftmove);
imageout=imresize(finaldatathis,[xxxx yyyy], 'nearest');
% figure,imshow(finaldatathis,[])