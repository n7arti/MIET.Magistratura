
//������ ������� ����� ����������������� ����


#define STRICT
#include <windows.h>
#include <windowsx.h>
#include <math.h>
#include <stdio.h>
#include <tchar.h>


//��� ������ ����
WCHAR szClassName[] = L"LineClass";
//��������� ����
WCHAR szWindowTitle[] = L"Korneev V.        "
			L"   Vector-Field,       "
			L"   rotation  by  mouse  and  keyboard (arrows)";


struct ANGLS {
	double fi, teta;
};

static ANGLS angl,anglOld;


//��������� �������
BOOL RegisterApp(HINSTANCE hInst);
HWND CreateApp(HINSTANCE, int);
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
void LineCreate();
void LineDestroy();
void LinePaint(HWND);
void LineLButtonDown(HWND,int,int);
void LineMouseMove(HWND,int,int);
void DrawBox(HWND, HDC, ANGLS);
void LineLButtonUp(HWND);
void PointCorns();


//������� �������
int PASCAL WinMain(HINSTANCE hInst,
						 HINSTANCE hPrevInstance,
						 LPSTR     lpszCmdParam,
						 int       nCmdShow)
{
	MSG msg;

	if(!RegisterApp(hInst))  //����������� ����������
		return FALSE;

	if(!CreateApp(hInst,nCmdShow))  //�������� ���� ����������
		return FALSE;

	while(GetMessage(&msg,NULL,0,0))   //���� ��������� ���������
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	return 0;
}

//����������� ������ ����
BOOL RegisterApp(HINSTANCE hInst)
{
	WNDCLASS wc;

	wc.style         = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc   = WndProc;
	wc.cbClsExtra    = 0;
	wc.cbWndExtra    = 0;
	wc.hInstance     = hInst;
	wc.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
	wc.hCursor		  = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = GetStockBrush(LTGRAY_BRUSH);
	wc.lpszMenuName  = (LPCTSTR)"APP_MENU";
	wc.lpszClassName = szClassName;

	return RegisterClass(&wc);
}



//�������� ����
HWND CreateApp(HINSTANCE hInstance, int nCmdShow)
{
	 HWND hwnd;

	 hwnd = CreateWindow(szClassName,
									 szWindowTitle,
									 WS_OVERLAPPEDWINDOW,
									 100, 
									 30, 
									 700, 
									 700, 
									 NULL,
									 NULL,
									 hInstance,
									 NULL);

	if(hwnd == NULL)
		return hwnd;

	ShowWindow(hwnd,nCmdShow);
	UpdateWindow(hwnd);

	return hwnd;
}






//������� ��������� ���������  
LRESULT CALLBACK  WndProc(HWND hwnd, UINT msg,
											WPARAM wParam, LPARAM lParam)
{

	int x,y;
	switch(msg)
	{
		case WM_CREATE:
			LineCreate();
			break;

		case WM_PAINT:
			LinePaint(hwnd);
			break;

		case WM_LBUTTONDOWN:
				x = LOWORD(lParam);
				y = HIWORD(lParam);
				LineLButtonDown(hwnd,x,y);
			break;

		case WM_LBUTTONUP:
				LineLButtonUp(hwnd);
				InvalidateRect(hwnd,NULL,TRUE);
			break;


		case WM_MOUSEMOVE:
				x = LOWORD(lParam);
				y = HIWORD(lParam);

				LineMouseMove( hwnd,x,y);
			break;

		case WM_KEYDOWN:
			switch(wParam)
			{
				case VK_LEFT:
					angl.fi += 10;
					InvalidateRect(hwnd,NULL,TRUE);
					break;

				case VK_RIGHT:
					angl.fi -= 10;
					InvalidateRect(hwnd,NULL,TRUE);
					break;

				case VK_UP:
					angl.teta += 10;
					InvalidateRect(hwnd,NULL,TRUE);
					break;

				case VK_DOWN:
					angl.teta -= 10;
					InvalidateRect(hwnd,NULL,TRUE);
					break;
			}
			break;

		case WM_DESTROY:
			LineDestroy();
			break;

		default:
			return DefWindowProc(hwnd,msg,wParam,lParam);
	}

	return 0L;
}






double const M_PI = 3.141592654;

struct TDATA {
	BOOL ButtonDown;
	BOOL Drawing;
};

static TDATA Dat;


struct CORD {
	int x, y;
};

static CORD cor,corOld;

struct POINT3 {
	double x, y, z;
};

static POINT3 Point[8];
//static POINT3 Point[8], PointB[32];

struct VECTORS {
	double x, y, z;
	double dx, dy, dz;
};

static VECTORS vect[32];

struct VECMAG {
	double hx, hy, hz;
};



