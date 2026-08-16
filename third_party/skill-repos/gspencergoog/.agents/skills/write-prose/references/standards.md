# Foundational Writing Standards (`standards.md`)

This document synthesizes international writing standards (ISO 24495-1:2023, W3C Cognitive Accessibility, Plain Writing Act, Simplified Technical English) and natural writing controls to eliminate "AI-isms" and structural fluff.

---

## 1. Quantitative Targets & Measurement Limits

When writing or auditing text, aim for these quantitative thresholds:

| Metric | Target / Limit | Rule |
| :--- | :--- | :--- |
| **Sentence Length (Procedural)** | $\le \mathbf{20\text{ words}}$ | Procedural steps must be short and direct (1 action per step). |
| **Sentence Length (Descriptive)**| $\le \mathbf{25\text{ words}}$ (15–20 average) | Flag and split any sentence over 25 words. |
| **Paragraph Length** | $\le \mathbf{4\text{ sentences}}$ (40–80 words) | Keep paragraphs focused on a single concept. |
| **Word Length** | $\le \mathbf{5\text{ characters}}$ median | Prefer simple words (*use* vs *utilize*, *check* vs *investigate*). |
| **Noun Clusters** | $\le \mathbf{3\text{ consecutive nouns}}$ | Avoid heavy noun stacks (e.g., write *"system for monitoring engine temperature"*, not *"engine temperature monitoring system"*). |

Run `python3 /usr/local/google/home/gspencer/.gemini/config/skills/write-prose/scripts/analyze_prose.py <path-to-file>` to measure these stats automatically.

---

## 2. Technical Markup & Markdown Link Rules

