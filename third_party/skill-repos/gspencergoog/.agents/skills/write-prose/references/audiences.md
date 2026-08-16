# Audience & Voice Matrix (`audiences.md`)

This guide provides concrete matrices and **one-shot reference examples** demonstrating how the same technical concept is adapted across 5 distinct audiences.

---

## 1. Audience Matrix & Rule Adaptations

| Audience | Primary Goal | Voice / Person | Verb & Tense Style | Structural Focus |
| :--- | :--- | :--- | :--- | :--- |
| **Peer Engineers** | PR descriptions, commit logs, code reviews | Factual / Impersonal | Past-tense for changes (*"Added"*, *"Fixed"*); Present for logic intent (*"Why"* over *"How"*). | Summary $\rightarrow$ Logic Changes $\rightarrow$ Impact $\rightarrow$ Testing Steps. |
| **API Consumers** | Library docs, docstrings, SDK references | Third-person neutral | 3rd-person singular present (*"Calculates..."*, *"Retries..."*); Booleans start with *"Whether..."*. | 1-Sentence Summary $\rightarrow$ Parameter Prose $\rightarrow$ Usage Code Sample. |
| **End Users / Devs** | Tutorials, user guides, setup docs | Direct second-person ("you") | Imperative action verbs (*"Open"*, *"Configure"*); 1 action per step. | Prerequisites $\rightarrow$ Numbered Steps $\rightarrow$ Expected Result. |
| **Leadership / RFCs** | System designs, RFCs, technical proposals | Objective / Analytical | Present tense; decision-first layout. | Executive Summary $\rightarrow$ Proposal $\rightarrow$ Trade-offs Table $\rightarrow$ Migration. |
| **AI Agents / LLMs** | System prompts, agent skills, tool directives | Imperative / Unambiguous | Direct imperative commands (*"Execute"*, *"Return"*); positive action directives. | Role Anchor $\rightarrow$ XML Delimiters $\rightarrow$ Guardrails $\rightarrow$ Examples. |

---

## 2. One-Shot Reference Examples (Same Topic, 5 Audiences)

**Scenario**: Adding exponential backoff retry logic to an HTTP network service client.

### Example A: Peer Engineers (PR Description)

```markdown
## Summary
Adds automatic HTTP retry logic with exponential backoff to `HttpClient` to prevent transient network dropouts from failing user requests.

## Changes
* Wrapped `HttpClient.send()` in a retry loop using `ExponentialBackoff`.
* Added `maxRetries` (default: 3) and `initialDelayMs` (default: 200ms) parameters to `HttpClientConfig`.
* Retries only on HTTP 502, 503, 504, and socket timeout exceptions.

## Testing
* Added unit tests in `test/http_client_test.dart` verifying backoff delays: 200ms, 400ms, 800ms.
* Verified that HTTP 4xx errors fail immediately without retrying.
```

---

### Example B: API Consumers (Docstrings / API Reference)

```dart
/// Sends an HTTP request and retries transient failures using exponential backoff.
///
/// Retries up to [HttpClientConfig.maxRetries] times when encountering HTTP 502,
/// 503, or 504 status codes, or network socket timeouts. Throws [HttpException]
/// if all retries fail or if a non-retriable error (e.g. 4xx) occurs.
///
/// Usage:
/// ```dart
/// final response = await client.send(request);
/// ```
Future<HttpResponse> send(HttpRequest request);
```

---

### Example C: End Users / Developers (User Guide / Setup Doc)

```markdown
## Configuring Automatic Retries

You can configure the client to retry failed requests automatically when temporary network errors occur.

1. Open your project configuration file (`config.yaml`).
2. Add the `retry_policy` block to your network settings:

```yaml
network:
  max_retries: 3
  initial_delay_ms: 200
```

3. Save the file and restart your application service.
```

---

### Example D: Leadership / RFCs (System Design / RFC)

```markdown
# RFC: Network Client Resilience & Transient Failure Handling

## Executive Summary
We propose introducing exponential backoff retries to the core HTTP client. This will reduce user-facing network error spikes by an estimated 80% during transient cloud gateway dropouts.

## Proposed Design & Trade-offs

| Option | Implementation Cost | Latency Impact | Resilience |
| :--- | :--- | :--- | :--- |
| **1. No Retries (Current)** | Zero | 0ms added | Poor (Errors surface immediately) |
| **2. Exponential Retries (Proposed)** | Low (2 days) | +200ms–1400ms on transient failures | High (Recovers from transient outages) |

## Migration & Risk
This change is non-breaking. Default retry values (3 attempts, 200ms initial delay) apply automatically without configuration changes.
```

---

### Example E: AI Agents / LLMs (System Prompt Directive)

```markdown
<role>
You are an expert networking engineer assisting with HTTP client resilience.
</role>

<instructions>
When configuring retry logic, enforce exponential backoff using these parameters:
1. Set initial delay to 200ms with a multiplier of 2.0.
2. Limit retries strictly to HTTP 502, 503, 504, and socket timeouts.
3. Fail non-retriable HTTP 4xx status codes immediately.
</instructions>

<output_format>
Return client configuration as a YAML block formatted inside ```yaml code fences.
</output_format>
```
