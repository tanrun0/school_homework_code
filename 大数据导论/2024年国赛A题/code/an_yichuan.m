% 主程序 genmain.m  
function genmain()  
    tic;  
    clear;  
    clf;  
  
    popsize = 200; % 群体大小  
    chromlength = 30; % 字符串长度（个体长度），每个变量10位，共3个变量  
    pc = 0.8; % 交叉概率  
    pm = 0.3; % 变异概率  
  
    pop = initpop(popsize, chromlength); % 随机产生初始群体  
    for i = 1:20 % 20为迭代次数  
        [objvalue] = calobjvalue(pop); % 计算目标函数  
        fitvalue = calfitvalue(objvalue); % 计算群体中每个个体的适应度  
        [newpop] = selection(pop, fitvalue); % 复制  
        [newpop] = crossover(newpop, pc); % 交叉，注意这里使用newpop  
        [newpop] = mutation(newpop, pm); % 变异，注意这里使用newpop  
        [bestindividual, bestfit] = best(newpop, fitvalue); % 求出群体中适应值最大的个体及其适应值  
        y(i) = bestfit; % 这里记录的是适应度，对于求最小值问题，适应度最大即目标函数值（经过转换）最小  
        n(i) = i;  
        % 解码最优个体  
        [alpha1_opt, alpha2_opt, r2_opt] = decodeindividual(bestindividual, chromlength);  
        x(i) = alpha1_opt; % 可以选择记录不同的变量  
        pop = newpop; % 更新种群  
    end  
  
    % 绘图（略去，因为目标函数较复杂）  
    % 可以使用 scatter3 或其他3D绘图函数展示 alpha1, alpha2, r2 的关系  
  
    % 这里不需要再找最小值，因为y已经记录了每次迭代的最优适应度（即目标函数的最小值，经过适应度转换）  
    fprintf('Optimal alpha1: %f, alpha2: %f, r2: %f, Minimum y (fitness): %f\n', alpha1_opt, alpha2_opt, r2_opt, max(y)); % 注意这里是max(y)因为y记录的是适应度  
    toc;  
end 
  
% 初始化 initpop.m  
function pop = initpop(popsize, chromlength)  
    pop = round(rand(popsize, chromlength)); % rand随机产生每个单元为 {0,1}  
end  
  
% 解码函数 decodeindividual.m（新增）  
function [alpha1, alpha2, r2] = decodeindividual(individual, chromlength)  
    alpha1_bin = individual(1:10);  
    alpha2_bin = individual(11:20);  
    r2_bin = individual(21:30);  
      
    alpha1 = bi2de(alpha1_bin, 'left-msb') / 1023 * 2 * pi; % 解码为0-2*pi  
    alpha2 = bi2de(alpha2_bin, 'left-msb') / 1023 * 2 * pi; % 解码为0-2*pi  
    r2 = bi2de(r2_bin, 'left-msb') / 1023 * 2.25; % 解码为0-2.25  
end  
  
% 二进制转十进制 decodebinary.m（修改）  
function pop2 = decodebinary(pop)  
    [px, py] = size(pop);  
    for i = 1:py  
        pop1(:, i) = 2.^(py - i) .* pop(:, i);  
    end  
    pop2 = sum(pop1, 2);  
end  
  
% 计算目标函数 calobjvalue.m（修改）  
function [objvalue] = calobjvalue(pop)  
    [alpha1, alpha2, r2] = decodevariables(pop);  
    % 罚函数处理约束条件  
    penalty = 1e3 * abs(sin(alpha1) - 0.5 * sin(alpha2));  
    objvalue = 2 * r2 .* alpha1 + r2 .* alpha2 + penalty;  
end  

  
% 解码所有变量 decodevariables.m（新增）  
function [alpha1, alpha2, r2] = decodevariables(pop)  
    popsize = size(pop, 1);  
    alpha1 = zeros(popsize, 1);  
    alpha2 = zeros(popsize, 1);  
    r2 = zeros(popsize, 1);  
    for i = 1:popsize  
        [alpha1(i), alpha2(i), r2(i)] = decodeindividual(pop(i, :), 30);  
    end  
end  
  
function fitvalue = calfitvalue(objvalue)  
    % 使用目标函数值的相反数作为适应度（求最小值）  
    % 并且进行归一化处理  
    Cmax = max(objvalue);  
    fitvalue = Cmax - objvalue;  
    fitvalue = fitvalue / sum(fitvalue); % 归一化  
end
  
function [newpop] = selection(pop, fitvalue)  
    % 使用轮盘赌选择算法  
    totalfit = sum(fitvalue);  
    fitvalue = fitvalue / totalfit; % 归一化适应度  
    fitvalue = cumsum(fitvalue); % 计算累积和  
    [px, ~] = size(pop);  
    ms = rand(px, 1); % 生成随机数  
    newpop = zeros(size(pop));  
    for i = 1:px  
        % 查找第一个大于或等于随机数的累积适应度位置  
        idx = find(fitvalue >= ms(i), 1, 'first');  
        newpop(i, :) = pop(idx, :);  
    end  
end 
  
% 交叉 crossover.m（未修改）  
function [newpop] = crossover(pop, pc)  
    [px, py] = size(pop);  
    newpop = ones(size(pop));  
    for i = 1:2:px-1  
        if rand < pc  
            cpoint = round(rand * py);  
            newpop(i, :) = [pop(i, 1:cpoint), pop(i + 1, cpoint + 1:py)];  
            newpop(i + 1, :) = [pop(i + 1, 1:cpoint), pop(i, cpoint + 1:py)];  
        else  
            newpop(i, :) = pop(i);  
            newpop(i + 1, :) = pop(i + 1);  
        end  
    end  
end  
  
% 变异 mutation.m（未修改）  
function [newpop] = mutation(pop, pm)  
    [px, py] = size(pop);  
    newpop = ones(size(pop));  
    for i = 1:px  
        if rand < pm  
            mpoint = round(rand * py);  
            if mpoint <= 0  
                mpoint = 1;  
            end  
            newpop(i) = pop(i);  
            if any(newpop(i, mpoint)) == 0  
                newpop(i, mpoint) = 1;  
            else  
                newpop(i, mpoint) = 0;  
            end  
        else  
            newpop(i) = pop(i);  
        end  
    end  
end  

% 求出群体中最大适应值及其个体 best.m（修改，求最小值）  
function [bestindividual, bestfit] = best(pop, fitvalue)  
    [px, py] = size(pop);  
    bestindividual = pop(1, :);  
    bestfit = fitvalue(1); % 这里是适应度，对于求最小值问题，适应度最大即目标函数值最小  
    for i = 2:px  
        if fitvalue(i) > bestfit % 适应度比较  
            bestindividual = pop(i, :);  
            bestfit = fitvalue(i);  
        end  
    end  
end