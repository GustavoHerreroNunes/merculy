## App Screens Overview

### 1️. Onboarding Finished Screen
- Purpose: Final message marking the last step of onboarding.
- Button: `"Finalizar"` — navigates to **My Newsletters** screen.

---

### 2️. My Newsletters Screen
- Displays: All newsletters the user has.
- Each newsletter is shown as a **card component** containing:
  - Title
  - Description
  - Icon
  - Optional 🔴 red notification circle (top-right corner for new data)
- Cards: Dynamically generated from a **local list of newsletters**
- Navigation:
  - On newsletter tap → navigates to **Newsletter** screen
- Footer:
  - Bottom navigation bar (must be its own reusable component)

---

### 3️. Newsletter Screen
- Displays: All details of a selected newsletter.
- Structure:
  #### Heading
  - Title
  - Icon
  - Date
  - Custom background
  - Implemented using **Custom Painter**
    - Parameters: all data listed above + color palette for background

  #### Sections
  **3.1 Main News**
  - Shows 3 news items with high level of detail:
    - Cover image
    - Summary
    - Main topics
    - Title and “Details” button: both clickable (for future page links)

  **3.2 Other News**
  - Shows 4 news items in a simpler layout

  **3.3 Share Button**

  **3.4 Footer**

---

## Tech Implementation Notes

### Data Models
- **News Headline Model**
  - Used for both Main News and Other News
  - Fields:
    - Some items will have **all fields filled**
    - Others only include **required (NOT NULL)** data
    - Add a boolean `"is_main_news"`
        - If True: `"sources"` is list of multiple articles
        - If False: `"sources"` is list of a single article

- **Source Model**
    - Used for headline model
    - Fields:
        - Website root (i.e. "g1.com.br")
        - Fantasy name (i.e. "G1")
        - Article link (i.e. "https://...")


- **Newsletter Model**
  - Used to generate cards in **My Newsletters** screen

### Component Generation
- All visual elements should be dynamically created from local data lists:
  - News → from the **news headline model**
  - Newsletters → from the **newsletter model**
