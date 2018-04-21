%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Segmentacja metoda zliczania pikesli (pixel counting)           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;

[I,map]=imread('circles1.bmp');
colormap(map);
Io=rgb2gray(I); %zmiana obrazu na odcienie szarosci
%Io=edge(Io,'canny'); % zastosowanie na obrazie filtru 'canny'

[row, col, deep]=size(I); %przypisanie rozmiarow obrazu do zmiennych
r_min=5; %minimalny rozwazany promien okregu
r_max=90; %maksymalny rozwazany promien okregu

H=zeros(row,col,r_max-r_min+1); % tworzenie przestrzeni Hougha

Xp=[]; Yp=[];
%lista pikseli aktywnych obrazu
lpa=0; %liczba pikseli aktywnych
for x=1:col
    for y=row:-1:1
        if Io(y,x)==0 %piksele aktywne obrazu
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
        counter=0; %zmienna do zliczania pikseli
        x1=max([x-r 1]);
        x2=min([x+r size(Io,2)]);
        for x0=x1:x2 %rozwazany zasieg okregu x=(x-r,x+r)
            %wyznaczenie roznicy y-y0 z rownania okregu
            y_roznica=sqrt(r^2-(x-x0)^2);
            if y_roznica==0 %dla zerowej roznicy jeden punkt
                if Io(y,x0)
                   counter=counter+1;
                end
            else %w przeciwnym wypadku punkt "gorny" i punkt "dolny"
                y1=round(y-y_roznica); %"gorny" punkt
                y2=round(y+y_roznica); %"dolny" punkt
                if y1>0&&y1<(row+1)
                    if Io(y1,x0)
                        counter=counter+1; 
                    end
                end
                if y2>0&&y2<(row+1)
                    if Io(y2,x0)
                        counter=counter+1; 
                    end
                end
            end
        end
        H(y,x,r-r_min+1)=counter;
    end
end

prog=0.4; %minimalny czesc wykrytych pikseli
nHoodSize=[8 8 4]; %promien otoczenia w H

okregi=zeros(0,4); % x ,y ,r ,c (ilosc wykrytych punktow)/2*pi*r
for r=r_min:r_max %petla zmieniajaca wartosc rozwazanego promienia
    %skopiowanie wartosci "plastra" z macierzy H dla danego promienia
    slice=H(:,:,r-r_min+1);
    c=2*pi*r; %rozwazana liczba pikseli dla okregu
    slice(slice<(c*prog))=0;
    while max(slice(:))>0
        smax=max(slice(:));
        [y, x, liczba]=find(slice==smax,1); %wspolrzedne maksimum w H
        okregi=[okregi;[y, x, r*ones(length(x),1), liczba/c]];
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
title('Obraz z wykrytymi okregami');
for i = 1:size(okregi,1) %petla po wykrytych okregach
    y = okregi(i,2)-okregi(i,3); %wartosc y srodka okregu
    x = okregi(i,1)-okregi(i,3); %wartosc x srodka okregu
    w = 2*okregi(i,3); %do narysowania potrzebna jest srednica okregu
    rectangle('Position',[y x w w],'EdgeColor','red','Curvature',[1 1]);
end
hold off;