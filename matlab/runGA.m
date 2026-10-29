% runGA.m - Genetic Algorithm for Thermistor Circuit Optimization

% Clear workspace and command window
clear; clc;

% Load Standard Component Values
sourceDir = fileparts(mfilename('fullpath'));
addpath(sourceDir);
load(fullfile(sourceDir, '..', 'config', 'StandardComponentValues.mat'), 'Res', 'ThVal', 'ThBeta');

% Desired Temperature and Voltage Data
Tdata = -40:5:85;
Vdata = 1.026E-1 + -1.125E-4 * Tdata + 1.125E-5 * Tdata.^2;

% GA Parameters
popSize = 80;          % Population Size
numGenerations = 100;   % Number of Generations
mutationRate = 0.15;     % Mutation Rate (e.g., 0.1 for 10%)
crossoverRate = 0.8;    % Crossover Rate (e.g., 0.8 for 80%)
selectionPressure = 3;  % Selection Pressure (Tournament Size)
eliteCount = 1;         % Number of Elites to Preserve

% Number of independent optimization runs
numRuns = 10;

% Initialize results storage
bestObjValues = zeros(numRuns,1);
convergenceData = zeros(numRuns, numGenerations);

% Loop over runs
for run = 1:numRuns
    fprintf('Run %d/%d with current GA parameters...\n', run, numRuns);

    % Initialize Population
    numVariables = 6; % x(1) to x(6)
    lb = [1 1 1 1 1 1]; % Lower bounds
    ub = [length(Res) length(Res) length(Res) length(Res) length(ThVal) length(ThVal)]; % Upper bounds

    population = zeros(popSize, numVariables);
    for i = 1:numVariables
        population(:, i) = randi([lb(i), ub(i)], popSize, 1);
    end

    % Initialize Best Solution Tracking
    bestObj = Inf;
    bestSol = [];
    bestObjGen = zeros(numGenerations, 1);

    % Prepare state structure for ThOptimPlot
    options = struct();
    state = struct();
    state.Generation = 0;

    % Evaluate Initial Fitness
    fitness = zeros(popSize, 1);
    for i = 1:popSize
        x = population(i, :);
        fitness(i) = objectiveFunction(x, Res, ThVal, ThBeta, Tdata, Vdata);
    end
    state.Population = population;
    state.Score = fitness;

    % Call ThOptimPlot with 'init' flag for the first run only
    if run == 1
        ThOptimPlot(options, state, 'init', Tdata, Vdata, Res, ThVal, ThBeta);
    end

    % GA Loop
    for gen = 1:numGenerations
        state.Generation = gen;

        % Selection (Tournament Selection)
        matingPool = zeros(popSize, numVariables);
        for i = 1:popSize
            competitors = randi(popSize, selectionPressure, 1);
            [~, bestIdx] = min(fitness(competitors));
            matingPool(i, :) = population(competitors(bestIdx), :);
        end

        % Elitism: Preserve best individuals
        [sortedFitness, sortedIdx] = sort(fitness);
        elites = population(sortedIdx(1:eliteCount), :);

        % Crossover
        newPopulation = zeros(popSize, numVariables);
        for i = 1:2:(popSize - eliteCount)
            parent1 = matingPool(randi(popSize), :);
            parent2 = matingPool(randi(popSize), :);

            if rand < crossoverRate
                % Two-point crossover
                cp1 = randi(numVariables - 1);
                cp2 = randi([cp1 + 1, numVariables]);
                offspring1 = [parent1(1:cp1), parent2(cp1 + 1:cp2), parent1(cp2 + 1:end)];
                offspring2 = [parent2(1:cp1), parent1(cp1 + 1:cp2), parent2(cp2 + 1:end)];
            else
                offspring1 = parent1;
                offspring2 = parent2;
            end
            newPopulation(i, :) = offspring1;
            if i + 1 <= (popSize - eliteCount)
                newPopulation(i + 1, :) = offspring2;
            end
        end

        % Mutation
        for i = 1:(popSize - eliteCount)
            for j = 1:numVariables
                if rand < mutationRate
                    newPopulation(i, j) = randi([lb(j), ub(j)]);
                end
            end
        end

        % Include elites in new population
        newPopulation(end - eliteCount + 1:end, :) = elites;

        % Ensure variables are integers within bounds
        for i = 1:numVariables
            newPopulation(:, i) = max(lb(i), min(ub(i), round(newPopulation(:, i))));
        end

        % Update population
        population = newPopulation;

        % Evaluate Fitness
        fitness = zeros(popSize, 1);
        for i = 1:popSize
            x = population(i, :);
            fitness(i) = objectiveFunction(x, Res, ThVal, ThBeta, Tdata, Vdata);
        end
        state.Population = population;
        state.Score = fitness;

        % Update Best Solution
        [minFitness, minIdx] = min(fitness);
        if minFitness < bestObj
            bestObj = minFitness;
            bestSol = population(minIdx, :);
        end
        bestObjGen(gen) = bestObj;
        convergenceData(run, gen) = bestObj;

        % Call ThOptimPlot with 'iter' flag for the first run only
        if run == 1
            ThOptimPlot(options, state, 'iter', Tdata, Vdata, Res, ThVal, ThBeta);
        end
    end

    % Store best objective value for this run
    bestObjValues(run) = bestObj;

    fprintf('Best Objective Value for Run %d: %f\n', run, bestObj);
end

% Statistical Analysis
bestValue = min(bestObjValues);
worstValue = max(bestObjValues);
averageValue = mean(bestObjValues);
stdDeviation = std(bestObjValues);

% Display Results
fprintf('\nGA Parameters Used:\n');
fprintf('Population Size: %d\n', popSize);
fprintf('Number of Generations: %d\n', numGenerations);
fprintf('Mutation Rate: %.2f\n', mutationRate);
fprintf('Crossover Rate: %.2f\n', crossoverRate);
fprintf('Selection Pressure: %d\n', selectionPressure);
fprintf('Elite Count: %d\n', eliteCount);

fprintf('\nBest Objective Function Values over %d runs:\n', numRuns);
disp(bestObjValues);

% Create Results Table
resultsTable = table((1:numRuns)', bestObjValues, 'VariableNames', {'Run', 'BestObjectiveValue'});
disp(resultsTable);

% Summary Statistics Table
summaryTable = table([bestValue; worstValue; averageValue; stdDeviation], ...
    'RowNames', {'Best', 'Worst', 'Average', 'Standard Deviation'}, ...
    'VariableNames', {'ObjectiveFunctionValue'});
disp(summaryTable);

% Convergence Curve
averageConvergence = mean(convergenceData, 1);
figure;
plot(1:numGenerations, averageConvergence, '-b', 'LineWidth', 2);
title('Average Convergence Curve over Runs');
xlabel('Generation');
ylabel('Average Best Objective Function Value');
grid on;