//���������� �������
POINT3 CoordCharge[3];
//�������� �������
double qCharge[3];
//����� �������
int NCharge;
//����� ������
int iCharge;
//��������� ����� ����� ����
POINT3 PointB[26];
//������ ��������� ����� ����� ����
POINT3 qPointB[26][3];



/*

//������� ��������� ���������
double Px[4], Py[4], Pz[4];
*/

//������� ���� ������ � ������� ����������� � � ��������
double xe1, xe2, ye1, ye2;
int    ne1, ne2, me1, me2;

//����� ������������ ���� (� ������� �����������)
double xmax, ymax, zmax;

//������� ��������� ���������
double ax, ay;



//������ ����� ������ ������ � ������� ���������� ����� ����
double R0; 



//������ ��������� ��������� � ������ ������ ����������
void LineCreate()
{

//������� ���� ������ � ������� ����������� � � ��������
	xe1 = -3;  xe2 =   3; ye1 =  -3; ye2 =  3;
//	ne1 = 100; ne2 = 500; me1 = 450; me2 = 50;

//����� ������������ ���� (� ������� �����������)
	xmax=1.8, ymax=1.8, zmax=1.8;

//������ ������� ����, ���������� � ��������� �������� ���������
	PointCorns();


	//����� �������
	NCharge = 3;

	//������ ��������� 3-� �������
	CoordCharge[0].x = 2.0;
	CoordCharge[0].y = 0.0;
	CoordCharge[0].z = 0.0;
	qCharge[0] = -2;

	CoordCharge[1].x = 0.0;
	CoordCharge[1].y = 2.0;
	CoordCharge[1].z = 0.0;
	qCharge[1] = 1;

	CoordCharge[2].x = 0.0;
	CoordCharge[2].y = -2.0;
	CoordCharge[2].z = 0.0;
	qCharge[2] = 1;



	
	//������ ����� ������ ������ � ������� ���������� ����� ����
	R0 = 0.2; 


/*

//������� ��������� ���������
	ax = xmax/2, ay = ymax/2;


//������ ������� ��������� ���������
	Px[0] =   ax;  Py[0] =   ay;  Pz[0] =  0.0;
	Px[1] =  -ax;  Py[1] =   ay;  Pz[1] =  0.0;
	Px[2] =  -ax;  Py[2] =  -ay;  Pz[2] =  0.0;
	Px[3] =   ax;  Py[3] =  -ay;  Pz[3] =  0.0;


//������ ��������� ����� ����� ����
	int i, j, k, N = 4 ,  M = 4;
	double x, y, dx = 2*ax/(N-1), dy = 2*ay/(M-1);
	double d = 0.1;

	for( i=0; i<N; i++)
	{
		x = -ax + dx*i;
		for(j=0; j<M; j++)
		{
			y = -ay + dy*j;
			k = j + 4*i;
			PointB[k].x = x;
			PointB[k].y = y;
			PointB[k].z = d;

			PointB[k+16].x = x;
			PointB[k+16].y = y;
			PointB[k+16].z = -d;
		}
	}
*/

//��������� �������� ����� �������� ������� ���������
	angl.fi = 30; angl.teta = 60;
}


//������ ������� ����, ���������� � ��������� �������� ���������
void	PointCorns()
{
	Point[0].x =  xmax; Point[0].y =  ymax; Point[0].z = -zmax;
	Point[1].x = -xmax; Point[1].y =  ymax; Point[1].z = -zmax;
	Point[2].x = -xmax; Point[2].y = -ymax; Point[2].z = -zmax;
	Point[3].x =  xmax; Point[3].y = -ymax; Point[3].z = -zmax;
	Point[4].x =  xmax; Point[4].y =  ymax; Point[4].z = zmax;
	Point[5].x = -xmax; Point[5].y =  ymax; Point[5].z = zmax;
	Point[6].x = -xmax; Point[6].y = -ymax; Point[6].z = zmax;
	Point[7].x =  xmax; Point[7].y = -ymax; Point[7].z = zmax;
}


//��������� ���� (hx,hy,hz) � �������� ����� ������������ (x,y,z)
VECMAG magn(double q, double x, double y, double z,double x0, double y0, double z0)
{
	VECMAG mag;

	double dx = x - x0, dy = y - y0,dz = z - z0;
	double r3 = pow(dx*dx + dy*dy + dz*dz, 1.5);
	
	mag.hx = q/r3*dx; mag.hy = q/r3*dy; mag.hz = q/r3*dz; 
	
	return mag;
}

