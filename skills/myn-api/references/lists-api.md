# Lists API

Grocery and shopping list management scoped to households.

## Base Path

`/api/v1/households/{householdId}/grocery-list`

## Actions

The `myn_lists` tool supports these actions: `get`, `add`, `update`, `toggle`, `delete`, `delete_checked`, `bulk_add`, `convert_to_tasks`.

## Prerequisites

All list endpoints require a `householdId`. The plugin auto-resolves it via:

```
GET /api/v1/households/current
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
| `success` | boolean | Operation success |
| `items` | object[] | Array of list items |
| `items[].id` | UUID | Item identifier |
| `items[].name` | string | Item name |
| `items[].category` | string | Item category (nullable, e.g., `Produce`, `Dairy`) |
| `items[].quantity` | string | Quantity description (nullable, e.g., `2 lbs`, `1 dozen`) |
| `items[].notes` | string | Additional notes (nullable) |
| `items[].checked` | boolean | Whether the item has been picked up |
| `items[].addedAt` | datetime | When the item was added |
| `items[].addedBy` | number | User ID who added the item |
| `items[].addedByName` | string | Name of the user who added the item (nullable) |
| `items[].position` | number | Sort position |
| `items[].householdId` | UUID | Household ID |
| `items[].createdAt` | datetime | Creation timestamp |
| `items[].updatedAt` | datetime | Last update timestamp |

```bash
curl -H "X-API-KEY: $MYN_API_KEY" \
  "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list"
```

### Add Item

```
POST /api/v1/households/{householdId}/grocery-list
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | **Required.** Item name |
| `category` | string | Optional category (e.g., `Produce`, `Dairy`, `Frozen`) |
| `quantity` | string | Optional quantity (e.g., `2 lbs`, `1 gallon`) |
| `notes` | string | Optional notes |

**Response:** `{ success, item: { id, name, category?, quantity?, notes?, checked, addedAt, addedByName? } }`

```bash
curl -X POST "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Avocados",
    "category": "Produce",
    "quantity": "4",
    "notes": "Ripe ones for guacamole"
  }'
```

### Update Item

```
PATCH /api/v1/households/{householdId}/grocery-list/{itemId}
```

Updates an existing grocery list item. At least one field is required.

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | New item name |
| `category` | string | New category |
| `quantity` | string | New quantity |
| `notes` | string | New notes |

**Response:** `{ success, item: { id, name, category?, quantity?, notes?, checked } }`

```bash
curl -X PATCH "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list/ITEM_ID" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"quantity": "6", "notes": "Updated quantity"}'
```

### Toggle Item Checked

```
PATCH /api/v1/households/{householdId}/grocery-list/{itemId}/toggle
```

Toggles the checked state of a grocery list item.

**Response:** `{ success, item: { id, name, checked }, checked }`

```bash
curl -X PATCH "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list/ITEM_ID/toggle" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Delete Item

```
DELETE /api/v1/households/{householdId}/grocery-list/{itemId}
```

Deletes a single grocery list item.

**Response:** `{ success, deleted }`

```bash
curl -X DELETE "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list/ITEM_ID" \
  -H "X-API-KEY: $MYN_API_KEY"
```

### Delete Checked Items

```
DELETE /api/v1/households/{householdId}/grocery-list/checked
```

Deletes all checked (completed) items from the grocery list.

**Response:** `{ success, deletedCount, undoAvailable }`

```bash
curl -X DELETE "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list/checked" \
  -H "X-API-KEY: $MYN_API_KEY"
```

### Bulk Add Items

```
POST /api/v1/households/{householdId}/grocery-list/bulk
```

**Body Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| `items` | object[] | **Required.** Array of items to add |
| `items[].name` | string | **Required.** Item name |
| `items[].category` | string | Optional category |
| `items[].quantity` | string | Optional quantity |

**Response:** `{ success, items: [{ id, name, category?, quantity?, checked }], count }`

```bash
curl -X POST "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list/bulk" \
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

**Response:** `{ success, tasks: [{ id, title }], count }`

```bash
curl -X POST "$MYN_API_URL/api/v1/households/HOUSEHOLD_ID/grocery-list/convert-to-tasks" \
  -H "X-API-KEY: $MYN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "uncheckedOnly": true,
    "priority": "OPPORTUNITY_NOW"
  }'
```
