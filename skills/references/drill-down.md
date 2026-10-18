# Drill-down Drill-Down

> **Start with the problem or requirement as a whole, then progressively break down and refine the solution until it can be implemented directly**

The final level can be a chapter, section, or subsection
At that level, describe the solution in enough detail to implement it directly, without adding more heading levels

Before each breakdown, clarify the problem and scope of the current part and establish an overall approach
Then divide the parts by responsibility, making clear what each part handles and how the parts work together

- Keep closely related content together and retain only necessary interfaces between parts
- Ensure the parts together cover the current problem, with no gaps or overlaps in responsibilities
- Resolve design decisions that are difficult to make or likely to change within the relevant part, rather than deferring them to implementation
- Define handling for normal operation, failures, interruptions, and external dependency errors together within the relevant part

If objects, inputs and outputs, processing rules, or error behavior remain unclear, continue refining the corresponding content

During breakdown and refinement, repeatedly check the responsibilities and interactions of all parts to confirm that they can solve the current problem together
If responsibilities are unclear, missing, or overlapping, or interfaces are inconsistent, adjust the overall division and the solutions for the relevant parts before continuing the breakdown and refinement

References:

- [Simon, *The Architecture of Complexity*, 1962](../../SSOT.md#4-design-and-maintainability)
- [Parnas, *On the Criteria To Be Used in Decomposing Systems into Modules*, 1972](../../SSOT.md#4-design-and-maintainability)
- [Ousterhout, *A Philosophy of Software Design*, 2018](../../SSOT.md#4-design-and-maintainability)
- [Stevens, Myers, Constantine, *Structured Design*, 1974](../../SSOT.md#4-design-and-maintainability)
- [Dijkstra, *The Structure of the "THE"-Multiprogramming System*, 1968](../../SSOT.md#4-design-and-maintainability)
