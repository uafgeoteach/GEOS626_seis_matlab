%
% run_Bkspline.m
%
% This is a plotting test function for Bkspline.m, which returns a
% spherical spline basis function at specifited lat-lon points.
% It also returns the spatial derivatives of the basis function,
% which are useful for representating derivatives of target functions,
% as well as for damping.
%

clear, close all, clc
format short
format compact

deg = 180/pi;

%-----------------

% create sample data
numx = 200;  % KEY COMMAND
ax1 = [-122 -114 32 37];
lonmin = ax1(1); lonmax = ax1(2);
latmin = ax1(3); latmax = ax1(4);
[lon,lat] = gridvec(lonmin,lonmax,numx,latmin,latmax);

% select sample spline (DEFAULT: pick one at random)
q = 6;      % KEY: determines the scalelength of the spline (q = 0-10)
clon = (lonmax - lonmin)*rand + lonmin;
clat = (latmax - latmin)*rand + latmin;

% evaluate spline function
ff = Bkspline(clon, clat, q, lon, lat);

% plotting
[X,Y,Z] = griddataXB(lon,lat,ff(:,1),100,'cubic');
figure; pcolor(X,Y,Z); shading interp;
axis equal, axis(ax1); caxis([0 1]); colorbar('vert'); 
xlabel(' Longitude (deg)'); ylabel(' Latitude (deg)');
title([' Spherical spline basis function, order q=' num2str(q) ', centered at lon = ' ...
    sprintf('%.2f',clon) ', lat = ' sprintf('%.2f',clat) ]);

break

%--------------------------------------------------------------------------
% THE REST IS FOR LOOKING AT DERIVATIVES OF BASIS FUNCTIONS --
% THIS IS NOT NEEDED IN THE TOMOGRAPHY PROBLEM

ncol = 5;
ff = Bkspline(clon, clat, q, lon, lat, {ncol});

dfdp = ff(:,2);
dfdt = ff(:,3);
th   = (90-lat)/deg;

% magnitude of surface gradient of spline
% check the computation return Bkspline.m
dfmag = sqrt( dfdt.^2 + ((1./sin(th)) .* dfdp).^2 );
norm( dfmag - ff(:,5) )

d1max = max([ max(abs(dfdp)) max(abs(dfdt)) ]);

% plot
figure; nr=3; nc=2;
stitd = {' f',' d f / d \phi',' d f / d \theta',' \nabla^2 f',' | \nabla f | '};

for ii=1:length(stitd)
    [X,Y,Z] = griddataXB(lon,lat,ff(:,ii),100,'cubic');
    subplot(nr,nc,ii);
    pcolor(X,Y,Z); shading interp;
    title(stitd{ii});
    axis equal, axis(ax1); colorbar('horiz');
    if or(ii==2,ii==3), caxis([-1 1]*d1max); end
end
%fontsize(8); orient tall, pause(1); wysiwyg

%------------------------------------
% plot the surface gradient

figure; hold on;

[X,Y,Z] = griddataXB(lon,lat,ff(:,5),numx,'cubic');
pcolor(X,Y,Z); shading interp;
title(stitd{ii});
axis equal, axis(ax1); colorbar('horiz');

% create sample data
[lon,lat] = gridvec(lonmin,lonmax,20,latmin,latmax);
ff = Bkspline(clon, clat, q, lon, lat, {ncol});

[X,Y,Z] = griddataXB(lon,lat,ff(:,5),100,'cubic');
quiver(lon,lat,ff(:,2),-ff(:,3),'k');  % minus sign is to plot the EAST component
axis equal, axis(ax1); colorbar('horiz');
title(' surface gradient vector field, along with the magnitude');
%orient tall, wysiwyg

%==========================================================================
