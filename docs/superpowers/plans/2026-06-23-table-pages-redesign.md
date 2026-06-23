# Table Pages Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task.

**Goal:** Redesign 3 admin table JSPs with dark-tech aesthetic, FullView toggle, and detail modals.

**Architecture:** Each JSP is self-contained — CSS in `<style>`, HTML, JS inline. Sidebar/topbar shared via `sidebar.jsp` include. No backend changes needed.

**Tech Stack:** JSP 2.0, JSTL, Bootstrap 5.3, Bootstrap Icons, vanilla JS

## Global Constraints
- Keep existing sidebar/topbar CSS and HTML structure intact
- Preserve all JSP scriptlets, taglibs, EL expressions
- Keep existing Add/Edit User modals in authLog.jsp and systemLog.jsp
- Dark tech theme with neon color variables (`--neon-purple`, `--neon-pink`, etc.)
- Client-side pagination: 10 rows/page

---

### Task 1: Redesign manage-user.jsp

**Files:**
- Modify: `web/manage-user.jsp` (entire file — keep structure, replace body content + modals + JS)

**Changes:**
- `<title>` → "User Management — Network Manager"
- Add CSS before `</style>`: table-card, stats-bar, badges, icons, fullview, detail modal
- Replace `.page-body` content with: page header + stats bar + search + table card + pagination/fullview bar
- Replace modals section: add Detail modal, restyle Add/Edit modals
- Replace JS: pagination + fullview toggle + detail modal logic

### Task 2: Redesign authLog.jsp

**Files:**
- Modify: `web/authLog.jsp`

**Changes:**
- Same pattern as Task 1, but:
  - Columns: Log ID, Username, Status, IP Address, Login Time, User ID
  - No search bar
  - No Add/Edit modals (keep existing as-is)
  - Status badge: Success (green) / Failed (red)
  - Detail modal shows all auth log fields

### Task 3: Redesign systemLog.jsp

**Files:**
- Modify: `web/systemLog.jsp`

**Changes:**
- Same pattern as Task 1, but:
  - Columns: Log ID, Action, Details, Performed By, Created At
  - No search bar
  - No Add/Edit modals (keep existing as-is)
  - Action badge: colored by action type
  - Detail modal shows full details text + metadata
