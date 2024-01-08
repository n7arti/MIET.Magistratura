x=[0:0.1:10];
yV1=zeros([1,101]);
plot(x,yV1, 'Linewidth',4)
hold on
yV2=zeros([1,20]);
yV2=[yV2, (x(21:50)-2)./3.*0.05];
yV2=[yV2, (8-x(51:80))./3.*0.05];
yV2=[yV2, zeros([1,21])];
plot(x,yV2, 'Linewidth',4, 'Color', 'red')
grid on
hold on
yV3= zeros([1,101]);
plot(x,yV3, 'Linewidth',4, 'Color', 'green')

figure()
A=[yV1;yV2;yV3];
y=max(A);
plot(x,y,'Linewidth',4)
grid on

sum1=0;
sum2=0;
for (i=1:101)
sum1=sum1+x(i)*y(i);
sum2=sum2+y(i);
end
c=sum1/sum2