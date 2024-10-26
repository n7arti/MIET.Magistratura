% E -  (TM - )
%  

%      
%      

%      
%      

clc
clear

format short g

%  z = 0
%   t0
t0 = 1/8; %    T

%,  
P = 1000; % ()

% 
a = 2; % (cm)
b = 1; % (cm)

fm = 50; %  (GHz)
eGHz = 1.e+9; % 
c = 3.e+8; %  (cm/m)
eps0 = 8.8542e-12; %  (/)
mu0 = 4*pi*1.e-7; %  (/)

%   E_nm
n=1; 
m=1;  

% 
f_nm = c/2*sqrt((n/a)^2 + (m/b)^2)*100/eGHz; % (GHz)
fc = f_nm;
disp('fc=')
disp(fc)

%  f = 1.5*fc
f = 1.5*fc;  % (GHz)   
disp('f=')
disp(f)

%   'bet'   E_nm
%  f
bet = 2*pi/c*eGHz*sqrt(f.^2 - f_nm^2)/100;  % (1/cm)
disp('bet=')
disp(bet)

%    E_nm
lamb = 2*pi/bet; % (cm)
disp('lamb=')
disp(lamb)

%   
vp = 2*pi*f*eGHz/bet; % (cm/c)
disp('vp=')
disp(vp)

%   
vg = c*(c/vp)*10^4; % (cm/c)
disp('vg=')
disp(vg)

% 
kA = bet*2*pi*f*eGHz*eps0/100/2*((pi*n/a)^2 + (pi*m/b)^2)*a*b/4; % (/(^2*))
A1 = sqrt(P/kA); % (*)
disp('A1=')
disp(A1)

%      
%  
A1m = pi*m/b*A1/sqrt(2); % ()
A1n = pi*n/a*A1/sqrt(2); % ()

%  
Ed = bet*A1m;              % (/)
Bd = 2*pi*f*eGHz/c^2*A1m;  % ()
Hd = Bd/mu0/100;           % (/)   

%  
Er = bet*A1n;              % (/)
Br = 2*pi*f*eGHz/c^2*A1n;  % ()
Hr = Bd/mu0/100;           % (/)   

%  
Et = bet*A1m;              % (/)
Bt = 2*pi*f*eGHz/c^2*A1m;  % ()
Ht = Bd/mu0/100;           % (/)   

%  
El = bet*A1n;              % (/)
Bl = 2*pi*f*eGHz/c^2*A1n;  % ()
Hl = Bd/mu0/100;           % (/)   

Emax = max([Ed, Er, Et, El]);
Bmax = max([Bd, Br, Bt, Bl]);
Hmax = max([Hd, Hr, Ht, Hl]);

disp('    Emax,      Bmax,      Hmax')
disp([Emax   Bmax   Hmax])

%      
%   
%  

%  
roSd = Ed*100*eps0/10^4*10^9;   % (/^2)
jSd  = Bd/mu0/100;          % (/)

%  
roSr = Er*100*eps0/10^4*10^9;   % (/^2)
jSr  = Br/mu0/100;          % (/)

%  
roSt = Et*100*eps0/10^4*10^9;   % (/^2)
jSt  = Bt/mu0/100;          % (/)

%  
roSl = El*100*eps0/10^4*10^9;   % (/^2)
jSl  = Bl/mu0/100;          % (/)

roSmax = max([roSd, roSr, roSt, roSl]);
jSmax  = max([jSd, jSr, jSt, jSl]);

disp('    roSmax,    jSmax')
disp([roSmax   jSmax])

% ///////////////////////////////////////////////////
% ,      

%  
s1 = 0:0.01:a;
x = s1;
E1 = Ed*sin(pi*n/a*x);          % (/)
B1 = Bd*sin(pi*n/a*x);          % ()
roS1 = E1*100*eps0/10^4*10^9;   % (/^2)
jS1  = B1/mu0/100;              % (/)

%  
s2 = a:0.01:a+b;
y = s2 - a;
E2 = Er*(-1)^(n+1)*sin(pi*m/b*y);   % (/)
B2 = Br*(-1)^(n+1)*sin(pi*m/b*y);   % ()
roS2 = E2*100*eps0/10^4*10^9;       % (/^2)
jS2  = B2/mu0/100;                  % (/)

%  
s3 = a+b:0.01:2*a+b;
x = -s3 + 2*a + b;
E3 = Ed*(-1)^(m+1)*sin(pi*n/a*x);   % (/)
B3 = Bd*(-1)^(m+1)*sin(pi*n/a*x);   % ()
roS3 = E3*100*eps0/10^4*10^9;       % (/^2)
jS3  = B3/mu0/100;                  % (/)

%  
s4 = 2*a+b:0.01:2*a+2*b;
y = -s4 + 2*a + 2*b;
E4 = Er*sin(pi*m/b*y);       % (/)
B4 = Br*sin(pi*m/b*y);       % ()
roS4 = E4*100*eps0/10^4*10^9;       % (/^2)
jS4  = B4/mu0/100;                  % (/)

s = cat(2,s1,s2,s3,s4);
E = cat(2,E1,E2,E3,E4);
B = cat(2,B1,B2,B3,B4);
roS = cat(2,roS1,roS2,roS3,roS4);
jS  = cat(2,jS1,jS2,jS3,jS4);

B = B*10^6;
roS = roS*10^2;

Bmax = Bmax*10^6;
roSmax = roSmax*10^2;

EBmax = max(Emax,Bmax);
roSjSmax = max(roSmax,jSmax);

%     

figure(13)
hPl = plot(s,E,s,B,'--');
set(hPl,'LineWidth',4);
axis([0 2*a+2*b -1.1*EBmax 1.1*EBmax]);
% gca      (  axis)  
hAxes = gca;
% set     'x'   hAxes

set(hAxes,'FontSize',26,'FontWeight','bold');
%    'x'   
xlabel('s     (cm)')
%    'y'   
ylabel('E  (V/cm),        B (10^{-6} T)')

grid on


strn = int2str(n);
strm = int2str(m);
string = ['E   and   B   fields on countour.  TM - mode, E_',strn,'_',strm];
title(string)

%       

figure(14)
hPl = plot(s,roS,s,jS,'--');
set(hPl,'LineWidth',4);
axis([0 2*a+2*b -1.1*roSjSmax 1.1*roSjSmax]);
% gca      (  axis)  
hAxes = gca;
% set     'x'   hAxes
set(hAxes,'FontSize',26,'FontWeight','bold');
%    'x'   
xlabel('s     (cm)')
%    'y'   
ylabel('\rho_{S}  (10^{-2} nQ/cm^{2}),        j_{S} (A/cm)')

grid on
strn = int2str(n);
strm = int2str(m);
string = ['\rho_{S}    and    j_{S}    on countour.  TM - mode, E_',strn,'_',strm];
title(string)

format short


