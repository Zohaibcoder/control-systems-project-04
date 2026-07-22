# Aircraft Pitch Control System — Modeling, Analysis, and PID Control Using MATLAB and Simulink

**Classical Control Systems | Aircraft Dynamics | Non-Minimum Phase Systems | MATLAB | Simulink | Aerospace Engineering**

This repository contains my fourth independent control systems project — the first to use a real aerospace plant. Project 04 applies every concept from Projects 01-03 to the longitudinal pitch dynamics of a fixed-wing aircraft, revealing fundamental control limitations that do not appear in simpler electromechanical systems.

---

## Overview

Projects 01-03 built the foundation: dynamic modeling, transfer function analysis, and PID controller design. Project 04 is where that foundation meets real aerospace engineering.

The aircraft pitch plant is a third-order system with a right-half-plane (RHP) zero — making it non-minimum phase. This single property changes everything about how the system can be controlled. The gain margin is tight, the plant initially responds in the wrong direction, and the best achievable PID performance is far below what a real autopilot requires. Understanding why — and what to do about it — is the central lesson of this project.

---

## Engineering Problem

A pilot commands the aircraft to pitch up 5 degrees. What actually happens?

```
Pilot Command (δe)
        ↓
Elevator Deflects Up
        ↓
Downward Force at Tail (initial wrong direction — RHP zero effect)
        ↓
Nose Briefly Pitches DOWN (undershoot)
        ↓
Aerodynamic Moment Builds
        ↓
Nose Pitches UP (correct direction)
        ↓
Aircraft Stabilizes at Commanded Pitch
```

This non-minimum phase behavior makes this plant fundamentally harder to control than any system studied in Projects 01-03.

---

## Transfer Function

The linearized aircraft longitudinal pitch transfer function:

```
θ(s)/δe(s) = K(τs + 1) / (s³ + a₂s² + a₁s + a₀)
```

| Parameter | Symbol | Value | Physical Meaning |
|---|---|---|---|
| Gain | K | −1.282 | Control effectiveness |
| Zero time constant | τ | −1.0 | Produces RHP zero at s = +1 |
| Pitch damping | a₂ | 1.935 | Aerodynamic pitch rate damping |
| Speed stability | a₁ | 0.987 | Speed-pitch coupling |
| Static stability | a₀ | 0.179 | Pitch restoring moment |

Numerical transfer function:

```
G(s) = (1.282s − 1.282) / (s³ + 1.935s² + 0.987s + 0.179)
```

---

## Open-Loop Analysis

### Poles and Flight Modes

| Pole | Location | Flight Mode |
|---|---|---|
| p₁ | −1.2679 | Short Period — fast, heavily damped |
| p₂ | −0.3336 + 0.1730j | Phugoid — slow, lightly damped |
| p₃ | −0.3336 − 0.1730j | Phugoid — conjugate |

**Zero:** s = +1 (Right-Half Plane — Non-Minimum Phase)

### Open-Loop Step Response (1° elevator input)

| Parameter | Value |
|---|---|
| Rise Time | 7.56 s |
| Settling Time | 13.93 s |
| Overshoot | 0.23% |
| **Undershoot** | **3.16% (RHP zero signature)** |
| Steady-State Pitch | −7.16° (for +1° elevator) |

---

## Parameter Sensitivity Study

### Effect of Static Stability (a0)

| a0 | Nature | Overshoot | Settling Time | SS Pitch |
|---|---|---|---|---|
| 0.1 | Overdamped (all real poles) | 0% | 32.76 s | −12.82° |
| 0.179 (nominal) | Mixed | 0.23% | 13.93 s | −7.18° |
| 0.5 | Underdamped | 28.71% | 19.96 s | −3.30° |
| 1.0 | Highly underdamped | 68.44% | 35.20 s | −2.16° |

Increasing a0 → more statically stable aircraft → lower steady-state pitch → more oscillation.

### Effect of Pitch Damping (a2) — The Paradox

| a2 | Overshoot | Settling Time |
|---|---|---|
| 0.5 | 0.01% | 23.17 s |
| 1.935 (nominal) | 0.23% | 13.93 s |
| 3.0 | 6.13% | 24.46 s |
| 5.0 | 15.60% | 42.37 s |

Increasing pitch damping paradoxically increased overshoot and settling time — because it pushes one pole far left while pulling the dominant poles closer to the imaginary axis.

### Effect of Dynamic Stability (a1)

| a1 | Overshoot | Settling Time |
|---|---|---|
| 0.3 | 58.56% | 65.88 s |
| 0.987 (nominal) | 0.23% | 13.93 s |
| 2.0 | 0% | 41.72 s |
| 4.0 | 0% | 86.99 s |

Increasing a1 makes the system slower by moving the dominant pole closer to the origin.

---

## Closed-Loop PID Control (Reference: 5 degrees pitch)

### P Controller — Gain Margin Discovery

| Kp | Stable? | SS Pitch | SSE |
|---|---|---|---|
| 0.1 | ✅ Yes | 2.09° | 58% |
| 0.2 | ✅ Yes | 2.90° | 42% |
| 0.3 | ⚠️ Marginal | — | — |
| 0.4 | ⚠️ Edge of stability | — | — |
| 0.5 | ❌ UNSTABLE | — | — |

