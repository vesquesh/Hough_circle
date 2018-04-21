%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Segmentacja metod� projekcji wstecznej (backprojection)          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
H=zeros(row+2*r_max,col+2*r_max,r_max-r_min+1); %przestrze� Hougha

Xp=[]; Yp=[];
%lista pikseli aktywnych obrazu
lpa=0; %liczba pikseli aktywnych
for x=1:col
    for y=row:-1:1
        if Io(y,x)==1 %piksele aktywne obrazu
            Xp=[Xp x];
            Yp=[Yp y];
            lpa=lpa+1;
        end
    end
end

for r=r_min:r_max %petla po rozwa�anych promieniach okr�g�w
    for xy=1:lpa %piksele aktywne obrazu
        x=Xp(xy);
        y=Yp(xy);
        for x0=x-r:x+r %rozwazany zasieg okregu x=(x-r,x+r)
            %wyznaczenie roznicy y-y0 z rownania okr�gu
            y_roznica=sqrt(r^2-(x-x0)^2);
            xz=x0+r_max;
            if y_roznica==0 %dla zerowej roznicy jeden punkt
                yz=y+r_max;
                H(yz,xz,r-r_min+1)=H(yz,xz,r-r_min+1)+1;
            else %w przeciwnym wypadku punkt "g�rny" i punkt "dolny"
                y1=round(y-y_roznica); %"gorny" punkt
                y2=round(y+y_roznica); %"dolny" punkt
                H(y1+r_max,xz,r-r_min+1)=H(y1+r_max,xz,r-r_min+1)+1;
                H(y2+r_max,xz,r-r_min+1)=H(y2+r_max,xz,r-r_min+1)+1;
            end
        end
    end
end

prog=0.4; %minimalny czesc wykrytych pikseli
nHoodSize=[8 8 4]; %promien otoczenia w H

okregi=zeros(0,4); % x ,y ,r ,c (ilosc wykrytych punktow)/2*pi*r
for r=r_min:r_max %petla zmieniajaca wartosc rozwazanego promienia
    %skopiowanie warto�ci "plastra" z macierzy H dla danego promienia
    slice=H(:,:,r-r_min+1);
    c=2*pi*r; %rozwazana liczba pikseli dla okr�go
    slice(slice<(c*prog))=0;
    while max(slice(:))>0
        smax=max(slice(:));
        [y, x, liczba]=find(slice==smax,1); %wspolrzedne maksimum w H
        okregi=[okregi;[y-r_max, x-r_max, r*ones(length(x),1), liczba/c]];
        %wyznaczenie otoczenia maksimum lokalnego
        highY=min([floor(y+nHoodSize(1)) size(H,1)]);
        lowY=max([ceil(y-nHoodSize(1)) 1]);
        highX=min([floor(x+nHoodSize(2)) size(H,2)]);
        lowX=max([ceil(x-nHoodSize(2)) 1]);
        highR=min([floor(r+nHoodSize(3)) size(H,3)]);
        lowR=max([ceil(r-nHoodSize(3)) 1]);
        slice(lowY:highY,lowX:highX)=0; %wyzerowanie otoczenia "plastra"
        H(lowY:highY,lowX:highX,lowR:highR)=0; %wyzerowanie otoczenia w H
    end
end
okregi = sortrows(okregi,-4); %posortowanie okregow malejaco

figure(1)
imshow(I), hold on;
title('Obraz z wykrytymi okr�gami');
for i = 1:size(okregi,1) %petla po wykrytych okregach
    y = okregi(i,2)-okregi(i,3); %warto�� y �rodka okr�gu
    x = okregi(i,1)-okregi(i,3); %warto�� x �rodka okr�gu
    w = 2*okregi(i,3); %do narysowania potrzebna jest srednica okregu
    rectangle('Position',[y x w w],'EdgeColor','red','Curvature',[1 1]);
end
hold off;