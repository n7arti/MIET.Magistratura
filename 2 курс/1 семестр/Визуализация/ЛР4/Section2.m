function [xL,zL] = Section2(xb,xe,N,yb,ye,M,x1,x2,y1,y2,x,y,z)

xL = [];
zL = [];

dx = (xe - xb)/(N-1);
dy = (ye - yb)/(M-1);

kx = x2 - x1;
ky = y2 - y1;
%накло прямой - сечения
if(abs(kx) > abs(ky))
    flag = 1; %наклон < 45 град (относительно OX) 
else
    flag = 2; %наклон > 45 град (относительно OX)
end
flag

%определяем параметры первой точки x1,y1
%находим номера узловых точек меду которыми лежит  x1
%         x(i1a) <= x1 <= x(ilb)
i1a = fix((x1-xb)/dx)+1
i1b = ceil((x1-xb)/dx)+1

%находим номера узловых точек меду которыми лежит  y1
%         y(j1a) <= y1 <= y(jlb)
j1a = fix((y1-yb)/dy)+1
j1b = ceil((y1-yb)/dy)+1

%индексы начальной точки x1,y1
N1 = i1a
M1 = j1a

%находим zL(1) = z(x1,y1)
if((i1a == i1b) && (j1a == j1b))
    zL(1) = z(i1a,j1a);
else
    if((i1a ~= i1b) && (j1a == j1b))
        a = x1 - x(i1a); b = x(i1b) - x1;
        zL(1) = (b*z(i1a,j1a) + a*z(i1b,j1a ))/dx;
    end
    if((i1a == i1b) && (j1a ~= j1b))
        a = y1 - y(j1a); b = y(j1b) - y1;
        zL(1) = (b*z(i1a,j1a) + a*z(i1a,j1b))/dy;
    end
end

%задаем xL(1)
xL(1) = 0;


%определяем параметры последней точки x2,y2
%находим номера узловых точек меду которыми лежит x2
%         x(i2a) <= x2 <= x(i2b)
i2a = fix((x2-xb)/dx)+1
i2b = ceil((x2-xb)/dx)+1

%находим номера узловых точек меду которыми лежит y2
%         y(j2a) <= y2 <= y(j2b)
j2a = fix((y2-yb)/dy)+1
j2b = ceil((y2-yb)/dy)+1


%индексы конечной точки x2,y2
N2 = i2b
M2 = j2b

%находим число точек K на линии сечении
if(flag == 1)
    if(N1 < N2)
        K = N2 - N1 + 1
    else
        K = N1 - N2 + 1
    end
end

if(flag == 2)
    if(M1 < M2)
        K = M2 - M1 + 1
    else
        K = M1 - M2 + 1
    end
end


%находим zL(K) = z(x2,y2)
if((i2a == i2b) && (j2a == j2b))
    zL(K) = z(i2b,j2b);
else
    if((i2a ~= i2b) && (j2a == j2b))
        a = x2 - x(i2a); b = x(i2b) - x2;
        zL(K) = (b*z(i2a,j2b) + a*z(i2b,j2b))/dx;
    end
    if((i2a == i2b) && (j2a ~= j2b))
        a = y2 - y(j2a); b = y(j2b) - y2;
        zL(K) = (b*z(i2b,j2a) + a*z(i2b,j2b))/dy;
    end
end

%находим xL(K)
xL(K) = ((x2-x1)^2 + (y2-y1)^2)^0.5;
xL(K)

%находим на линии сечения два массива zL(i), xL(i) i=2,3,...,K-1
if(flag == 1)
    for(i=2:K-1)
        if(N1 < N2)
            ii = N1+i-1;
        else
            ii = N1-(i-1);
        end
        yt = ky/kx*(x(ii) - x1) + y1;
        ja = fix((yt-yb)/dy)+1;
        jb = ceil((yt-yb)/dy)+1;
        if(ja == jb)
            zL(i) = z(ii,jb);
        else
            a = yt - y(ja); b = y(jb) - yt;
            zL(i) = (b*z(ii,ja) + a*z(ii,jb))/dy;
        end
        xL(i) = ((x(ii) - x1)^2 + (yt - y1)^2)^0.5;    
    end
end


%находим на линии сечения два массива zL(i), xL(i) i=2,3,...,K-1
if(flag == 2)
    for(i=2:K-1)
        if(M1 < M2)
            ii = M1+i-1;
        else
            ii = M1-(i-1);
        end
        xt = kx/ky*(y(ii) - y1) + x1;
        ia = fix((xt-xb)/dx)+1
        ib = ceil((xt-xb)/dx)+1
        if(ia == ib)
            zL(i) = z(ib,ii);
        else
            a = xt - x(ia); b = x(ib) - xt;
            zL(i) = (b*z(ia,ii) + a*z(ib,ii))/dx;
        end
        xL(i) = ((y(ii) - y1)^2 + (xt - x1)^2)^0.5;    
    end
end










%for(i=1:N)
%    xL(i) = xb + dx*(i-1);
%    zL(i) = z(i,j1a);
%end