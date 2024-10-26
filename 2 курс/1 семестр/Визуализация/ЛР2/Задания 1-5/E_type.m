% E -  (TM - )
%      
% ¤ 

clc
clear


%  z = 0
%   t0
t0 = 1/8; %    T


a = 2;
b = 1;

%    [0 a 0 b]
%¤ ¤  ¤
dx = a/300;
dy = b/100;
[x,y] = meshgrid(0:dx:a, 0:dy:b);


%  E_nm
n = 1;
m = 1;
z = sin(pi*n*x/a).*sin(pi*m*y/b)*sin(-2*pi*t0);    %    

%   (  ¤)
[C,hc] = contour(x,y,z,6);        
set(hc,'LineWidth',3,'Color',[0.3 0.3 0.8]);
axis([0 a 0 b]);
%clabel(C,hc)

%    [0 a 0 b]
%¤ ¤  
dx = a/60;
dy = b/20;
[x,y] = meshgrid(0:dx:a, 0:dy:b);

z = sin(pi*n*x/a).*sin(pi*m*y/b)*sin(-2*pi*t0);    %    

%   ¤ z(x,y)
[px,py] = gradient(-z);                  


hold on;
%   ( )
h = quiver(x,y,px,py,1.5);     
set(h,'LineWidth',2,'Color',[0.8 0.3 0.3]);


%¤ gca      (  axis)  
hAxes = gca;
%¤ set     'x'   hAxes
set(hAxes,'xtick',[0.0 0.5 1.0  1.5 2.0 2.5 3.0]);
set(hAxes,'ytick',[0.0 0.5 1.0]);
set(hAxes,'FontSize',20,'FontWeight','bold');

%    'x'   
xlabel('x     (cm)')
%    'y'   
ylabel('y     (cm)')

%title('Lines E and B fields')

strn = int2str(n);
strm = int2str(m);
string = ['Lines of E and B fields.  TM - mode, E_',strn,'_',strm];
title(string)

