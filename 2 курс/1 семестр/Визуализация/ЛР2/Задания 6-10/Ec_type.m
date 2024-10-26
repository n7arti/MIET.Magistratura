%����� E - ���� (TM - �����)
%��������� ����� �������������� � ���������� ����� 
%� ��������� �������� �������

clc
clear

%���� nu_nm ������� ������� Jn(nu_nm) = 0
nuB(1,2) = 2.405; %nu_01
nuB(2,2) = 3.832;
nuB(1,3) = 5.520;
nuB(2,3) = 7.016;

%� ������� z = 0
%� ������ ������� t0
t0 = 1/8; % � �������� ������� T


%������ ���������
a = 2; % (cm)

b = a;

%������ ����� � ������� [-a a -b b]
%��� ��������� ����� ������
dx = a/100;
dy = b/100;
[x,y] = meshgrid(-a:dx:a, -b:dy:b);


%�������� ���� E_nm
n = 1;
m = 1;

%���� ������� �������
nu_nm = nuB(n+1,m+1);

%������������� ��������� ����� �� ����� 
r = sqrt(x.^2+y.^2);
psi = atan2(y,x);
z = besselj(n,nu_nm*r/a).*sin(n*psi-2*pi*t0);  


%������ ����������������� ����� (����� ���������� ����)
[C,hc] = contour(x,y,z);       
set(hc,'LineWidth',3,'Color',[0.3 0.3 0.8]);
axis([-a a -b b]);


%������ ����� � ������� [0 a 0 b]
%��� ��������� ����� ���������
dx = a/10;
dy = b/10;
[x,y] = meshgrid(-a:dx:a, -a:dy:b);


%������������� ��������� ����� �� ����� 
r = sqrt(x.^2+y.^2);
psi = atan2(y,x);
z = besselj(n,nu_nm*r/a).*sin(n*psi-2*pi*t0);  


%������� ����� �������� ���� z(x,y)
[px,py] = gradient(-z);                  


hold on;
%������ ������� ��������� (������������� ����)
h = quiver(x,y,px,py,1.5);     
set(h,'LineWidth',2,'Color',[0.8 0.3 0.3]);


%������ ������ ���������
fi=0:0.01:2*pi;
xc = a*cos(fi);
yc = a*sin(fi);
hy=line(xc, yc); 
set(hy,'color',[0.5 0.5 0.5],'LineWidth',10);

%�������� ����� ������ ������� ������ �����
xp = [xc a a -a -a a a ];
yp = [yc 0 -b -b b b 0 ];

fill(xp,yp,'w')

%������� gca ���������� ���������� ������� ���� ��������� (������������ ������ axis)  
hAxes = gca;
%������� set ������������� ����� ����� ��� 'x' ������������ ���� hAxes
ticX = -a:0.5:a;
ticY = -b:0.5:b;
%set(hAxes,'xtick',[0.0 0.5 1.0  1.5 2.0 2.5 3.0]);
%set(hAxes,'ytick',[0.0 0.5 1.0]);
set(hAxes,'xtick',ticX);
set(hAxes,'ytick',ticY);
set(hAxes,'FontSize',20,'FontWeight','bold');

%������������� ����� �� ��� 'x' ������� ���� ���������
xlabel('x     (cm)')
%������������� ����� �� ��� 'y' ������� ���� ���������
ylabel('y     (cm)')

%title('Lines E and B fields')

strn = int2str(n);
strm = int2str(m);
string = ['Lines of E and B fields.  TM - mode, E_',strn,'_',strm];
title(string)

%������ ���������� ������� ������� ������� ���������
axis square