% E -  (TM - )
%   
%  

clc
clear

% 
a = 2; % (cm)
b = 1; % (cm)
fm = 50; %  (GHz)
eGHz = 1.e+9; % 
c = 3.e+10; %  (cm/s)

%  
n=1;  m=1;  

% 
f_nm = c/2*sqrt((n/a)^2 + (m/b)^2)/eGHz; % (GHz)

%   'bet'   E_11
f1=f_nm:0.01:fm;
bet1 = 2*pi/c*eGHz*sqrt(f1.^2 - f_nm^2);

%  bet = 2*pi/c*f
f0=0:0.01:fm;
bet0 = 2*pi/c*eGHz*f0;



hPl=plot(f1,bet1,f0,bet0,'--');
set(hPl,'LineWidth',4);
grid on
% gca      (  axis)  
hAxes = gca;
% set     'x'   hAxes
%set(hAxes,'xtick',[1.5 1.75 2.0 2.25 2.5])
set(hAxes,'FontSize',20,'FontWeight','bold');


%    'x'   
xlabel('f     (GHz)')
%    'y'   
ylabel('\beta     (1/cm)')
text(11.0, 0.5,'E_{11}','Color',[0 0 0],'FontSize',20,'FontWeight','bold')
title('Dispersion Relation     \beta  =  \beta (f)')


