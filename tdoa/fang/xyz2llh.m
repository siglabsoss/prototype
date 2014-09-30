function llh=xyz2llh(xyz)
%xyz2llh(xyz)       llh=xyz2llh(xyz)
%
%Calculates longitude, latitude, and height on the
%WGS-84 reference ellipsoid, given global (XYZ) cartesian
%coordinates.
%
%Input 'xyz' and output 'llh' are 3xn, where n is the number
%of coordinate triples.
%
%N.B., longitude and latitude are outputted in decimal degrees;
%height in km.
%
%November 4, 2000.  Peter Cervelli

%Set ellipsoid constants (for WGS-84)

     a=6378137.0;
     f=1/298.257223563;
     b=a-f*a;
     e2=2*f - f^2;
     E2=(a^2-b^2)/(b^2);

%Calculate longitude

     llh(1,:)=atan2(xyz(2,:),xyz(1,:));

%Calculate latitude

     p=sqrt(xyz(1,:).^2 + xyz(2,:).^2);
     theta=atan((xyz(3,:)*a)./(p*b));
     llh(2,:)=atan((xyz(3,:)+E2*b*sin(theta).^3)./(p-e2*a*cos(theta).^3));

%Calculate height

     N=a./sqrt(1-e2*sin(llh(2,:)).^2);
     llh(3,:)=p./cos(llh(2,:))-N;

%Do conversion into appropriate units

     llh(1:2,:)=llh(1:2,:)*180/pi;
     llh(3,:)=llh(3,:)/1000;
