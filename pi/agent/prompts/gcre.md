---
description: "Guidelines for writing commit messages in Regask Projects"
---

Commit message for Regask Projects:

```
[type]: [REG-<ticket_number>] - [short_description]

[long_description]
````

Where
- `[type]` is the type of change being made (e.g., feat, fix, docs, style, refactor, test, chore).
- `[REG-<ticket_number>]` is the reference to the Regask ticket number associated if having no ticket, then it will be REG-XXXX
- `[short_description]` is a brief summary of the change being made.
- `[long_description]` is a more detailed explanation of the change, including any relevant context, motivation, and potential impact on the project. This section dont have to be too details but it need to be provided just enough and clear to understand the change being made.

Example:

```
feat: [REG-1234] - Add user authentication feature

This commit introduces a new user authentication feature to the application.

## Context:
User authentication is a critical aspect of any application that handles user data. It ensures that only authorized

## Motivation:
The application currently lacks a secure way for users to authenticate themselves, which is essential for protecting user data and ensuring that only authorized users can access certain features. By implementing this feature, we aim to enhance the security of the application and provide a better user experience.

The implementation includes:
- A new login page where users can enter their credentials.
- Backend logic to handle authentication requests and validate user credentials.
- Integration with the existing user management system to ensure seamless user experience.
- Unit tests to verify the functionality of the authentication feature.

## Impact:
This change will improve the security of the application and allow users to securely access their accounts. It may require users to update their credentials if they have not done so recently, and it will also require
```