/*

//��������� ��������� ���� (hx,hy,hz) � �������� ����� ������������ (x,y,z)
VECMAG magn(double x, double y, double z)
{
	VECMAG mag;
	double s11, s12, s21, s22;
	double u1, u2, v1, v2;

	u1 = x - ax; u2 = x + ax;
	v1 = y - ay; v2 = y + ay;

	s11 = sqrt(u1*u1 + v1*v1 + z*z);
	s12 = sqrt(u1*u1 + v2*v2 + z*z);
	s21 = sqrt(u2*u2 + v1*v1 + z*z);
	s22 = sqrt(u2*u2 + v2*v2 + z*z);


	mag.hx =
			 log(((v1 + s21)/(v1 + s11))*((v2 + s12)/(v2 + s22)));
	mag.hy =
			 log(((u1 + s12)/(u1 + s11))*((u2 + s21)/(u2 + s22)));
	mag.hz =
			 atan((u2*v2)/(z*s22)) - atan((u1*v2)/(z*s12)) -
			 atan((u2*v1)/(z*s21)) + atan((u1*v1)/(z*s11));

	return mag;
}
*/


void LineDestroy()
{
	PostQuitMessage(0);   //��������� ���� ����������
}



//������� ������������ �������� ������� ���������
double sf,cf,st,ct;

//������� � ������� ������� ��������� � ��������������� ������������� 
double Xe(double x,double y)
{
  return -sf*x+cf*y;
}

//������� � ������� ������� ��������� � ��������������� ������������� 
double Ye(double x,double y,double z)
{
  return -ct*cf*x-ct*sf*y+st*z;
}


//������� �� ������� ��������� � �������� ����������� 

//������� �� ��������� x � ������� n
inline int xn(double x)
{
	return (int)((x - xe1)/(xe2 - xe1)*(ne2 - ne1)) + ne1;
}


//������� �� ��������� y � ������� m
inline int ym(double y)
{
	return (int)((y - ye1)/(ye2 - ye1)*(me2 - me1)) + me1;
}




//������ ��������� ����� ����� ����
void LineBeginPoints(double x0,double y0,double z0)
{
	double dfi = M_PI/4, dtet = M_PI/4;
	double fi,tet;
	int k = 0;

	PointB[0].x = x0; PointB[0].y = y0; PointB[0].z = z0 + R0;

	for(int i = 1; i <= 3; i++)
	{
		tet = i*dtet;
		for(int j = 0; j < 8; j++)
		{
			fi = j*dfi;
			k++;
			PointB[k].x = x0 + R0*sin(tet)*cos(fi);
			PointB[k].y = y0 + R0*sin(tet)*sin(fi);
			PointB[k].z = z0 + R0*cos(tet);
		}
	}
	PointB[25].x = x0; PointB[25].y = y0; PointB[25].z = z0 - R0;

}


//������ 2D ������-�������
void arrowVector(HDC hdc, int x1, int y1, int x2, int y2, COLORREF rgb)
{
	int k = 5; //������� ������� � ��������
	double d = sqrt((double)((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1)));
	double nx = (x2-x1)/d, ny = (y2-y1)/d; 
	double mx = -ny, my = nx;

	int x3, y3, x4, y4, x0, y0;
	
	x0 = int(k*nx) + x1;
	y0 = int(k*ny) + y1;
	x3 = int(k*mx) + x1;
	y3 = int(k*my) + y1;
	x4 = -int(k*mx) + x1;
	y4 = -int(k*my) + y1;

	HPEN hPen = CreatePen(PS_SOLID,2,rgb);
	HPEN hPenOld = (HPEN)SelectObject(hdc,hPen);
	
	MoveToEx(hdc,x3,y3,0);
	LineTo(hdc,x0,y0);
	LineTo(hdc,x4,y4);

	SelectObject(hdc,hPenOld);
	DeleteObject(hPen);
}





