---
name: write-prose
description: Master prose writing and orchestration skill for creating clear, plain, accessible, and natural human writing. Synthesizes ISO 24495-1:2023, W3C Cognitive Accessibility Guidance, Plain Writing Act, and Simplified Technical English (STE) standards. Use when writing, drafting, editing, or reviewing reports, PR descriptions, commit messages, API docstrings, READMEs, architecture documents, user guides, prompts, or general technical prose.
---

# Master Prose Writing & Orchestration (`write-prose`)

> [!CAUTION]
> **MANDATORY LINGUISTIC AUDIT**
> Language models naturally default to pre-trained "AI-isms" (*delve, leverage, seamless, robust, pivotal, testament, not only... but also*). You MUST actively execute the Two-Pass Drafting Protocol below to audit and replace machine-generated fluff before producing final output.

> [!IMPORTANT]
> **WORKSPACE HYGIENE & FILE LOCATION RULES**
> - **No Repo Pollution**: Never create temporary draft files or scratch markdown in the project repository root or source directories.
> - **Temporary Drafts**: Store intermediate drafts, multi-pass review files, or scratch notes in the conversation scratch directory: `<appDataDir>/brain/<conversation-id>/scratch/`.
> - **Final Artifacts**: Write persistent, user-facing markdown reports or documents to the conversation artifacts directory: `<appDataDir>/brain/<conversation-id>/`.

This skill serves as the central source of truth for clear, plain, accessible, and natural human writing across all technical and non-technical documents.

## Procedural Workflow

### Step 1: Context & Audience Inference
Determine the target audience and document format:
1. **Pull Requests / Commits**: Engineering peers $\rightarrow$ Focus on "Why" over "How", factual tone, no fluff.
2. **API Documentation / Docstrings**: API consumers $\rightarrow$ Third-person singular verbs, concise summaries, clear parameter prose.
3. **User Guides / Tutorials**: End users $\rightarrow$ Direct second-person ("you"), short critical paths, explicit step-by-step instructions.
4. **Architecture / Design RFCs**: Team leads & stakeholders $\rightarrow$ Clear tradeoffs, decision-first layout, plain language.
5. **Prompts & System Instructions**: AI Agents / LLMs $\rightarrow$ Imperative tone, XML tags, positive directives, assume high baseline knowledge (name concepts without explaining them).

> [!NOTE]
> If the target audience or document context is ambiguous, use `ask_question` to clarify before drafting.

For detailed audience templates and tone matrices, see [references/audiences.md](references/audiences.md).

---

### Mode A: Writing & Drafting New Prose

#### Step 2: Sub-Skill Coordination
For specialized document types, delegate content gathering to domain skills while enforcing `write-prose` quality standards:
- **Pull Request Descriptions**: Refer to [`write-pr-description`](../write-pr-description/SKILL.md) for diff structure and testing steps.
- **Commit Messages**: Refer to [`commit-changes`](../commit-changes/SKILL.md) for conventional commit formatting.
- **Code & API Documentation**: Refer to [`code-documentation`](../code-documentation/SKILL.md) for docstring and tag conventions.
- **AI Prompts & Skill Instructions**: Refer to Section 7 in [`references/standards.md`](references/standards.md#7-prompt-design-standards-for-llm-audiences) for XML tagging, primacy placement, and token conservation.

#### Step 3: Apply Plain Writing & Accessibility Standards
Before writing, consult [references/standards.md](references/standards.md) to apply core principles from:
- **ISO 24495-1:2023**: Ensure content is relevant, findable, understandable, and usable.
- **W3C Cognitive Accessibility (COGA)**: Use clear words, literal language, short text, separate steps, short critical paths, and no reliance on memory.
- **Plain Writing Act**: Ensure immediate first-reading clarity using active voice and short sentences (15–20 words max).
- **Simplified Technical English (STE / ASD-STE100)**: Use controlled vocabulary, explicit sequential steps, max 3 nouns per cluster, and warnings before actions.

#### Step 4: Two-Pass Drafting & Anti-AI-ism Self-Correction
Execute this mandatory two-pass procedure before finalizing output:

1. **Pass 1 (Content Draft)**: Draft the response focusing on technical accuracy, structure, and domain content.
2. **Pass 2 (Linguistic Inspection & Rewrite)**:
   - Scan the draft line-by-line against the **Positive Replacement Pairs** in [references/standards.md](references/standards.md#61-positive-replacement-pairs-banned-words-mappings).
   - Flag and replace any banned verbs (*delve, leverage, foster, cultivate, maximize, democratize, resonate, encompass, bridge, underscore*).
   - Replace vague adjectives (*robust, seamless, pivotal, crucial, holistic, intuitive*) with **specific physical/technical behaviors** (e.g. replace *"robust error handling"* with *"retries failed HTTP requests up to 3 times"*).
   - Eliminate copula substitutions (*"serves as"* $\rightarrow$ *"is"*), negative parallelism (*"not only... but also"*), and rule-of-three lists.
3. **Output**: Present only the polished, post-audit prose.

---

### Mode B: Reviewing & Auditing Existing Prose

When the user asks to review, audit, or critique an existing document, PR description, or prompt:

1. **Run the Statistical Analyzer**:
   Execute the analyzer script on the target file:
   ```bash
   python3 /usr/local/google/home/gspencer/.gemini/config/skills/write-prose/scripts/analyze_prose.py <path-to-file>
   ```
2. **Evaluate Output Metrics**:
   - Check total word count, sentence count, median sentence length, and paragraph stats.
   - Note any sentences exceeding **25 words**, paragraphs exceeding **4 sentences**, or **banned AI words** returned by the script.
3. **Generate Audit Report Table**:
   Output a clear feedback report detailing findings and concrete fixes:

   | Line / Location | Issue / Violation | Standard Violated | Suggested Plain Language Fix |
   | :--- | :--- | :--- | :--- |
   | Line 12 | *"serves as a robust framework"* | Anti-AI-ism / Copula Sub | *"is a framework that retries HTTP requests"* |
   | Line 34 | Sentence length (42 words) | STE / Plain Language | Split into two sentences ($\le 20$ words each). |
