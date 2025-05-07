% 给定s计算积分上限theta_upper  
function theta_upper = f4(a, b, theta_lower, s)  
    % 被积函数  
    integrand = @(theta) sqrt(b^2 + (a + b*theta).^2);  
  
    % 定义一个函数，该函数计算从theta_lower到theta_upper的积分，并返回与目标s的差值  
    fun = @(theta_upper) integral(integrand, theta_lower, theta_upper) - s;  
  
    theta_upper = fzero(fun, theta_lower);  

end