//"������" ���� ����� ���� �� ��������� ����� x0, y0,z0 
//����������� ����������� ����� � ������� ����� ������ q
void LineField(HDC hdc,double x0,double y0,double z0,double q,int iCh)
{
	COLORREF rgb;
	VECTORS vect;	
	vect.x = x0;
	vect.y = y0;
	vect.z = z0;
	
	//������� ���������� ������������ �����
//	double xe, ye, ze1, ze2;
	double xe, ye;
	//���������� ��������
	int x1,y1,x2,y2;

	int Nstep = 100; //������� ����� ����� � ����� ����
	double dt = 2*sqrt(xmax*xmax+ymax*ymax+zmax*zmax)/Nstep; //����� ���� �� ����� ����

//	double dt = 0.1; //����� ���� �� ����� ����
	double x, y, z, Hx, Hy, Hz, Ha;
	int k = 0;

	VECMAG mag;

	HPEN hPen, hPenOld;   


	//������ ���� ���� � ���� ����� � ����������� �� ����� ������
	if(q < 0)
	{
		dt = -dt;
		rgb = RGB(0,0,255);
		hPen = CreatePen(PS_SOLID,3,rgb);
		hPenOld = SelectPen(hdc,hPen);   
	}
	else
	{
		rgb = RGB(255,0,0);
		hPen = CreatePen(PS_SOLID,3,rgb);
		hPenOld = SelectPen(hdc,hPen);   
	}
	int nbr =0;
	double xt1,yt1,zt1,xt2,yt2,zt2;

		vect.dx = 0;
		vect.dy = 0;
		vect.dz = 0;

	//���� ��������� �� ����� ����
	//����������� �������� � ���� �������
	// 1 - ����� ��������� ������� ����
	// 2 - ����� ������� ������� ������ � ��������� ������
	// 3 - ����� ������� ������� ������ � ����� ������������� ����
	do
	{
		
		x = vect.x;
		y = vect.y;
		z = vect.z;

		int jCh;
		
		//������������ ���� �� ������ �������
		// NCharge - ����� �������
		double magx=0, magy=0, magz=0;
		for(jCh = 0; jCh < NCharge; jCh++)
		{	

			mag = magn(qCharge[jCh],x,y,z,CoordCharge[jCh].x,
					CoordCharge[jCh].y,CoordCharge[jCh].z);
			magx += mag.hx;
			magy += mag.hy;
			magz += mag.hz;

		}		
		
		Hx = magx;
		Hy = magy;
		Hz = magz;

		//����� ������� � ����� �������������, ��� Ha = 0 !!
		//������ ��������� ����������� ����� > 90 ��������
		if(Hx*vect.dx+Hy*vect.dy+Hz*vect.dz<0)
			break;

		//��������� ����������� ������� ����
		//�������� ���������� �������
		Ha = sqrt(Hx*Hx + Hy*Hy + Hz*Hz);


		vect.dx = Hx/Ha;
		vect.dy = Hy/Ha;
		vect.dz = Hz/Ha;


		//��������� ����������� �������� �� ����� ����
		//� ����������� �� ����� ������
		if(q > 0)
		{
		xt1 = vect.x; yt1 = vect.y; zt1 = vect.z;
		xt2 = xt1 + vect.dx*dt;
		yt2 = yt1 + vect.dy*dt;
		zt2 = zt1 + vect.dz*dt;

		}
		else
		{
		xt2 = vect.x; yt2 = vect.y; zt2 = vect.z;
		xt1 = xt2 + vect.dx*dt;
		yt1 = yt2 + vect.dy*dt;
		zt1 = zt2 + vect.dz*dt;
		}

		double dd1,dd2,dx,dy,dz;

		
		//��������� ������� �� ����� ���� ������ ������
		//� ������ �� �������� �������
		int flag;
		flag = 0;
		for(jCh = 0; jCh < NCharge; jCh++)
		{	
			dx = xt1 - CoordCharge[jCh].x; 
			dy = yt1 - CoordCharge[jCh].y; 
			dz = zt1 - CoordCharge[jCh].z; 
			dd1 = dx*dx + dy*dy + dz*dz;
	
			dx = xt2 - CoordCharge[jCh].x; 
			dy = yt2 - CoordCharge[jCh].y; 
			dz = zt2 - CoordCharge[jCh].z; 
			dd2 = dx*dx + dy*dy + dz*dz;
	
			if((dd1 < 0.1*R0*R0) || (dd2 < 0.1*R0*R0))
				flag = 1;
		}		
		
		if(flag == 1)
			break;
	
/*
		//�������� ������� ���������� � ������� � �����������
		//��������������, � ��������� ���������� ������� ���������
		//� ���������� ��������
		xe=Xe(xt1,yt1,zt1);
		ye=Ye(xt1,yt1,zt1);
		ze1=Ze(xt1,yt1,zt1);
		x1=xn(xe);
		y1=ym(ye);

		xe=Xe(xt2,yt2,zt2);
		ye=Ye(xt2,yt2,zt2);
		ze2=Ze(xt2,yt2,zt2);
		x2=xn(xe);
		y2=ym(ye);

*/			xe=Xe(xt1,yt1);
			ye=Ye(xt1,yt1,zt1);
			x1=xn(xe);
			y1=ym(ye);

			xe=Xe(xt2,yt2);
			ye=Ye(xt2,yt2,zt2);
			x2=xn(xe);
			y2=ym(ye);

			MoveToEx(hdc,x1,y1,NULL);
			LineTo(hdc,x2,y2);

/*		
		//"������" ������� ����� ���� �������� �������� � ������
		//� ������ Z-������
		ZbufLineWidth(hdc,x1,y1,x2,y2,ze1,ze2,3,rgb);
*/
		if(q > 0)
		{
		vect.x = xt2;
		vect.y = yt2;
		vect.z = zt2;
		}
		else
		{
		vect.x = xt1;
		vect.y = yt1;
		vect.z = zt1;
		}

		//����� 10-� ����� �� ���� ���� "������" �������
//		k++;
//		if(k == 30)
//		{
//			arrowVector(hdc,x1,y1,x2,y2,RGB(0,0,255));
//			k = 0;
//		}

	//���������� �������� ����� ���� �� ������� ����
	}while((x>-1.1*xmax)&&(x<1.1*xmax)&&
		(y>-1.1*ymax)&&(y<1.1*ymax)&&(z>-1.1*zmax)&&(z<1.1*zmax));

	SelectPen(hdc,hPenOld);   
	DeletePen(hPen);          

}


