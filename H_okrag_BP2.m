clc;
clear;

[I,map]=imread('circles.jpg');
colormap(map);
Io=rgb2gray(I); %zmiana obrazu na odcienie szarosci
Io=edge(Io,'canny'); % zastosowanie na obrazie filtru 'canny'

[row, col, deep]=size(I); %przypisanie rozmiar�w obrazu do zmiennych
r_min=5; %minimalny rozwazany promien okregu
r_max=90; %maksymalny rozwazany promien okregu

%Przestrzen powiekszona o mozliwe kola "wykraczajace" poza obszar
H=zeros(row+2*r_max,col+2*r_max,r_max-r_min+1); %przestrzen Hougha

Xp=[]; Yp=[];
%lista pikseli aktywnych obrazu
lpa=0; %liczba pikseli aktywnych
for x=1:col
    for y=row:-1:1
        if I(y,x)==0 %piksele aktywne obrazu
            Xp=[Xp x];
            Yp=[Yp y];
            lpa=lpa+1;
        end
    end
end

for r=r_min:r_max %petla po rozwazanych promieniach okregow
    for xy=1:lpa %piksele aktywne obrazu
        x=Xp(xy);
        y=Yp(xy);
        for x0=x-r:x+r %rozwazany zasieg okregu x=(x-r,x+r)
            %wyznaczenie roznicy y-y0 z rownania okregu
            y_roznica=sqrt(r^2-(x-x0)^2);
            xz=x0+r_max;
            if y_roznica==0 %dla zerowej roznicy jeden punkt
                yz=y+r_max;
                H(yz,xz,r-r_min+1)=H(yz,xz,r-r_min+1)+1;
            else %w przeciwnym wypadku punkt "gorny" i punkt "dolny"
                y1=round(y-y_roznica); %"gorny" punkt
                y2=round(y+y_roznica); %"dolny" punkt
                H(y1+r_max,xz,r-r_min+1)=H(y1+r_max,xz,r-r_min+1)+1;
                H(y2+r_max,xz,r-r_min+1)=H(y2+r_max,xz,r-r_min+1)+1;
            end
        end
    end
end

prog=0.3; %minimalna czesc wykrytych pikseli
nHoodSize=[8 8 4]; %promien otoczenia w H
numpeaks=10;
okregi=zeros(0,6); % x ,y ,r ,Hmax/4r ,Hmax ,4r

nowyH=H;
for r=r_min:r_max
   for x=1:size(H,2)
        for y=1:size(H,1)
            nowyH(y,x,r-r_min+1)=nowyH(y,x,r-r_min+1)/(4*r);
        end
    end 
end

for n=1:numpeaks
   Hmax=max(nowyH(:));
   [y,x,ri]=ind2sub(size(nowyH),find(nowyH==Hmax,1));
   r=ri+r_min-1;
   c=4*r;
   if(Hmax>prog)
        okregi=[okregi;[y-r_max, x-r_max, r, Hmax, Hmax*c, c]];
        highY=min([floor(y+nHoodSize(1)) size(H,1)]);
        lowY=max([ceil(y-nHoodSize(1)) 1]);
        highX=min([floor(x+nHoodSize(2)) size(H,2)]);
        lowX=max([ceil(x-nHoodSize(2)) 1]);
        highR=min([floor(r+nHoodSize(3)) size(H,3)]);
        lowR=max([ceil(r-nHoodSize(3)) 1]);
        nowyH(lowY:highY,lowX:highX,lowR:highR)=0; 
   end
end
okregi = sortrows(okregi,-4); %posortowanie okregow malejaco

figure(1)
imshow(I), hold on;
title('Obraz z wykrytymi okregami');
for i = 1:size(okregi,1) %petla po wykrytych okregach
    y = okregi(i,2)-okregi(i,3); %wartosc y srodka okregu
    x = okregi(i,1)-okregi(i,3); %wartosc x srodka okregu
    w = 2*okregi(i,3); %do narysowania potrzebna jest srednica okregu
    rectangle('Position',[y x w w],'EdgeColor','blue','Curvature',[1 1]);
end
hold off;