# Accessibility checklist

Status values: pending, pass, fail, blocked.

| Check | Status | Evidence |
|---|---|---|
| One skip link reaches the primary manuscript | Pass | Root layout uses one visible-on-focus link to each route's main-content target |
| Logical H1-H4 hierarchy | Pending | Schema/content tests pass; rendered outline still requires browser inspection |
| Navigation landmarks have distinct labels | Pass | Book contents, On this page, breadcrumbs and reader tools have distinct labels |
| Desktop rail controls expose expanded state | Pass | Both toolbar triggers publish aria-controls and live aria-expanded |
| Mobile drawers trap focus only while open | Blocked | Focus trap is implemented at 980/1180 px breakpoints; real-browser keyboard proof unavailable |
| Escape closes drawers and returns focus | Blocked | Escape and focus return are implemented; real-browser keyboard proof unavailable |
| All controls have visible focus | Pending | Global two-tone focus rule is present; rendered coverage unavailable |
| Touch targets are at least 44 by 44 CSS px where practical | Pending | Controls use 40-44 px minimums; mobile rendered measurement unavailable |
| Theme and preference feedback is announced | Pass | Reader preference changes update a polite live region |
| Quiz feedback uses a live region and is not colour-only | Pass | Storage incident feedback uses text plus aria-live=polite |
| Answer content is hidden before intentional reveal | Pass | Answered assessments use native details; reader isolation tests pass |
| Tables expose headers, captions where available and local overflow | Pass | Structured tables use scoped headers and a labelled, focusable local overflow region |
| Code controls are keyboard accessible and labelled | Pass | Native buttons provide copy/wrap state; code keeps independent overflow |
| Contrast meets WCAG AA in paper, night and sepia | Pass | Primary/secondary/accent pairs calculate from 5.03:1 to 14.56:1 |
| 200 percent zoom produces no page-level horizontal overflow | Blocked | Requires real-browser review |
| Reduced motion disables nonessential transitions | Pass | prefers-reduced-motion removes smooth scroll and collapses transition duration |
| Print hides navigation/tools and preserves content | Pending | Print contract is implemented; print-preview proof unavailable |
| Notes warn against secrets and production data | Pass | Context rail explicitly rejects secrets, credentials, employer data and production evidence |

Automated checks are necessary but not sufficient. Keyboard, screen-reader semantics, zoom and visual focus require a rendered browser.
