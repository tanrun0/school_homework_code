r2 = 2.86/2 ; % 因为小圆的直径需要大于龙头两把手之间的距离，所以易得小圆的最小半径

s_long = 3*r2*pi;
disp(["最短掉头曲线S的长度是：",s_long])

b = 1.7/(2*pi); % 螺距1.7
% 进入点的极经和极角(也是龙头第0秒时候的坐标)（原螺线方程求出来的就是进入点）
r0 = 3*r2;
theta0 = r0/b; 
thetat = r0/(-b); % 出来的点

theta0_c = normalizeAngle(theta0);
thetat_r = normalizeAngle(thetat);

%% 计算圆心的坐标和半径
big = [r2*cos(theta0_c),r2*sin(theta0_c)];
small = [2*r2*cos(thetat),2*r2*sin(thetat)];

%% 求解对应情况下的位置和速度 
%% weizhi（掉头前-100s）

a = 0; % 起始半径（起始点距离原点的距离）
s = 1; % 龙头1s内走过的弧长
theta_lower = theta0;  % 当前时刻的角度（下限）
result1 = zeros(448,201); % 存放x，y坐标
result_r = zeros(448,201); % 存放r和theta

% 初始化龙头的0时刻位置(放在最后一列)
result_r(1,101) = r0;
result_r(2,101) = theta0;
result1(1,101) = r0 * cos(theta0);
result1(2,101) = r0 * sin(theta0);


% 求解各时刻龙头的位置（越往前时刻，r是越来越大的）
for t = 101:-1:1

    theta = f4(a,b,theta_lower,1);
    r = a + b * theta;
    result_r(1,t) = r; % 从后往前赋值
    result_r(2,t) = theta; 

    x = r * cos(theta);
    y = r * sin(theta);
    result1(1,t) = x;
    result1(2,t) = y;
    theta_lower = theta;

end

% 计算龙头的位置
% 101就是第0s
% 0-8s在大圆里面
for t = 101:108
    X = movePointOnCircle(big(1),big(2),2*r2,result1(1,t),result1(2,t),1);
    result1(1,t+1) = X(1);
    result1(2,t+1) = X(2);
    Y = cartesianToPolar(X(1),X(2));
    result_r(1,t+1) = Y(1);
    result_r(2,t+1) = Y(2);
end

% 后面四秒在小圆弧
for t = 108:112
    X = movePointOnCircle(big(1),big(2),2*r2,result1(1,t),result1(2,t),1);
    result1(1,t+1) = X(1);
    result1(2,t+1) = X(2);
    Y = cartesianToPolar(X(1),X(2));
    result_r(1,t+1) = Y(1);
    result_r(2,t+1) = Y(2);
end

% 在中心对称的螺线上了
for t = 113:200
    theta_upper = result_r(2,t);
    theta = f4(a,-b,theta_upper,1);
    r = a + (-b) * theta;
    result_r(1,t+1) = r;
    result_r(2,t+1) = theta;

    x = r * cos(theta);
    y = r * sin(theta);
    result1(1,t+1) = x;
    result1(2,t+1) = y;
    theta_upper = theta;

end

%% 


%% 单独算出第一节龙身
for t = 101:-1:1
    X = f2(result_r(1,t), result_r(2,t), b, 2.86);

    result_r(3,t) = X(1);
    result_r(4,t) = X(2);

    x = X(1) * cos(X(2));
    y = X(1) * sin(X(2));
    result1(3,t) = x;
    result1(4,t) = y;

end
for t = 102:201

    X = f2(result_r(1,t), result_r(2,t), b, 2.86);

    result_r(3,t) = X(1);
    result_r(4,t) = X(2);

    x = X(1) * cos(X(2));
    y = X(1) * sin(X(2));
    result1(3,t) = x;
    result1(4,t) = y;
end



%% 循环，利用前把手的位置算出下一个把手的位置
for i = 2:223
    for t = 101:-1:1
    X = f2(result_r(2*i-1,t), result_r(2*i,t), b, 1.65);

    result_r(2*i+1,t) = X(1);  
    result_r(2*i+2,t) = X(2);

    x = X(1) * cos(X(2));
    y = X(1) * sin(X(2));
    result1(2*i+1,t) = x;
    result1(2*i+2,t) = y;
    end
end

for i = 2:223
    for t = 102:201
    X = f2(result_r(2*i-1,t), result_r(2*i,t), b, 1.65);

    result_r(2*i+1,t) = X(1);
    result_r(2*i+2,t) = X(2);

    x = X(1) * cos(X(2));
    y = X(1) * sin(X(2));
    result1(2*i+1,t) = x;
    result1(2*i+2,t) = y;
    end
end


%% 计算速度
load r_theta.mat
result2 = zeros(224,201);
deta_t = 1;
result2(1,:) = ones(1,201); 


% t = 0s 时的速度
for i = 2:224
    x = result1(2*i-1,2) - result1(2*i-1,1);  % 1s-0s
    y = result1(2*i,2) - result1(2*i,1); 
    result2(i,1) = sqrt(x^2 + y^2)/deta_t;
end



for t = 2:200
    for i = 2:224
        x = result1(2*i-1,t+1) - result1(2*i-1,t-1);
        y = result1(2*i,t+1) - result1(2*i,t-1);
        result2(i,t) = sqrt(x^2 + y^2)/2*deta_t;
    end

end



for i = 2:224
    x = result1(2*i-1,201) - result1(2*i-1,200);  
    y = result1(2*i,201) - result1(2*i,200); 
    result2(i,201) = sqrt(x^2 + y^2)/deta_t;
end

