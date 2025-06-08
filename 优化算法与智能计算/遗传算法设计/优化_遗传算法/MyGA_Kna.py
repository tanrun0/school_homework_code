# 混合模拟退火 + 遗传：遗传全局搜索，模拟退火局部搜索
import random
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from deap import base, creator, tools
from math import exp

class KnapsackProblem:
    """背包问题类，用于定义问题实例和评估解决方案"""

    def __init__(self):
        # 定义物品列表，每个物品由(名称, 重量, 价值)元组表示
        self.items = [
            ("map", 9, 150),
            ("compass", 13, 35),
            ("water", 153, 200),
            ("sandwich", 50, 160),
            ("glucose", 15, 60),
            ("tin", 68, 45),
            ("banana", 27, 60),
            ("apple", 39, 40),
            ("cheese", 23, 30),
            ("beer", 52, 10),
            ("suntan cream", 11, 70),
            ("camera", 32, 30),
            ("t-shirt", 24, 15),
            ("trousers", 48, 10),
            ("umbrella", 73, 40),
            ("waterproof trousers", 42, 70),
            ("waterproof overclothes", 43, 75),
            ("note-case", 22, 80),
            ("sunglasses", 7, 20),
            ("towel", 18, 12),
            ("socks", 4, 50),
            ("book", 30, 10)
        ]
        # 背包的最大容量
        self.maxCapacity = 400

    def getValue(self, chromosome):
        """
        计算染色体的总价值
        忽略会导致累积重量超过最大重量的物品
        """
        totalWeight = 0
        totalValue = 0

        for i in range(len(chromosome)):
            item, weight, value = self.items[i]
            if totalWeight + weight <= self.maxCapacity:
                totalWeight += chromosome[i] * weight
                totalValue += chromosome[i] * value
        return totalValue

    def printItems(self, chromosome):
        """
        打印染色体中选择的物品
        忽略会导致累积重量超过最大重量的物品
        """
        totalWeight = 0
        totalValue = 0

        for i in range(len(chromosome)):
            item, weight, value = self.items[i]
            if totalWeight + weight <= self.maxCapacity:
                if chromosome[i] > 0:
                    totalWeight += weight
                    totalValue += value
                    print(
                        f"-Adding {item}: weight = {weight}, value = {value}, accumulated weight = {totalWeight}, accumulated value = {totalValue}")
        print(f"-Total weight = {totalWeight}, Total value = {totalValue}")

# 创建一个实例并测试问题
knapsack = KnapsackProblem()

# 遗传算法参数设置 - 和传统遗传算法一致
POPULATION_SIZE = 30  # 种群大小
P_CROSSOVER = 0.9  # 交叉概率
P_MUTATION = 0.1  # 变异概率
MAX_GENERATIONS = 75  # 最大迭代次数
HALL_OF_FAME_SIZE = 1  # 精英个体数量

# 模拟退火参数
INITIAL_TEMPERATURE = 200
MIN_TEMPERATURE = 10  # 最低温度阈值
COOLING_RATE = 0.95  # 降温率
SA_ITERATIONS = 10  # SA迭代次数

# 设置随机种子，确保结果可重现
RANDOM_SEED = 42
random.seed(RANDOM_SEED)

# 创建遗传算法工具箱
toolbox = base.Toolbox()

# 创建一个随机返回0或1的函数，用于生成染色体基因
toolbox.register("zeroOrOne", random.randint, 0, 1)

# 定义适应度类，设置为最大化问题
creator.create("FitnessMax", base.Fitness, weights=(1.0,))

# 创建个体类，基于列表结构
creator.create("Individual", list, fitness=creator.FitnessMax)

# 创建个体生成器，使用zeroOrOne函数填充个体
toolbox.register("individualCreator", tools.initRepeat, creator.Individual, toolbox.zeroOrOne, len(knapsack.items))

# 创建种群生成器，生成指定大小的种群
toolbox.register("populationCreator", tools.initRepeat, list, toolbox.individualCreator, POPULATION_SIZE)


# 适应度计算函数 - 保持与原始遗传算法一致
def knapsackValue(individual):
    return knapsack.getValue(individual),  # 返回一个元组，符合DEAP库的要求


# 注册适应度评估函数
toolbox.register("evaluate", knapsackValue)

# 注册遗传算法操作
toolbox.register("select", tools.selTournament, tournsize=3)  # 锦标赛选择
toolbox.register("mate", tools.cxTwoPoint)  # 两点交叉
toolbox.register("mutate", tools.mutFlipBit, indpb=1.0 / len(knapsack.items))  # 位翻转变异

