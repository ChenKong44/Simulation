import numpy as np
import sympy as sp
import matplotlib.pyplot as plt
from typing import List, Tuple


def cal_distance(target: List[int], index: int) -> List[int]:
    """Placeholder for node switching logic.

    This function should update the ``target`` list based on ``index`` to
    select a new target node.  The current implementation simply returns the
    original target list unchanged.
    """
    return target


def soilmodel(moisture: float, frequency: float) -> Tuple[float, float]:
    ep_0 = 8.854e-11
    mu_0 = 0.5
    mu_r = 1

    freq = frequency * 1e6
    ro_b = 1.07
    ro_s = 2.66
    m_v = moisture
    ep_win = 4.9
    ep_w0 = 80.1

    S = 51.51 / 100
    C = 13.43 / 100

    tau_w = 0.58 * (1e-9) / (2 * np.pi)
    ep_s = (1.01 + 0.44 * ro_s) ** 2 - 0.062
    mue_eff = -1.645 + 1.939 * ro_b - 0.02313 * S + 0.01594 * C

    ep_fwpr = ep_win + (ep_w0 - ep_win) / (1 + (2 * np.pi * freq * tau_w) ** 2)
    ep_fwprr = (2 * np.pi * freq * tau_w * (ep_w0 - ep_win)) / (1 + (2 * np.pi * freq * tau_w) ** 2) + (
        mue_eff) / (2 * np.pi * ep_0 * freq)

    b_pr = (127.48 - 0.519 * S - 0.152 * C) / 100
    b_prr = (1.33797 - 0.603 * S - 0.166 * C) / 100

    ep_pr = (1 + (ro_b / ro_s) * (ep_s ** 0.65 - 1) + (m_v ** b_pr) * (ep_fwpr ** 0.65) - m_v) ** (1 / 0.65)
    ep_prr = ((m_v ** b_prr) * (ep_fwprr ** 0.65)) ** (1 / 0.65)

    alpha = 2 * np.pi * freq * np.sqrt(((mu_0 * mu_r * ep_pr * ep_0) * (np.sqrt(1 + (ep_prr / ep_pr) ** 2) - 1)) / 2)
    beta = 2 * np.pi * freq * np.sqrt(((mu_0 * mu_r * ep_pr * ep_0) * (np.sqrt(1 + (ep_prr / ep_pr) ** 2) + 1)) / 2)

    return float(alpha), float(beta)


def pathloss(underground, aboveground, moisture: float, frequency: float):
    alpha, beta = soilmodel(moisture, frequency)
    d_ug = underground
    d_ag = aboveground
    a = sp.Float(alpha)
    b = sp.Float(beta)
    freq = frequency

    L_ug = 6.4 + 20 * sp.log(d_ug * 1e-3, 10) + 20 * sp.log(b, 10) + 8.69 * a * d_ug * 1e-3
    L_ab = 32.45 + 20 * sp.log(d_ag, 10) + 20 * sp.log(freq, 10)

    return L_ug, L_ab


def transmissionpower(basedistance, underground, aboveground, mean_CMS_distance, moisture, frequency):
    L_ug, L_ab = pathloss(underground, aboveground, moisture, frequency)
    L_path_cm = L_ab + L_ug

    L_ug, L_ab = pathloss(mean_CMS_distance * 0.158, mean_CMS_distance * 0.9, moisture, frequency)
    L_path_cm_cm = L_ug

    L_ug, L_ab = pathloss(basedistance * 0.03, basedistance * 0.97, moisture, frequency)
    L_path_b = L_ab + L_ug

    antennagain = 2.15
    cableloss = 10
    Noisefactor = 6

    sf = 7
    bw = 125 * 1e3
    cr = 4 / 5
    snr = -2.5 * (sf - 6) - 5

    bitrate = (bw / (2 ** sf)) * (4 / (4 + cr))
    base = 10 * sp.log(bw, 10) + Noisefactor + snr - 174 - antennagain + cableloss
    Energy_transit_b = base + L_path_b
    Energy_transit_cm = base + L_path_cm
    Energy_transit_cm_cm = base + L_path_cm_cm

    return bitrate, Energy_transit_b, Energy_transit_cm, Energy_transit_cm_cm