/*


//������ ���� ����� ���� �� ��������� ����� PointB 
void LineField(HDC hdc,POINT3 PointB)
{

	VECTORS vect;	
		vect.x = PointB.x;
		vect.y = PointB.y;
		vect.z = PointB.z;
	
	//������� ���������� ������������ �����
	double xe, ye;
//���������� ��������
	int x1,y1,x2,y2;

	double dt = 0.01;
	double x, y, z, Hx, Hy, Hz, Ha;

	VECMAG mag;
	double xt1,yt1,zt1,xt2,yt2,zt2;

	do
		{
			x = vect.x;
			y = vect.y;
			z = vect.z;

			mag = magn(x,y,z);

			Hx = mag.hx;
			Hy = mag.hy;
			Hz = mag.hz;

			Ha = sqrt(Hx*Hx + Hy*Hy + Hz*Hz);

			vect.dx = Hx/Ha;
			vect.dy = Hy/Ha;
			vect.dz = Hz/Ha;


			xt1 = vect.x; yt1 = vect.y; zt1 = vect.z;
			xt2 = xt1 + vect.dx*dt;
			yt2 = yt1 + vect.dy*dt;
			zt2 = zt1 + vect.dz*dt;

			xe=Xe(xt1,yt1);
			ye=Ye(xt1,yt1,zt1);
			x1=xn(xe);
			y1=ym(ye);

			xe=Xe(xt2,yt2);
			ye=Ye(xt2,yt2,zt2);
			x2=xn(xe);
			y2=ym(ye);

			MoveToEx(hdc,x1,y1,NULL);
			LineTo(hdc,x2,y2);

			vect.x = xt2;
			vect.y = yt2;
			vect.z = zt2;


		}while((x>-xmax)&&(x<xmax)&&(y>-ymax)&&(y<ymax)&&(z>-zmax)&&(z<zmax));
}

*/



//"������ �������� �����" � ���� ����� �������� 5 ��������,
// ������ rgb
//x0,y0,z0 - ���������� ��������� ������ � ������� ������� ���������
void Circle(HDC hdc,double x0, double y0, double z0, COLORREF rgb)
{
	int i,j;
	int  x, y, x1, y1;
//	double xe,ye,zz;
	double xe,ye;
//	unsigned long p;
	unsigned char r,g,b;


			xe=Xe(x0,y0);
			ye=Ye(x0,y0,z0);

//	xe=Xe(x0,y0,z0);
//	ye=Ye(x0,y0,z0);
//	zz=Ze(x0,y0,z0);
	x=xn(xe);
	y=ym(ye);

	COLORREF crColor;

	r = (unsigned char) rgb;
	g = (unsigned char) (rgb>>8);
	b = (unsigned char) (rgb>>16);
	
	crColor = RGB(r, g, b);
	
	for(i=-5; i<=5 ; i++)
		for(j=-5; j<=5; j++)
		{
			if(i*i + j*j <= 25)
			{
				x1 = x+i; y1 = y+j;
				if((x1 >= ne1)&&(x1 <= ne2)&&(y1 >= me2)&&(y1 <= me1))
				{
					SetPixel(hdc, x1, y1, crColor);

				}
			}
		}

}





