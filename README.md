# MBDA-Class-Helper

Repositorio de apoyo para la materia **Modelado y Diseño de Software (MYSD)** — Escuela Colombiana de Ingeniería Julio Garavito, 2026-01.

Contiene modelos de dominio UML, ejercicios resueltos y material de clase con diagramas en Mermaid.

## Estructura

```
ClassWork/
├── W3-W4/          # Semanas 3–4: Modelo de dominio — Amazon Marketplace
│   ├── README.md
│   └── MYSD-TT1-2026-02.pdf
└── PPT1/            # Parcial Primer Tercio: Grúas Nacionales S.A.S.
    ├── README.md
    └── Parcial-T1-2026-1-MYSD-DiegoAlfonso.pdf
```

## Contenido por semana

| Carpeta | Tema | Descripción |
|---|---|---|
| `W3-W4` | Amazon Marketplace | Modelo conceptual inicial y extendido (vendedores, productos, compradores, pedidos, envíos) |
| `PPT1` | Grúas Nacionales S.A.S. | Parcial primer tercio — modelo conceptual de gestión de grúas y asistencia vehicular |

## Convenciones

- Todo el contenido está en **español** (nombres de clases, relaciones, explicaciones).
- Los diagramas UML usan sintaxis **Mermaid `classDiagram`** para renderizar directamente en GitHub.
- Cada ejercicio incluye: modelo reducido (sin atributos) → modelo extendido (con atributos y reglas) → supuestos explícitos.
- Las clases de asociación se modelan como **clases intermedias** (Mermaid no soporta association classes nativamente).