def some_function(index: int, target: List[int], iteration: int, z: np.ndarray,
                  lamda: np.ndarray, theta: np.ndarray, L_result: np.ndarray,
                  H_result: np.ndarray):
    step_size = 0.08
    delta = 1e-1

    idx = index - 1
    if target[idx] == 0:
        return z, lamda, target, theta, L_result, H_result

    max_clustersize = 50
    interference = 1
    density1 = 4.5
    coverage = 4.4

    x = sp.symbols('x')
    intraclustermembers = sp.sqrt(20 / 4 / density1)
    underground_cluster = sp.sqrt(x / 4 / density1) * 0.05
    aboveground_cluster = sp.sqrt(x / 4 / density1) * 0.95
    basedistance = sp.sqrt(x / 4 / density1) + sp.sqrt(z[target[idx] - 1] / 4 / density1)

    bitrate, Energy_transit_b, Energy_transit_cm, Energy_transit_cm_cm = transmissionpower(
        basedistance, underground_cluster, aboveground_cluster, intraclustermembers, theta[idx], 868)

    Energy_transfer_ch = (10 ** (Energy_transit_b / 10) * 1e-3) * 1e-7
    Energy_transfer_cm = (10 ** (Energy_transit_cm / 10) * 1e-3) * 1e-7
    Energy_transfer_intracms = (10 ** (Energy_transit_cm_cm / 10) * 1e-3) * 1e-7
    Energy_receive = 50 * 1e-9

    brmax = bitrate
    ctrPacketLength = 32 * 8
    packetLength = 32 * 8

    if abs(theta[idx] - theta[target[idx] - 1]) < 0.003:
        print('change node')
        target = cal_distance(target, index)
        if target[idx] == 0:
            return z, lamda, target, theta, L_result, H_result

        br = (x / (1 + interference * (x - 1))) * (125 * 1e3 / (2 ** 7)) * (4 / (4 + 4 / 5))
        L_expect = (
            (x - 1) * (Energy_receive + Energy_transfer_cm) * packetLength / brmax
            + (max_clustersize - x) * (Energy_transfer_intracms) * packetLength / brmax
            + ctrPacketLength * (Energy_transfer_ch + Energy_receive) / brmax
        )
        L_expectdiff = sp.diff(L_expect, x)
        L_gradient1 = float(L_expectdiff.subs(x, z[idx]))

        a, b = sp.symbols('a b')
        h_constraint = 3 / 2 * (sp.sqrt(a / 4 / density1) + sp.sqrt(b / 4 / density1)) - coverage
        h_constraintdiff = sp.Abs(sp.diff(h_constraint, a))
        h_gradient = float(h_constraintdiff.subs({a: z[idx], b: z[target[idx] - 1]}))
        if h_gradient == 0:
            h_gradient = 0.0001

        laplase = L_gradient1 + (lamda[idx, target[idx] - 1] + lamda[target[idx] - 1, idx]) * h_gradient
        z_new = z[idx] - step_size * laplase
        z_new = min(max(z_new, 0), max_clustersize)
    else:
        z_new = float(z[idx])

    z_new = 1 / iteration * z[idx] + (iteration - 1) / iteration * z_new

    L_expect = (
        (x - 1) * (Energy_receive + Energy_transfer_cm) * packetLength / brmax
        + (max_clustersize - x) * (Energy_transfer_intracms) * packetLength / brmax
        + ctrPacketLength * (Energy_transfer_ch + Energy_receive) / brmax
    )
    L_result[idx] = float(L_expect.subs(x, z[idx]))
    L_expectdiff = sp.diff(L_expect, x)
    L_gradient1 = float(L_expectdiff.subs(x, z_new))

    a, b = sp.symbols('a b')
    h_constraint = 3 / 2 * (sp.sqrt(a / 4 / density1) + sp.sqrt(b / 4 / density1)) - coverage
    h_result = float(h_constraint.subs({a: z_new, b: z[target[idx] - 1]}))
    H_result[idx] = float(h_constraint.subs({a: z[idx], b: z[target[idx] - 1]}))
    h_constraintdiff = sp.diff(h_constraint, a)
    h_gradient = float(h_constraintdiff.subs({a: z_new, b: z[target[idx] - 1]}))
    if h_gradient == 0:
        h_gradient = 0.0001

    laplase = L_gradient1 + (lamda[idx, target[idx] - 1] + lamda[target[idx] - 1, idx]) * h_gradient
    z[idx] = z_new - step_size * laplase
    z[idx] = min(max(z[idx], 1), max_clustersize)

    lamda[idx, target[idx] - 1] = max((1 - step_size * delta) * lamda[idx, target[idx] - 1] + step_size * h_result, 0)

    return z, lamda, target, theta, L_result, H_result


