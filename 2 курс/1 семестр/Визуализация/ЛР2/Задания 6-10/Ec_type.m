%волна E - типа (TM - волна)
%рисование линий электрического и магнитного полей 
%в волноводе круглого сечения

clc
clear

%нули nu_nm функции Бесселя Jn(nu_nm) = 0
nuB(1,2) = 2.405; %nu_01
nuB(2,2) = 3.832;
nuB(1,3) = 5.520;
nuB(2,3) = 7.016;

%в сечении z = 0
%в момент времени t0
t0 = 1/8; % в единичах периода T


%радиус волновода
a = 2; % (cm)

b = a;

%задаем сетку в области [-a a -b b]
%для рисования линий уровня
dx = a/100;
dy = b/100;
[x,y] = meshgrid(-a:dx:a, -b:dy:b);


%выбираем моду E_nm
n = 1;
m = 1;

%нуль функции Бесселя
nu_nm = nuB(n+1,m+1);

%Электрический потенциал Герца на сетке 
r = sqrt(x.^2+y.^2);
psi = atan2(y,x);
z = besselj(n,nu_nm*r/a).*sin(n*psi-2*pi*t0);  


%рисует эквипотенциальные линии (линии магнитного поля)
[C,hc] = contour(x,y,z);       
set(hc,'LineWidth',3,'Color',[0.3 0.3 0.8]);
axis([-a a -b b]);


%задаем сетку в области [0 a 0 b]
%для рисования линий градиента
dx = a/10;
dy = b/10;
[x,y] = meshgrid(-a:dx:a, -a:dy:b);


%Электрический потенциал Герца на сетке 
r = sqrt(x.^2+y.^2);
psi = atan2(y,x);
z = besselj(n,nu_nm*r/a).*sin(n*psi-2*pi*t0);  


%находим минус градиент поля z(x,y)
[px,py] = gradient(-z);                  


hold on;
%рисует векторы градиента (электрическое поле)
h = quiver(x,y,px,py,1.5);     
set(h,'LineWidth',2,'Color',[0.8 0.3 0.3]);


%рисуем контур волновода
fi=0:0.01:2*pi;
xc = a*cos(fi);
yc = a*sin(fi);
hy=line(xc, yc); 
set(hy,'color',[0.5 0.5 0.5],'LineWidth',10);

%заливаем белым цветом область вокруг круга
xp = [xc a a -a -a a a ];
yp = [yc 0 -b -b b b 0 ];

fill(xp,yp,'w')

%функция gca возвращает дескриптор текущих осей координат (гарафический объект axis)  
hAxes = gca;
%функция set устанавливает метки вдоль оси 'x' координатных осей hAxes
ticX = -a:0.5:a;
ticY = -b:0.5:b;
%set(hAxes,'xtick',[0.0 0.5 1.0  1.5 2.0 2.5 3.0]);
%set(hAxes,'ytick',[0.0 0.5 1.0]);
set(hAxes,'xtick',ticX);
set(hAxes,'ytick',ticY);
set(hAxes,'FontSize',20,'FontWeight','bold');

%устанавливаем метку на оси 'x' текущих осей координат
xlabel('x     (cm)')
%устанавливаем метку на оси 'y' текущих осей координат
ylabel('y     (cm)')

%title('Lines E and B fields')

strn = int2str(n);
strm = int2str(m);
string = ['Lines of E and B fields.  TM - mode, E_',strn,'_',strm];
title(string)

%делаем квадратной область текущей области рисования
axis square