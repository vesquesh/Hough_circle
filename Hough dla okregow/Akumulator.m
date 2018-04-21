function [H] = Akumulator(I,radius_range)

[row, col, deep]=size(I);
r_min=radius_range(1);
r_max=radius_range(2);

H=zeros(2*r_max+row,2*r_max+col,r_max-r_min+1);

Xpoints=[];Ypoints=[];
Pnumber=0;
for x=1:col
   for y=row:-1:1
      if I(y,x)==1
         Xpoints=[Xpoints x];
         Ypoints=[Ypoints y];
         Pnumber=Pnumber+1;
      end
   end
end

for r=r_min:r_max
    for xy=1:Pnumber
       x=Xpoints(xy);
       y=Ypoints(xy);
       for x0=x-r:x+r
          y_subtraction=sqrt(r^2-(x0-x)^2);
          x_move=x0+r_max;
          r_actual=r-r_min+1;
          if y_subtraction==0
             y_move=y+r_max;
             H(y_move,x_move,r_actual)=H(y_move,x_move,r_actual)+1;
          else
              y1=round(y-y_subtraction);
              y2=round(y_y_subtraction);
              H(y1+r_max,x_move,r_actual)=H(y1+r_max,x_move,r_actual)+1;
              H(y2+r_max,x_move,r_actual)=H(y2+r_max,x_move,r_actual)+1;
          end
       end
    end
end

end

