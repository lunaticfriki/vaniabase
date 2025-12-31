# Vaniabase

Vaniabase is a personal collection manager designed with a cyberpunk aesthetic. It allows users to track their books, movies, games, and other media in a visually striking interface.

## 🚀 Technology Stack

- **Framework**: Preact + Vite
- **Language**: TypeScript
- **Styling**: Tailwind CSS (Vanilla CSS mostly for custom animations/fonts)
- **State Management**: @preact/signals
- **Dependency Injection**: InversifyJS
- **Testing**: Vitest + TS-Mockito (Uses **Object Mother** pattern for test fixtures)
- **Data Persistence**: Firebase (Firestore & Storage)

## 🏗 Architecture

The project follows **Hexagonal Architecture (Ports and Adapters)** to decouple the core domain logic from external concerns.

### Layers (`src/`)

1.  **Domain** (`domain/`)
    - Contains the core business logic, entities, value objects, and repository interfaces.
    - _Dependency Rule_: Knows nothing about outer layers.

2.  **Application** (`application/`)
    - Orchestrates use cases and application services (e.g., `ItemStateService`, `AuthService`).
    - Dependent on Domain.

3.  **Infrastructure** (`infrastructure/`)
    - Implementations of interfaces defined in the Domain.
    - **Current Status**: Uses **Firebase** for persistence and authentication.

4.  **Presentation** (`presentation/`)
    - UI components, Pages, and ViewModels.
    - Responsible for displaying data and handling user interaction.

## ✨ Features

- **Dashboard**: A centralized hub showing statistics (Total items, counts by Category, Tag, Topic, Format).
- **Categories**: Supports **Books, Movies, Videogames, Music, Comics, and Magazines**.
- **Internationalization**: Fully localized in **English** and **Catalan**.
- **Cyberpunk UI**: Custom "neon" styling with irregular image shapes (`clip-path`) and glowing drop-shadows.
- **Smart Sorting**: 
    - Lists are automatically sorted by quantity (descending) to highlight the most relevant content.
    - Items are displayed chronologically (Newest First) on Home and Collection pages.
- **Authentication**: Simulated login system with private user collections.
- **Search**: Full-text search capability.

## 🛠 Getting Started

### Prerequisites

- Node.js (LTS recommended)
- pnpm (or npm)

### Installation

```bash
pnpm install
```

### Development

Start the development server:

```bash
npm run dev
```

Or use the **Tmux** setup for a complete development environment (splits terminal for git, tests, and server):

```bash
npm run tmux
```

### Build

Build for production:

```bash
npm run build
```

### Testing

Run unit tests:

```bash
npm test
```

## 🎨 Design Notes

The UI uses a dark theme (`#242424`) with high-contrast accent colors:

- **Brand Violet**: `#2e004f`
- **Brand Magenta**: `#ff00ff`
- **Brand Yellow**: `#ffff00`
- **Font**: Inconsolata (Monospace)