**Gain margin is between Kp = 0.4 and 0.5.** P control cannot achieve acceptable SSE before hitting the stability boundary.

### PI Controller — SSE Eliminated but Slow

| Ki (Kp=0.1) | Settling Time | SSE | Stable? |
|---|---|---|---|
| 0.01 | 65.31 s | 0% ✅ | Yes |
| 0.03 | 35.04 s | 0% but overshoots | Yes |
| 0.05 | Marginal | — | Marginal |
| 0.07 | N/A | — | ❌ UNSTABLE |

Ki = 0.01 achieves exactly 5 degrees with zero SSE — but 65 seconds settling time is unacceptable for a real autopilot.

### pidtune() Automatic Tuning — Best Achievable PID

| | Kp | Ki | Kd | Rise Time | Settling Time | Overshoot | Undershoot |
|---|---|---|---|---|---|---|---|
| pidtune() | 0.264 | 0.0372 | 0.455 | 1.99 s | 19.49 s | 3.39% | 18.12% |

Even the best automatic PID gains cannot eliminate the 18.12% undershoot — it is the RHP zero signature. No PID controller can overcome this fundamental plant limitation.

---

## Complete Controller Comparison

| Controller | Rise Time | Settling Time | Overshoot | Undershoot | SS Error |
|---|---|---|---|---|---|
| Open Loop | 7.56 s | 13.93 s | 0.23% | 3.16% | Large |
| P (Kp=0.1) | 3.51 s | 20.73 s | 18.12% | 5.46% | 58% |
| P (Kp=0.5) | — | — | — | — | UNSTABLE |
| PI (Kp=0.1, Ki=0.01) | 31.90 s | 65.31 s | 0% | 2.47% | 0% ✅ |
| PID — pidtune() | 1.99 s | 19.49 s | 3.39% | 18.12% | 0% ✅ |

---

## Disturbance Rejection — Wind Gust Test

A 2-degree wind gust injected at t=50s using pidtune() gains:

| Condition | Pitch Before | Peak After Gust | Final Pitch | Recovery |
|---|---|---|---|---|
| Without disturbance | 5.00° | — | 5.00° | N/A |
| With +2° gust at t=50s | 5.00° | ~10.6° | 5.00° | ✅ Complete |

The autopilot fully rejected the disturbance and returned to exactly 5 degrees commanded pitch.

---

## Key Engineering Conclusions

**1.** The Short Period mode (fast pole at −1.2679) and Phugoid mode (slow complex poles at −0.3336±0.1730j) are the two fundamental longitudinal dynamics of any fixed-wing aircraft.

**2.** The RHP zero at s=+1 causes non-minimum phase behavior — the aircraft initially pitches in the wrong direction. This cannot be eliminated by any PID controller.

**3.** The gain margin of this plant is between Kp=0.4 and Kp=0.5. P control reaches the stability boundary before achieving acceptable steady-state error.

**4.** Integral action eliminates steady-state error but the stability margin is so tight that even Ki=0.05 causes instability with Kp=0.1.

**5.** The best achievable PID settling time is 19.5 seconds. A real aircraft autopilot requires 2-5 seconds. **PID is not the right controller for this plant.** State-space methods (Projects 07-09) will achieve 5-second settling times on the same plant.

**6.** Always simulate long enough. Results at 30 seconds showed Kp=0.4 appearing stable. At 100 seconds the same simulation revealed growing instability. Simulation time must be at least 5× the expected settling time near gain margin boundaries.

---

## Why This Matters for Teknofest VLR

The Teknofest Vertical Landing Rocket attitude controller faces similar challenges:
- Tight stability margins due to aerodynamic coupling
- Changing plant dynamics as fuel burns (nonlinear)
- Disturbance rejection from atmospheric turbulence
- RCS thruster bandwidth limitations analogous to gain margin

The gain margin concepts, disturbance rejection methodology, and understanding of dominant poles from this project apply directly to the VLR control design.

---


## Project Roadmap

```
✅ Project 01 — Mass-Spring-Damper Analysis
✅ Project 02 — DC Motor Modeling
✅ Project 03 — PID Speed Control
✅ Project 04 — Aircraft Pitch Control ← YOU ARE HERE

→ Project 05 — Root Locus Design
→ Project 06 — Bode & Nyquist Analysis
→ Project 07 — State-Space Modeling
→ Project 08 — Pole Placement
→ Project 09 — LQR Optimal Control
→ Project 10 — Kalman Filter
→ Project 11 — UAV Attitude Control
→ Project 12 — Rocket Attitude Control
→ Project 13 — Satellite Attitude Control
→ Project 14 — Missile Guidance
→ Project 15 — Complete Flight Control System
```

---

## Software Used

- MATLAB R2024b
- Simulink
- Control System Toolbox

---

## Author

**Zohaib Imtiaz**
Aerospace Engineering Student | Teknofest VLR Team — Flight Control

---

## License

This project is released under the MIT License.
