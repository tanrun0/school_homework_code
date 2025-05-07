function X = movePointOnCircle(a, b, r, x0, y0, L)  
    % a, b: 圆心坐标  
    % r: 圆的半径  
    % x0, y0: 初始点坐标  
    % L: 运动的弧长  
  
    % 计算初始角度  
    theta0 = atan2(y0-b, x0-a);  
      
    % 计算角度增量  
    deltaTheta = L / r;  
      
    % 更新角度（考虑周期性，使用mod确保角度在-pi到pi之间）  
    theta1 = mod(theta0 + deltaTheta + pi, 2*pi) - pi;  
      
    % 计算新坐标  
    newX = a + r * cos(theta1);  
    newY = b + r * sin(theta1);  

    X = [newX, newY];
end  