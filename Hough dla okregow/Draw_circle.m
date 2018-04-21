function Draw_circle(I,circles)
figure(1)
imshow(I),hold on;
title('Obraz z wykrytymi okregami');
for i=1:size(circles,1)
    y=circles(i,2)-circles(i,3);
    x=circles(i,1)-circles(i,3);
    w=2*circles(i,3);
    rectangle('Position',[y x w w],'EdgeColor','red','Curvature',[1 1]);
end
hold off;