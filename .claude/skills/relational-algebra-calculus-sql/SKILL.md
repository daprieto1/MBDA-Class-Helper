---
name: relational-algebra-calculus-sql
description: Write and verify Relational Algebra queries (traditional Greek notation: σ, π, ⋈, ÷, ρ, ∪, ∩, −, ×), Tuple Relational Calculus queries (traditional set notation {t | P(t)} with ∃/∀), and their equivalent SQL, for the introductory database course based on C.J. Date. ALWAYS USE THIS whenever Diego asks to: generate the answer key for a reading quiz involving relational algebra/calculus or SQL, translate between algebra-calculus-SQL, check whether a hand-written query is correct, or create example queries/exercises for class — even if he just mentions "the correct query," "the answer in algebra," "what it would look like in SQL," or pastes a query to review. Date's book uses Tutorial D (JOIN/WHERE/RENAME), NOT Greek symbols — this skill translates those concepts into the traditional Greek notation Diego uses in his course, preventing notation errors.
---

# Relational Algebra, Relational Calculus, and SQL (Date-style)

## Purpose

Diego teaches an introductory database course using C.J. Date's textbook as the core
text. The book explains relational operators using **Tutorial D** (reserved words:
`JOIN`, `WHERE`, `RENAME`, `TIMES`, `MINUS`, `DIVIDEBY ... PER`, `EXISTS`, `FORALL`,
`RANGEVAR`), but in the course and on assessments Diego uses the **traditional
Greek/mathematical notation** for Relational Algebra and the **traditional set
notation** for Tuple Relational Calculus — which is what most students recognize and
what's asked for on reading quizzes and class activities.

This skill exists so that translations between "what Date explains conceptually" and
"the correct traditional symbol/syntax" are always exact, and so that equivalent SQL
is generated correctly. It's especially critical when the main use is **generating an
answer key**: a key with misused notation invalidates the entire quiz.

## Golden rule

Never invent semantics. Before translating one of Date's operators into traditional
notation, confirm in the text (searching project knowledge if needed) exactly what
that operator does according to Date — then apply the equivalence table below. If a
question involves a chapter or schema that isn't in the project files, say so and ask
for the material rather than inventing the "correct" query.

---

## 1. Relational Algebra — traditional notation

| Operation (Date's term) | Symbol | Syntax | Notes |
|---|---|---|---|
| Restrict / select | σ (sigma) | `σ_condition(R)` | Filters tuples. Date calls it "restrict"; some authors say "select" — same operator. |
| Project | π (pi) | `π_A1,A2,...(R)` | Removes attributes and duplicates. |
| Rename | ρ (rho) | `ρ_new/old(R)` or `ρ_new(R)` | Date does this with `RENAME A AS B`. Not one of Codd's original 8 operators, but standard in traditional notation. |
| Union | ∪ | `R ∪ S` | Requires R and S to be *union-compatible* (same schema/type). |
| Intersection | ∩ | `R ∩ S` | Same compatibility requirement. |
| Difference | − | `R − S` | Tuples in R that are not in S. Careful: not commutative. |
| Cartesian product | × | `R × S` | Combines every tuple of R with every tuple of S. |
| Natural join | ⋈ | `R ⋈ S` | Combines on identically-named attributes; removes duplicate columns from the result. |
| Theta-join | ⋈ with subscript | `R ⋈_condition S` | Join with an explicit condition, not necessarily equality or shared attributes. |
| Division | ÷ | `R ÷ S` | The operator most prone to conceptual errors — see the common pitfalls section. |

**Precedence and grouping:** when an expression combines several operators, use
explicit parentheses instead of relying on implicit precedence — that's what's
expected in a hand-written quiz and it avoids ambiguity when grading.

**Formatting when writing in chat/markdown:** use the Unicode characters directly
(σ π ρ ∪ ∩ ⋈ ÷ ×), and write the condition subscript inline with an underscore:
`σ_CITY='London'(V)`. If the deliverable is a .docx or PDF (see the `docx`/`pdf`
skills), use real subscript formatting wherever the editor allows it instead of the
underscore approximation.

### Reference example (Date's Suppliers-Parts-Shipments schema)

Default schema if the exercise doesn't specify another one (Date's chapters 3 and 6):

- `S(S#, SNAME, STATUS, CITY)` — suppliers
- `P(P#, PNAME, COLOR, WEIGHT, CITY)` — parts
- `SP(S#, P#, QTY)` — shipments (relates S to P)

> "Get supplier numbers and cities for suppliers who supply part P2."

