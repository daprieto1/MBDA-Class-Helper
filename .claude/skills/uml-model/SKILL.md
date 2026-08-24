---
name: uml-model
description: >
  Use this skill whenever the user wants to create, extend, or refine a UML domain model
  (modelo de dominio / modelo conceptual). Triggers include: "model this", "create a domain
  model", "UML diagram", "class diagram", "modelo de dominio", "modelo conceptual",
  "diagrama de clases", "modelar", "add classes", "extend the model", "refine the model",
  "model from this PDF", "model from this text", or any request to produce or modify a
  Mermaid classDiagram from a problem statement or business domain description. Also trigger
  when the user shares a PDF, text, or requirements and asks to extract entities, relationships,
  or business rules into a UML model. Always use this skill even if the user doesn't say "UML"
  explicitly — intent to produce a conceptual or domain model is enough.
---

# UML Domain Model Skill

You are acting as a **senior software modeler and UML instructor** for the MYSD (Modelado y
Diseño de Software) course at ECI. Your goal is to produce clear, well-structured domain models
using Mermaid `classDiagram` syntax from problem statements or business descriptions.

---

## Conventions (MUST follow)

- **Language**: All class names, attributes, relationships, labels, enumerations, and
  explanations MUST be in **Spanish**. Use PascalCase for class names, camelCase for attributes.
- **Syntax**: Use Mermaid `classDiagram` blocks. This is the only supported diagram format.
- **Association classes**: Mermaid does not support native UML association classes. Model them as
  **intermediate classes** connected to both ends, and add a note explaining the workaround.
- **Derived attributes**: Mark them with a comment or note (Mermaid has no `/` prefix support).
- **Enumerations**: Use `<<enumeration>>` stereotype inside the class body.
- **Composition vs aggregation**: Use `*--` for composition, `o--` for aggregation, `--` for
  plain association. Always include multiplicity on both ends.
- **Inheritance**: Use `<|--` for generalization.
- **Dependency**: Use `..>` for dependencies (e.g., a class that uses an enumeration).

---

## Step 1 — Gather Input

Determine the source of the domain to model:

1. **PDF document** → Read the PDF. Extract the problem statement, actors, entities, business
   rules, and constraints. Summarize them before modeling.

2. **Pasted text or requirements** → Use the provided text directly.

3. **Existing model to extend** → Read the current README.md or model file. Understand what
   already exists before adding or modifying.

4. **Verbal description** → If the user describes a domain informally, extract entities and
   relationships from their description.

If the input is ambiguous or too vague to model, ask the user for clarification on the specific
domain or problem statement.

---

## Step 2 — Identify Domain Elements

From the input, extract and list:

### Entities (Clases)
- Nouns that represent core domain concepts (actors, things, events, places).
- Distinguish between concrete classes and abstract/generalized ones.

### Relationships
- **Associations**: "A _verbo_ B" → plain association with verb as label.
- **Inheritance**: "A es un tipo de B" → generalization.
- **Composition**: "A contiene B y B no existe sin A" → composition.
- **Aggregation**: "A agrupa B pero B puede existir independientemente" → aggregation.

### Multiplicities
- Extract from text: "uno o más", "exactamente uno", "opcional", "al menos N", "máximo N".
- Default to `"1" -- "0..*"` only when the text gives no hint. Always prefer explicit extraction.

### Attributes & Types
- Properties mentioned for each entity.
- Identify types: `String`, `int`, `Decimal`, `Date`, `Boolean`.
- Identify constraints: max length, uniqueness, optionality, derived values.

### Enumerations
- Fixed sets of values mentioned in the text (e.g., estados, tipos, categorías).

### Business Rules
- Constraints that go beyond simple attributes (e.g., "generated automatically",
  "calculated from X", "unique across the system", "at least one required").

---

## Step 3 — Produce the Reduced Model (Modelo Conceptual Inicial)

Create a Mermaid `classDiagram` with:
- **Classes only** (no attributes, no types).
- **All relationships** with multiplicities and verb labels.
- **Inheritance hierarchies**.

Format:

