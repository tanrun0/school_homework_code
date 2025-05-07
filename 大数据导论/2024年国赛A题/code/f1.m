% 给定s计算积分下限theta_lower
function theta_lower = f1(a, b, theta_upper, s)  
    % 被积函数  
    integrand = @(theta) sqrt(b^2 + (a + b*theta).^2);  

    % 定义一个函数，该函数计算从theta_lower到theta_upper的积分，并返回与目标s的差值  
    fun = @(theta_lower) integral(integrand, theta_lower, theta_upper) - s;  

    % 使用fzero找到使得fun(theta_lower) = 0的下限  
    % 设fzero初始猜测值为theta_upper
    theta_lower = fzero(fun, theta_upper);  

end




