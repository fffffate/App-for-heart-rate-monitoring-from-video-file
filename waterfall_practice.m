for i=1:100
    x(i)=i+2;
    y(i)=x(i)*2;
    
end
grid on;
figure
[X,Y] = meshgrid(x);
Z = peaks(X,Y);
meshz(Z)