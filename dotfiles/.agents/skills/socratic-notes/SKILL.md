---
name: socratic-notes
description: Use after completing a Socratic teaching session when you need to generate study notes from the dialogue. Triggers when user says "capture the learning", "generate notes from this", "write this to a note", "create a study note", "document what we learned", or when a teaching session concludes and the user wants to save the knowledge. This skill transforms the Q&A dialogue into a structured markdown note with background knowledge, examples, mistakes with corrections, and a TODO list for follow-up.
---

# Socratic Notes Generator

Generate clean, comprehensive markdown notes from Socratic teaching dialogues.

## When to Use

After a Socratic teaching session concludes and you need to:
- Capture learning as structured notes
- Document knowledge gaps and misconceptions
- Create study materials for future review

## Input

The skill expects the full conversation history of a Socratic teaching session, including:
- Questions asked by the teacher
- Learner responses (correct and incorrect)
- Corrections and explanations given
- Final understanding achieved

## Output: Note Structure

Generate a markdown file with this exact structure:

```markdown
# [Topic Title]

## Core Concepts
[2-4 sentences explaining the key takeaway]

---

## Background Knowledge
[Comprehensive background needed to understand this topic]
[Include definitions of key terms]

### Key Terms
| Term | Definition |
|------|------------|
| [term] | [definition] |

---

## Deep Dive
[Deep dive into each concept covered]
[Use headings to organize by sub-topic]

### [Sub-topic 1]
[Explanation with code examples if applicable]

```ts
// Example code
```

### [Sub-topic 2]
[More detailed explanation]

---

## Example Scenarios
[Real-world use cases discussed in the session]

### Scenario 1: [Scenario name]
[Problem description and solution]
```ts
// Relevant code
```

### Scenario 2: [Scenario name]
[Another practical example]

---

## Common Misconceptions
[Errors the learner made during the dialogue, with corrections]

### Misconception: [Descriptive title]
- **Wrong understanding**: [What the learner incorrectly believed]
- **Correct understanding**: [What is actually true]
- **Why**: [Explanation of why the misconception was wrong]

---

## Decision Matrix / Quick Reference
[If applicable: tables comparing approaches, tools, or strategies]

| Scenario | Choice | Reason |
|----------|--------|--------|
| [case] | [choice] | [reason] |

---

## Knowledge Weak Points

- [ ] TODO: [Knowledge point to master]
- [ ] WEAKNESS: [Area that needs more practice]

---

## Further Reading
- [Related concept 1]
- [Related concept 2]
```

## Writing Guidelines

### For Background Knowledge
- Define all technical terms introduced in the session
- Include prerequisite knowledge the learner should have
- Use tables for comparing multiple related concepts

### For Mistakes Section
Every mistake must have:
1. The incorrect answer/understanding given
2. The correct understanding
3. A brief explanation of why the misconception occurred

Use this format:
```
### Misconception: [Descriptive title of the misconception]
- **Wrong understanding**: [What was said/believed incorrectly]
- **Correct understanding**: [The corrected understanding]
- **Why**: [Root cause of the misunderstanding - was it a wrong assumption, missing context, etc.]
```

### For TODO List
Mark items as:
- `[ ]` - Not yet addressed
- `[x]` - Understood and addressed

Prefix weak areas with `WEAKNESS:` to make them visually distinct for later review.

### Style Requirements
- Use English in the note content
- Minimize emoji - only use when they add genuine clarity
- Use code blocks with language hints (```ts, ```bash, etc.)
- Use tables for comparisons and lists
- Keep explanations concise but complete
- No unnecessary decorative elements

## File Naming

Save notes to a path that makes sense for the topic. Use the format:
```
notes/[Category]/[Topic].md
```

Or if the user specifies a location, use that instead.

## Processing Steps

1. **Analyze the conversation**: Identify all Q&A pairs, corrections, and key insights
2. **Extract mistakes**: Find every instance where the learner gave an incorrect or incomplete answer
3. **Identify weak areas**: Note concepts that are still shaky or require more practice
4. **Organize by structure**: Arrange into the sections outlined above
5. **Write the note**: Generate clean markdown, following the format exactly
6. **Save the file**: Write to the appropriate location

## Quality Checklist

- [ ] All mistakes from the dialogue are documented with corrections
- [ ] Background knowledge is comprehensive enough for future review
- [ ] Code examples are complete and runnable
- [ ] TODO list distinguishes between "needs practice" and "understood"
- [ ] Note is self-contained - no missing context
- [ ] Clean formatting with minimal emoji
