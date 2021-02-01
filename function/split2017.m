function bwbwredfinal=split2017(originalimage,sigma,threshlimit)

imb=originalimage;


% sigma=2;
kernel = fspecial('gaussian',4*sigma+1,sigma);
im2=imfilter(imb,kernel,'symmetric');
L = watershed(max(im2(:))-im2);
% [x,y]=find(L==0);

tmp=zeros(size(imb));
% max(L(:))
for i=1:max(L(:))
    
    ind=find(L==i);
    %   mask=L==i;
    [thr,metric] =multithresh(im2(ind),1);
    if metric>threshlimit
        tmp(ind)=im2(ind)>thr;
        
    end
end

bwbwredfinal=imopen(tmp,strel('disk',1));




% figure,imagesc(tmp),axis image