def saddle():
    z = np.array([20.0, 20.0, 20.0, 20.0])
    z_spare, z_spare2, z_spare3, z_spare4 = [], [], [], []
    L_spare, L_spare2, H_spare = [], [], []

    xmin_CH = [0.05, 0.25, 0.40, 0.15]
    xmax_CH = [0.15, 0.35, 0.55, 0.30]
    n = 20
    theta = np.zeros(4)
    for i in range(4):
        x = xmin_CH[i] + np.random.rand(n) * (xmax_CH[i] - xmin_CH[i])
        theta[i] = np.random.choice(x)

    lamda = np.zeros((4, 4))
    L_result = np.zeros(4)
    H_result = np.zeros(4)
    iteration = 1000
    target = [2, 1, 3, 4]

    for t in range(1, iteration + 1):
        print(f'iteration #: {t}')
        z, lamda, target, theta, L_result, H_result = some_function(1, target, t, z, lamda, theta, L_result, H_result)
        z, lamda, target, theta, L_result, H_result = some_function(2, target, t, z, lamda, theta, L_result, H_result)
        z, lamda, target, theta, L_result, H_result = some_function(3, target, t, z, lamda, theta, L_result, H_result)
        z, lamda, target, theta, L_result, H_result = some_function(4, target, t, z, lamda, theta, L_result, H_result)
        print(f'z: {int(z[0])} {int(round(z[1]))} {int(round(z[2]))} {int(round(z[3]))}')

        z_spare.append(z[0])
        z_spare2.append(z[1])
        z_spare3.append(z[2])
        z_spare4.append(z[3])

        L_spare.append(int(round(L_result[1])))
        H_spare.append(H_result[1])
        L_spare2.append(int(round(L_result[1])))

    x_vals = np.arange(1, iteration + 1)

    plt.subplot(2, 1, 1)
    plt.plot(x_vals, z_spare2, 'b-')
    plt.legend(['ClusterHead# 1'])
    plt.xlabel('Number of Iteration', fontweight='bold', fontsize=11, fontname='Cambria')
    plt.ylabel('Cluster size', fontweight='bold', fontsize=11, fontname='Cambria')
    plt.title('Function1 vs. Iteration#', fontweight='bold', fontsize=12, fontname='Cambria')

    plt.subplot(2, 1, 2)
    plt.plot(x_vals, z_spare3, 'b-', x_vals, H_spare, 'r-')
    plt.legend(['Objective funcion', 'Constraint Violation'])
    plt.xlabel('Number of Iteration', fontweight='bold', fontsize=11, fontname='Cambria')
    plt.ylabel('Objective function & Constraint violation', fontweight='bold', fontsize=11, fontname='Cambria')
    plt.title('Objective function & Constraint violation vs. Iteration#', fontweight='bold', fontsize=12, fontname='Cambria')

    plt.show()


if __name__ == '__main__':
    saddle()
