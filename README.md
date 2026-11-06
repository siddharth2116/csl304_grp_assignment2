# AI Group Assignment 2

## Group Members

| # | Name | Roll Number |
|---|------|-------------|
| 1 | Siddharth | B24EC017 |
| 2 | Parveen | B24EC013 |
| 3 | Rakesh | B24EC023 |
| 4 | Jnaneswar | B24ME027 |

## Folder Structure

```
AI_Group_Assignment_2/
├── README.md
├── Problem1/                              Smart Home Energy (Bayesian Networks)
│   ├── Problem1_Bayesian_Network.ipynb    source code, Parts A–E
│   ├── Problem1_Report.pdf                answers and analysis
│   └── outputs/                           screenshots, plots, generated datasets, comparison tables
├── Problem2/                              Mars Rover Planning (PDDL)
│   ├── Domain.pddl
│   ├── Problem.pddl
│   ├── Problem_extended.pddl
│   ├── Problem2_Mars_Rover_PDDL.ipynb     runs the planner, validates and simulates the plans
│   ├── Problem2_Report.pdf                analysis report
│   └── planner_output/                    plans, planner logs, summary table, screenshots
└── Problem3/                              Royal Archive (Resolution Refutation)
    ├── royal_archive_access.pl            Prolog program, Steps 1–8
    ├── Problem3_Report.pdf                steps and proof explained
    └── screenshots/                       final proof output (empty clause)
```

## How to Run

### Problem 1
Needs Python 3 and these packages:
```
pip install pgmpy numpy pandas networkx matplotlib jupyter
```
Open `Problem1_Bayesian_Network.ipynb` and run all cells. Results are saved to `outputs/`. The random seed is 42; the three datasets use seeds 42, 43 and 44.

### Problem 2
Needs the Fast Downward planner (https://github.com/aibasel/downward) and the VAL validator (https://github.com/KCL-Planning/VAL). Before starting Jupyter, set the paths:
```
export FD_PATH=/path/to/downward/fast-downward.py
export VAL_PATH=/path/to/VAL/build/bin/Validate
```
Then open `Problem2_Mars_Rover_PDDL.ipynb` and run all cells. You can also run the planner directly:
```
fast-downward.py Domain.pddl Problem.pddl --search "eager_greedy([ff()])"   # satisficing
fast-downward.py Domain.pddl Problem.pddl --search "astar(ipdb())"          # optimal
```

### Problem 3
Needs SWI-Prolog.
```
swipl royal_archive_access.pl
```
The program prints every transformation step, then each resolvent, ending with the empty clause [].

## Summary of Results

**Problem 1:** P(EnergyConsumption = High) = 0.5806, both from code and by hand. Of the three independence statements, Weather ⊥ DayType and Weather ⊥ ApplianceLoad | Occupancy hold, while Weather ⊥ DayType | EnergyConsumption does not. On the 500-sample dataset the Bayesian (BDeu) estimator beats MLE, with mean error 0.0220 vs 0.0254. With more data the two estimators give almost the same results.

**Problem 2:**

| Scenario | Satisficing (GBFS + FF) | Optimal (A* + iPDB) |
|---|---|---|
| Base | 30 actions | 25 actions |
| Extended | 51 actions | 40 actions |

VAL confirms all four plans are valid.

**Problem 3:** five resolution steps derive the empty clause from ¬trusted(mira), which proves that Mira is trusted.