//������ ������� ����� ����, ����������� ���, ��� � �.�.
void LinePaint(HWND hwnd)
{

//��������� ������� ���� ������ � ��������� ���������� ������� ����
//--------------------------------------------------------------------
	RECT rct;
	GetClientRect(hwnd,&rct);

	ne1 = rct.left+50; ne2 = rct.right -50;
	me1 = rct.bottom -50; me2 = rct.top + 50;
//------------------------------------------------------------------

	PAINTSTRUCT ps;

//�������� ������� ���������� ��� ������
	HDC hdcWin = BeginPaint(hwnd, &ps);

	HDC hdc = CreateCompatibleDC(hdcWin); //������� ��������
                     //������ �������� � ���������� ������

   //������ ���� ������� ��� ������ - ������� ������� ����� � ��������
   // ��� � ������. � ������ ����� �������� �� ������� �����
	HBITMAP hBitmap, hBitmapOld;
	hBitmap = CreateCompatibleBitmap(hdcWin, ne2, me1); //�������
               //������� ����� ���������� � ���������� ������
	hBitmapOld = (HBITMAP)SelectObject(hdc, hBitmap); //��������
                // ������� ����� � �������� ������


//�������� ������������� �������
	HRGN hrgn2 = CreateRectRgn(ne1,me2-30,ne2,me1);

//�������� ���������� ������� ����������� ������
	HBRUSH hBrush2 = CreateSolidBrush(RGB(0xC0,0xC0,0xC0));
    FillRgn(hdc,hrgn2,hBrush2);


	
	HPEN hPen, hPenOld;

	MoveToEx(hdc,ne1,me1-1,NULL);
	LineTo(hdc,ne2-1,me1-1);
	LineTo(hdc,ne2-1,me2);
	LineTo(hdc,ne1,me2);
	LineTo(hdc,ne1,me1);


//���������� ������� ������������� �������� ������� ���������
	sf=sin(M_PI*angl.fi/180);
	cf=cos(M_PI*angl.fi/180);
	st=sin(M_PI*angl.teta/180);
	ct=cos(M_PI*angl.teta/180);


//���������� �� ����� �������� ������� ���������
	TCHAR ss[20];
	SetBkColor(hdc,RGB(0xC0,0xC0,0xC0));
	SetTextColor(hdc,RGB(0,0,0x80));
	swprintf_s(ss,20,L"fi = %4.0lf",angl.fi);
	TextOut(hdc,(ne1+ne2)/2-80,me2-25,ss,9);
	swprintf_s(ss,20,L"teta = %4.0lf",angl.teta);
	TextOut(hdc,(ne1+ne2)/2+20,me2-25,ss,11);




	int iCh;

/*
	//"������" ������������� ������ �������� ������ �������� Z-�����	
*/
	//"������" ������������� ������ �������� ������	
	//-----------------------------------------------------------------------
	for(iCh = 0; iCh < NCharge; iCh++)
	{	

	if(qCharge[iCh] < 0)
		Circle(hdc,CoordCharge[iCh].x,CoordCharge[iCh].y,
				CoordCharge[iCh].z,RGB(0,0,255));
	else
		Circle(hdc,CoordCharge[iCh].x,CoordCharge[iCh].y,
				CoordCharge[iCh].z,RGB(255,0,0));
	}
	//------------------------------------------------------------------
	


	
	//������ ��������� ����� ����� ���� ��� ���� �������
	//------------------------------------------------------
	for(iCh = 0; iCh < NCharge; iCh++)
	{	
		LineBeginPoints(CoordCharge[iCh].x,CoordCharge[iCh].y,CoordCharge[iCh].z);
		for(int n = 0; n < 26; n++)
		{
			qPointB[n][iCh].x = PointB[n].x;
			qPointB[n][iCh].y = PointB[n].y;
			qPointB[n][iCh].z = PointB[n].z;
		}
	}
	//-------------------------------------------------------


/*
	//"������" ����� ���� �������� Z-����� ��� ���� �������
*/

	//"������" ����� ���� ��� ���� �������
	//----------------------------------------------------------------
	for(iCh = 0; iCh < NCharge; iCh++)
	{	
		double x0,y0,z0;
		for(int i=0; i<26; i++)
		{
			x0 = qPointB[i][iCh].x; y0 = qPointB[i][iCh].y; z0 = qPointB[i][iCh].z; 
			LineField(hdc,x0,y0,z0,qCharge[iCh],iCh);
		
		}
	}
	//-----------------------------------------------------------------------



//------------------------------------------------------------------------
//������ ����������� ���
	hPen = CreatePen(PS_SOLID,1,RGB(0,255,255));
	hPenOld = SelectPen(hdc,hPen);    

//������� ���������� ������������ �����
	double xe, ye;
//���������� ��������
	int x1,y1,x2,y2;


//��� Ox
	xe=Xe(-1.5*xmax/3,0);
	ye=Ye(-1.5*xmax/3,0,0);
	x1=xn(xe);
	y1=ym(ye);
	xe=Xe(1.5*xmax,0);
	ye=Ye(1.5*xmax,0,0);
	x2=xn(xe);
	y2=ym(ye);
	
	MoveToEx(hdc,x1,y1,NULL);
	LineTo(hdc,x2,y2);

	SetBkColor(hdc,RGB(0xC0,0xC0,0xC0));
	SetTextColor(hdc,RGB(120,120,120));
	TextOut(hdc,x2, y2, _T("X"),1);

//��� Oy
	xe=Xe(0,-1.5*ymax/3);
	ye=Ye(0,-1.5*ymax/3,0);
	x1=xn(xe);
	y1=ym(ye);
	xe=Xe(0,1.5*ymax);
	ye=Ye(0,1.5*ymax,0);
	x2=xn(xe);
	y2=ym(ye);
	
	MoveToEx(hdc,x1,y1,NULL);
	LineTo(hdc,x2,y2);

	SetBkColor(hdc,RGB(0xC0,0xC0,0xC0));
	SetTextColor(hdc,RGB(120,120,120));
	TextOut(hdc,x2, y2, _T("Y"),1);

//��� Oz
	xe=Xe(0,0);
	ye=Ye(0,0,-1.5*zmax/3);
	x1=xn(xe);
	y1=ym(ye);
	xe=Xe(0,0);
	ye=Ye(0,0,1.5*zmax);
	x2=xn(xe);
	y2=ym(ye);

	MoveToEx(hdc,x1,y1,NULL);
	LineTo(hdc,x2,y2);

	SetBkColor(hdc,RGB(0xC0,0xC0,0xC0));
	SetTextColor(hdc,RGB(120,120,120));
	TextOut(hdc,x2, y2, _T("Z"),1);

	SelectPen(hdc,hPenOld);    
	DeletePen(hPen);           
//-----------------------------------------------------------------------------

/*
//---------------------------------------------------------------------------
//������ ��������� ��������� ������ ������, �������� 4 �������
	hPen = CreatePen(PS_SOLID,4,RGB(255,255,0));
	hPenOld = SelectPen(hdc,hPen);    

	double xt1,yt1,zt1,xt2,yt2,zt2;
	int j;

	for(int i=0; i<4; i++)
	{
		j = i + 1;
		if(j==4)
			j = 0;
		xt1 = Px[i]; yt1 = Py[i]; zt1 = Pz[i];
		xt2 = Px[j]; yt2 = Py[j]; zt2 = Pz[j];

		xe=Xe(xt1,yt1);
		ye=Ye(xt1,yt1,zt1);
		x1=xn(xe);
		y1=ym(ye);

		xe=Xe(xt2,yt2);
		ye=Ye(xt2,yt2,zt2);
		x2=xn(xe);
		y2=ym(ye);

		MoveToEx(hdc,x1,y1,NULL);
		LineTo(hdc,x2,y2);
	}


	SelectPen(hdc,hPenOld);    
	DeletePen(hPen);           
//------------------------------------------------------------------






//----------------------------------------------------------------
//������ ����� ����

//������ 16 ����� ���� ������� ������
	hPen = CreatePen(PS_SOLID,2,RGB(255,0,0));
	hPenOld = SelectPen(hdc,hPen);   

	for(int i=0; i<16; i++)
	{
		LineField(hdc,PointB[i]);
		
	}

	SelectPen(hdc,hPenOld);   
	DeletePen(hPen);          


//������ 16 ����� ���� ����� ������
	hPen = CreatePen(PS_SOLID,2,RGB(0,0,255));
	hPenOld = SelectPen(hdc,hPen);    

	for(int i=16; i<32; i++)
	{
		LineField(hdc,PointB[i]);
	}

	SelectPen(hdc,hPenOld);    
	DeletePen(hPen);           
//-----------------------------------------------------------------------
*/

//----------------------------------------------------------------------
//������ ���
	hPen = CreatePen(PS_SOLID,1,RGB(160,160,160));
	hPenOld = SelectPen(hdc,hPen);

	DrawBox(hwnd, hdc, angl);

	SelectPen(hdc,hPenOld);
	DeletePen(hPen);       
//------------------------------------------------------------------------

	BitBlt(hdcWin,ne1,me2-30,ne2,me1,hdc,ne1,me2-30,SRCCOPY); //����-
   //���� �������� ������ � �������� ������

	DeleteObject(hBrush2);
	DeleteObject(hrgn2);


	SelectObject(hdc, hBitmapOld); //�������������� �������� ������
	DeleteObject(hBitmap); //������� ������� �����
	DeleteDC(hdc);  //  ����������� �������� ������


	EndPaint(hwnd, &ps);   
}



