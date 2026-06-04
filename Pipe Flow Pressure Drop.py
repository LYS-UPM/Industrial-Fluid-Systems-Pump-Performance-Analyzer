# -*- coding: utf-8 -*-
import math
from scipy.optimize import fsolve

def calculate_pipe_flow():
    """
    工业级管道压降与水泵功率计算器
    (Industrial Pipe Flow Pressure Drop & Pump Power Calculator)
    """
    # 1. 物理参数 (Physical Parameters)
    rho = 998.0         # 水的密度 (kg/m^3)
    mu = 1.002e-3       # 水的动力粘度 (Pa.s)
    
    # 2. 管道参数 (Piping System Input)
    L = 500.0           # 管道总长度 (m)
    D = 0.15            # 管道内径 (m) - 150mm
    epsilon = 0.045e-3  # 商业钢管的绝对粗糙度 (m)
    Q = 0.02            # 体积流量 (m^3/s) - 比如 20 L/s
    
    # 3. 局部阻力系数 (Minor Loss Coefficients - K factors)
    # 假设系统有: 4个90度弯头, 1个全开闸阀, 1个半开截止阀
    K_elbow = 4 * 0.9
    K_gate_valve = 1 * 0.2
    K_globe_valve = 1 * 4.5
    K_total = K_elbow + K_gate_valve + K_globe_valve
    
    # ==========================================
    # 核心流体力学计算 (Core Calculations)
    # ==========================================
    
    # 流速 (Velocity)
    A = math.pi * (D**2) / 4.0
    v = Q / A
    
    # 雷诺数 (Reynolds Number)
    Re = (rho * v * D) / mu
    
    # 求解摩擦系数 f (Solving for friction factor)
    if Re < 2300:
        # 层流 (Laminar flow)
        f = 64.0 / Re
        flow_type = "Laminar (层流)"
    else:
        # 湍流 (Turbulent flow) - 使用 Colebrook 方程求解隐式函数
        flow_type = "Turbulent (湍流)"
        
        # 定义 Colebrook 函数，要求该函数返回 0
        def colebrook(f_guess):
            # 【关键修复】: 提取数组中的第一个数字，把 Array 变成单纯的 Float
            f_val = f_guess[0] 
            
            # 使用提取出来的 f_val 进行计算
            term1 = 1.0 / math.sqrt(f_val)
            term2 = -2.0 * math.log10((epsilon / D) / 3.7 + 2.51 / (Re * math.sqrt(f_val)))
            return term1 - term2
            
        # 初始猜测值 (使用列表形式传递给 fsolve)
        f_initial_guess = [0.02] 
        
        # 使用 fsolve 进行数值迭代求解
        f = fsolve(colebrook, f_initial_guess)[0]

    # ==========================================
    # 压降与功率计算 (Pressure Drop & Power)
    # ==========================================
    
    # 沿程压降 (Major Pressure Drop) - Darcy-Weisbach
    delta_P_major = f * (L / D) * (rho * v**2 / 2.0)
    
    # 局部压降 (Minor Pressure Drop)
    delta_P_minor = K_total * (rho * v**2 / 2.0)
    
    # 总压降
    delta_P_total = delta_P_major + delta_P_minor
    
    # 所需水泵水力功率 (Hydraulic Pump Power in kW)
    pump_power_kW = (delta_P_total * Q) / 1000.0
    
    # ==========================================
    # 打印工程报告
    # ==========================================
    print("===================================================")
    print("      PIPE FLOW & PRESSURE DROP REPORT             ")
    print("===================================================")
    print(f" Flow Velocity     : {v:.2f} m/s")
    print(f" Reynolds Number   : {Re:.0f} ({flow_type})")
    print(f" Friction Factor(f): {f:.5f}")
    print("---------------------------------------------------")
    print(f" Major Press Drop  : {delta_P_major/1000:.2f} kPa")
    print(f" Minor Press Drop  : {delta_P_minor/1000:.2f} kPa")
    print(f" Total Press Drop  : {delta_P_total/1000:.2f} kPa")
    print("---------------------------------------------------")
    print(f" Min. Pump Power   : {pump_power_kW:.2f} kW")
    print("===================================================")

# 运行计算器
print("Running Piping System Solver...\n")
calculate_pipe_flow()
