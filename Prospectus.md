# Surrogate thinking
<b>How the motivated use of predictive correspondence facilitates transfer of source knowledge to target inferences in other contexts or domains</b>
## Abstract
People use the range of their knowledge to help make predictions and solve problems, often drawing from a breadth of domains. A novel situation that requires analogical thinking. The recognition that physical processes from a range of domains can be described by a common relational category or schema. Coupling with extended mental devices and aids like diagrams or other cognitive tools. And even basic category recognition that requires near-instantaneous direction of attention toward diagnostic features. These all require people to depend on an alignment of their target situation with some source knowledge. But what makes these alignments dependable? My thesis is that the motivated use of predictive correspondence can be considered a rational activity with a statistical basis. While not entirely a new idea, a susceptibility to bias may have prevented correspondence-making from being considered a rational activity. Here, I establish an explicit inference by correspondence paradigm, which I use to reveal patterns in people’s thinking and decision making that can be compared to the behavior of rational models. I also carefully address the potential and propensity for bias in these kind of processes.
## Approach
I develop four correspondence tasks of increasing complexity to a) illustrate how correspondence can be used to improve predictions, b) characterize optimal patterns in the use of correspondence, and c) identify human behaviors and compare them to optimal patterns. 

1. Feature match statistic -- How do people make predictions in aligned, noisy strings with shared feature sets?
   * <u>Model</u> -- Correspondence statistic that estimates predictive power of internal and external structure. Bayesian model that uses Dirichlet to co-evaluate (internal/external) or Beta to estimate correspondence independently.
2. Relational match statistic -- How do people make predictions in aligned, noisy strings with distinct feature sets where the mapping must first be observed/learned before the statistic can be validated?
   * <u>Model</u> -- Uses the feature matching model above, but must first make use of correspondence data to establish the relation between features in the source and target feature sets in order to establish the likely mapping. People may or may not count the data for both purposes.
3. Single source foraging -- When exploring a target domain is relatively costly, how do people coordinate search across the source and target to identify and validate a statistical correspondence? Search may be characterized by source/target, local/global, identify/validate predictive structure, accept/reject source, explore/seeking. 
   * <u>Model</u> -- Reinforcement learning (Q-learning) to decide exploration sequences. The correspondence statistic is tracked throughout which the RL algorithm may use (model based) or not (model free). Cognitive task analysis may be used to characterize and compare the algorithm and people’s behavior.
4. Sequential source foraging -- When multiple sources are available, how do people prioritize sources, halt exploration of a source to retrieve a new source, and abandon use of sources even when others are still available?
   * <u>Model</u> -- RL/Q-learning model above, but with new action space to retrieve or select a new source. This may lead to a hazard analysis for surrogate thinking.
## Tentative Outline
1. Introduction
   1. The motivated use of predictive correspondence (credible informants, heterogenous logic, surrogate reasoning, category vs analogy vs metaphor, reuse, predictive correspondence, not complex transformations here. Correspondence at what level?  Substitution of elements within a predicate structure, generalization of similar predicates, versus features?)
   2. Correspondence problems and extant approaches
      1. Identifying a source (source representation - BART, MAC/FAC)
      2. . Completing the correspondence (i.e., SME, FARG, LISA, Constraint satisfaction, predicate substitution) 
      3. Evaluating predictive qualities (i.e.,  usefulness, validity, source/target reliability, correspondence reliability, alignability/ambiguity/1to1, rhetorical use credibility?)(i.e., SIAM, ERIC; Phineas)
      4. Making a prediction (does this come before or after iii? Consider ex-post plausibility assessment of candidate inferences, it isn’t clear weather iii or iv happens first, or if they iteratively co-occur)
      5. Foraging for sources--Evaluation of the correspondence as a ‘surrogate thinking engine’ (i.e., Source appeal: generality (turing incompleteness esp. analog systems), flexibility/manipulability, precision, perceptual/computational ease, aesthetic motivations, free rides, MAGI Fergusen)
   3. . Rationality and partiality
       1. Early ideas about inductive validity of correspondences
       2. Modern approaches in cognitive science
       3. Arguments and counter arguments against rational treatment (counting problem, non-iid motivated search, kind world, non-Poincarean world)
   4. Thesis, approach and plan 
2. Feature match statistic  (simple correspondence)
   1.  Example
   2.  Model approach
   3.  Experiment (symbol strings/arenas/darkroom)
       1.  Details
       2.  Experiment Results
   4.  Model performance (Psychological sensitivity to rational, compare simple heuristics, cognitive task analysis)
   5.  Discussion
3.  Relational match statistic (see above: a, b, c, d, e)
4.  Single source foraging (see above: a, b, c, d, e)
5.  Sequential source foraging (see above: a, b, c, d, e)
6.  ​Conclusion
7.  References
