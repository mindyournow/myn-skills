# Lists API

Grocery and shopping list management scoped to households.

## Base Path

`/api/v1/households/{householdId}/grocery-list`

## Prerequisites

All list endpoints require a `householdId`. Retrieve it from the current user profile:

```bash
# Get your household ID
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/customers/me"
# Response includes: households[0].id
```

## Endpoints

### Get Grocery List

```
GET /api/v1/households/{householdId}/grocery-list
```

Returns the full grocery list for the household.

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `householdId` | UUID | Household identifier |
| `items` | object[] | Array of list items |
| `items[].id` | UUID | Item identifier |
| `items[].name` | string | Item name |
| `items[].category` | string | Item category (nullable, e.g., `Produce`, `Dairy`) |
| `items[].quantity` | string | Quantity description (nullable, e.g., `2 lbs`, `1 dozen`) |
| `items[].notes` | string | Additional notes (nullable) |
| `items[].checked` | boolean | Whether the item has been picked up |
| `items[].addedAt` | datetime | When the item was added |
| `items[].addedBy` | string | Name of the user who added the item |
| `categories` | string[] | All distinct categories in the list |
| `lastModified` | datetime | Last modification timestamp |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/households/880e8400-e29b-41d4-a716-446655440003/grocery-list"
```

### Add Item

```
POST /api/v1/households/{householdId}/grocery-list/items
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | **Required.** Item name |
| `category` | string | Optional category (e.g., `Produce`, `Dairy`, `Frozen`) |
| `quantity` | string | Optional quantity (e.g., `2 lbs`, `1 gallon`) |
| `notes` | string | Optional notes |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `itemId` | UUID | New item identifier |
| `added` | boolean | Whether the item was successfully added |

```bash
curl -X POST "$MYN_API_URL/api/v1/households/880e8400-e29b-41d4-a716-446655440003/grocery-list/items" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Avocados",
    "category": "Produce",
    "quantity": "4",
    "notes": "Ripe ones for guacamole"
  }'
```

### Toggle Item Checked

```
PATCH /api/v1/households/{householdId}/grocery-list/items/{itemId}
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `checked` | boolean | Set checked state (toggles if omitted by some clients) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `itemId` | UUID | Item identifier |
| `checked` | boolean | New checked state |

```bash
# Mark an item as picked up
curl -X PATCH "$MYN_API_URL/api/v1/households/880e8400-e29b-41d4-a716-446655440003/grocery-list/items/990e8400-e29b-41d4-a716-446655440004" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"checked": true}'
```

### Bulk Add Items

```
POST /api/v1/households/{householdId}/grocery-list/items/bulk
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `items` | object[] | **Required.** Array of items to add |
| `items[].name` | string | **Required.** Item name |
| `items[].category` | string | Optional category |
| `items[].quantity` | string | Optional quantity |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `addedCount` | number | Number of items added |
| `itemIds` | UUID[] | IDs of the newly created items |

```bash
curl -X POST "$MYN_API_URL/api/v1/households/880e8400-e29b-41d4-a716-446655440003/grocery-list/items/bulk" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"name": "Milk", "category": "Dairy", "quantity": "1 gallon"},
      {"name": "Eggs", "category": "Dairy", "quantity": "1 dozen"},
      {"name": "Bread", "category": "Bakery"},
      {"name": "Chicken breast", "category": "Meat", "quantity": "2 lbs"}
    ]
  }'
```

### Convert to Tasks

```
POST /api/v1/households/{householdId}/grocery-list/convert-to-tasks
```

Converts grocery list items into MYN tasks (e.g., for a shopping trip).

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `uncheckedOnly` | boolean | Only convert unchecked items (default: true) |
| `priority` | string | Priority for created tasks (e.g., `OPPORTUNITY_NOW`) |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `convertedCount` | number | Number of items converted to tasks |
| `taskIds` | UUID[] | IDs of the created tasks |

```bash
# Convert unchecked items to Opportunity Now tasks
curl -X POST "$MYN_API_URL/api/v1/households/880e8400-e29b-41d4-a716-446655440003/grocery-list/convert-to-tasks" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "uncheckedOnly": true,
    "priority": "OPPORTUNITY_NOW"
  }'
```
