# Documentation Directory

Welcome to the comprehensive documentation for the claude-go-containers project.

## 📖 Start Here

**New to the project?** → [INDEX.md](INDEX.md) - Complete navigation guide

---

## Quick Links

### Essential Documentation

- **[INDEX.md](INDEX.md)** - Master index with complete navigation
- **[API_REFERENCE.md](API_REFERENCE.md)** - Function and package documentation
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design and technical decisions
- **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - Complete development workflows
- **[go-in-2025-guide.md](guides/go-in-2025-guide.md)** - Go ecosystem guide (16K+ words)

### Root Directory Documentation

- **[../README.md](../README.md)** - Project overview
- **[../QUICKSTART.md](../QUICKSTART.md)** - Quick start guide
- **[../CLAUDE.md](../CLAUDE.md)** - AI assistant guidance
- **[../CONTRIBUTING.md](../CONTRIBUTING.md)** - Contribution guidelines

---

## Documentation by Purpose

### Learning Go

Start your Go learning journey:

1. [../QUICKSTART.md](../QUICKSTART.md) - Basic Go concepts and first steps
2. [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Modern Go patterns and ecosystem
3. [API_REFERENCE.md](API_REFERENCE.md) - Example implementations

### Building Features

Develop in this project:

1. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Daily workflows and best practices
2. [../CLAUDE.md](../CLAUDE.md) - Quick command reference
3. [API_REFERENCE.md](API_REFERENCE.md) - Code patterns and examples

### Understanding Architecture

System design and decisions:

1. [ARCHITECTURE.md](ARCHITECTURE.md) - Complete architecture documentation
2. [go-in-2025-guide.md](guides/go-in-2025-guide.md) - Ecosystem patterns and tools

### Contributing

Join the project:

1. [../CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
2. [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Development workflows

---

## Documentation Structure

```
docs/
├── README.md                 # This file - docs directory overview
├── INDEX.md                  # Master index with complete navigation
├── API_REFERENCE.md          # Function and package documentation
├── ARCHITECTURE.md           # System architecture and design
├── DEVELOPMENT_GUIDE.md      # Development workflows and guidelines
├── guides/                   # Step-by-step guides and learning resources
│   ├── README.md            # Guides directory overview
│   ├── OPENCODE_SETUP.md    # AI tools setup and usage
│   ├── go-in-2025-guide.md  # Go ecosystem comprehensive guide
│   └── go-learning-plan.md  # Go learning path
└── meta/                     # Project metadata and documentation management
    ├── README.md            # Meta directory overview
    └── DOCUMENTATION_UPDATES.md  # Documentation changelog

../                           # Project root
├── README.md                 # Project overview
├── QUICKSTART.md            # Quick start guide
├── CLAUDE.md                # AI assistant guidance (Claude Code)
└── CONTRIBUTING.md          # Contribution guidelines
```

---

## Document Descriptions

### INDEX.md
Master navigation hub with:
- Quick start paths
- Documentation organized by role (learners, developers, contributors, architects)
- Documentation organized by topic
- Complete file reference
- Task-based documentation finder
- Cross-reference map
- Recommended reading paths

### API_REFERENCE.md
Complete API documentation:
- `examples` package (Greet, Add functions)
- `main` package (application entry point)
- Testing patterns (table-driven tests)
- Error handling patterns
- Concurrency patterns
- Code examples for all functions

### ARCHITECTURE.md
System architecture documentation:
- System overview and design principles
- Component architecture (container, application, AI tools, build)
- Data flow and workflows
- Testing architecture
- Configuration management
- Security considerations
- Scalability and growth path
- Architecture decision log

### DEVELOPMENT_GUIDE.md
Complete development guide:
- Development environment setup
- Daily development workflow
- Code writing guidelines (naming, documentation, errors)
- Testing strategy (table-driven tests)
- AI-assisted development (Claude CLI + Crush)
- Debugging techniques
- Performance optimization
- Code review process
- Troubleshooting
- Quick reference commands

### guides/ Directory
Step-by-step guides and learning resources:

**OPENCODE_SETUP.md** - AI tools setup:
- OpenCode AI configuration and usage
- Claude CLI integration
- Optional Crush AI feature
- AI tool comparison

**go-in-2025-guide.md** - Go ecosystem guide (16K+ words):
- Modern Go development patterns
- Common pitfalls to avoid
- Charm.sh TUI ecosystem (Bubble Tea, Lip Gloss, Bubbles)
- Web frameworks (Gin, Fiber, Echo, Chi)
- Database libraries (GORM, sqlc, Ent)
- Testing practices, build tools, observability
- Performance optimization and production patterns

**go-learning-plan.md** - Structured Go learning path

### meta/ Directory
Project metadata and documentation management:

**DOCUMENTATION_UPDATES.md** - Documentation changelog:
- Record of documentation updates
- Change tracking and version history
- Quality improvement tracking

---

## Quick Access by Task

| Task | Documentation |
|------|---------------|
| Get started | [../QUICKSTART.md](../QUICKSTART.md) |
| Write first function | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#file-organization) |
| Write tests | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#testing-strategy) |
| Use AI tools | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#ai-assisted-development) |
| Debug code | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#debugging-techniques) |
| Optimize performance | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#performance-optimization) |
| Understand architecture | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Learn Go patterns | [go-in-2025-guide.md](guides/go-in-2025-guide.md) |
| API reference | [API_REFERENCE.md](API_REFERENCE.md) |
| Contribute | [../CONTRIBUTING.md](../CONTRIBUTING.md) |

---

## Documentation Statistics

- **Total Documentation**: 11 files
- **Total Size**: ~45,000+ words
- **Code Examples**: 100+
- **External References**: 50+
- **Coverage**: Setup, Learning, Development, Architecture, Ecosystem

---

## Documentation Quality

All documentation follows these standards:

✅ Clear, concise language
✅ Practical code examples
✅ Cross-referenced sections
✅ Table of contents for navigation
✅ Consistent formatting
✅ Regular updates

---

## Getting Help

**Can't find what you need?**

1. Check [INDEX.md](INDEX.md) for complete navigation
2. Use AI tools:
   ```bash
   claude "How do I [task]?"
   crush  # Interactive help session
   ```
3. Review [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#troubleshooting)
4. Check [go-in-2025-guide.md](guides/go-in-2025-guide.md)

---

## Maintenance

When updating documentation:

- **Code changes** → Update [API_REFERENCE.md](API_REFERENCE.md)
- **Architecture changes** → Update [ARCHITECTURE.md](ARCHITECTURE.md)
- **Workflow changes** → Update [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)
- **New features** → Update [../README.md](../README.md)
- **New examples** → Update [../QUICKSTART.md](../QUICKSTART.md)

See [../CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines.

---

**Last Updated**: 2025-11-11
**Documentation Version**: 1.0
**Go Version**: 1.24.9
