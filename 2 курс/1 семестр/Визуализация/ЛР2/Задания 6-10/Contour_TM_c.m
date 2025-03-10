%����� E - ���� (TM - �����)
%�������� �������� �������


%  ������������� �������������� � ���������� ����
%    �� ������� ���������

%  ������������� �������������� ������ � �������������� ����
%    �� ������� ���������



clc
clear

format short g


%���� nu_nm ������� ������� Jn(nu_nm) = 0
nuB(1,2) = 2.405; nuB(1,3) = 5.520; nuB(1,4) =  8.654; nuB(1,5) = 11.792;
nuB(2,2) = 3.832; nuB(2,3) = 7.016; nuB(2,4) = 10.173; nuB(2,5) = 13.324;
nuB(3,2) = 5.136; nuB(3,3) = 8.417; nuB(3,4) = 11.620; nuB(3,5) = 14.796;
nuB(4,2) = 6.380; nuB(4,3) = 9.761; nuB(4,4) = 13.015; nuB(4,5) = 16.223;

%� ������� z = 0
%� ������ ������� t0
t0 = 1/8; % � �������� ������� T


%��������, ����������� �����
P = 1000; % (��)


%������ ���������
a = 2; % (cm)

fm = 50; %������������ ������� (GHz)
eGHz = 1.e+9; %���� ��������
c = 3.e+8; %�������� ����� (cm/m)
eps0 = 8.8542e-12; %������������� ���������� (�/�)
mu0 = 4*pi*1.e-7; %��������� ���������� (��/�)

%������� ����������� ���� E_nm
n=1; 
m=1;  

%���� ������� �������
nu_nm = nuB(n+1,m+1);
%������� �������
f_nm = c/2/pi*nu_nm/a*100/eGHz; % (GHz)

fc = f_nm;
disp('fc=')
disp(fc)




%�������� ������� f = 1.5*fc
f = 1.5*fc;  % (GHz)   
disp('f=')
disp(f)



%������� ���������� ��������������� 'bet' ��� ���� E_nm
%�� ������� f
bet = 2*pi/c*eGHz*sqrt(f.^2 - f_nm^2)/100;  % (1/cm)
disp('bet=')
disp(bet)


%������� ����� ����� ���� E_nm
lamb = 2*pi/bet; % (cm)
disp('lamb=')
disp(lamb)

%������� ������� �������� �����
vp = 2*pi*f*eGHz/bet; % (cm/c)
disp('vp=')
disp(vp)


%������� ��������� �������� ����
vg = c*(c/vp)*10^4; % (cm/c)
disp('vg=')
disp(vg)




%��������� ����
kA = bet*2*pi*f*eGHz*eps0/100*pi*nu_nm^2/2*(besselj(n+1,nu_nm))^2; % (�/(��^2*�))
A1 = sqrt(P/kA); % (�*��)
disp('A1=')
disp(A1)

%������� ���������� �������� �������������� � ���������� �����
%�� ������� ���������

%���������� ������� J'_n(z) = n/z*J_n(z) - J_(n+1)(z)
Ampl = -nu_nm/a*A1*besselj(n+1,nu_nm); % (�)


Eampl = bet*Ampl;
Bampl = 2*pi*f*eGHz/c^2*Ampl;

Emax = abs(Eampl);              % (�/��)
Bmax = abs(Bampl);              % (��)
Hmax = Bmax/mu0/100;           % (�/��)   



disp('    Emax,      Bmax,      Hmax')
disp([Emax   Bmax   Hmax])


%������� ���������� �������� ������������� ��������� �������������� ������
%������������� ��������� �������������� ����
%�� ������� ���������

roSampl = Eampl*100*eps0/10^4*10^9;
jSampl  = Bampl/mu0/100;          

roSmax = abs(roSampl);        % (���/��^2)
jSmax  = abs(jSampl);          % (�/��)

disp('    roSmax,    jSmax')
disp([roSmax   jSmax])



% ///////////////////////////////////////////////////
%������� ����, ������ � ���� �� ������� ���������


s1 = 0:0.01:2*pi*a;
psi1 = s1/a;
E1 = Eampl*sin(n*psi1 - 2*pi*t0);          % (�/��)
B1 = Bampl*sin(n*psi1 - 2*pi*t0);          % (��)
roS1 = roSampl*sin(n*psi1 - 2*pi*t0);   % (���/��^2)
jS1  = jSampl*sin(n*psi1 - 2*pi*t0);              % (�/��)



B1 = B1*10^6;
roS1 = roS1*10^2;

Bmax = Bmax*10^6;
roSmax = roSmax*10^2;

EBmax = max(Emax,Bmax);
roSjSmax = max(roSmax,jSmax);

% ///////////////////////////////////////////////////



%   3) ///////////////////////////////////////////////////
%������ ������������ ���� �� ������� ���������

figure(12)
hPl = plot(s1,E1,s1,B1,'--');
set(hPl,'LineWidth',4);
axis([0 2*pi*a -1.1*EBmax 1.1*EBmax]);
%������� gca ���������� ���������� ������� ���� ��������� (������������ ������ axis)  
hAxes = gca;
%������� set ������������� ����� ����� ��� 'x' ������������ ���� hAxes
%set(hAxes,'xtick',[1.5 1.75 2.0 2.25 2.5])
set(hAxes,'FontSize',26,'FontWeight','bold');
%������������� ����� �� ��� 'x' ������� ���� ���������
xlabel('s     (cm)')
%������������� ����� �� ��� 'y' ������� ���� ���������
ylabel('E  (V/cm),        B (10^{-6} T)')
%title('E  (V/cm),          B (10^{-6} T)')

grid on


strn = int2str(n);
strm = int2str(m);
string = ['E   and   B   fields on countour.  TM - mode, E_',strn,'_',strm];
title(string)


% ///////////////////////////////////////////////////




%   4) ///////////////////////////////////////////////////
%������ ������������ ������ � ���� �� ������� ���������

figure(13)
hPl = plot(s1,roS1,s1,jS1,'--');
set(hPl,'LineWidth',4);
axis([0 2*pi*a -1.1*roSjSmax 1.1*roSjSmax]);
%������� gca ���������� ���������� ������� ���� ��������� (������������ ������ axis)  
hAxes = gca;
%������� set ������������� ����� ����� ��� 'x' ������������ ���� hAxes
%set(hAxes,'xtick',[1.5 1.75 2.0 2.25 2.5])
set(hAxes,'FontSize',26,'FontWeight','bold');
%������������� ����� �� ��� 'x' ������� ���� ���������
xlabel('s     (cm)')
%������������� ����� �� ��� 'y' ������� ���� ���������
ylabel('\rho_{S}  (10^{-2} nQ/cm^{2}),        j_{S} (A/cm)')
%title('\rho_{S}  (10^{-2} nQ/cm^{2}),        j_{S} (A/cm)')

grid on
strn = int2str(n);
strm = int2str(m);
string = ['\rho_{S}    and    j_{S}    on countour.  TM - mode, E_',strn,'_',strm];
title(string)

% ///////////////////////////////////////////////////


format short
