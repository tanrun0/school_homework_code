function X = f2(r_1, theta_1, b, L) 
    X = zeros(1,2);
    % 初始猜测值  
    x0 = [r_1 + 0.02; theta_1]; 
  
    % 用fsolve求解  返回r_2和theta_2
    x_sol = fsolve(@(x) robot_arm_equations(x, r_1, b, theta_1, L), x0);  
  
    % 输出解  
    X(1) = x_sol(1);  
    X(2) = x_sol(2);  
end  
  
function F = robot_arm_equations(x, r_1, b, theta_1, L)  
    % x 是包含 r_2 和 theta_2 的向量  
    r_2 = x(1);  
    theta_2 = x(2);  
  
    % 定义方程组  
    eq1 = r_2 - r_1 - b * (theta_2 - theta_1);  
    eq2 = L^2 - (r_1^2 + r_2^2 - 2 * r_1 * r_2 * cos(theta_2 - theta_1));  
  
    % 返回方程组作为零差  
    F = [eq1; eq2];  
end