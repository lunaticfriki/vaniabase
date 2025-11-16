# Vaniabase

A comprehensive collection management application for organizing and cataloging various media items including books, CDs, video games, magazines, comics, and more.

## 📖 Overview

Vaniabase is built with a Domain-Driven Design (DDD) and Hexagonal Architecture approach, providing a clean separation of concerns and maintainable codebase. The application allows users to track their personal collections with detailed metadata for each item.

## 🏗️ Architecture

The project follows DDD and Hexagonal Architecture principles:

```
src/
├── domain/          # Business logic and entities (Item domain model)
├── infrastructure/  # External adapters (API clients, repositories)
├── application/     # Use cases and application services
└── presentation/    # UI components and views (React)
```

## 🚀 Tech Stack

- **Framework:** React 19 + TypeScript
- **Build Tool:** Vite
- **Styling:** Tailwind CSS
- **State Management:** Preact Signals
- **Testing:** Vitest + Testing Library + ts-mockito + ts-arch
- **Package Manager:** pnpm

## 📋 Prerequisites

- Docker and VS Code with Dev Containers extension (recommended)
- **OR** Node.js (v20 or higher) and pnpm (for local setup)

## 🐳 Dev Container

This project includes a fully configured development container for a consistent development environment.

**Features:**

- **Base Image:** Node.js 20 on Debian Bookworm
- **Pre-installed:** pnpm, git, curl
- **VS Code Extensions:**
  - ESLint
  - Prettier
  - Tailwind CSS IntelliSense
  - Vitest Explorer
- **Auto-configuration:**
  - Format on save enabled
  - ESLint auto-fix on save
  - Port forwarding for Vite (5173)
  - Automatic `pnpm install` on container creation

**To use:**

1. Open the project in VS Code
2. Click "Reopen in Container" when prompted
3. Wait for the container to build and dependencies to install
4. Start developing!

**Manual setup** (without Dev Container):

- Ensure Node.js 20+ and pnpm are installed locally

## 🛠️ Setup

1. **Install dependencies:**

   ```bash
   pnpm install
   ```

2. **Start development server:**

   ```bash
   pnpm dev
   ```

3. **Start mock API server** (for development without backend):
   ```bash
   pnpm mock:server
   ```

## 📜 Available Scripts

- `pnpm dev` - Start Vite development server
- `pnpm build` - Build for production
- `pnpm preview` - Preview production build
- `pnpm lint` - Run ESLint
- `pnpm test` - Run tests in watch mode
- `pnpm test:ci` - Run tests once (used in CI/hooks)
- `pnpm test:ui` - Run tests with UI
- `pnpm test:coverage` - Generate test coverage report
- `pnpm mock:server` - Start mock API server (port 3001)
- `pnpm commit` - Interactive commit helper with type selection and testing

## 🧪 Testing

The project uses Vitest for unit and integration testing. Test files are located alongside the source files with the `__tests__` suffix.

**Testing Strategy:**

- **Object Mother Pattern** - Test data builders in `__tests__/objectMothers/` for creating domain entities with realistic test data
- **Unit Tests** - Testing domain logic and business rules
- **Integration Tests** - Testing component behavior and interactions

Run tests:

```bash
pnpm test
```

## � Git Hooks (Husky)

The project uses Husky to enforce code quality through automated git hooks:

### Interactive Commit Helper

Instead of using `git commit` directly, use:

```bash
pnpm commit
```

This will:

1. ✅ Prompt you to select a commit type (feat, fix, refactor, test, docs, style, chore, perf)
2. ✅ Ask for a commit description
3. ✅ Run all tests automatically
4. ✅ Create the commit if tests pass
5. ❌ Abort if tests fail

**Commit Message Format:** `<type>: <description>`

Example: `feat: add item filtering functionality`

### Pre-Push Hook

When you run `git push`, the hook will:

1. ✅ Run all tests automatically
2. ✅ Allow push if tests pass
3. ❌ Block push if tests fail

This ensures only tested code reaches the repository.

## �🗄️ Mock API Server

A mock REST API server is available for development purposes. See [`mock/README.md`](./mock/README.md) for details.

The mock server provides:

- 20 pre-seeded items
- Full CRUD operations
- CORS enabled
- Runs on `http://localhost:3001`

## 🎯 Domain Model

The core domain entity is `Item`, which represents any collectible with properties:

- `id`, `name`, `author`, `description`
- `imageUrl`, `topic`, `tags`
- `owner`, `completed`, `year`
- `language`, `format`

## 📝 Configuration Files

- `vite.config.ts` - Vite configuration
- `vitest.config.ts` - Test configuration
- `tsconfig.json` - TypeScript configuration
- `tailwind.config.js` - Tailwind CSS configuration
- `eslint.config.js` - ESLint rules
- `.devcontainer/` - Dev container configuration
- `eslint.config.js` - ESLint rules

## 📄 License

Private project
