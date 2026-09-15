# IRONMAN Race Management — Project

## Setup Local Database

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose

### Levantar la base de datos

```bash
cd Project
docker compose up -d
```

Esto inicia un contenedor PostgreSQL 16 con la base de datos `ironman`. Los scripts SQL en `1. Structure/` se ejecutan automáticamente en orden al crear el contenedor por primera vez:

| Archivo | Descripción |
|---|---|
| `1-Tables.sql` | Estructura base de tablas |
| `2-Attributes.sql` | Dominios y tipos de atributos |
| `3-Primaries.sql` | Llaves primarias |
| `4-Uniques.sql` | Restricciones de unicidad |
| `5-Foreign.sql` | Llaves foráneas |
| `6-PopulateOK.sql` | Datos válidos de prueba |
| `7-PopulateNOOK.sql` | Datos inválidos (pruebas de restricciones) |
| `8-Queries.sql` | Consultas de ejemplo |
| `9-XPopulate.sql` | Datos adicionales |
| `10-XTables.sql` | Tablas adicionales |

### Conexión

```
Host:     localhost
Port:     5432
Database: ironman
User:     ironman
Password: ironman
```

Con `psql`:

```bash
docker exec -it ironman-db psql -U ironman -d ironman
```

O desde tu máquina (requiere `psql` instalado):

```bash
psql -h localhost -p 5432 -U ironman -d ironman
```

### Reiniciar la base de datos desde cero

```bash
docker compose down -v
docker compose up -d
```

El flag `-v` elimina el volumen de datos, forzando la re-ejecución de los scripts de inicialización.

### Detener

```bash
docker compose down
```

---

# PROJECT FORMULATION

## A. Identification

- **Project:** IRONMAN Race Management and Rankings System
- **Participants:** [To be defined]

## B. Topic

### Presentation

The project addresses the data system modeling that supports the operation of **IRONMAN**, the world's leading triathlon race organization. IRONMAN manages hundreds of annual events across multiple countries, where athletes of different ages and nationalities compete in races that combine swimming, cycling, and running across various distances (sprint, olympic, 70.3, and full IRONMAN).

The topic is interesting because IRONMAN represents a real and complex data management case: it involves races with thousands of participants, results segmented by discipline, a points system by age category, seasonal rankings, and a qualification mechanism for world championships. Modeling this domain allows applying fundamental relational database concepts in a rich and well-defined context.

### Research

The key aspects to understand include:

- Structure of a triathlon race: segments (swim, bike, run, transitions), official distances and their differences.
- Age-group category system: how athletes are grouped by sex and age range.
- Points mechanics: how points are assigned based on the athlete's position within their age-group.
- Seasonal ranking: how points accumulate over a year and the ranking is generated.
- World championship qualification: how slots are assigned to world championships based on performance in qualifying races.

**Information sources:**

- Official IRONMAN website (ironman.com): race information, public results, age-group rules.
- Public regulations from IRONMAN and World Triathlon.
- General triathlon domain knowledge.

## C. Organization

### Description

- **Name:** IRONMAN (The IRONMAN Group / World Triathlon Corporation)
- **Main activity:** Organization and production of worldwide triathlon and endurance events, including the IRONMAN series, IRONMAN 70.3, and other distances.
- **Mission:** To provide world-class race experiences that inspire athletes to achieve their personal goals, promoting an active and healthy lifestyle.

### Stakeholders

| Stakeholder | Main interest |
|---|---|
| **Athletes** | Register for races, check their results and segment times, know their ranking position and world championship qualification options. |
| **Race organizers** | Manage the race catalog, record official results, assign qualification slots. |
| **Ranking administrators** | Configure points rules per season, generate and publish rankings, manage seasons. |

## D. Problem

### Justification

IRONMAN manages a significant volume of operational data: hundreds of races per year, each with thousands of registered athletes, results broken down by segment (swim, T1, bike, T2, run), multiple age categories by sex, and a points system that feeds a global ranking per season. Additionally, certain races serve as qualifiers for world championships, requiring a slot allocation mechanism.

Without a structured data model, this information is difficult to query, maintain, and analyze consistently. The opportunities to leverage include:

- Centralizing race, athlete, and result information in a coherent relational model.
- Automating points calculation and seasonal ranking generation.
- Facilitating qualification slot assignment based on verifiable data.

### Impact

The expected general benefits are:

