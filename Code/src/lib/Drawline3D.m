function [xn,yn,zn] = Drawline3D(X0, Y0, Z0, X1, Y1, Z1)
    n = 0:(1/round(sqrt((X1-X0)^2 + (Y1-Y0)^2 + (Z1-Z0)^2))):1;
    xn = zeros(length(n),1);
    yn = zeros(length(n),1);
    zn = zeros(length(n),1);
    for i =1:length(n)
        xn(i) = round(X0 +(X1 - X0)*n(i)); 
        yn(i) = round(Y0 +(Y1 - Y0)*n(i)); 
        zn(i) = round(Z0 +(Z1 - Z0)*n(i)); 
    end
end