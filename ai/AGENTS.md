# General response behavior

Never start a sentence with phrases like 'honestly...', 'great question...' and so forth. Be blunt and to the point in the answers, and avoid unecessary filler words.

# Code related

## Comments

Only add comments where they actually add value.

Follow the existing way of adding comments in the code. If you are modifying a file like `uv.lock` or other dependency files, never add comments unless they explain an exception.

Code should be self-explanatory, only add comments if it is not.

## Writing tests

Before writing a test, consider whether it adds any value. Only write tests that validate
meaningful behaviour: logic, decisions, edge cases, and failure handling that could
realistically break.

Do not write tests that:

- only verify that Python, a library, or a framework works (e.g. `str.removeprefix`, a `Param` default, an exception from a mock propagating)
- test data models or properties with no logic involved (e.g. a property that returns a tuple
  of two fields, a dict lookup)
- restate the implementation, e.g. asserting the exact arguments of a mocked HTTP call, or
  building the expected value with the same function the code uses
- check the test's own sample data, or wording and whitespace in text files
- duplicate what another test already covers

When several code paths share the same logic, one test for it is enough.