- **Efficient queries:** Quickly obtain a season's ranking, an athlete's results, or a race's qualifiers.
- **Traceability:** Every point assigned and every slot granted is backed by officially recorded results.
- **Consistency:** A normalized model ensures data is free from redundancies and anomalies.
- **Scalability:** The model can grow to incorporate new distances or seasons without restructuring.

## E. Solution

### Description

The proposed solution is a **relational database** that models the core business concepts of IRONMAN:

- **Races:** Triathlon events with date, location, distance (sprint, olympic, 70.3, full) and type (regular, world championship qualifier).
- **Athletes:** Registered individuals with basic data (name, nationality, date of birth, sex), which determines their age-group.
- **Registrations:** Relationship between athletes and races, representing an athlete's enrollment in a specific event.
- **Results:** Segment times (swim, T1, bike, T2, run) and total time, associated with a registration. Includes overall position and age-group position.
- **Points:** Points assigned to an athlete based on their age-group position in a race, using a simplified scheme (fixed points per position).
- **Seasons:** Annual periods in which points accumulate and a ranking is generated.
- **Ranking:** Each athlete's position within their age-group for a given season, calculated from the sum of points.
- **Qualification slots:** World championship entries assigned to the top athletes in each age-group at qualifying races.

**Main users:** Athletes, race organizers, ranking administrators.

**Main services (queries):**

- Register an athlete for a race.
- Record race results.
- Query a season's ranking by age-group.
- Query an athlete's results in a specific race.
- Query athletes who qualified for a world championship.

### Objectives

1. Design a normalized relational model that faithfully represents the IRONMAN domain of races, athletes, results, and rankings.
2. Implement the database in SQL with the necessary tables, constraints, and relationships.
3. Develop SQL queries that address the stakeholders' information needs (rankings, results, qualifications).
4. Validate the model with fictional scenarios covering the main business flows.

### Scope

**Included:**

- Race catalog (multiple distances and types).
- Athlete registration and basic data.
- Athlete enrollment in races.
- Result recording by segment and positions.
- Simplified points system (fixed points per age-group position).
- Annual ranking by season and age-group.
- Basic slot assignment for world championships.

**Excluded:**

- Operational race management (volunteers, logistics, venues).
- Payment processing or commercial registrations.
- IRONMAN Legacy Program (special access for multiple finishers).
- Slot rolldown mechanism (reassignment when a qualifier declines).
- Graphical interface or web application (database and SQL only).

### Contribution

The project contributes to IRONMAN's goals by providing a structured data model that supports the organization's core operations: race management, result recording, ranking generation, and world championship qualification assignment. A well-designed relational model is the foundation upon which the applications and services used daily by athletes and organizers are built.

### Validation

**Fictional scenarios** simulating real business situations will be used:

1. **Registration:** Create athletes of different ages, sexes, and nationalities. Create races of different distances and types. Enroll athletes in races.
2. **Results:** Record segment times for enrolled athletes. Calculate overall and age-group positions.
3. **Points and ranking:** Assign points based on age-group position. Accumulate points within a season. Generate the ranking.
4. **Qualification:** Identify qualifying races. Assign slots to the top finishers in each age-group. Query athletes qualified for a world championship.

## F. Critical Success Factors

### Factors

1. **Correct and normalized relational model:** Tables must be in at least third normal form (3NF), avoiding redundancies and update anomalies.
2. **Clear business rules for age-groups:** Athlete classification into age categories must be precise and consistent with IRONMAN rules.
3. **Well-defined points system:** Although simplified, the points assignment rules must be clear and uniformly applicable.
4. **Key query coverage:** SQL queries must address the stakeholders' real information needs (rankings, results, qualifications).
5. **Representative test data:** Fictional scenarios must be varied enough to validate the model across different situations.

### Risks

| Risk | Mitigation |
|---|---|
| Complexity of real IRONMAN rules (the actual domain is more complex than what is modeled). | Limit the scope to a manageable subset and document simplifications. |
| Ambiguity in the points system when translating real rules into a simplified scheme. | Define points rules explicitly before implementation. |
| Difficulty representing dynamic age-groups (they depend on the athlete's age at the time of the race). | Calculate the age-group based on date of birth and race date. |
| Insufficient test scenarios to cover edge cases. | Design scenarios that include athletes in multiple races, point ties, and races with insufficient registrants. |