Algebra: `π_S#,CITY(σ_P#='P2'(S ⋈ SP))`

---

## 2. Tuple Relational Calculus — traditional notation

| Element | Notation | Notes |
|---|---|---|
| Full expression | `{ t | P(t) }` | "The set of tuples t such that P(t) is true." |
| Tuple variable | `t`, `s`, lowercase | Equivalent to Date's `RANGEVAR`, but without a prior explicit declaration — the domain is indicated inside P(t) (e.g. `t ∈ S`). |
| Attribute reference | `t.A` or `t[A]` | Both forms are accepted; be consistent within a single query. |
| Membership | `t ∈ R` | Equivalent to Date's relational comparison / membership condition. |
| Existential quantifier | `∃t (P(t))` | Equivalent to `EXISTS` in Date. |
| Universal quantifier | `∀t (P(t))` | Equivalent to `FORALL` in Date. Remember the identity `∀t(P) ≡ ¬∃t(¬P)`, useful if Diego asks students to rewrite without FORALL. |
| Logical connectives | `∧` `∨` `¬` (or `AND` `OR` `NOT`) | Use the symbols if the rest of the query uses symbolic notation; don't mix styles within the same expression. |

**Free-variable rule:** every free variable appearing in the condition `P(t)` must
also appear in the result tuple (to the left of the `|`). This is the same
requirement Date imposes on the `<prototuple>` — if an answer key violates it, that's
an error, not a valid alternative.

### Same example, in tuple calculus

> "Get supplier numbers and cities for suppliers who supply part P2."

`{ t.S#, t.CITY | t ∈ S ∧ ∃s (s ∈ SP ∧ s.S# = t.S# ∧ s.P# = 'P2') }`

Teaching note: this query needs an existential quantifier because it connects two
relations (S and SP) without being able to "flatten" the condition into a single
tuple — worth pointing out in the answer-key justification, since it's exactly the
point Date makes in chapter 7 when comparing algebra and calculus.

---

## 3. Equivalent SQL

Same example:

```sql
SELECT S.S#, S.CITY
FROM S
WHERE EXISTS (
    SELECT * FROM SP
    WHERE SP.S# = S.S# AND SP.P# = 'P2'
);
```

Or with an explicit JOIN (equivalent, closer to the algebra form):

```sql
SELECT DISTINCT S.S#, S.CITY
FROM S JOIN SP ON S.S# = SP.S#
WHERE SP.P# = 'P2';
```

When generating an answer key, present all three forms (algebra, calculus, SQL)
aligned to the same prompt whenever the quiz asks for them separately — that way
Diego can check at a glance that all three are consistent with each other.

---

## 4. Common pitfalls to check before calling a query correct

- **Division (÷):** only valid when S's schema is a subset of R's. Check attributes
  before applying it; this is the operator where errors slip in most often.
- **Difference / set subtraction:** `R − S` requires R and S to be union-compatible
  (same attributes). If they aren't, the expression doesn't make sense and can't be
  "fixed" with a join — the query needs to be rethought.
- **NULL / unknown values:** Date's book is explicitly critical of how SQL handles
  NULL compared to pure relational algebra/calculus. If a question touches this
  topic, don't equate SQL's behavior with the algebra's without flagging it.
- **Natural join vs. theta-join:** if the attributes don't share a name, natural `⋈`
  doesn't apply — use a theta-join with an explicit condition, or rename first (`ρ`).
- **FORALL via EXISTS:** if the quiz asks to "rewrite using only ∃," use the identity
  `∀t(P) ≡ ¬∃t(¬P)` and double-check that the negation of P is built correctly (De
  Morgan mistakes are the most common failure here).

---

## 5. When generating answer keys for reading quizzes

Follow the standing rules already established for Diego's quizzes:

1. Base the query **only** on the schema and tables that appear in the quiz prompt
   or in the project files — never invent attributes.
2. Give the answer in whatever notation(s) the quiz asks for (by default: traditional
   algebra and/or traditional tuple calculus, plus SQL if explicitly requested).
3. If the quiz asks for a justification, cite the section or page in Date where the
   operator is defined (e.g. "Restrict — section 6.4") and explain in one or two
   sentences why that operation solves the prompt — don't rewrite the chapter.
4. Check the query against the common-pitfalls list (section 4) before delivering it
   as the final answer key.
5. If a single prompt admits more than one correct query (common in algebra: join
   then restrict vs. restrict then join, or EXISTS vs. join+DISTINCT in SQL), include
   them as valid alternatives in the key instead of marking only one — it's common
   for different students to arrive at different but equivalent forms.