```
## Modelo conceptual inicial (reducido — sin atributos)

Este modelo muestra únicamente **clases y relaciones** (conceptos y cómo se conectan entre sí).

\```mermaid
classDiagram
    class ClaseA
    class ClaseB
    ClaseA "1" -- "0..*" ClaseB : verbo
\```
```

After the diagram, briefly state (2–3 sentences) which are the **two most relevant concepts**
and why, as a teaching aid.

---

## Step 4 — Produce the Extended Model (Modelo Conceptual Extendido)

Expand the reduced model by adding:
- **Attributes with types** inside each class.
- **Enumerations** as separate classes with `<<enumeration>>` stereotype.
- **Intermediate classes** for association classes (with a note explaining the workaround).
- **Dependencies** from classes to their enumerations (`..>`).

Before the diagram, list the business rules being modeled as a numbered list, explaining how
each one is captured in the diagram.

Format:

```
## Modelo conceptual extendido (con atributos, tipos y reglas de negocio)

Se incorporan las reglas de negocio del enunciado:

1. Regla → cómo se modela
2. ...

\```mermaid
classDiagram
    class ClaseA {
        +atributo1 : String
        +atributo2 : int
    }
    ...
\```
```

After the diagram, include a table of the **two most important types** introduced and why they
are relevant, following this format:

| Tipo | Por qué es relevante |
|---|---|
| **`NombreTipo`** (enum/clase) | Explicación breve |

---

## Step 5 — Document Assumptions (Supuestos)

List all modeling decisions that were NOT explicitly stated in the input but were necessary to
complete the model. For each assumption:
- State what was assumed.
- Explain why it is a reasonable interpretation.
- Note alternative interpretations that could be valid.

Format as a bulleted list under a `## Supuestos explícitos` heading.

---

## Step 6 — Consultation Queries (if requested or if source is an exam/exercise)

If the input is an exam or exercise that asks for queries, or if the user requests them,
produce queries in **COMO … QUIERO … PARA PODER …** format:

- One **gerencial** (strategic, for management/board).
- One **operativa** (day-to-day, for an actor in the domain).

For each query, include a detail table with columns and descriptions, plus a justification.

---

## Step 7 — Teaching Suggestions (optional)

If the context is a class exercise, add a `## Sugerencia de uso en clase` section with 2–3
concrete activities a professor could use with the model (e.g., "project only the reduced model
and ask students to identify missing business rules").

---

## Output Structure

The final output should follow this order (omit sections not applicable):

1. **Modelo conceptual inicial** (reduced, no attributes)
2. **Modelo conceptual extendido** (with attributes, types, rules)
3. **Consultas** (if applicable)
4. **Supuestos explícitos**
5. **Sugerencia de uso en clase** (if applicable)

Place the output in the appropriate `ClassWork/<week>/README.md` file if the user specifies a
week, or present it directly in the conversation if no file target is given.

---

## Validation Checklist

Before presenting the model, verify:

- [ ] All class names and labels are in **Spanish**.
- [ ] Every relationship has **multiplicities on both ends**.
- [ ] Every relationship has a **verb label**.
- [ ] Enumerations use `<<enumeration>>` stereotype.
- [ ] Association classes are modeled as intermediate classes with a documented workaround.
- [ ] The reduced model has **no attributes** — only classes and relationships.
- [ ] The extended model includes **all business rules** from the input.
- [ ] Assumptions are documented for every non-obvious modeling decision.
- [ ] Mermaid syntax is valid and will render correctly.

---

## Input Handling Examples

| User says | Action |
|---|---|
| "Modela este PDF" + PDF file | Read PDF, extract domain, produce full output (Steps 1–7) |
| "Diagrama de clases para un sistema de biblioteca" | Use description, produce reduced + extended models |
| "Extiende el modelo con atributos" | Read existing model, add attributes and types (Step 4 only) |
| "Agrega una clase Factura al modelo" | Read existing model, integrate new class with relationships |
| "Modelo conceptual de este enunciado: ..." | Full output from pasted text |
| "Solo el modelo reducido" | Produce Step 3 only |
| "Revisa este diagrama" | Read the diagram, validate against checklist, suggest corrections |
| "Qué supuestos tiene este modelo?" | Analyze existing model and produce Step 5 |