To ensure technical clarity and prevent UI rendering breakage:
- **Code Symbols & Paths**: Enclose variable names, function names, CLI flags, and file paths in backticks: `` `my_function()` ``, `` `--verbose` ``, `` `src/main.ts` ``.
- **Code Blocks**: Always specify a language specifier for code blocks (`python`, `bash`, `json`, `markdown`).
- **Markdown Links (CRITICAL RULE)**: **NEVER** wrap Markdown link text in backticks. Wrapping a link in backticks breaks clickable formatting in IDEs and web views:
  - ❌ **Incorrect**: ``[`main.ts`](file:///path/to/main.ts)`` or ``[`MyClass`](file:///path/to/main.ts#L10)``
  - ✅ **Correct**: `[main.ts](file:///path/to/main.ts)` or `[MyClass](file:///path/to/main.ts#L10)`

---

## 3. ISO 24495-1:2023 (Plain Language Principles)

Content must satisfy four core principles:
1. **Relevant**: Include only information the reader needs to achieve their goal. Eliminate filler and background tangents.
2. **Findable**: Structure document with descriptive, sentence-case headings (`## Header`), bulleted lists, and logical ordering so information is easily scannable.
3. **Understandable**: Use familiar words, short sentences (15–20 words on average), and simple sentence structures.
4. **Usable**: Provide clear, actionable instructions that enable the reader to perform their task without re-reading.

---

## 4. W3C Cognitive Accessibility Guidance (COGA)

To support cognitive accessibility and reduce mental load:
- **Clear & Literal Language**: Avoid metaphors, idioms, hyperbole, and abstract expressions.
- **Short Text & Paragraphs**: Limit paragraphs to 2–4 sentences focusing on a single idea.
- **Separate Steps**: Present multi-step instructions as numbered lists (`1.`, `2.`, `3.`) with one action per step.
- **Short Critical Paths**: Put the most important action or decision first.
- **No Memory Reliance**: Do not expect the reader to remember details from earlier sections; repeat critical parameters or link directly.

---

## 5. Plain Writing Act & STE Standards

- **Active Voice**: Make the actor the subject of the sentence (*"The server rejected the request"* instead of *"The request was rejected by the server"*).
- **Direct Address**: Use second-person pronouns ("you", "your") for user-facing instructions and guides.
- **Subject-Verb Proximity**: Keep subjects and their main verbs close together.
- **No Nominalizations**: Do not turn verbs into heavy nouns (use *"decide"* instead of *"make a decision"*).
- **Sequential Safety/Context**: Always state prerequisites, warnings, or conditions *before* the action verb.

---

## 6. Natural Writing & Anti-AI-ism Controls

### 6.1 Positive Replacement Pairs (Banned Words Mappings)

Do NOT use high-probability AI filler words. Replace them using this direct mapping table during **Pass 2** self-correction:

| Banned Word / Phrase | Recommended Direct Alternative(s) |
| :--- | :--- |
| **leverage** | *use*, *apply*, *build on* |
| **delve / delve into** | *examine*, *study*, *check*, *look at* |
| **foster / cultivate** | *support*, *encourage*, *build*, *develop* |
| **utilize** | *use* |
| **seamless / seamlessly** | *without extra setup*, *automatically*, *directly* |
| **robust** | State exact behavior: *handles errors*, *retries up to 3 times* |
| **intuitive** | State exact design: *uses standard defaults*, *requires no configuration* |
| **pivotal / crucial** | State facts directly: *important*, *key*, or state why it matters |
| **tapestry / landscape / realm** | *context*, *area*, *environment*, *system* |
| **testament to / serves as** | *is*, *shows*, *demonstrates* |
| **holistic / comprehensive** | *complete*, *full*, or list the specific parts |
| **in order to** | *to* |
| **at this point in time** | *now*, *currently* |

---

### 6.2 Side-by-Side Contrastive Examples

Use these contrastive pairs to calibrate self-correction during drafting:

| ❌ Machine-Generated Fluff (AI-ism) | ✅ Human Plain Language |
| :--- | :--- |
| *"The library serves as a robust framework for leveraging telemetry data."* | *"The library collects telemetry data and retries on failure."* |
| *"This pull request marks a pivotal moment in streamlining database queries..."* | *"This pull request reduces database query latency by indexing the user ID column."* |
| *"The team continues to foster innovation while seamlessly navigating challenges."* | *"The team resolved 5 open issues and added unit test coverage."* |
| *"Nestled in the architecture, this module acts as a cornerstone..."* | *"This module handles authentication."* |
| *"It is not only a caching layer, but also a security boundary."* | *"It caches data and enforces access controls."* |
| *"Despite initial hurdles, the pipeline continues to thrive..."* | *"The build pipeline passed all checks."* |
| *"Certainly! I would be happy to delve into this robust solution for you."* | *"Here is the design breakdown."* |

---

### 6.3 Converting Vague Adjectives into Concrete Technical Behaviors

Never use vague praise adjectives (*robust, seamless, intuitive, frictionless, scalable*). Replace them with the actual technical mechanism:

- ❌ *"Implements robust error handling."*  
  $\rightarrow$ ✅ *"Catches `NetworkException` and retries failed requests up to 3 times before timing out."*
- ❌ *"Provides a seamless user experience."*  
  $\rightarrow$ ✅ *"Saves user settings automatically without requiring a manual save button."*
- ❌ *"Highly scalable architecture."*  
  $\rightarrow$ ✅ *"Distributes requests across worker isolates using a round-robin pool."*

---

## 7. Prompt Design Standards for LLM Audiences

When writing system prompts, agent skills, tool guidelines, or automated prompts:

1. **Token Conservation Principles**:
   - **Treat Context as a Finite Resource**: Every token consumed in a prompt reduces attention efficiency and limits remaining history/code space.
   - **Eliminate Polite & Conversational Filler**: Omit phrases like *"Please make sure to..."*, *"It would be appreciated if you..."*, *"As an AI assistant, you should..."*. Use direct imperative verbs (*"Extract parameters..."*, *"Return JSON format..."*).
   - **Use High-Density Delimiters**: Use brief XML tags (`<instructions>`, `<constraints>`) or Markdown bullet points instead of prose paragraphs to delineate sections.
   - **Modular Depth & Context Layering**: Where supported (such as agent skills), use progressive disclosure by separating core instructions from deep reference files (`references/`). For standalone prompts where multi-file loading is not feasible, keep the primary directive concise at the top and relegate large reference data or schemas to distinct, clearly delimited sections at the end of the prompt.

2. **Assume High Baseline Knowledge**:
   - **Do NOT explain basic concepts**: Models already have extensive pre-trained knowledge about ASTs, REST APIs, Conventional Commits, or ISO standards. Name the concept directly without writing explanatory paragraphs.
   - **Only explain specific constraints**: Elaborate only when defining a non-standard rule, custom domain schema, or project-specific edge case.

3. **Semantic Delimiters**:
   - Use XML tags (`<instructions>`, `<constraints>`, `<context>`, `<examples>`) or Markdown headers (`#`) to bound prompt components. Delimiters help the model's attention mechanism distinguish instructions from user input.

4. **Primacy & Recency Placement**:
   - Place role definition, primary objective, and core callouts at the **very top** (`> [!CAUTION]`).
   - Place critical output formatting constraints at the **very bottom** (immediately before the response threshold).

5. **Positive Action Directives**:
   - Frame instructions as direct, positive actions (*"Format the output as a 3-column table with headers X, Y, Z"*) rather than vague negative prohibitions (*"Don't generate bad tables"*).

6. **Few-Shot Concrete Examples**:
   - Provide 1–2 exact `Input -> Output` pairs for complex output formats. Examples communicate format requirements more effectively than token-heavy prose explanations.
