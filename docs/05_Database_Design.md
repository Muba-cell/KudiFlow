# KudiFlow Database Design

## 1. Database Overview

KudiFlow will use Cloud Firestore as its primary database.

Firestore is a NoSQL cloud database that stores information in collections and documents.

The database design will focus on:

- Scalability
- Security
- Fast data access
- Simple synchronization between devices

---

# 2. Database Collections

The KudiFlow database will contain the following main collections:

- Users
- Transactions
- Budgets
- Savings Goals
- Notifications

---

# 3. Users Collection

## Purpose

Stores information about registered KudiFlow users.

## Fields

| Field | Type | Description |
|---|---|---|
| userId | String | Unique user identifier |
| name | String | User's full name |
| email | String | User email address |
| currency | String | Preferred currency |
| createdAt | Timestamp | Account creation date |

---

# 4. Transactions Collection

## Purpose

Stores all user income and expense records.

## Fields

| Field | Type | Description |
|---|---|---|
| transactionId | String | Unique transaction identifier |
| userId | String | Owner of transaction |
| type | String | Income or Expense |
| amount | Number | Transaction amount |
| category | String | Transaction category |
| description | String | Transaction details |
| date | Timestamp | Transaction date |

---

# 5. Budgets Collection

## Purpose

Stores user-created spending limits.

## Fields

| Field | Type | Description |
|---|---|---|
| budgetId | String | Unique budget identifier |
| userId | String | Budget owner |
| category | String | Budget category |
| limitAmount | Number | Maximum spending amount |
| month | String | Budget month |

---

# 6. Savings Goals Collection

## Purpose

Stores user's financial goals.

## Fields

| Field | Type | Description |
|---|---|---|
| goalId | String | Unique goal identifier |
| userId | String | Goal owner |
| goalName | String | Name of goal |
| targetAmount | Number | Desired amount |
| currentAmount | Number | Amount saved |
| deadline | Timestamp | Target completion date |

---

# 7. Notifications Collection

## Purpose

Stores user reminders and alerts.

## Fields

| Field | Type | Description |
|---|---|---|
| notificationId | String | Unique notification identifier |
| userId | String | Notification owner |
| title | String | Notification title |
| message | String | Notification content |
| createdAt | Timestamp | Creation date |
| isRead | Boolean | Read status |

---

# 8. Database Relationship Model (ERD)

The following relationship model describes how KudiFlow entities are connected.

```
+----------------+
|     Users      |
+----------------+
| userId (PK)    |
| name           |
| email          |
| currency       |
| createdAt      |
+----------------+
        |
        |
        | 1-to-Many
        |
        |
+----------------+
| Transactions   |
+----------------+
| transactionId PK|
| userId (FK)    |
| type           |
| amount         |
| category       |
| description    |
| date           |
+----------------+


        |
        |
        | 1-to-Many
        |
        |

+----------------+
|    Budgets     |
+----------------+
| budgetId (PK)  |
| userId (FK)    |
| category       |
| limitAmount    |
| month          |
+----------------+


        |
        |
        | 1-to-Many
        |
        |

+----------------+
| Savings Goals  |
+----------------+
| goalId (PK)    |
| userId (FK)    |
| goalName       |
| targetAmount   |
| currentAmount  |
| deadline       |
+----------------+


        |
        |
        | 1-to-Many
        |
        |

+----------------+
| Notifications  |
+----------------+
| notificationId|
| userId (FK)   |
| title         |
| message       |
| createdAt     |
| isRead        |
+----------------+
```

---

## Explanation

The Users collection is the central entity in KudiFlow.

Each user owns their personal financial data. Transactions, budgets, savings goals, and notifications are connected to the user's unique identifier.

This structure ensures:

- User data remains separated and secure.
- Information can be retrieved efficiently.
- The database can scale as the number of users grows.

