function [circles]=Sort_circle(H,radius_range,threshold,nhoodsize,numpeaks)
circles=zeros(0,6);
r_min=radius_range(1);
r_max=radius_range(2);

newH=H;
for rn=r_min:r_max
   for xi=1:size(H,2)
      for yi=1:size(H,1)
         newH(yi,xi,rn-r_min+1)=newH(yi,xi,rn-r_min+1)/(4*rn); 
      end
   end
end

for n=1:numpeaks
    Hmax=max(newH(:));
    [y,x,ri]=ind2sub(size(newH),find(newH==Hmax,1));
    r=ri+r_min-1;
    c=4*r;
    if(Hmax>threshold)
        circles=[circles; [y-r_max,x-r_max, r, Hmax, Hmax*c, c]];
        highY=min([floor(y+nhhodsize(1)) size(H,1)]);
        lowY=max([ceil(y-nhoodsize(1)) 1]);
        highX=min([floor(x+nhhodsize(2)) size(H,2)]);
        lowX=max([ceil(x-nhoodsize(2)) 1]);
        highR=min([floor(r+nhhodsize(3)) size(H,3)]);
        lowR=max([ceil(r-nhoodsize(3)) 1]);
        newH(lowY:highY,lowX:highX,lowR:highR)=0;
    end
end
circles=sortrows(circles,-4);

end