//������������ ������� ����� ������� �����
void LineLButtonDown(HWND hwnd, int x, int y)
{
	Dat.ButtonDown = TRUE;
	Dat.Drawing = FALSE;
	
	anglOld.fi = angl.fi;
	anglOld.teta = angl.teta;
	corOld.x = x;
	corOld.y = y;
	
//��� ������� ������� ���� ���������� ��� ����� ������
	HDC PaintDC = GetDC(hwnd);
	HPEN hPen, hPenOld;
	hPen = CreatePen(PS_SOLID,1,RGB(0,0,255));
	hPenOld = SelectPen(PaintDC,hPen);   

	SetROP2(PaintDC, R2_NOTXORPEN);
		
	DrawBox(hwnd, PaintDC, anglOld);

	SelectPen(PaintDC,hPenOld);  
	DeletePen(hPen);           

	ReleaseDC(hwnd, PaintDC);
}

//������������ ���������� ����� ������� �����
void LineLButtonUp(HWND hwnd)
{
	if(Dat.ButtonDown && Dat.Drawing)
		Dat.Drawing = FALSE;

	Dat.ButtonDown = FALSE;
}


//������������ �������� ���� ��� ������� ����� �������
void LineMouseMove(HWND hwnd,int x, int y)
{

	if(Dat.ButtonDown)
	{
		Dat.Drawing = TRUE;

		HDC PaintDC = GetDC(hwnd);
		
//�������������� ��� � ����� ��������� � ������ NOTXOR
		HPEN hPen, hPenOld;
		hPen = CreatePen(PS_SOLID,1,RGB(0,0,255));
		hPenOld = SelectPen(PaintDC,hPen);  

		SetROP2(PaintDC, R2_NOTXORPEN);
		
		DrawBox(hwnd, PaintDC, anglOld);

		angl.fi += corOld.x-x;
		angl.teta += corOld.y-y;
		
		corOld.x = x; corOld.y = y;

		anglOld.fi   = angl.fi;
		anglOld.teta   = angl.teta;

		DrawBox(hwnd, PaintDC, anglOld);

		SelectPen(PaintDC,hPenOld);   
		DeletePen(hPen);           


//���������� �� ����� �������� ����
		TCHAR ss[20];
		SetBkColor(PaintDC,RGB(0xC0,0xC0,0xC0));
		SetTextColor(PaintDC,RGB(0,0,0x80));
		swprintf_s(ss,20,L"fi = %4.0lf",angl.fi);
		TextOut(PaintDC,(ne1+ne2)/2-80,me2-25,ss,9);
		swprintf_s(ss,20,L"teta = %4.0lf",angl.teta);
		TextOut(PaintDC,(ne1+ne2)/2+20,me2-25,ss,11);

		ReleaseDC(hwnd, PaintDC);
	}

}


