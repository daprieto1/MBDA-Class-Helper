# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

University class helper repository for **MYSD (Modelado y Diseño de Software)** at ECI (Escuela Colombiana de Ingeniería). Contains teaching materials, domain model examples, and exam-related content organized by week/session.

## Repository Structure

- `ClassWork/` — All class materials organized by week (`W3-W4/`, etc.) and evaluations (`PPT1/`)
- Each week folder may contain a `README.md` with Mermaid UML diagrams and teaching notes, plus PDF source documents

## Conventions

- **Language**: All class content is written in **Spanish** (domain terms, diagram labels, explanations). Keep this consistent.
- **UML Diagrams**: Use Mermaid `classDiagram` syntax for domain models. When Mermaid doesn't support a UML concept natively (e.g., association classes), simplify with intermediate classes and document the workaround.
- **Commit style**: Short conventional commits (e.g., `feat: class w3`).
- **Content structure per week**: Start with a reduced conceptual model (classes + relationships only), then an extended model (with attributes, types, business rules), followed by explicit assumptions and teaching suggestions.
