# Contributing to Catholic Missal API

Thank you for your interest in contributing to the Catholic Missal API! This project aims to provide accurate and accessible Catholic liturgical data while respecting copyright laws and Church teachings.

## 🙏 Guiding Principles

When contributing to this project, please keep these principles in mind:

1. **Respect for Church Teaching**: All contributions should align with Catholic Church teachings and traditions
2. **Copyright Compliance**: Respect all copyright and licensing requirements
3. **Accuracy**: Liturgical information must be accurate and verified
4. **Attribution**: Provide proper attribution for all sources
5. **Reverence**: Maintain a reverent and respectful approach to sacred content

## 🚀 Getting Started

### Prerequisites

- Python 3.11 or higher
- Git
- Docker (recommended for development)

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/catholic-missal-api.git
   cd catholic-missal-api
   ```

3. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   pip install -r requirements-dev.txt  # If available
   ```

5. Copy environment file:
   ```bash
   cp .env.example .env
   ```

6. Run tests:
   ```bash
   pytest tests/
   ```

7. Start the development server:
   ```bash
   uvicorn app.main:app --reload
   ```

## 📋 Types of Contributions

We welcome several types of contributions:

### 🐛 Bug Reports

When reporting bugs, please include:
- Clear description of the issue
- Steps to reproduce
- Expected vs. actual behavior
- System information (OS, Python version, etc.)
- Any relevant liturgical context

### ✨ Feature Requests

For new features, please:
- Explain the liturgical or pastoral need
- Provide use cases
- Consider copyright and licensing implications
- Suggest implementation approach if possible

### 🔧 Code Contributions

#### Areas where we need help:
- **Data Source Integrations**: Adding new official Catholic data sources
- **Liturgical Calculations**: Improving calendar calculations for different rites
- **Internationalization**: Adding support for different languages and regions
- **Testing**: Expanding test coverage
- **Documentation**: Improving API documentation and guides
- **Performance**: Optimizing data fetching and caching

#### Before submitting code:
1. Ensure all tests pass
2. Add tests for new functionality
3. Update documentation
4. Verify copyright compliance
5. Test with multiple liturgical scenarios

### 📚 Documentation

Help improve:
- API documentation
- Setup guides
- Usage examples
- Copyright and licensing information
- Liturgical explanations

## 🎯 Pull Request Process

1. **Create a branch**: Use descriptive names like `feature/add-byzantine-calendar` or `fix/easter-calculation`

2. **Make your changes**:
   - Follow the existing code style
   - Add appropriate tests
   - Update documentation
   - Ensure copyright compliance

3. **Test thoroughly**:
   ```bash
   pytest tests/
   # Test with different dates and liturgical scenarios
   ```

4. **Commit with clear messages**:
   ```bash
   git commit -m "Add Byzantine liturgical calendar support"
   ```

5. **Push and create PR**:
   - Provide clear description
   - Reference any related issues
   - Explain liturgical context if relevant

## 📖 Code Style Guidelines

### Python Code Style
- Follow PEP 8
- Use type hints
- Write descriptive docstrings
- Use meaningful variable names
- Keep functions focused and small

### API Design
- Follow RESTful principles
- Use consistent response formats
- Provide clear error messages
- Include proper HTTP status codes
- Document all endpoints

### Liturgical Data
- Verify accuracy with official sources
- Include source attribution
- Respect liturgical precedence rules
- Consider regional variations
- Test with edge cases (leap years, date boundaries)

## ⚖️ Copyright and Licensing Guidelines

### When adding liturgical content:

1. **Verify Source**: Ensure content comes from legitimate sources
2. **Check Copyright**: Verify licensing requirements
3. **Provide Attribution**: Always include proper source attribution
4. **Respect Policies**: Follow USCCB, Vatican, and other source policies
5. **Document Usage**: Clearly document how content is used

### Acceptable Sources:
- ✅ Public domain prayers and texts
- ✅ Official Church documents with proper attribution
- ✅ USCCB content under fair use (educational/religious)
- ✅ Vatican documents with attribution
- ✅ Your own liturgical calculations and algorithms

### Unacceptable:
- ❌ Copyrighted material without permission
- ❌ Commercial liturgical texts without licensing
- ❌ Content that contradicts Church teaching
- ❌ Inaccurate or unverified liturgical information

## 🧪 Testing Guidelines

### Test Categories:
1. **Unit Tests**: Test individual functions and classes
2. **Integration Tests**: Test API endpoints and data flow
3. **Liturgical Tests**: Verify liturgical calculations and rules
4. **Data Source Tests**: Test external data fetching (with mocks)

### Writing Tests:
```python
def test_easter_calculation_2024():
    """Test Easter calculation for 2024."""
    calendar = LiturgicalCalendar(2024)
    easter = calendar.easter_date
    assert easter == date(2024, 3, 31)  # Verify with official sources
```

### Test Data:
- Use real liturgical dates for verification
- Test edge cases (leap years, date boundaries)
- Include both common and rare liturgical scenarios
- Verify against multiple official sources

## 🌍 Internationalization

When adding support for different regions or rites:

1. **Research thoroughly**: Understand local liturgical practices
2. **Consult experts**: Work with liturgical scholars when possible
3. **Verify accuracy**: Cross-reference with local bishops' conferences
4. **Document differences**: Clearly explain regional variations
5. **Maintain flexibility**: Design for configurability

## 📞 Getting Help

If you need help with contributions:

1. **Check existing issues**: See if your question has been addressed
2. **Open a discussion**: Use GitHub Discussions for questions
3. **Join the community**: Connect with other contributors
4. **Consult documentation**: Review API docs and code comments

## 🎖️ Recognition

Contributors will be recognized in:
- README.md acknowledgments
- Release notes for significant contributions
- Special recognition for liturgical expertise

## 📜 Code of Conduct

This project follows Catholic principles of charity, respect, and truth:

- **Be charitable**: Approach discussions with kindness and understanding
- **Be respectful**: Honor different perspectives while maintaining accuracy
- **Be truthful**: Ensure all contributions are accurate and well-sourced
- **Be patient**: Remember that liturgical topics can be complex
- **Be collaborative**: Work together for the good of the Church

## 🙏 Final Notes

Remember that this project serves the Catholic community and supports the Church's mission of evangelization and education. All contributions should be made with this sacred purpose in mind.

*Ad Majorem Dei Gloriam* - For the Greater Glory of God

Thank you for your contributions to this project!