//������ ���, ��������� � ��������� �������� ���������
void DrawBox(HWND hwnd, HDC hdc, ANGLS an)
{
	sf=sin(M_PI*an.fi/180);
	cf=cos(M_PI*an.fi/180);
	st=sin(M_PI*an.teta/180);
	ct=cos(M_PI*an.teta/180);

	double xe, ye;
	int x1,y1,x2,y2;
	double xt1,yt1,zt1,xt2,yt2,zt2;
	int j;

	for(int i=0; i<4; i++)
	{
		j = i + 1;
		if(j==4)
			j = 0;
		xt1 = Point[i].x; yt1 = Point[i].y; zt1 = Point[i].z;
		xt2 = Point[j].x; yt2 = Point[j].y; zt2 = Point[j].z;

		xe=Xe(xt1,yt1);
		ye=Ye(xt1,yt1,zt1);
		x1=xn(xe);
		y1=ym(ye);

		xe=Xe(xt2,yt2);
		ye=Ye(xt2,yt2,zt2);
		x2=xn(xe);
		y2=ym(ye);

		MoveToEx(hdc,x1,y1,NULL);
		LineTo(hdc,x2,y2);
	}



	for(int i=4; i<8; i++)
	{
		j = i + 1;
		if(j==8)
			j = 4;
		xt1 = Point[i].x; yt1 = Point[i].y; zt1 = Point[i].z;
		xt2 = Point[j].x; yt2 = Point[j].y; zt2 = Point[j].z;

		xe=Xe(xt1,yt1);
		ye=Ye(xt1,yt1,zt1);
		x1=xn(xe);
		y1=ym(ye);

		xe=Xe(xt2,yt2);
		ye=Ye(xt2,yt2,zt2);
		x2=xn(xe);
		y2=ym(ye);

		MoveToEx(hdc,x1,y1,NULL);
		LineTo(hdc,x2,y2);
	}

	for(int i=0; i<4; i++)
	{
		xt1 =   Point[i].x; yt1 =   Point[i].y; zt1 =   Point[i].z;
		xt2 = Point[i+4].x; yt2 = Point[i+4].y; zt2 = Point[i+4].z;

		xe=Xe(xt1,yt1);
		ye=Ye(xt1,yt1,zt1);
		x1=xn(xe);
		y1=ym(ye);

		xe=Xe(xt2,yt2);
		ye=Ye(xt2,yt2,zt2);
		x2=xn(xe);
		y2=ym(ye);

		MoveToEx(hdc,x1,y1,NULL);
		LineTo(hdc,x2,y2);
	}


	for(int i=0; i<2; i++)
	{
		xt1 =   Point[i].x; yt1 =   Point[i].y; zt1 =   Point[i].z;
		xt2 = Point[i+2].x; yt2 = Point[i+2].y; zt2 = Point[i+2].z;

		xe=Xe(xt1,yt1);
		ye=Ye(xt1,yt1,zt1);
		x1=xn(xe);
		y1=ym(ye);

		xe=Xe(xt2,yt2);
		ye=Ye(xt2,yt2,zt2);
		x2=xn(xe);
		y2=ym(ye);

		MoveToEx(hdc,x1,y1,NULL);
		LineTo(hdc,x2,y2);
	}


}


