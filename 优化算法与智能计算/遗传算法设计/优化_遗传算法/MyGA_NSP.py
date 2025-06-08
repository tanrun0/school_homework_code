# 混合模拟退火遗传算法求解 NSP
import random
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from deap import base, creator, tools, algorithms
from math import exp

class NurseScheduleProblem:
    """
    护士排班问题类
    """

    def __init__(self, hardConstraintPenalty):
        # 硬约束惩罚系数
        self.hardConstraintPenalty = hardConstraintPenalty
        # 8名护士列表
        self.nurses = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
        # 护士的班次偏好 - 早班、午班、晚班
        self.shiftPreference = [[1, 0, 0], [1, 1, 0], [0, 0, 1], [0, 1, 0], [0, 0, 1], [1, 1, 1], [0, 1, 1], [1, 1, 1]]
        # 医院规则：每个班次最少需要的护士数
        self.shiftMin = [2, 2, 1]
        # 医院规则：每个班次最多允许的护士数
        self.shiftMax = [3, 4, 1]
        # 医院规则：每个护士每周最多工作班次数
        self.maxShiftsPerweek = 5
        # 排班周数
        self.weeks = 1
        # 每天班次数
        self.shiftPerDay = 3
        # 每周班次数
        self.shiftsPerWeek = 7 * self.shiftPerDay
        # 排班总长度（基因数）
        self.scheduleLength = len(self.nurses) * self.shiftsPerWeek * self.weeks

    def getCost(self, schedule):
        """
        计算给定排班方案的总成本（违反约束的程度）
        """
        # 将整个排班转换为按护士划分的子排班字典
        numOfGenesPerNurse = self.scheduleLength // len(self.nurses)
        nurseShiftDict = {}  # 空字典
        index = 0
        # 填充字典
        for nurse in self.nurses:
            nurseShiftDict[nurse] = schedule[index: index + numOfGenesPerNurse]
            index += numOfGenesPerNurse

        # 计算各种违反约束的情况
        # 1. 连续工作违反
        consecutiveViolations = 0
        # 遍历每个护士的班次
        for shiftsPerNurse in nurseShiftDict.values():
            # 查找两个连续的1（表示连续工作）
            for shift1, shift2 in zip(shiftsPerNurse, shiftsPerNurse[1:]):
                if shift1 == 1 and shift2 == 1:
                    consecutiveViolations += 1

        # 2. 每周班次数违反
        shiftsPerWeekViolations = 0
        # 获取每个护士的班次（包含多周排班）
        for shiftsPerNurse in nurseShiftDict.values():
            # 遍历每周排班
            for i in range(self.weeks):
                weelyShifts = shiftsPerNurse[i * self.shiftsPerWeek: (i + 1) * self.shiftsPerWeek]
                if sum(weelyShifts) > self.maxShiftsPerweek:
                    shiftsPerWeekViolations += (sum(weelyShifts) - self.maxShiftsPerweek)

        # 3. 班次护士数违反
        nursesPerShiftViolations = 0
        # 创建包含每个班次护士数的列表
        numOfNursesPerShift = [sum(nursesPerShift) for nursesPerShift in zip(*nurseShiftDict.values())]
        # 计算违反情况
        for shiftIndex, numOfNurses in enumerate(numOfNursesPerShift):
            shiftType = shiftIndex % self.shiftPerDay  # 0:早班, 1:午班, 2:晚班
            if numOfNurses > self.shiftMax[shiftType]:
                nursesPerShiftViolations += (numOfNurses - self.shiftMax[shiftType])
            elif numOfNurses < self.shiftMin[shiftType]:
                nursesPerShiftViolations += (self.shiftMin[shiftType] - numOfNurses)

        # 4. 偏好违反
        preferenceViolations = 0
        # 8名护士的偏好
        for nurseIndex, shiftPreference in enumerate(self.shiftPreference):
            # 将每日偏好复制为每周偏好
            nursePreference = shiftPreference * (self.shiftsPerWeek // self.shiftPerDay)
            # 护士的排班
            sheduleOfTheNurse = nurseShiftDict[self.nurses[nurseIndex]]
            # 比较护士偏好和实际排班
            for preference, shedule in zip(nursePreference, sheduleOfTheNurse):
                if preference == 0 and shedule == 1:
                    preferenceViolations += 1

        # 硬约束违反总数（乘以惩罚系数）
        hardContstraintViolations = (
                                            consecutiveViolations + shiftsPerWeekViolations + nursesPerShiftViolations) * self.hardConstraintPenalty
        # 软约束违反总数（不加惩罚）
        softConstraintViolations = preferenceViolations
        # 总成本
        cost = hardContstraintViolations + softConstraintViolations
        return cost

    def printInfo(self, schedule):
        """
        打印给定排班方案的信息
        """
        # 将整个排班转换为按护士划分的子排班字典
        numOfGenesPerNurse = self.scheduleLength // len(self.nurses)
        nurseShiftDict = {}  # 空字典
        index = 0
        # 填充字典
        for nurse in self.nurses:
            nurseShiftDict[nurse] = schedule[index: index + numOfGenesPerNurse]
            index += numOfGenesPerNurse

        # 打印护士排班字典
        print("每位护士的排班: ")
        for nurse, nurseShedule in nurseShiftDict.items():
            print(nurse, ":", nurseShedule)

        # 计算各种违反约束的情况
        # 1. 连续工作违反
        consecutiveViolations = 0
        for shiftsPerNurse in nurseShiftDict.values():
            for shift1, shift2 in zip(shiftsPerNurse, shiftsPerNurse[1:]):
                if shift1 == 1 and shift2 == 1:
                    consecutiveViolations += 1

        # 打印连续工作违反
        print("连续工作违反次数: ", consecutiveViolations)

        # 2. 每周班次数违反
        shiftsPerWeekViolations = 0
        for shiftsPerNurse in nurseShiftDict.values():
            for i in range(self.weeks):
                weelyShifts = shiftsPerNurse[i * self.shiftsPerWeek: (i + 1) * self.shiftsPerWeek]
                if sum(weelyShifts) > self.maxShiftsPerweek:
                    shiftsPerWeekViolations += (sum(weelyShifts) - self.maxShiftsPerweek)

        # 打印每周班次数违反
        print("每周班次数违反: ", shiftsPerWeekViolations)

        # 3. 班次护士数违反
        nursesPerShiftViolations = 0
        numOfNursesPerShift = [sum(nursesPerShift) for nursesPerShift in zip(*nurseShiftDict.values())]
        for shiftIndex, numOfNurses in enumerate(numOfNursesPerShift):
            shiftType = shiftIndex % self.shiftPerDay
            if numOfNurses > self.shiftMax[shiftType]:
                nursesPerShiftViolations += (numOfNurses - self.shiftMax[shiftType])
            elif numOfNurses < self.shiftMin[shiftType]:
                nursesPerShiftViolations += (self.shiftMin[shiftType] - numOfNurses)

        # 打印班次护士数违反
        print("班次护士数违反: ", nursesPerShiftViolations)

        # 4. 偏好违反
        preferenceViolations = 0
        for nurseIndex, shiftPreference in enumerate(self.shiftPreference):
            nursePreference = shiftPreference * (self.shiftsPerWeek // self.shiftPerDay)
            sheduleOfTheNurse = nurseShiftDict[self.nurses[nurseIndex]]
            for preference, shedule in zip(nursePreference, sheduleOfTheNurse):
                if preference == 0 and shedule == 1:
                    preferenceViolations += 1

        # 打印偏好违反
        print("偏好违反: ", preferenceViolations)

        # 硬约束违反总数（乘以惩罚系数）
        hardContstraintViolations = (
                                            consecutiveViolations + shiftsPerWeekViolations + nursesPerShiftViolations) * self.hardConstraintPenalty
        # 软约束违反总数（不加惩罚）
        softConstraintViolations = preferenceViolations
        # 总成本
        cost = hardContstraintViolations + softConstraintViolations
        print("总成本: ", cost)


# 遗传算法参数
POPULATION_SIZE = 200
P_CROSSOVER = 0.9
P_MUTATION = 0.1
MAX_GENERATIONS = 100
HALL_OF_FAME_SIZE = 5

# 模拟退火参数
INITIAL_TEMPERATURE = 200
MIN_TEMPERATURE = 1
COOLING_RATE = 0.95
SA_ITERATIONS = 10  # 每个温度下的迭代次数

# 设置随机种子
RANDOM_SEED = 42
random.seed(RANDOM_SEED)

# 创建护士排班问题实例
nsp = NurseScheduleProblem(hardConstraintPenalty=10)

# 创建遗传算法工具箱
toolbox = base.Toolbox()

# 定义单目标最小化适应度策略
creator.create("FitnessMin", base.Fitness, weights=(-1.0,))

# 创建个体类
creator.create("Individual", list, fitness=creator.FitnessMin)

# 注册遗传算法操作
toolbox.register("zeroOrOne", random.randint, 0, 1)
toolbox.register("individualCreator", tools.initRepeat, creator.Individual, toolbox.zeroOrOne, nsp.scheduleLength)
toolbox.register("populationCreator", tools.initRepeat, list, toolbox.individualCreator, POPULATION_SIZE)


# 适应度函数
def evaluate(individual):
    return nsp.getCost(individual),


toolbox.register("evaluate", evaluate)
toolbox.register("select", tools.selTournament, tournsize=3)
toolbox.register("mate", tools.cxTwoPoint)
toolbox.register("mutate", tools.mutFlipBit, indpb=1.0 / nsp.scheduleLength)


# 模拟退火局部搜索函数
def simulated_annealing(individual, temperature):
    current = list(individual)
    current_cost = evaluate(current)[0]

    for _ in range(SA_ITERATIONS):
        # 生成邻域解
        neighbor = list(current)

        # 随机选择变异方式
        if random.random() < 0.5:
            # 随机翻转一位
            pos = random.randint(0, len(neighbor) - 1)
            neighbor[pos] = 1 - neighbor[pos]
        else:
            # 交换两位
            i, j = random.sample(range(len(neighbor)), 2)
            neighbor[i], neighbor[j] = neighbor[j], neighbor[i]

        neighbor_cost = evaluate(neighbor)[0]

        # 计算成本差
        delta = neighbor_cost - current_cost

        # 接受准则
        if delta < 0 or (temperature > MIN_TEMPERATURE and random.random() < exp(-delta / temperature)):
            current = neighbor
            current_cost = neighbor_cost

    return creator.Individual(current)


# 混合遗传算法+模拟退火的主函数
def hybrid_ga_sa():
    # 初始化种群
    population = toolbox.populationCreator()

    # 设置统计
    stats = tools.Statistics(lambda ind: ind.fitness.values[0])
    stats.register("min", np.min)
    stats.register("avg", np.mean)
    stats.register("max", np.max)


    hof = tools.HallOfFame(HALL_OF_FAME_SIZE)

    # 评估初始种群
    fitnesses = list(map(toolbox.evaluate, population))
    for ind, fit in zip(population, fitnesses):
        ind.fitness.values = fit

    # 记录初始状态
    logbook = tools.Logbook()
    logbook.header = ["gen", "nevals", "min", "avg", "max"]
    record = stats.compile(population)
    logbook.record(gen=0, nevals=len(population), **record)

    # 初始化温度
    temperature = INITIAL_TEMPERATURE

    for gen in range(1, MAX_GENERATIONS + 1):
        # 选择下一代
        offspring = toolbox.select(population, len(population))
        offspring = list(map(toolbox.clone, offspring))

        # 应用交叉和变异
        for child1, child2 in zip(offspring[::2], offspring[1::2]):
            if random.random() < P_CROSSOVER:
                toolbox.mate(child1, child2)
                del child1.fitness.values
                del child2.fitness.values

        for mutant in offspring:
            if random.random() < P_MUTATION:
                toolbox.mutate(mutant)
                del mutant.fitness.values

        # 对部分优秀个体应用模拟退火 (前20%)
        offspring.sort(key=lambda ind: ind.fitness.values[0] if ind.fitness.valid else float('inf'))
        for i in range(int(len(offspring) * 0.2)):
            if not offspring[i].fitness.valid:
                offspring[i].fitness.values = toolbox.evaluate(offspring[i])
            offspring[i] = simulated_annealing(offspring[i], temperature)

        # 评估所有无效个体
        invalid_ind = [ind for ind in offspring if not ind.fitness.valid]
        fitnesses = map(toolbox.evaluate, invalid_ind)
        for ind, fit in zip(invalid_ind, fitnesses):
            ind.fitness.values = fit


        hof.update(offspring)

        # 环境选择 - 精英保留
        population[:] = tools.selBest(offspring, len(population) - HALL_OF_FAME_SIZE) + hof[:HALL_OF_FAME_SIZE]

        # 降温
        temperature = max(temperature * COOLING_RATE, MIN_TEMPERATURE)

        # 记录统计
        record = stats.compile(population)
        logbook.record(gen=gen, nevals=len(invalid_ind), **record)

        # 打印进度
        if gen % 10 == 0:
            print(
                f"Generation {gen}: Min cost = {record['min']:.2f}, Avg cost = {record['avg']:.2f}, Temp = {temperature:.2f}")

    return population, logbook, hof


# 运行混合算法
population, logbook, hof = hybrid_ga_sa()

# 输出结果
best = hof[0]
print("\nBest Solution Found:")
print(f"Cost: {best.fitness.values[0]}")
nsp.printInfo(best)

# 可视化结果
# plt.figure(figsize=(10, 6))
sns.set_style("whitegrid")
min_cost = logbook.select("min")
avg_cost = logbook.select("avg")

plt.plot(min_cost, 'r-', label="Minimum Cost")
plt.plot(avg_cost, 'g-', label="Average Cost")
plt.xlabel("Generation")
plt.ylabel("Cost")
plt.title("Nurse Scheduling Problem - GA+SA Hybrid Algorithm Performance")
plt.legend()
plt.show()
