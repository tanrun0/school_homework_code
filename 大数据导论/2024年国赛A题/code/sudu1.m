load r_theta.mat
load x_y.mat
result2 = zeros(224,301);
deta_t = 1;
result2(1,:) = ones(1,301); 


% t = 0s 时的速度
for i = 2:224
    x = x_y(2*i-1,2) - x_y(2*i-1,1);  % 1s-0s
    y = x_y(2*i,2) - x_y(2*i,1); 
    result2(i,1) = sqrt(x^2 + y^2)/deta_t;
end



for t = 2:300
    for i = 2:224
        x = x_y(2*i-1,t+1) - x_y(2*i-1,t-1);
        y = x_y(2*i,t-1) - x_y(2*i,t+1);
        result2(i,t) = sqrt(x^2 + y^2)/2*deta_t;
    end

end


% 计算第300s的速度
for i = 2:224
    x = x_y(2*i-1,301) - x_y(2*i-1,300);  % 300s-299s
    y = x_y(2*i,301) - x_y(2*i,300); 
    result2(i,301) = sqrt(x^2 + y^2)/deta_t;
end

