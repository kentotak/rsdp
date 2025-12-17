% from image processing toolbox: find sub pixel peak by 2D polynomial fit (added standard deviation)
% standard deviation is calculated according to (Lunt,2015) "A review of micro-scale focused ion beam milling and digital image correlation analysis for residual stress evaluation and error estimation"
function [xpeak, ypeak, xstd, ystd, max_f] = findpeak(f,subpixel)
%FINDPEAK Find extremum of matrix.
%   [XPEAK,YPEAK,MAX_F] = FINDPEAK(F,SUBPIXEL) finds the extremum of F,
%   MAX_F, and its location (XPEAK, YPEAK). F is a matrix. MAX_F is the maximum
%   absolute value of F, or an estimate of the extremum if a subpixel
%   extremum is requested.
%
%   SUBPIXEL is a boolean that controls if FINDPEAK attempts to estimate the
%   extremum location to subpixel precision. If SUBPIXEL is false, FINDPEAK
%   returns the coordinates of the maximum absolute value of F and MAX_F is
%   max(abs(F(:))). If SUBPIXEL is true, FINDPEAK fits a 2nd order
%   polynomial to the 9 points surrounding the maximum absolute value of
%   F. In this case, MAX_F is the absolute value of the polynomial evaluated
%   at its extremum.
%
%   Note: Even if SUBPIXEL is true, there are some cases that result
%   in FINDPEAK returning the coordinates of the maximum absolute value
%   of F:
%   * When the maximum absolute value of F is on the edge of matrix F.
%   * When the coordinates of the estimated polynomial extremum would fall
%     outside the coordinates of the points used to constrain the estimate.

%   Copyright 1993-2004 The MathWorks, Inc.
%   

xstd=1e-4;
ystd=1e-4;

% get absolute peak pixel
[max_f, imax] = max(abs(f(:)));
[ypeak, xpeak] = ind2sub(size(f),imax(1));
    
if ~subpixel || ...
    xpeak==1 || xpeak==size(f,2) || ypeak==1 || ypeak==size(f,1) % on edge
    return % return absolute peak
    
else
    % fit a 2nd order polynomial to 9 points  
    % using 9 pixels centered on irow,jcol    
    u = f(ypeak-1:ypeak+1, xpeak-1:xpeak+1);
    u = u(:);
    x = [-1 -1 -1  0  0  0  1  1  1]';
    y = [-1  0  1 -1  0  1 -1  0  1]';    

    % u(x,y) = A(1) + A(2)*x + A(3)*y + A(4)*x*y + A(5)*x^2 + A(6)*y^2
    X = [ones(9,1),  x,  y,  x.*y, x.^2,  y.^2];
    
    % u = X*A
    A = X\u;

    % get absolute maximum, where du/dx = du/dy = 0
    x_num = (-A(3)*A(4)+2*A(6)*A(2));
    den = (A(4)^2-4*A(5)*A(6));
    x_offset = x_num / den ;
    y_num = (A(4)*A(2)-2*A(5)*A(3));
    y_offset = -1 * y_num / ( den );
    
    % calculate residuals
    e=u-X*A;
    
    % calculate estimate of the noise variance
    n=9; % number of data points
    p=6; % number of fitted parameters
    var=sum(e.^2)/(n-p);
    
    % calculate covariance matrix
    cov=inv(X'*X)*var;
    
    % produce vector of std deviations on each term
    s=sqrt([cov(1,1),cov(2,2),cov(3,3),cov(4,4),cov(5,5),cov(6,6)]);
    
    % Calculate standard deviation of denominator, and numerators
    x_num_std=sqrt(4*A(6)^2*A(2)^2*((s(6)/A(6))^2+(s(2)/A(2))^2)+A(3)^2*A(4)^2*((s(3)/A(3))^2+(s(4)/A(4))^2));
    den_std=sqrt(16*A(5)^2*A(6)^2*((s(5)/A(5))^2+(s(6)/A(6))^2)+2*s(4)^2*A(4)^2);
    y_num_std=sqrt(4*A(5)^2*A(3)^2*((s(5)/A(5))^2+(s(3)/A(3))^2)+A(4)^2*A(2)^2*((s(4)/A(4))^2+(s(2)/A(2))^2));

    % Calculate standard deviation of x and y positions
    xstd=sqrt(x_offset^2*((x_num_std/x_num)^2+(den_std/den)^2));
    ystd=sqrt(y_offset^2*((den_std/den)^2+(y_num_std/y_num)^2));

    if abs(x_offset)>1 || abs(y_offset)>1
        % adjusted peak falls outside set of 9 points fit,
        return % return absolute peak
    end
    
    % return only one-tenth of a pixel precision
    x_offset = round(1000*x_offset)/1000;
    y_offset = round(1000*y_offset)/1000;
    
    xpeak = xpeak + x_offset;
    ypeak = ypeak + y_offset;    
    
    % Calculate extremum of fitted function
    max_f = [1 x_offset y_offset x_offset*y_offset x_offset^2 y_offset^2] * A;
    max_f = abs(max_f);
    
end
