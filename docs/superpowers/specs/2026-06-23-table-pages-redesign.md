# Table Pages Redesign — manage-user, authLog, systemLog

## Goal
Redesign 3 admin table pages (`manage-user.jsp`, `authLog.jsp`, `systemLog.jsp`) with a modern dark-tech aesthetic matching the existing Neon theme, adding a **FullView toggle** mode.

## Design

### Color Palette (existing)
- `--neon-purple: #8b5cf6`, `--neon-pink: #d946ef`, `--neon-blue: #60a5fa`, `--neon-cyan: #22d3ee`
- Surface: `#10172a`, Border: `#2a3555`, Text: `#f2f5ff`, Muted: `#9aa6c7`

### Layout (per page)
- Page header: gradient icon + title "User Management / Administration" + action buttons row
- Stats bar: colored chips (Total, Active, Inactive, role breakdown — or log-specific stats)
- Search bar (manage-user only) 
- Table card: glassmorphic (`backdrop-filter: blur(12px)`), rounded corners, border glow
- Pagination or FullView info bar
- Table with sticky header, monospace ID badges, colored role/status badges, icon action buttons
- Empty state with icon + message

### FullView Toggle
- **Paginated mode** (default): 10 rows/page, prev/next pagination controls
- **FullView mode**: all rows visible in scrollable container (`max-height: 420px; overflow-y: auto`), sticky table header
- Toggle button in card header: "📋 FullView" (paginated) / "← Back" (fullview)
- Toggle does NOT navigate away from the page; it's a JS in-page switch

### Action Buttons
- manage-user: 👁 view (opens detail modal), ✏ edit (opens edit modal), 🗑 delete (confirms, submits form)
- authLog, systemLog: only 👁 view (detail modal)
- Detail modal: dark glass overlay, centered panel, labeled sections for all fields

### Page-Specific Details

#### manage-user.jsp
- Columns: #ID | Username | Full Name | Email | Role | Status | Actions
- Roles: Admin (red badge), Tech (purple), Viewer (blue)
- Status: Active (green with glow dot), Inactive (red)
- Modals: Add User (form), Edit User (pre-populated form), Detail View (read-only)
- Search: GET form to UserController

#### authLog.jsp
- Columns: #Log ID | Username | Status | IP Address | Login Time | User ID
- Status: Success (green badge) / Failed (red badge)
- Detail modal: all fields + formattes timestamps
- Existing Add/Edit User modals kept as-is (user request)

#### systemLog.jsp
- Columns: #Log ID | Action | Details | Performed By | Created At
- Action badges: colored by action type (blue/info, yellow/warn, red/critical)
- Detail modal: full details text (long content wrapped), all metadata
- Existing Add/Edit User modals kept as-is (user request)

## Implementation

### Files to Modify
1. `web/manage-user.jsp` — replace `<title>`, add CSS, replace `.page-body`, update modals, replace JS
2. `web/authLog.jsp` — same pattern
3. `web/systemLog.jsp` — same pattern

### What Stays
- JSP directives, taglib imports, scriptlets
- Sidebar CSS, topbar CSS, page-body wrapper
- `sidebarActive` set, `sidebar.jsp` include
- Existing Add/Edit modal HTML (log pages keep them)
- Page title labels JS object, `showPage()` function
- Bootstrap CDN links

### What Changes
- `<title>` text (per page)
- New CSS classes added before `</style>` 
- `.page-body` content entirely replaced with new header + card + table design
- Modals section: new fullview detail modal; existing modals restyled
- JavaScript: pagination rewritten to support `isFullView` toggle; detail modal logic added

### Key CSS Classes
- `.page-manage-header`, `.stats-bar`, `.stat-chip`
- `.table-card`, `.table-wrap` (scrollable), `.id-badge`, `.role-badge-*`, `.status-badge-*`
- `.btn-icon-view/edit/delete`, `.btn-fullview`
- `.fullview-overlay`, `.fullview-panel` (detail modal)

### Key JavaScript
- `toggleFullView()` — switches between paginated and fullview modes
- `openDetail(rowData)` / `closeDetail()` — opens/closes detail modal
- Preserved: `initPagination()`, `showPageForTable()`, `prevPage()`, `nextPage()`

## Verification
- Open each page in browser, verify table renders with test data
- Test pagination (prev/next, page labels)
- Toggle FullView, verify all rows visible, scrollable, header sticky
- Toggle Back, verify pagination resets
- Click 👁 on a row, verify detail modal opens with correct data
- Click ✏ (manage-user), verify edit modal pre-populated
- Click 🗑 (manage-user), verify confirm dialog and form submission
