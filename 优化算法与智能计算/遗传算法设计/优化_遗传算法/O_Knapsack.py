# 背包问题的传统遗传算法实现
class KnapsackProblem:
    """背包问题类，用于定义问题实例和评估解决方案"""

    # 初始化实例变量
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
randomSolution = [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0]
knapsack.printItems(randomSolution)


# 遗传算法部分
from deap import base
from deap import creator
from deap import tools
from deap import algorithms
import random
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# 遗传算法参数设置
POPULATION_SIZE = 30        # 种群大小
P_CROSSOVER = 0.9           # 交叉概率
P_MUTATION = 0.1            # 变异概率
MAX_GENERATIONS = 75        # 最大迭代次数
HALL_OF_FAME_SIZE = 1       # 精英个体数量

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


# 适应度计算函数
def knapsackValue(individual):
    return knapsack.getValue(individual),  # 返回一个元组，符合DEAP库的要求


# 注册适应度评估函数
toolbox.register("evaluate", knapsackValue)

# 注册遗传算法操作
# 锦标赛选择，每次从3个个体中选择最优的
toolbox.register("select", tools.selTournament, tournsize=3)
# 两点交叉操作
toolbox.register("mate", tools.cxTwoPoint)
# 位翻转变异，变异概率与染色体长度相关
toolbox.register("mutate", tools.mutFlipBit, indpb=1.0 / len(knapsack.items))


# 遗传算法主流程
# 创建初始种群（第0代）
population = toolbox.populationCreator()

# 设置统计对象，用于记录每代的适应度信息
stats = tools.Statistics(lambda ind: ind.fitness.values)
stats.register("max", np.max)  # 记录每代的最大适应度
stats.register("avg", np.mean)  # 记录每代的平均适应度

# 创建精英个体记录器
hof = tools.HallOfFame(HALL_OF_FAME_SIZE)

# 执行遗传算法
population, logbook = algorithms.eaSimple(population, toolbox,
                                          cxpb=P_CROSSOVER, mutpb=P_MUTATION, ngen=MAX_GENERATIONS,
                                          stats=stats, halloffame=hof, verbose=True)

# 输出最优解
best = hof.items[0]
print(f"Best ever individual: {best}")
print(f"Best ever fitness: {best.fitness.values[0]}")  # best.fitness.values是一个只有一个元素的元组

# 打印最优解包含的物品
knapsack.printItems(best)

# 提取统计数据并可视化
maxFitnessValues, meanFitnessValues = logbook.select("max", "avg")

# # 设置图表样式并绘制适应度曲线
sns.set_style("whitegrid")

# 绘制适应度曲线
plt.plot(maxFitnessValues, color='red', label='Max Fitness', linewidth=2)
plt.plot(meanFitnessValues, color='green', label='Average Fitness', linewidth=2)

# 设置图表标题和轴标签
plt.title('Fitness Evolution over Generations', fontsize=14)
plt.xlabel('Generation', fontsize=12)
plt.ylabel('Fitness Value', fontsize=12)

# 设置坐标轴范围
plt.xlim(0, MAX_GENERATIONS)
plt.ylim(min(meanFitnessValues) * 0.9, max(maxFitnessValues) * 1.05)

# 增加网格线密度和样式
plt.grid(True, linestyle='-', alpha=0.7)  # 主要网格线
plt.minorticks_on()  # 启用次要网格线
plt.grid(True, which='minor', linestyle='--', alpha=0.3)  # 次要网格线

# 添加图例和优化布局
plt.legend(fontsize=12)
plt.tight_layout()  # 优化布局，避免标签重叠

# 显示图表
plt.show()