# Entity Relationship Diagram (ERD)

This template has no persistent data store yet. The diagram below shows the placeholder entities that will be replaced per project.

## Mermaid

```mermaid
erDiagram
  ENTITY_A ||--o{ ENTITY_B : has
  ENTITY_A {
    string id PK
    string name
    timestamp created_at
  }
  ENTITY_B {
    string id PK
    string a_id FK
    string value
    timestamp updated_at
  }
```

## PlantUML

```plantuml
@startuml
!theme plain
hide circle
skinparam linetype ortho

entity "ENTITY_A" as a {
  * id : string <<PK>>
  --
  name : string
  created_at : timestamp
}

entity "ENTITY_B" as b {
  * id : string <<PK>>
  --
  a_id : string <<FK>>
  value : string
  updated_at : timestamp
}

a ||--o{ b
@enduml
```

## Entities

- **ENTITY_A** — _primary entity (replace per project)_
- **ENTITY_B** — _dependent entity, many-to-one with ENTITY_A_