# 优化的模拟退火函数
def optimized_sa(individual, temperature):
    current = list(individual)
    current_fitness = knapsack.getValue(current)

    best_solution = list(current)
    best_fitness = current_fitness

    # 计算当前解的重量（修正变量名：chromosome → current）
    current_weight = sum(current[i] * knapsack.items[i][1] for i in range(len(current)))

    # 背包问题特定的邻域操作
    for _ in range(SA_ITERATIONS):
        neighbor = list(current)

        # 根据当前解的状态选择不同的邻域操作
        if current_weight > knapsack.maxCapacity:
            # 超重时，优先移除物品
            ones = [i for i, x in enumerate(neighbor) if x == 1]
            if ones:
                i = random.choice(ones)
                neighbor[i] = 0
        else:
            # 未超重时，尝试添加或交换物品
            if random.random() < 0.7:  # 70%概率尝试添加物品
                zeros = [i for i, x in enumerate(neighbor) if x == 0]
                if zeros:
                    i = random.choice(zeros)
                    # 检查添加后是否超重
                    if current_weight + knapsack.items[i][1] <= knapsack.maxCapacity:
                        neighbor[i] = 1
            else:  # 30%概率交换物品
                ones = [i for i, x in enumerate(neighbor) if x == 1]
                zeros = [i for i, x in enumerate(neighbor) if x == 0]
                if ones and zeros:
                    i = random.choice(ones)
                    j = random.choice(zeros)
                    # 检查交换后是否更优
                    if knapsack.items[j][1] <= knapsack.items[i][1] and knapsack.items[j][2] > knapsack.items[i][2]:
                        neighbor[i], neighbor[j] = neighbor[j], neighbor[i]

        neighbor_fitness = knapsack.getValue(neighbor)

        # 接受准则
        delta = neighbor_fitness - current_fitness
        if delta > 0 or (temperature > MIN_TEMPERATURE and random.random() < exp(delta / temperature)):
            current = neighbor
            current_fitness = neighbor_fitness
            # 更新当前重量（修正变量名）
            current_weight = sum(current[i] * knapsack.items[i][1] for i in range(len(current)))

            # 更新全局最优解
            if current_fitness > best_fitness:
                best_solution = list(current)
                best_fitness = current_fitness

    return creator.Individual(best_solution)


# 改进的混合算法
def improved_hybrid_algorithm():
    # 创建初始种群
    population = toolbox.populationCreator()

    # 设置统计对象
    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("max", np.max)
    stats.register("avg", np.mean)

    # 创建精英记录器
    hof = tools.HallOfFame(HALL_OF_FAME_SIZE)

    # 评估初始种群
    fitnesses = list(map(toolbox.evaluate, population))
    for ind, fit in zip(population, fitnesses):
        ind.fitness.values = fit

    # 初始化日志
    logbook = tools.Logbook()
    logbook.header = ['gen', 'nevals', 'max', 'avg']
    record = stats.compile(population)
    logbook.record(gen=0, nevals=len(population), **record)

    # 初始温度
    temperature = INITIAL_TEMPERATURE

    # 记录全局最优解
    best_individual = tools.selBest(population, 1)[0]

    # 主循环
    for gen in range(1, MAX_GENERATIONS + 1):
        # 选择
        offspring = toolbox.select(population, len(population))
        offspring = list(map(toolbox.clone, offspring))

        # 应用交叉
        for child1, child2 in zip(offspring[::2], offspring[1::2]):
            if random.random() < P_CROSSOVER:
                toolbox.mate(child1, child2)
                del child1.fitness.values, child2.fitness.values

        # 应用变异
        for mutant in offspring:
            if random.random() < P_MUTATION:
                toolbox.mutate(mutant)
                del mutant.fitness.values

        # 评估未评估的个体
        invalid_ind = [ind for ind in offspring if not ind.fitness.valid]
        fitnesses = map(toolbox.evaluate, invalid_ind)
        for ind, fit in zip(invalid_ind, fitnesses):
            ind.fitness.values = fit

        # 更新精英
        hof.update(offspring)

        # 更新全局最优解
        current_best = tools.selBest(offspring, 1)[0]
        if current_best.fitness.values[0] > best_individual.fitness.values[0]:
            best_individual = current_best

        # 对精英应用模拟退火
        elite_copy = toolbox.clone(hof[0])
        elite_after_sa = optimized_sa(elite_copy, temperature)
        elite_after_sa.fitness.values = toolbox.evaluate(elite_after_sa)

        # 如果SA后精英更好，则更新精英记录器（修复HallOfFame更新问题）
        if elite_after_sa.fitness.values[0] > hof[0].fitness.values[0]:
            # 清空当前精英记录器
            hof.clear()
            # 添加新的精英个体
            hof.update([elite_after_sa])

        # 环境选择 - 精英保留
        population[:] = tools.selBest(offspring, len(population) - HALL_OF_FAME_SIZE) + hof[:]

        # 降温
        temperature = max(temperature * COOLING_RATE, MIN_TEMPERATURE)

        # 记录统计数据
        record = stats.compile(population)
        logbook.record(gen=gen, nevals=len(invalid_ind), **record)

        # 打印进度
        if gen % 10 == 0:
            print(f"Generation {gen}: Max = {record['max']}, Avg = {record['avg']}, Temp = {temperature:.2f}")

    return population, logbook, hof, best_individual

# 执行算法
population, logbook, hof, best_individual = improved_hybrid_algorithm()

# 输出结果
print("\nBest Solution Found:")
print(f"Chromosome: {best_individual}")
print(f"Fitness: {best_individual.fitness.values[0]}")
knapsack.printItems(best_individual)

maxFitnessValues, meanFitnessValues = logbook.select("max", "avg")

# 可视化结果
sns.set_style("whitegrid")

# 增加网格线密度和样式
plt.grid(True, linestyle='-', alpha=0.7)  # 主要网格线
plt.minorticks_on()  # 启用次要网格线
plt.grid(True, which='minor', linestyle='--', alpha=0.3)  # 次要网格线

# plt.figure(figsize=(10, 6))
plt.plot(maxFitnessValues, 'r-', label='Max Fitness')
plt.plot(meanFitnessValues, 'g-', label='Avg Fitness')
plt.xlabel('Generation')
plt.ylabel('Fitness')
plt.title('Evolution of Fitness in Improved Hybrid Algorithm')
plt.legend()
plt.grid(True)
plt.show()